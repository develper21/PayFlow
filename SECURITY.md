# PayFlow Security Documentation

## Security Measures Implemented

### 1. Data Encryption in SharedPreferences
- **AES-256 Encryption**: All bill data stored in SharedPreferences is encrypted using AES-256 with CBC mode.
- **Key Derivation**: Encryption key is derived from app package name + device-specific salt.
- **Migration**: Existing unencrypted data is automatically migrated to encrypted storage.
- **Files**:
  - `lib/shared/services/encryption_service.dart` - Core encryption logic
  - `lib/shared/widgets/boleto_list/boleto_list_controller.dart` - Encrypted save/load

### 2. Input Sanitization
- **Bill Name**: Removes special characters (`<`, `>`, `&`, `"`, `'`)
- **Barcode**: Only allows numeric characters (44 or 48 digits for Brazilian boletos)
- **Date Validation**: Validates DD/MM/YYYY format and checks for valid dates
- **Value Validation**: Ensures amounts are within valid range (0 to 999,999,999.99)
- **SQL Injection Prevention**: Detects and blocks SQL injection patterns
- **Files**:
  - `lib/shared/utils/input_sanitizer.dart` - Sanitization utilities
  - `lib/modules/insert_boleto/insert_boleto_controller.dart` - Input validation

### 3. Google Sign-In Token Verification
- **JWT Structure Validation**: Verifies token has 3 parts separated by dots
- **Token Length Check**: Validates token is within expected length (100-2000 chars)
- **Session Expiry**: Optional 30-day session timeout
- **Client-Side Verification**: Basic format validation (full server-side verification requires backend)
- **Files**:
  - `lib/shared/auth/auth_controller.dart` - Token verification logic

### 4. Firebase API Keys
**IMPORTANT**: Firebase API keys are client-side keys and are **NOT a security risk** when exposed in the app code.

#### Why Firebase API Keys Are Safe to Expose:
1. **Client-Side Only**: Firebase API keys are designed for client-side use
2. **No Secret Operations**: They only identify the app to Firebase services
3. **Security Rules**: Data access is controlled by Firebase Security Rules, not the API key
4. **Domain/App Restriction**: API keys can be restricted to specific apps/domains in Firebase Console
5. **No Admin Privileges**: Client keys cannot perform admin operations

#### Security Rules Control Access:
```javascript
// Example Firebase Firestore Security Rule
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/bills/{billId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### API Key Location:
- **File**: `lib/firebase_options.dart`
- **Keys**: `android`, `ios`, `web` configurations

### 5. Additional Security Measures
- **Connectivity Checks**: Monitors network status for cloud sync operations
- **Error Boundaries**: Catches and handles runtime errors gracefully
- **Session Management**: User sessions are tracked with timestamps
- **Data Validation**: All user inputs are validated before processing

## Security Best Practices for Production

### 1. Backend Verification (Recommended)
For production apps, implement server-side token verification:
```javascript
// Backend (Node.js example)
const {OAuth2Client} = require('google-auth-library');
const client = new OAuth2Client(CLIENT_ID);

async function verifyToken(idToken) {
  const ticket = await client.verifyIdToken({
    idToken: idToken,
    audience: CLIENT_ID,
  });
  return ticket.getPayload();
}
```

### 2. Firebase Security Rules
Ensure strict security rules in Firebase Console:
- Only authenticated users can access their data
- Validate data structure in rules
- Rate limiting for write operations

### 3. App Check (Optional)
Enable Firebase App Check to prevent abuse:
- **SafetyNet** for Android
- **DeviceCheck** for iOS
- **reCAPTCHA** for Web

### 4. Encryption Key Management (Advanced)
For production, consider:
- Using Android Keystore / iOS Keychain for key storage
- Implementing key rotation
- Using Hardware Security Modules (HSM)

## Security Checklist

- [x] AES-256 encryption for local storage
- [x] Input sanitization for all user inputs
- [x] Token format verification
- [x] Session management
- [x] Error handling and logging
- [x] Connectivity checks
- [x] Data validation
- [ ] Backend token verification (optional)
- [ ] Firebase App Check (optional)
- [ ] Certificate pinning (optional)

## Reporting Security Issues

If you discover a security vulnerability, please report it privately to the development team.

## References
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
