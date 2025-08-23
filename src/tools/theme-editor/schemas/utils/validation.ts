/**
 * Weltenwind Theme Schema Validation Helper
 * 
 * Live Schema-Validation, $refs Resolution, Auto-Suggestions
 * für das modulare Gaming Theme System
 */

import { JSONSchema7, JSONSchema7Definition } from 'json-schema';

// =====================================================
// TYPES & INTERFACES
// =====================================================

export interface ValidationResult {
  valid: boolean;
  errors: ValidationError[];
  warnings: ValidationWarning[];
  suggestions: SchemaSuggestion[];
}

export interface ValidationError {
  path: string;
  message: string;
  schemaPath: string;
  expectedType?: string;
  actualValue?: any;
  severity: 'error' | 'critical';
}

export interface ValidationWarning {
  path: string;
  message: string;
  suggestion?: string;
  performance?: boolean;
}

export interface SchemaSuggestion {
  path: string;
  property: string;
  suggestedValue: any;
  reason: string;
  category: 'performance' | 'accessibility' | 'gaming' | 'visual';
}

export interface SchemaReference {
  $ref: string;
  resolved?: JSONSchema7;
  circular?: boolean;
}

export interface ModuleDependency {
  module: string;
  requiredBy: string[];
  optional: boolean;
  loadOrder: number;
}

export interface BundleConfig {
  type: 'minimal' | 'basic' | 'gaming' | 'complete';
  context: 'pre-game' | 'world-preview' | 'in-game' | 'universal';
  modules: string[];
  dependencies: ModuleDependency[];
  estimatedSize: number;
  loadPriority: number;
}

// =====================================================
// SCHEMA VALIDATOR CLASS
// =====================================================

export class WeltenwindThemeValidator {
  private schemas: Map<string, JSONSchema7> = new Map();
  private resolvedRefs: Map<string, JSONSchema7> = new Map();
  private validationCache: Map<string, ValidationResult> = new Map();
  
  constructor() {
    this.initializeSchemas();
  }

  // =====================================================
  // SCHEMA LOADING & RESOLUTION
  // =====================================================

  private async initializeSchemas(): Promise<void> {
    try {
      // Main schema
      const mainSchema = await this.loadSchema('../main.schema.json');
      this.schemas.set('main', mainSchema);

      // Core schemas
      const coreSchemas = [
        'colors', 'typography', 'spacing', 'radius'
      ];
      
      for (const schema of coreSchemas) {
        try {
          const loaded = await this.loadSchema(`../core/${schema}.schema.json`);
          this.schemas.set(`core.${schema}`, loaded);
        } catch (error) {
          console.warn(`⚠️ Schema ${schema} nicht gefunden, wird übersprungen`);
        }
      }

      // Gaming schemas
      const gamingSchemas = [
        'inventory', 'progress', 'hud', 'accessibility'
      ];
      
      for (const schema of gamingSchemas) {
        try {
          const loaded = await this.loadSchema(`../gaming/${schema}.schema.json`);
          this.schemas.set(`gaming.${schema}`, loaded);
        } catch (error) {
          console.warn(`⚠️ Gaming Schema ${schema} nicht gefunden`);
        }
      }

      // Effects schemas
      const effectSchemas = [
        'visual', 'animations'
      ];
      
      for (const schema of effectSchemas) {
        try {
          const loaded = await this.loadSchema(`../effects/${schema}.schema.json`);
          this.schemas.set(`effects.${schema}`, loaded);
        } catch (error) {
          console.warn(`⚠️ Effects Schema ${schema} nicht gefunden`);
        }
      }

      console.log(`✅ ${this.schemas.size} Schemas geladen und bereit`);
    } catch (error) {
      console.error('❌ Schema-Initialisierung fehlgeschlagen:', error);
    }
  }

  private async loadSchema(path: string): Promise<JSONSchema7> {
    // In einer echten Implementation würde hier fetch() oder fs.readFile() verwendet
    // Für jetzt simulieren wir das Schema-Laden
    throw new Error(`Schema loading not implemented: ${path}`);
  }

  // =====================================================
  // $REFS RESOLUTION
  // =====================================================

