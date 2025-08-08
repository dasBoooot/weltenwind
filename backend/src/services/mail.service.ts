import nodemailer from 'nodemailer';
import { loggers } from '../config/logger.config';

export interface MailOptions {
  to: string;
  subject: string;
  html?: string;
  text?: string;
}

export interface InviteMailData {
  email: string;
  worldName: string;
  inviteToken: string;
  inviterName?: string;
}

export interface PasswordResetMailData {
  email: string;
  username: string;
  resetToken: string;
}

class MailService {
  private transporter: nodemailer.Transporter | null = null;
  private isConfigured = false;

  constructor() {
    this.initializeTransporter();
  }

  private async initializeTransporter() {
    const {
      MAIL_HOST,
      MAIL_PORT,
      MAIL_SECURE,
      MAIL_USER,
      MAIL_PASS,
      MAIL_FROM,
      MAIL_FROM_NAME
    } = process.env;

    // Prüfe ob Mail-Konfiguration vorhanden ist
    if (!MAIL_HOST || !MAIL_USER || !MAIL_PASS) {
      loggers.system.warn('📧 Mail-Service: Konfiguration unvollständig - Mail-Versand deaktiviert', {
        hasHost: !!MAIL_HOST,
        hasUser: !!MAIL_USER,
        hasPass: !!MAIL_PASS
      });
      return;
    }

    try {
      this.transporter = nodemailer.createTransport({
        host: MAIL_HOST,
        port: parseInt(MAIL_PORT || '587'),
        secure: MAIL_SECURE === 'true', // true für Port 465, false für andere Ports
        auth: {
          user: MAIL_USER,
          pass: MAIL_PASS,
        },
        // Microsoft/Outlook spezifische Konfiguration
        ...(MAIL_HOST.includes('outlook') && {
          service: 'Outlook365',
          tls: {
            ciphers: 'SSLv3',
            rejectUnauthorized: false
          }
        })
      });

      // Teste die Verbindung
      await this.transporter.verify();
      this.isConfigured = true;
      
      loggers.system.info('📧 Mail-Service erfolgreich konfiguriert', {
        host: MAIL_HOST,
        port: MAIL_PORT,
        secure: MAIL_SECURE === 'true',
        from: `${MAIL_FROM_NAME || 'Weltenwind'} <${MAIL_FROM || MAIL_USER}>`
      });

    } catch (error) {
      loggers.system.error('❌ Mail-Service Konfigurationsfehler', error as any);
      this.transporter = null;
      this.isConfigured = false;
    }
  }

  async sendMail(options: MailOptions): Promise<boolean> {
    if (!this.isConfigured || !this.transporter) {
      loggers.system.warn('📧 Mail-Versand übersprungen - Service nicht konfiguriert', {
        to: options.to,
        subject: options.subject
      });
      return false;
    }

    const {
      MAIL_FROM = process.env.MAIL_USER,
      MAIL_FROM_NAME = 'Weltenwind'
    } = process.env;

    try {
      const mailOptions = {
        from: `${MAIL_FROM_NAME} <${MAIL_FROM}>`,
        to: options.to,
        subject: options.subject,
        html: options.html,
        text: options.text || options.html?.replace(/<[^>]*>/g, '') // HTML zu Text fallback
      };

      const result = await this.transporter.sendMail(mailOptions);
      
      loggers.system.info('📧 E-Mail erfolgreich versendet', {
        to: options.to,
        subject: options.subject,
        messageId: result.messageId
      });

      return true;
    } catch (error) {
      loggers.system.error('❌ E-Mail Versand fehlgeschlagen', error as any, {
        to: options.to,
        subject: options.subject
      });
      return false;
    }
  }

  async sendInviteMail(data: InviteMailData, baseUrl: string): Promise<boolean> {
    const inviteUrl = `${baseUrl}/game/#/go/world-join/${data.inviteToken}`;
    
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .invite-button { display: inline-block; background: #4CAF50; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; font-weight: bold; }
          .footer { text-align: center; color: #666; font-size: 12px; margin-top: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🌍 Weltenwind Einladung</h1>
            <p>Du wurdest zu einer Welt eingeladen!</p>
          </div>
          <div class="content">
            <h2>Willkommen bei ${data.worldName}!</h2>
            <p>Du hast eine Einladung zur Welt <strong>${data.worldName}</strong> erhalten${data.inviterName ? ` von <strong>${data.inviterName}</strong>` : ''}.</p>
            
            <p>Klicke auf den Button unten, um der Welt beizutreten:</p>
            
            <a href="${inviteUrl}" class="invite-button">🚀 Welt beitreten</a>
            
            <p><small>Oder kopiere diesen Link in deinen Browser:<br>
            <a href="${inviteUrl}">${inviteUrl}</a></small></p>
            
            <hr>
            
            <p><strong>Was ist Weltenwind?</strong><br>
            Weltenwind ist eine Plattform für interaktive Online-Welten und Rollenspiele. 
            Erstelle deinen Charakter, erkunde neue Welten und erlebe spannende Abenteuer!</p>
          </div>
          <div class="footer">
            <p>Diese Einladung wurde automatisch generiert.<br>
            Falls du diese E-Mail irrtümlich erhalten hast, kannst du sie einfach ignorieren.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    return await this.sendMail({
      to: data.email,
      subject: `🌍 Einladung zur Welt "${data.worldName}" | Weltenwind`,
      html
    });
  }

  async sendPasswordResetMail(data: PasswordResetMailData, baseUrl: string): Promise<boolean> {
    const resetUrl = `${baseUrl}/game/#/go/auth/reset-password?token=${data.resetToken}`;
    
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #ff7e5f 0%, #feb47b 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .reset-button { display: inline-block; background: #ff6b6b; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; font-weight: bold; }
          .warning { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; color: #856404; }
          .footer { text-align: center; color: #666; font-size: 12px; margin-top: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🔒 Passwort zurücksetzen</h1>
            <p>Weltenwind Account</p>
          </div>
          <div class="content">
            <h2>Hallo ${data.username}!</h2>
            <p>Du hast eine Passwort-Zurücksetzung für dein Weltenwind-Konto angefordert.</p>
            
            <div class="warning">
              ⚠️ <strong>Wichtiger Sicherheitshinweis:</strong><br>
              Falls du diese Anfrage nicht gestellt hast, ignoriere diese E-Mail einfach. 
              Dein Passwort bleibt dann unverändert.
            </div>
            
            <p>Um ein neues Passwort zu setzen, klicke auf den folgenden Button:</p>
            
            <a href="${resetUrl}" class="reset-button">🔑 Neues Passwort setzen</a>
            
            <p><small>Oder kopiere diesen Link in deinen Browser:<br>
            <a href="${resetUrl}">${resetUrl}</a></small></p>
            
            <p><strong>Hinweise:</strong></p>
            <ul>
              <li>Dieser Link ist nur 24 Stunden gültig</li>
              <li>Er kann nur einmal verwendet werden</li>
              <li>Nach der Nutzung werden alle aktiven Sessions beendet</li>
            </ul>
          </div>
          <div class="footer">
            <p>Diese E-Mail wurde automatisch generiert.<br>
            Bei Fragen wende dich an den Administrator.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    return await this.sendMail({
      to: data.email,
      subject: `🔒 Passwort zurücksetzen | Weltenwind`,
      html
    });
  }

  isEnabled(): boolean {
    return this.isConfigured;
  }
}

export const mailService = new MailService();