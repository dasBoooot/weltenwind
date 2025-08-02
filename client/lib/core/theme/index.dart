/// 🎯 Theme System - New Architecture
/// 
/// Diese Datei exportiert die neue, saubere Theme-Architektur basierend auf
/// dem User's Kontextmodell:
/// 
/// 🔹 Global: ThemeRootProvider (ein globales Theme aktiv)
/// 🔸 Scoped: ThemePageProvider (ganzes Layout hat einen Kontext)  
/// 🔻 Mixed: ThemeContextConsumer (lokale Overrides pro Komponente)

// 🌍 Root Provider - Globaler Fallback
export '../providers/theme_root_provider.dart';

// 🎨 Page Provider - Page-Level Context
export '../providers/theme_page_provider.dart';

// 🎭 Context Consumer - Component-Level Overrides
export '../providers/theme_context_consumer.dart';

// 🛠️ Theme Helper - Mixed-Context Theme Access
export '../services/theme_helper.dart';

// 🔧 Core Services (weiterhin gebraucht)
export '../services/modular_theme_service.dart';
export '../services/theme_context_manager.dart';

// 🎨 Legacy Provider (für Übergangszeit)
export '../providers/theme_provider.dart';