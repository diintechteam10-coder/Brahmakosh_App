# Brahmakosh Authentication Module Documentation

## 1. Overview of the Auth Flow

The Authentication Module for the Brahmakosh App encompasses both standard Email/Password authentication and Google Single Sign-On (SSO). The registration flow is a multi-step process that ensures both Email and Mobile verification, followed by profile completion and avatar creation. 

### How Many Screens are in the Registration Flow?
There are a total of **5 Screens** involved in the core path from "Creating an Account" to "Finalizing Verification & Profile":

1. **Email Registration Screen** (`email_register_view.dart`)
2. **Email Verification OTP Screen** (`email_verify.dart`)
3. **Mobile Number & OTP Screen** (`mobile_number_page.dart`)
4. **Complete Profile Screen** (`complete_profile.dart`)
5. **Create/Generate Avatar Screen** (`create_avtar.dart`)

*(Note: There are 3 additional screens dedicated exclusively to the "Forgot Password" flow: Forgot Password, Verify Reset OTP, and Reset Password.)*

---

## 2. Screen-by-Screen Breakdown

### A. Register Step 1: Email Registration Screen
- **View**: `email_register_view.dart`
- **Controller**: `RegisterController`
- **Purpose**: Collects the user's `Email` and `Password`.
- **How it Works**: 
  - Validates input.
  - Sends a `POST` request to `ApiUrls.emailRegister` with the email, password, and `clientId: "CLI-KBHUMT"`.
  - On success, the backend dispatches an OTP to the user's email, and the app navigates to the **Email Verification OTP Screen**.

### B. Register Step 2: Email Verification OTP Screen
- **View**: `email_verify.dart`
- **Controller**: `EmailOtpController`
- **Purpose**: Verifies the email address.
- **How it Works**:
  - The user inputs the 6-digit OTP received via email.
  - Sends a `POST` request to `ApiUrls.emailRegister/verify`.
  - Upon successful validation, the app securely passes the verified email to the next screen and navigates to the **Mobile Number & OTP Screen**.

### C. Register Step 3: Mobile Number & Verification Screen
- **View**: `mobile_number_page.dart`
- **Controller**: `MobileOtpController`
- **Purpose**: Collects and verifies the user's mobile number.
- **How it Works**:
  - The user selects a country code (default: +91) and enters their mobile number. They can also select the notification channel (`whatsapp` or `sms/phone`).
  - **Send OTP**: Triggers `ApiUrls.mobileRegister`. The backend uses Gupshup/Twilio to send the OTP.
  - **Verify OTP**: Triggers `ApiUrls.mobileVerify` with the OTP and Email.
  - On success, navigates to the **Complete Profile Screen**.

### D. Register Step 4: Complete Profile Screen
- **View**: `complete_profile.dart`
- **Controller**: `CompleteProfileController`
- **Purpose**: Captures astrological and personal details required for the Brahmakosh app.
- **How it Works**:
  - Collects: *Name*, *Date of Birth (DOB)*, *Time of Birth*, *Place of Birth*, and *Gowthra*.
  - Converts DOB to a backend-friendly format (`YYYY-MM-DD`).
  - Submits data to `ApiUrls.completeProfile`.
  - **Critical Step**: The backend responds with the user's final authentication `token` and `userId`.
  - Saves the `token`, `userId`, `email`, and `isLoggedIn` flag to local `StorageService`.
  - Navigates to the **Create Avatar Screen**.

### E. Register Step 5: Create/Generate Avatar Screen
- **View**: `create_avtar.dart`
- **Controller**: `GenerateAvatarController`
- **Purpose**: Allows the user to select and upload a profile picture.
- **How it Works**:
  - Uses `image_picker` to open the phone gallery.
  - Formats the file into a `MultipartFile` and sends it to `ApiUrls.uploadProfileImage` along with the previously saved `email` and Bearer `token`.
  - Upon success, the user is navigated to the **Dashboard** (`AppConstants.routeDashboard`).

---

## 3. Login & Google Sign-In Flow

### A. Login Screen
- **View**: `login.dart`
- **Controller**: `AuthController`
- **Purpose**: Entry point for existing users or users wishing to use Google SSO.

### B. Standard Email Login
- **How it Works**:
  - Collects Email and Password.
  - Sends a `POST` request to `ApiUrls.login`.
  - On success, receives the user's `token` and `userId`.
  - Persists data in `StorageService` (`isLoggedIn = true`) and navigates directly to the **Dashboard**.

### C. Google Sign-In Flow (Hybrid Strategy)
The app uses Firebase Authentication alongside a custom backend check to determine if the Google user is new or returning.

- **Step 1:** Opens the Google Account Chooser UI via `GoogleSignIn`.
- **Step 2:** Retrieves the Google `accessToken` and `idToken`.
- **Step 3:** Signs into Firebase Auth (`_auth.signInWithCredential`) to get a Firebase UID and Email.
- **Step 4:** Calls the custom backend endpoint `ApiUrls.checkUser` passing the Google Email.
  - **If Existing User (`registered == true`)**: The backend returns the `token`. The app saves the session and navigates directly to the **Dashboard**.
  - **If New User (`registered == false`)**: The app skips Email verification (since Google already verified it) and redirects the user to the **Mobile Number & OTP Screen** (`mobileOtp`) to continue the registration flow from Step 3.

---

## 4. Local Storage & State Management
The Auth module heavily relies on GetX for state management and `StorageService` (likely SharedPreferences-based) for session persistence.

**Persisted Keys (`AppConstants`)**:
- `keyIsLoggedIn`: Boolean flag marking active session.
- `keyUserId`: Backend unique ID (`_id`).
- `keyAuthToken`: JWT Token used for subsequent API requests.
- `keyUserEmail`: The email of the active user.

**Sign Out Logic** (`signOut()` in `AuthController`):
- Signs out of `GoogleSignIn` and `FirebaseAuth`.
- Clears the entire `StorageService`.
- Navigates the user back to the `Login` screen.