  public resolveSchemaRefs(schema: JSONSchema7, visited: Set<string> = new Set()): JSONSchema7 {
    if (typeof schema !== 'object' || schema === null) {
      return schema;
    }

    const resolved: JSONSchema7 = { ...schema };

    // Handle $ref
    if (schema.$ref) {
      const refKey = schema.$ref;
      
      if (visited.has(refKey)) {
        console.warn(`🔄 Zirkuläre Referenz erkannt: ${refKey}`);
        return { type: 'object', description: `Circular reference to ${refKey}` };
      }

      visited.add(refKey);
      
      const referencedSchema = this.getSchemaByRef(refKey);
      if (referencedSchema) {
        const resolvedRef = this.resolveSchemaRefs(referencedSchema, visited);
        this.resolvedRefs.set(refKey, resolvedRef);
        return resolvedRef;
      } else {
        console.error(`❌ Schema-Referenz nicht gefunden: ${refKey}`);
        return { type: 'object', description: `Missing reference: ${refKey}` };
      }
    }

    // Recursively resolve nested schemas
    Object.keys(resolved).forEach(key => {
      const value = resolved[key as keyof JSONSchema7];
      
      if (typeof value === 'object' && value !== null) {
        if (Array.isArray(value)) {
          resolved[key as keyof JSONSchema7] = value.map(item => 
            typeof item === 'object' ? this.resolveSchemaRefs(item, visited) : item
          ) as any;
        } else {
          resolved[key as keyof JSONSchema7] = this.resolveSchemaRefs(value, visited) as any;
        }
      }
    });

    return resolved;
  }

  private getSchemaByRef(ref: string): JSONSchema7 | null {
    // Parse $ref URLs like "https://weltenwind.game/schemas/core/colors.schema.json"
    const match = ref.match(/\/schemas\/([^\/]+)\/([^.]+)\.schema\.json/);
    if (match) {
      const [, module, name] = match;
      const schemaKey = `${module}.${name}`;
      return this.schemas.get(schemaKey) || null;
    }

    // Handle relative refs
    if (ref.startsWith('../')) {
      const schemaName = ref.replace('../', '').replace('.schema.json', '');
      return this.schemas.get(schemaName) || null;
    }

    return null;
  }

  // =====================================================
  // LIVE VALIDATION
  // =====================================================

  public validateTheme(theme: any, schemaType: string = 'main'): ValidationResult {
    const cacheKey = `${schemaType}:${JSON.stringify(theme).substring(0, 100)}`;
    
    if (this.validationCache.has(cacheKey)) {
      return this.validationCache.get(cacheKey)!;
    }

    const result = this.performValidation(theme, schemaType);
    this.validationCache.set(cacheKey, result);
    
    // Cache nur 100 Einträge behalten
    if (this.validationCache.size > 100) {
      const firstKey = this.validationCache.keys().next().value;
      this.validationCache.delete(firstKey);
    }

    return result;
  }

  private performValidation(theme: any, schemaType: string): ValidationResult {
    const schema = this.schemas.get(schemaType);
    if (!schema) {
      return {
        valid: false,
        errors: [{
          path: '$',
          message: `Schema ${schemaType} nicht gefunden`,
          schemaPath: '$',
          severity: 'critical'
        }],
        warnings: [],
        suggestions: []
      };
    }

    const errors: ValidationError[] = [];
    const warnings: ValidationWarning[] = [];
    const suggestions: SchemaSuggestion[] = [];

    // Schema-Validation durchführen
    this.validateAgainstSchema(theme, schema, '', errors, warnings);
    
    // Gaming-spezifische Validierung
    this.validateGamingFeatures(theme, warnings, suggestions);
    
    // Performance-Validierung
    this.validatePerformance(theme, warnings, suggestions);
    
    // Accessibility-Validierung
    this.validateAccessibility(theme, warnings, suggestions);

    return {
      valid: errors.length === 0,
      errors,
      warnings,
      suggestions
    };
  }

