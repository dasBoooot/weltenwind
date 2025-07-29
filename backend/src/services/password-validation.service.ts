import zxcvbn from 'zxcvbn';

export interface PasswordValidationResult {
  valid: boolean;
  score: number; // 0-4 (0 = sehr schwach, 4 = sehr stark)
  feedback: string[];
  suggestions: string[];
  estimatedCrackTime: string;
  warning?: string;
}

// Konfiguration
const MIN_LENGTH = 8;
const MIN_SCORE = 2; // Mindestens "Fair" (0=sehr schwach, 1=schwach, 2=fair, 3=gut, 4=stark)
const MAX_COMMON_SUBSTRING_LENGTH = 4; // Max erlaubte Länge von Teilen des Usernamens im Passwort

// Zusätzliche häufige Passwörter (ergänzt zxcvbn's eingebaute Liste)
const ADDITIONAL_COMMON_PASSWORDS = [
  'weltenwind',
  'admin123',
  'user123',
  'test123',
  'demo123',
  'password123',
  'welcome123',
  'changeme',
  'letmein',
  'qwertz123',
  'qwerty123',
  '12345678',
  '123456789',
  'deutschland',
  'passwort',
  'hallo123'
];

// Validiert ein Passwort mit umfassenden Checks
export function validatePassword(
  password: string,
  userInputs?: string[] // Username, Email, etc. die nicht im Passwort sein sollten
): PasswordValidationResult {
  const feedback: string[] = [];
  const suggestions: string[] = [];
  
  // Basis-Checks
  if (!password) {
    return {
      valid: false,
      score: 0,
      feedback: ['Passwort ist erforderlich'],
      suggestions: [],
      estimatedCrackTime: 'sofort'
    };
  }

  // Längen-Check
  if (password.length < MIN_LENGTH) {
    feedback.push(`Passwort muss mindestens ${MIN_LENGTH} Zeichen lang sein`);
    suggestions.push('Verwende ein längeres Passwort');
  }

  // Whitespace-Check
  if (password !== password.trim()) {
    feedback.push('Passwort darf keine Leerzeichen am Anfang oder Ende haben');
  }

  // Nur Zahlen Check
  if (/^\d+$/.test(password)) {
    feedback.push('Passwort darf nicht nur aus Zahlen bestehen');
    suggestions.push('Füge Buchstaben und Sonderzeichen hinzu');
  }

  // Wiederholende Zeichen Check
  if (/(.)\1{2,}/.test(password)) {
    feedback.push('Passwort enthält zu viele wiederholende Zeichen');
    suggestions.push('Vermeide Zeichen-Wiederholungen wie "aaa" oder "111"');
  }

  // Keyboard-Pattern Check
  const keyboardPatterns = [
    'qwertz', 'qwerty', 'asdfgh', 'zxcvbn',
    '123456', '654321', 'abcdef', 'fedcba'
  ];
  
  const lowerPassword = password.toLowerCase();
  for (const pattern of keyboardPatterns) {
    if (lowerPassword.includes(pattern)) {
      feedback.push('Passwort enthält vorhersehbare Tastatur-Muster');
      suggestions.push('Vermeide Tastatur-Muster wie "qwerty" oder "123456"');
      break;
    }
  }

  // User-Input Check (Username/Email nicht im Passwort)
  if (userInputs && userInputs.length > 0) {
    for (const input of userInputs) {
      if (!input) continue;
      
      const lowerInput = input.toLowerCase();
      
      // Exakter Match
      if (lowerPassword.includes(lowerInput)) {
        feedback.push(`Passwort darf nicht "${input}" enthalten`);
        suggestions.push('Verwende keine persönlichen Informationen im Passwort');
      }
      
      // Teilstring-Check (z.B. "john" in "john123")
      if (lowerInput.length > MAX_COMMON_SUBSTRING_LENGTH) {
        for (let i = 0; i <= lowerInput.length - MAX_COMMON_SUBSTRING_LENGTH; i++) {
          const substring = lowerInput.substring(i, i + MAX_COMMON_SUBSTRING_LENGTH);
          if (lowerPassword.includes(substring)) {
            feedback.push(`Passwort enthält Teile von "${input}"`);
            suggestions.push('Wähle ein Passwort, das keine Bezüge zu deinem Benutzernamen hat');
            break;
          }
        }
      }
    }
  }

  // zxcvbn Analyse
  const analysis = zxcvbn(password, [
    ...(userInputs || []),
    ...ADDITIONAL_COMMON_PASSWORDS,
    'weltenwind',
    'mmorpg',
    'rollenspiel',
    'fantasy'
  ]);

  // Score-basierte Validierung
  if (analysis.score < MIN_SCORE) {
    feedback.push('Passwort ist zu schwach');
    
    // zxcvbn Feedback übersetzen und hinzufügen
    if (analysis.feedback.warning) {
      feedback.push(translateZxcvbnFeedback(analysis.feedback.warning));
    }
    
    // zxcvbn Vorschläge übersetzen
    if (analysis.feedback.suggestions) {
      for (const suggestion of analysis.feedback.suggestions) {
        suggestions.push(translateZxcvbnFeedback(suggestion));
      }
    }
  }

  // Zeit-Schätzung formatieren
  const estimatedCrackTime = formatCrackTime(analysis.crack_times_display.offline_slow_hashing_1e4_per_second);

  // Finale Validierung
  const valid = feedback.length === 0 && analysis.score >= MIN_SCORE;

  // Positive Rückmeldung bei starkem Passwort
  if (valid && analysis.score >= 3) {
    feedback.push('Starkes Passwort! 💪');
  }

  return {
    valid,
    score: analysis.score,
    feedback,
    suggestions: suggestions.length > 0 ? suggestions : 
      (valid ? [] : ['Verwende eine Kombination aus Groß-/Kleinbuchstaben, Zahlen und Sonderzeichen']),
    estimatedCrackTime,
    warning: analysis.feedback.warning ? translateZxcvbnFeedback(analysis.feedback.warning) : undefined
  };
}

