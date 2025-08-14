# 🔌 Weltenwind OpenAPI Specification

**Dieses Verzeichnis** enthält das OpenAPI/Swagger-Spezifikations-System für die Weltenwind API. Es generiert automatisch die kombinierte API-Dokumentation aus modularen YAML-Dateien.

---

## 📂 **Verzeichnis-Struktur**

```
docs/openapi/
├── 📄 README.md                 # Diese Datei - OpenAPI System Dokumentation
├── 📄 generate-openapi.js       # Build-Script für API-Generierung
├── 📄 package.json              # NPM Dependencies
├── 📄 package-lock.json         # NPM Lock File
├── 📁 node_modules/             # NPM Dependencies (auto-generated)
│
├── 📁 specs/                    # 📝 Individual API Specifications
│   ├── openapi.yaml             # Base OpenAPI Config & Common Schemas  
│   ├── auth.yaml                # Authentication Endpoints (/auth/*)
│   ├── worlds.yaml              # World Management (/worlds/*)
│   ├── invite.yaml              # Invite System (/invites/*)
│   ├── themes.yaml              # Theme System (/themes/*)
│   └── arb.yaml                 # Localization (/arb/*)
│
└── 📁 generated/                # 🏗️ Generated Files (auto-generated)
    └── api-combined.yaml        # Combined OpenAPI Specification
```

---

## 🚀 **Usage**

### **API-Dokumentation generieren:**
```bash
cd docs/openapi
node generate-openapi.js
```

### **Dependencies installieren:**
```bash
cd docs/openapi
npm install
```

### **Generated File verwenden:**
- **Backend**: Das Backend lädt automatisch `generated/api-combined.yaml`
- **Swagger UI**: Verfügbar unter `https://<VM-IP>/api/docs`
- **External Tools**: Import `generated/api-combined.yaml` in Postman, Insomnia, etc.

---

## 📝 **Individual Specifications**

### **`specs/openapi.yaml` - Base Configuration**
- **OpenAPI Version**: 3.0.3
- **API Metadata**: Title, Version, Description
- **Servers**: Development & Production URLs
- **Security Schemes**: JWT Bearer Auth
- **Common Schemas**: Error responses, User model, etc.
- **Global Security**: Bearer token requirement

### **`specs/auth.yaml` - Authentication**
**Endpoints:**
- `POST /auth/login` - User login
- `POST /auth/register` - User registration  
- `POST /auth/logout` - User logout
- `GET /auth/me` - Current user info
- `POST /auth/refresh` - Token refresh

### **`specs/worlds.yaml` - World Management**
**Endpoints:**
- `GET /worlds` - List worlds
- `POST /worlds` - Create world
- `GET /worlds/{id}` - World details
- `POST /worlds/{id}/join` - Join world
- `POST /worlds/{id}/leave` - Leave world

### **`specs/invite.yaml` - Invite System**
**Endpoints:**
- `POST /invites` - Create invitation
- `GET /invites/validate/{token}` - Validate invite
- `POST /invites/accept/{token}` - Accept invitation
- `POST /invites/decline/{token}` - Decline invitation
- `GET /invites` - List my invites
- `DELETE /invites/{id}` - Delete invite

### **`specs/themes.yaml` - Theme System**
**Endpoints:**
- `GET /themes` - List themes
- `GET /themes/{id}` - Theme details
- `GET /themes/bundles` - Theme bundles
- `GET /themes/world/{worldId}` - World theme

### **`specs/arb.yaml` - Localization**
**Endpoints:**
- `GET /arb/languages` - Supported languages
- `GET /arb/translations/{language}` - Language translations
- `GET /arb/keys` - Translation keys

---

## 🔧 **Development Workflow**

### **Adding New Endpoints:**
1. **Edit Individual Spec**: Modify appropriate `specs/*.yaml` file
2. **Add Schemas**: Define request/response schemas in respective file
3. **Regenerate**: Run `node generate-openapi.js`
4. **Test**: Check Swagger UI at `https://<VM-IP>/api/docs`

### **Creating New API Module:**
1. **Create Spec File**: Add new `specs/module.yaml`
2. **Update Generate Script**: Add module to `generate-openapi.js`
3. **Define Endpoints**: Add paths and schemas
4. **Regenerate & Test**

### **Schema Guidelines:**
- **Use References**: `$ref: '#/components/schemas/User'` for reusability
- **Common Responses**: Use shared error responses from `openapi.yaml`
- **Validation**: Define proper validation rules (minLength, format, etc.)
- **Examples**: Provide meaningful examples for all fields

---

## 📊 **Generated Output**

### **`generated/api-combined.yaml`**
- **Combined Specification**: All individual specs merged
- **Used by Backend**: Served at `/api-combined.yaml`
- **Used by Swagger UI**: Interactive documentation
- **Used by Tools**: Import into Postman, Insomnia, etc.

### **Generation Process:**
```javascript
// 1. Load individual specs
const base = yaml.load('specs/openapi.yaml');
const auth = yaml.load('specs/auth.yaml');
// ... etc

// 2. Merge paths
combined.paths = { ...auth.paths, ...worlds.paths, ... };

// 3. Deep merge components
deepMerge(combined.components, auth.components);
// ... etc

// 4. Write combined file
fs.writeFileSync('generated/api-combined.yaml', yaml.dump(combined));
```

---

## 🎯 **Best Practices**

### **Individual Spec Files:**
- ✅ **Modular**: One file per API domain
- ✅ **Self-contained**: Each module defines its own schemas
- ✅ **Consistent**: Use common response formats
- ✅ **Documented**: Meaningful descriptions and examples

### **Schema Design:**
- ✅ **Reusable**: Common schemas in `openapi.yaml`
- ✅ **Validated**: Proper validation rules
- ✅ **Typed**: Explicit types and formats
- ✅ **Examples**: Real-world examples

### **Security:**
- ✅ **Bearer Auth**: JWT token authentication
- ✅ **Scoped**: Individual endpoints can override security
- ✅ **Documented**: Clear auth requirements

---

## 🔍 **Troubleshooting**

### **Generation Fails:**
```bash
# Check YAML syntax
npx yaml-lint specs/*.yaml

# Check individual files
node -e "console.log(require('js-yaml').load(require('fs').readFileSync('specs/auth.yaml', 'utf8')))"
```

### **Backend Can't Load File:**
- ✅ Check path in `backend/src/server.ts` is correct
- ✅ Ensure `generated/api-combined.yaml` exists
- ✅ Restart backend after regeneration

### **Swagger UI Issues:**
- ✅ Check console for YAML parsing errors
- ✅ Validate generated file at `https://editor.swagger.io/`
- ✅ Clear browser cache

---

## 📚 **External Resources**

- **OpenAPI Specification**: https://spec.openapis.org/oas/v3.0.3
- **Swagger Editor**: https://editor.swagger.io/
- **JSON Schema**: https://json-schema.org/
- **js-yaml Documentation**: https://github.com/nodeca/js-yaml

---

**System Version**: 1.0  
**OpenAPI Version**: 3.0.3  
**Last Updated**: Januar 2025  
**Status**: ✅ Production Ready