  private validateAgainstSchema(
    data: any, 
    schema: JSONSchema7, 
    path: string, 
    errors: ValidationError[], 
    warnings: ValidationWarning[]
  ): void {
    // Required Properties
    if (schema.required && typeof data === 'object') {
      schema.required.forEach(prop => {
        if (!(prop in data)) {
          errors.push({
            path: `${path}.${prop}`,
            message: `Erforderliche Eigenschaft fehlt: ${prop}`,
            schemaPath: `${path}/required`,
            severity: 'error'
          });
        }
      });
    }

    // Type Validation
    if (schema.type && typeof data !== schema.type) {
      errors.push({
        path: path,
        message: `Falscher Typ: erwartet ${schema.type}, erhalten ${typeof data}`,
        schemaPath: `${path}/type`,
        expectedType: schema.type.toString(),
        actualValue: data,
        severity: 'error'
      });
    }

    // Pattern Validation (für Hex-Farben)
    if (schema.pattern && typeof data === 'string') {
      const regex = new RegExp(schema.pattern);
      if (!regex.test(data)) {
        errors.push({
          path: path,
          message: `String entspricht nicht dem Pattern: ${schema.pattern}`,
          schemaPath: `${path}/pattern`,
          actualValue: data,
          severity: 'error'
        });
      }
    }

    // Min/Max für Zahlen
    if (typeof data === 'number') {
      if (schema.minimum !== undefined && data < schema.minimum) {
        errors.push({
          path: path,
          message: `Wert zu klein: ${data} < ${schema.minimum}`,
          schemaPath: `${path}/minimum`,
          severity: 'error'
        });
      }
      if (schema.maximum !== undefined && data > schema.maximum) {
        errors.push({
          path: path,
          message: `Wert zu groß: ${data} > ${schema.maximum}`,
          schemaPath: `${path}/maximum`,
          severity: 'error'
        });
      }
    }

    // Recursive validation für Properties
    if (schema.properties && typeof data === 'object') {
      Object.keys(schema.properties).forEach(prop => {
        if (prop in data) {
          const propSchema = schema.properties![prop];
          if (typeof propSchema === 'object') {
            this.validateAgainstSchema(
              data[prop], 
              propSchema, 
              `${path}.${prop}`, 
              errors, 
              warnings
            );
          }
        }
      });
    }
  }

  // =====================================================
  // GAMING-SPECIFIC VALIDATION
  // =====================================================

  private validateGamingFeatures(
    theme: any, 
    warnings: ValidationWarning[], 
    suggestions: SchemaSuggestion[]
  ): void {
    // Inventory System Validation
    if (theme.gaming?.inventory) {
      const inventory = theme.gaming.inventory;
      
      // Slot-Größe Optimierung
      if (inventory.slots?.size) {
        if (inventory.slots.size < 48) {
          warnings.push({
            path: 'gaming.inventory.slots.size',
            message: 'Slot-Größe möglicherweise zu klein für Touch-Geräte',
            suggestion: 'Mindestens 48px für bessere Touch-Accessibility'
          });
        }
        if (inventory.slots.size > 80) {
          warnings.push({
            path: 'gaming.inventory.slots.size',
            message: 'Große Slot-Größe kann Performance beeinträchtigen',
            performance: true
          });
        }
      }

      // Rarity Colors Validation
      if (inventory.rarity) {
        const rarities = ['common', 'uncommon', 'rare', 'epic', 'legendary'];
        const missingRarities = rarities.filter(r => !inventory.rarity[r]);
        
        if (missingRarities.length > 0) {
          suggestions.push({
            path: 'gaming.inventory.rarity',
            property: missingRarities[0],
            suggestedValue: { color: '#FFFFFF', glowIntensity: 0.0, name: 'Standard' },
            reason: `Fehlende Rarity-Definition für bessere Gaming-Experience`,
            category: 'gaming'
          });
        }
      }
    }

    // Progress Bars Validation
    if (theme.gaming?.progress) {
      const progress = theme.gaming.progress;
      
      if (progress.health?.criticalThreshold > 0.3) {
        suggestions.push({
          path: 'gaming.progress.health.criticalThreshold',
          property: 'criticalThreshold',
          suggestedValue: 0.25,
          reason: 'Niedrigere kritische Schwelle für bessere Gaming-UX',
          category: 'gaming'
        });
      }

      if (progress.base?.height < 12) {
        warnings.push({
          path: 'gaming.progress.base.height',
          message: 'Progress Bars möglicherweise zu dünn für gute Sichtbarkeit'
        });
      }
    }

    // HUD System Validation
    if (theme.gaming?.hud) {
      const hud = theme.gaming.hud;
      
      if (hud.minimap?.size > 200) {
        warnings.push({
          path: 'gaming.hud.minimap.size',
          message: 'Große Minimap kann Sicht auf Spielfeld behindern',
          performance: true
        });
      }

      if (hud.buffBar?.maxBuffs > 15) {
        warnings.push({
          path: 'gaming.hud.buffBar.maxBuffs',
          message: 'Viele Buffs können UI überladen',
          suggestion: 'Maximal 12 Buffs für übersichtliche Anzeige'
        });
      }
    }
  }