// Übersetzt zxcvbn Feedback ins Deutsche
function translateZxcvbnFeedback(feedback: string): string {
  const translations: Record<string, string> = {
    'This is a top-10 common password': 'Dies ist eines der 10 häufigsten Passwörter',
    'This is a top-100 common password': 'Dies ist eines der 100 häufigsten Passwörter',
    'This is a very common password': 'Dies ist ein sehr häufiges Passwort',
    'This is similar to a commonly used password': 'Dies ähnelt einem häufig verwendeten Passwort',
    'A word by itself is easy to guess': 'Ein einzelnes Wort ist leicht zu erraten',
    'Names and surnames by themselves are easy to guess': 'Namen alleine sind leicht zu erraten',
    'Common names and surnames are easy to guess': 'Häufige Namen sind leicht zu erraten',
    'Straight rows of keys are easy to guess': 'Tastenreihen sind leicht zu erraten',
    'Short keyboard patterns are easy to guess': 'Kurze Tastaturmuster sind leicht zu erraten',
    'Repeats like "aaa" are easy to guess': 'Wiederholungen wie "aaa" sind leicht zu erraten',
    'Repeats like "abcabcabc" are only slightly harder to guess than "abc"': 'Wiederholungen wie "abcabcabc" sind kaum sicherer als "abc"',
    'Sequences like abc or 6543 are easy to guess': 'Sequenzen wie "abc" oder "6543" sind leicht zu erraten',
    'Recent years are easy to guess': 'Aktuelle Jahreszahlen sind leicht zu erraten',
    'Dates are often easy to guess': 'Datumsangaben sind oft leicht zu erraten',
    'Add another word or two. Uncommon words are better.': 'Füge ein oder zwei weitere Wörter hinzu. Ungewöhnliche Wörter sind besser.',
    'Use a few words, avoid common phrases': 'Verwende mehrere Wörter, vermeide häufige Phrasen',
    'No need for symbols, digits, or uppercase letters': 'Symbole, Zahlen oder Großbuchstaben sind nicht zwingend nötig',
    'Avoid repeated words and characters': 'Vermeide wiederholte Wörter und Zeichen',
    'Avoid sequences': 'Vermeide Sequenzen',
    'Avoid recent years': 'Vermeide aktuelle Jahreszahlen',
    'Avoid years that are associated with you': 'Vermeide Jahreszahlen, die mit dir in Verbindung stehen',
    'Avoid dates and years that are associated with you': 'Vermeide Daten und Jahre, die mit dir in Verbindung stehen',
    'Capitalization doesn\'t help very much': 'Groß-/Kleinschreibung hilft nur wenig',
    'All-uppercase is almost as easy to guess as all-lowercase': 'Nur Großbuchstaben sind fast genauso unsicher wie nur Kleinbuchstaben',
    'Reversed words aren\'t much harder to guess': 'Umgekehrte Wörter sind nicht viel sicherer',
    'Predictable substitutions like \'@\' instead of \'a\' don\'t help very much': 'Vorhersehbare Ersetzungen wie "@" statt "a" helfen kaum'
  };

  return translations[feedback] || feedback;
}

// Formatiert die geschätzte Crack-Zeit
function formatCrackTime(timeValue: string | number): string {
  // Konvertiere number zu string falls nötig
  const timeString = typeof timeValue === 'number' ? timeValue.toString() : timeValue;
  
  const translations: Record<string, string> = {
    'less than a second': 'weniger als eine Sekunde',
    'instant': 'sofort',
    'seconds': 'Sekunden',
    'minutes': 'Minuten',
    'hours': 'Stunden',
    'days': 'Tage',
    'months': 'Monate',
    'years': 'Jahre',
    'centuries': 'Jahrhunderte'
  };

  let translated = timeString;
  for (const [eng, ger] of Object.entries(translations)) {
    translated = translated.replace(new RegExp(eng, 'gi'), ger);
  }

  return translated;
}

// Generiert Passwort-Anforderungen als Text
export function getPasswordRequirements(): string[] {
  return [
    `Mindestens ${MIN_LENGTH} Zeichen lang`,
    'Keine häufigen oder vorhersehbaren Passwörter',
    'Darf keinen Benutzernamen oder E-Mail enthalten',
    'Keine Tastaturmuster oder wiederholende Zeichen',
    'Kombination aus Buchstaben, Zahlen und Sonderzeichen empfohlen'
  ];
}

// Berechnet Passwort-Stärke als Prozentsatz (für UI-Anzeige)
export function getPasswordStrengthPercentage(score: number): number {
  return Math.min(100, (score + 1) * 20); // 0=20%, 1=40%, 2=60%, 3=80%, 4=100%
}

// Gibt Farbe für Passwort-Stärke zurück (für UI)
export function getPasswordStrengthColor(score: number): string {
  const colors = ['#dc2626', '#f59e0b', '#eab308', '#22c55e', '#16a34a']; // rot -> grün
  return colors[score] || colors[0];
}

// Gibt Text für Passwort-Stärke zurück
export function getPasswordStrengthText(score: number): string {
  const texts = ['Sehr schwach', 'Schwach', 'Fair', 'Gut', 'Stark'];
  return texts[score] || texts[0];
}