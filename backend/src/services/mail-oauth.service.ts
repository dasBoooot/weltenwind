import nodemailer from 'nodemailer';
import { loggers } from '../config/logger.config';

export interface OAuth2MailConfig {
  service: 'outlook' | 'gmail';
  user: string;
  clientId: string;
  clientSecret: string;
  refreshToken: string;
  accessToken?: string;
}

class OAuth2MailService {
  private transporter: nodemailer.Transporter | null = null;
  private isConfigured = false;

  constructor() {
    this.initializeOAuth2Transporter();
  }

  private async initializeOAuth2Transporter() {
    const {
      MAIL_OAUTH_SERVICE,
      MAIL_USER,
      MAIL_CLIENT_ID,
      MAIL_CLIENT_SECRET,
      MAIL_REFRESH_TOKEN,
      MAIL_ACCESS_TOKEN
    } = process.env;

    // Fallback zu Standard-SMTP wenn OAuth2 nicht konfiguriert
    if (!MAIL_CLIENT_ID || !MAIL_CLIENT_SECRET || !MAIL_REFRESH_TOKEN) {
      loggers.system.info('📧 OAuth2 nicht konfiguriert - verwende Standard-SMTP');
      return;
    }

    try {
      const serviceConfig = MAIL_OAUTH_SERVICE === 'gmail' 
        ? { service: 'gmail' }
        : { 
            host: 'smtp-mail.outlook.com',
            port: 587,
            secure: false 
          };

      this.transporter = nodemailer.createTransport({
        ...serviceConfig,
        auth: {
          type: 'OAuth2',
          user: MAIL_USER,
          clientId: MAIL_CLIENT_ID,
          clientSecret: MAIL_CLIENT_SECRET,
          refreshToken: MAIL_REFRESH_TOKEN,
          accessToken: MAIL_ACCESS_TOKEN
        }
      });

      // Teste die Verbindung
      await this.transporter.verify();
      this.isConfigured = true;
      
      loggers.system.info('📧 OAuth2 Mail-Service erfolgreich konfiguriert', {
        service: MAIL_OAUTH_SERVICE,
        user: MAIL_USER
      });

    } catch (error) {
      loggers.system.error('❌ OAuth2 Mail-Service Konfigurationsfehler', { error });
      this.transporter = null;
      this.isConfigured = false;
    }
  }

  async sendMail(to: string, subject: string, html: string): Promise<boolean> {
    if (!this.isConfigured || !this.transporter) {
      loggers.system.warn('📧 OAuth2 Mail-Versand übersprungen - Service nicht konfiguriert');
      return false;
    }

    const { MAIL_USER, MAIL_FROM_NAME = 'Weltenwind' } = process.env;

    try {
      const result = await this.transporter.sendMail({
        from: `${MAIL_FROM_NAME} <${MAIL_USER}>`,
        to,
        subject,
        html
      });

      loggers.system.info('📧 OAuth2 E-Mail erfolgreich versendet', {
        to,
        subject,
        messageId: result.messageId
      });

      return true;
    } catch (error) {
      loggers.system.error('❌ OAuth2 E-Mail Versand fehlgeschlagen', {
        to,
        subject,
        error
      });
      return false;
    }
  }

  isEnabled(): boolean {
    return this.isConfigured;
  }
}

export const oauth2MailService = new OAuth2MailService();