  // =====================================================
  // PERFORMANCE VALIDATION
  // =====================================================

  private validatePerformance(
    theme: any, 
    warnings: ValidationWarning[], 
    suggestions: SchemaSuggestion[]
  ): void {
    // Animations Performance
    if (theme.gaming?.inventory?.animations?.itemAppear?.duration > 1000) {
      warnings.push({
        path: 'gaming.inventory.animations.itemAppear.duration',
        message: 'Lange Animationen können Performance beeinträchtigen',
        performance: true,
        suggestion: 'Maximal 600ms für flüssige Experience'
      });
    }

    // Particle System Performance
    if (theme.extensions?.particles?.density > 1.0) {
      warnings.push({
        path: 'extensions.particles.density',
        message: 'Hohe Partikel-Dichte kann FPS reduzieren',
        performance: true
      });
    }

    // Visual Effects Performance
    const effects = theme.extensions?.screenEffects;
    if (effects) {
      if (effects.bloom > 0.3) {
        suggestions.push({
          path: 'extensions.screenEffects.bloom',
          property: 'bloom',
          suggestedValue: 0.2,
          reason: 'Reduzierte Bloom-Intensität für bessere Performance',
          category: 'performance'
        });
      }
    }

    // Bundle Size Estimation
    const estimatedSize = this.estimateThemeSize(theme);
    if (estimatedSize > 50000) { // 50KB
      warnings.push({
        path: '$',
        message: `Theme-Größe geschätzt auf ${Math.round(estimatedSize/1000)}KB - könnte Ladezeiten beeinträchtigen`,
        performance: true
      });
    }
  }

  private estimateThemeSize(theme: any): number {
    const jsonString = JSON.stringify(theme);
    return jsonString.length * 1.2; // Schätzung mit Overhead
  }

  // =====================================================
  // ACCESSIBILITY VALIDATION
  // =====================================================

  private validateAccessibility(
    theme: any, 
    warnings: ValidationWarning[], 
    suggestions: SchemaSuggestion[]
  ): void {
    // Color Contrast Validation (vereinfacht)
    if (theme.colors) {
      const background = theme.colors.background?.surface_dark;
      const textPrimary = theme.colors.text?.primary;
      
      if (background && textPrimary) {
        // Vereinfachte Kontrast-Prüfung
        if (this.isSimilarColor(background, textPrimary)) {
          warnings.push({
            path: 'colors.text.primary',
            message: 'Möglicherweise geringer Kontrast zwischen Text und Hintergrund'
          });
        }
      }
    }

    // Focus Indicators
    if (!theme.gaming?.inventory?.accessibility?.focusIndicator) {
      suggestions.push({
        path: 'gaming.inventory.accessibility.focusIndicator',
        property: 'focusIndicator',
        suggestedValue: { color: '#A594D1', width: 2 },
        reason: 'Focus-Indikatoren für Keyboard-Navigation',
        category: 'accessibility'
      });
    }

    // Touch-Friendly Sizes
    const slotSize = theme.gaming?.inventory?.slots?.size;
    if (slotSize && slotSize < 44) {
      suggestions.push({
        path: 'gaming.inventory.slots.size',
        property: 'size',
        suggestedValue: 48,
        reason: 'Mindestgröße für Touch-Accessibility (44px WCAG)',
        category: 'accessibility'
      });
    }
  }

  private isSimilarColor(color1: string, color2: string): boolean {
    // Vereinfachte Farbähnlichkeits-Prüfung
    if (!color1 || !color2) return false;
    return color1.toLowerCase() === color2.toLowerCase();
  }

  // =====================================================
  // AUTO-SUGGESTIONS
  // =====================================================

  public generateAutoSuggestions(theme: any, context: 'gaming' | 'performance' | 'accessibility' = 'gaming'): SchemaSuggestion[] {
    const suggestions: SchemaSuggestion[] = [];

    switch (context) {
      case 'gaming':
        this.addGamingSuggestions(theme, suggestions);
        break;
      case 'performance':
        this.addPerformanceSuggestions(theme, suggestions);
        break;
      case 'accessibility':
        this.addAccessibilitySuggestions(theme, suggestions);
        break;
    }

    return suggestions;
  }

