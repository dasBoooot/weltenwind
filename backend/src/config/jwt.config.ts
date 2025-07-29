import crypto from 'crypto';

// JWT Secret Validation und Konfiguration
class JWTConfig {
  private static instance: JWTConfig;
  private secret: string;
  private readonly MIN_SECRET_LENGTH = 32; // Mindestens 256-bit

  private constructor() {
    this.secret = this.validateAndGetSecret();
  }

  public static getInstance(): JWTConfig {
    if (!JWTConfig.instance) {
      JWTConfig.instance = new JWTConfig();
    }
    return JWTConfig.instance;
  }

  private validateAndGetSecret(): string {
    const secret = process.env.JWT_SECRET;

    // Development-Modus: Warne nur, crashe nicht
    if (process.env.NODE_ENV === 'development') {
      if (!secret) {
        console.warn('⚠️  WARNUNG: JWT_SECRET ist nicht definiert!');
        console.warn('   Verwende temporäres Development-Secret.');
        console.warn('   DIES IST NUR FÜR ENTWICKLUNG AKZEPTABEL!');
        // Generiere ein temporäres Secret für Development
        return 'TEMPORARY-DEV-SECRET-' + crypto.randomBytes(32).toString('hex');
      }
      
      if (secret.length < this.MIN_SECRET_LENGTH) {
        console.warn(`⚠️  WARNUNG: JWT_SECRET ist zu kurz (${secret.length} Zeichen)`);
        console.warn(`   Empfohlen: Mindestens ${this.MIN_SECRET_LENGTH} Zeichen`);
      }
      
      return secret;
    }

    // Production-Modus: Strenge Validierung
    // Kein Secret definiert
    if (!secret) {
      console.error('❌ KRITISCHER FEHLER: JWT_SECRET ist nicht definiert!');
      console.error('   Bitte setze JWT_SECRET in der .env Datei.');
      console.error('   Generiere ein sicheres Secret mit: npm run generate-jwt-secret');
      process.exit(1);
    }

    // Secret zu kurz
    if (secret.length < this.MIN_SECRET_LENGTH) {
      console.error(`❌ KRITISCHER FEHLER: JWT_SECRET ist zu kurz (${secret.length} Zeichen)`);
      console.error(`   Mindestlänge: ${this.MIN_SECRET_LENGTH} Zeichen`);
      console.error('   Generiere ein sicheres Secret mit: npm run generate-jwt-secret');
      process.exit(1);
    }

    // Unsichere Secrets erkennen
    const unsecureSecrets = [
      'dev-secret',
      'secret',
      'password',
      'changeme',
      'your-secret-key-here',
      'test',
      'development',
      '12345',
      'admin'
    ];

    if (unsecureSecrets.some(unsecure => secret.toLowerCase().includes(unsecure))) {
      console.error('❌ KRITISCHER FEHLER: JWT_SECRET ist unsicher!');
      console.error('   Verwende niemals Standard- oder Test-Secrets in Produktion.');
      console.error('   Generiere ein sicheres Secret mit: npm run generate-jwt-secret');
      process.exit(1);
    }

    // Warnung für Entwicklungsumgebung
    if (process.env.NODE_ENV === 'development') {
      console.warn('⚠️  WARNUNG: Entwicklungsmodus aktiv. Stelle sicher, dass du in Produktion ein anderes JWT_SECRET verwendest!');
    }

    return secret;
  }

  public getSecret(): string {
    return this.secret;
  }

  // Generiere ein sicheres JWT Secret
  public static generateSecureSecret(): string {
    // 64 Bytes = 512 Bit Entropie
    return crypto.randomBytes(64).toString('base64');
  }

  // Token-Konfiguration
  public getTokenConfig() {
    return {
      secret: this.secret,
      accessTokenExpiry: '15m',
      refreshTokenExpiry: '7d',
      issuer: 'weltenwind-api',
      audience: 'weltenwind-client'
    };
  }
}

// Exportiere Singleton-Instanz
export const jwtConfig = JWTConfig.getInstance();

// Helper für direkten Secret-Zugriff
export function getJWTSecret(): string {
  return jwtConfig.getSecret();
}

// Export für Secret-Generation
export const generateSecureJWTSecret = JWTConfig.generateSecureSecret;