  private addGamingSuggestions(theme: any, suggestions: SchemaSuggestion[]): void {
    // Gaming-Bundle Suggestion
    if (!theme.bundle || theme.bundle.type !== 'gaming') {
      suggestions.push({
        path: 'bundle.type',
        property: 'type',
        suggestedValue: 'gaming',
        reason: 'Gaming Bundle für vollständige RPG-Features',
        category: 'gaming'
      });
    }

    // Mythic Rarity Suggestion
    if (theme.gaming?.inventory?.rarity && !theme.gaming.inventory.rarity.mythic) {
      suggestions.push({
        path: 'gaming.inventory.rarity.mythic',
        property: 'mythic',
        suggestedValue: {
          color: '#FFD700',
          glowIntensity: 1.0,
          name: 'Mythisch',
          animated: true
        },
        reason: 'Mythic Rarity für höchste Item-Stufe',
        category: 'gaming'
      });
    }
  }

  private addPerformanceSuggestions(theme: any, suggestions: SchemaSuggestion[]): void {
    // Low-Device Conditions
    if (!theme.conditions?.enabled) {
      suggestions.push({
        path: 'conditions.enabled',
        property: 'enabled',
        suggestedValue: true,
        reason: 'Conditional Loading für Performance-Optimierung',
        category: 'performance'
      });
    }
  }

  private addAccessibilitySuggestions(theme: any, suggestions: SchemaSuggestion[]): void {
    // Keyboard Navigation
    if (theme.gaming?.inventory && !theme.gaming.inventory.accessibility?.keyboardNavigation) {
      suggestions.push({
        path: 'gaming.inventory.accessibility.keyboardNavigation',
        property: 'keyboardNavigation',
        suggestedValue: true,
        reason: 'Keyboard-Navigation für Accessibility',
        category: 'accessibility'
      });
    }
  }

  // =====================================================
  // BUNDLE DEPENDENCY RESOLUTION
  // =====================================================

  public resolveBundleDependencies(bundle: BundleConfig): ModuleDependency[] {
    const dependencies: ModuleDependency[] = [];

    // Core Dependencies (immer erforderlich)
    dependencies.push({
      module: 'colors',
      requiredBy: ['*'],
      optional: false,
      loadOrder: 1
    });

    // Gaming Dependencies
    if (bundle.modules.includes('gaming')) {
      dependencies.push({
        module: 'gaming.inventory',
        requiredBy: ['gaming'],
        optional: false,
        loadOrder: 3
      });
      
      dependencies.push({
        module: 'gaming.progress',
        requiredBy: ['gaming'],
        optional: false,
        loadOrder: 3
      });
      
      dependencies.push({
        module: 'gaming.hud',
        requiredBy: ['gaming'],
        optional: false,
        loadOrder: 4
      });
    }

    // Effects Dependencies
    if (bundle.modules.includes('effects')) {
      dependencies.push({
        module: 'effects.visual',
        requiredBy: ['effects', 'gaming'],
        optional: true,
        loadOrder: 5
      });
    }

    return dependencies.sort((a, b) => a.loadOrder - b.loadOrder);
  }

  // =====================================================
  // UTILITY METHODS
  // =====================================================

  public clearCache(): void {
    this.validationCache.clear();
    console.log('🧹 Validation Cache geleert');
  }

  public getSchemaInfo(): { [key: string]: { size: number, refs: number } } {
    const info: { [key: string]: { size: number, refs: number } } = {};
    
    this.schemas.forEach((schema, key) => {
      const jsonString = JSON.stringify(schema);
      const refs = (jsonString.match(/\$ref/g) || []).length;
      
      info[key] = {
        size: jsonString.length,
        refs: refs
      };
    });

    return info;
  }

  public validateModularTheme(theme: any): ValidationResult {
    // Spezielle Validierung für modulare Themes
    const result = this.validateTheme(theme, 'main');
    
    // Zusätzliche modular-spezifische Prüfungen
    if (theme.$schema && !theme.$schema.includes('main.schema.json')) {
      result.warnings.push({
        path: '$schema',
        message: 'Schema-Referenz zeigt nicht auf main.schema.json',
        suggestion: 'Verwende "../schemas/main.schema.json" für modulare Themes'
      });
    }

    return result;
  }
}

// =====================================================
// EXPORT DEFAULT INSTANCE
// =====================================================

export const themeValidator = new WeltenwindThemeValidator();
export default themeValidator;