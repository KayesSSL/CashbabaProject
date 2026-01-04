# CashBaba iOS SDK (CBSDKSwiftCodes) Architecture and Flows

## Overview
- Module provides a UIKit-based SDK mirroring Android SDK flows (PIN management, transactions, CPQRC).
- Layers:
  - Facade: `CashBabaSDK`
  - Presenter/Coordinator: `SDKPresenter`, `MainCoordinator`, `Routes`
  - Networking: `APIHandler`, `WebServiceHandler`, `ApiPaths`, `Config`, `Encryptor`
  - Repository: `CashBabaRepository`, `CashBabaRepositoryImpl`
  - Models: Codable models in `Models.swift`
  - Utilities: `SDKError`, `SessionTimerManager`, `CBSDKDataStorage` (Android DataStorage parity), `CBSDKManager`, UI helpers
  - UI Modules: Splash, PIN Setup, Change PIN, Forget PIN, OTP Verification, Welcome/TnC

## Facade (`Init/CashBabaSDK.swift`)
- Public entry for API calls and config.
- Initialization:
  - `initialize(environment:languageCode:scope:wToken:pemData:)`
  - Convenience: `initialize(... pemResourceName:in:)` loads PEM from bundle.
- Callbacks channel (Android CurrentFlow equivalent):
  - `onSuccess(OnSuccessModel)`, `onFailed(OnFailedModel)`, `onUserCancel()` set via `setCallbacks(...)`.
- Token handling:
  - On `clientVerification`, stores token and starts `SessionTimerManager` with `expiresIn`.
  - Observes timer ticks and fires `onFailed("Session expired")` at expiry.
- Scope per flow:
  - PIN flows: `PinSet`
  - Payment/CPQRC: `Transaction`
  - Transfer: `LinkBank`
- Per-flow wToken overloads provided to mirror Android usage.

## Presentation & Navigation
- `Init/Routes.swift`:
  - `Route`: `.splash`, `.intro`, `.changePin`, `.forgotPin`, `.pinSetup(VerifyOTPType)`, `.verifyOTP(VerifyOTPType)`
  - `VerifyOTPType`: `.setPin`, `.changePin`, `.forgotPin`
  - `Coordinating` protocol
- `Init/MainCoordinator.swift`:
  - Owns a `UINavigationController` and maps `Route` to VCs. Implements a Splash overlay (added/removed with fade) to avoid flicker when transitioning to the first real screen.
  - `.intro` pushes `WelcomeVC`, which then proceeds to OTP via a tap handler.
  - `.changePin` and `.forgotPin` are wired to push `ChangePINVC`/`ForgetPinVC`.
  - `closeSDK(withError:)` calls facade `onFailed` and dismisses.
  - `closeSDKSuccessWithResult(_:)` dismisses UI and then calls facade `onSuccess` with payload.
  - Back-stack adjustment for Set PIN: when transitioning from `OTPVerificationVC` to `PINSetupVC` for `.setPin`, the coordinator removes the `OTPVerificationVC` from the navigation stack and inserts `PINSetupVC` so that the back button from `PINSetupVC` returns directly to `WelcomeVC` (skipping OTP). This keeps back behavior intuitive without custom per-screen back logic.
- `Init/SDKPresenter.swift`:
  - `NavigationArgs`: method type, wToken, language, environment, paymentReference, clientId/secret, phone, transferInfo.
  - Sets global config (lang/env/wToken) and callbacks, stores `CBSDKDataStorage.shared.navigationArgs = args`.
  - Creates `MainCoordinator` and presents nav.
  - `SDKStartRouteDecider` derives start route from args (adjust per flow).
- `UIModules/Splash/SplashVC.swift`:
  - Receives `NavigationArgs` from coordinator.
  - Calls `clientVerification`; on success, routes by `args.type`.
  - On failure, triggers `onFailed` and dismiss via coordinator.

## Networking
- `Utility/API Handler/Config.swift`:
  - `Environment.demo/live` with base URLs.
  - `CashBabaConfig` holds language, scope, wToken, accessToken.
- `Utility/API Handler/ApiPaths.swift`:
  - All endpoints including CPQRC validate/verify builders.
- `Utility/API Handler/APIHandler.swift`:
  - Default headers: `lang`, `scope`, `w-token`, `Authorization` (Bearer).
  - Methods: GET, POST form (`application/x-www-form-urlencoded`), POST multipart.
  - Multipart supports filenames/MIME (`MultipartPart`).
  - Error mapping policy:
    - 200/201 → success → `onSuccess` with raw `Data?`.
    - 401 → Unauthorized → APIHandler calls `CashBabaSDK.shared.closeSdkOnFailed(...)`, then `onFailure`.
    - 444/500/501 → Fatal → APIHandler calls `CashBabaSDK.shared.closeSdkOnFailed(...)`, then `onFailure`.
    - Other HTTP → parse `BaseResponse` for message and call `onFailure(message)` without closing.
    - Note: the multipart overload with `parts: [MultipartPart]` currently does not auto-close on 401/444 and returns the error message; upstream `WebServiceHandler` often performs the close in its `onFailure` handlers.
- `Utility/API Handler/Encryptor.swift`:
  - RSA PKCS#1 using SecKey; initialize with PEM.
- `Utility/API Handler/Models.swift`:
  - Codable responses mirroring Android; includes BaseResponse, token, PIN flows, payment, transfer, CPQRC.
- `Utility/API Handler/WebServiceHandler.swift`:
  - Composes form bodies and multipart; performs centralized PIN encryption just-in-time.
  - CPQRC multipart adds filenames and MIME detection.
  - On `validateCpQrcPayment` success, caches `cpqrcValidationData` to `CBSDKDataStorage`.
  - On `forgotPinOtpVerify` success, caches `forgetPinIdentifier` to `CBSDKDataStorage`.

## Repository
- `Utility/CBRepository/*` implements `CashBabaRepository` and `CashBabaRepositoryImpl` delegating to `WebServiceHandler`.

## Data Storage & Session
- `Utility/CBSDKDataStorage.swift` (Android DataStorage parity):
  - `navigationArgs`, `accessToken`, `languageCode`, `forgetPinIdentifier`, `environment`, `baseURL`, `tokenExpireInMillis`, `cpqrcValidationData`, `smileFacePath`, `blinkFacePath`.
  - Bridges to `SessionStore` and `APIHandler.config`.
- `Utility/CBSessionStore` (SessionStore):
  - Holds `accessToken`, `tokenExpiry` and computed `isTokenExpired`.
- `Utility/CommonUI/BaseVC/SessionTimerManager.swift`:
  - 1-second timer with `remainingSeconds`; posts `sessionTimerDidTick` notification each tick; used by facade to surface expiry.
 - Language:
   - `SplashVC` switches language using `CBSDKLanguageHandler.sharedInstance` based on `args.languageCode` ("en" or "bn").
   - `BaseViewController` conforms to `CBSDKLanguageDelegate` to react to language changes and updates UI elements (e.g., timer label) accordingly.

## UI Modules
- Splash:
  - Drives entry verification and routes to next screen according to flow.
- PIN Setup:
  - UI for setting PIN; calls facade APIs. PIN plaintext sent to `WebServiceHandler` where it is encrypted.
- Change PIN, Forget PIN, OTP Verification, Welcome/TnC:
  - Feature-specific VCs & views; all should hold `weak var coordinator: Coordinating?` for navigation.

## CPQRC (QR Payment) Flow

- **Validate-first routing**
  - `SplashVC.routeAfterVerification()` calls `coordinator.startCpqrcFlow(from:)` for `.CPQRC`.
  - `MainCoordinator.startCpqrcFlow(from:)` → `CashBabaSDK.cpqrcValidate(paymentReference:)`.
  - On success, `CBSDKDataStorage.shared.cpqrcValidationData` is populated (contains `transactionId`, `otpExpirySeconds`, `isFaceVerificationRequired`, etc.).
  - Branch:
    - If `isFaceVerificationRequired == true` → `startFaceKYC(from:)`.
    - Else → `navigate(.verifyOTP(.cpqrcPayment))` directly.

- **Face KYC (only when required)**
  - Launched by coordinator via `CBFaceDetectionSDK` with `CBFaceDetectionSDKDelegate` retained by `MainCoordinator`.
  - On `images(smile:blink:)`:
    - Persist file paths to `CBSDKDataStorage.shared.smileFacePath` and `.blinkFacePath`.
    - Navigate to `.verifyOTP(.cpqrcPayment)` (no re-validation; already done at entry).
  - On `userCancelled` → `closeSDKSuccess()`.
  - On `errorOccured` → `CashBabaSDK.shared.closeSdkOnFailed(error)` then `coordinator.closeSDK(withError:)`.

- **OTP Verification screen (Verify + Resend)**
  - `OTPVerificationVC` for `.cpqrcPayment`:
    - Starts OTP countdown UI (validation already occurred).
    - Verify action:
      - Reads `transactionId` from `CBSDKDataStorage.shared.cpqrcValidationData?.transactionId`.
      - Optionally loads `smile`/`blink` image `Data` from stored file paths.
      - Calls `CashBabaSDK.cpqrcConfirm(transactionId:otp:smileImage:blinkImage:)`.
      - On success: optionally calls `cpqrcVerify(paymentReference:)`, then `coordinator.closeSDKSuccess()`.
    - Resend action:
      - Requires `transactionId` from validation data.
      - Calls `CashBabaSDK.cpqrcResendOtp(transactionId:)`.
      - On success: resets and restarts timer.

- **Endpoints (iOS ↔ Android parity)**
  - Validate: GET `v1/transaction/CPQRCPaymentValidation/{paymentReference}`.
  - Confirm: POST multipart `v1/transaction/CPQRCPaymentConfirm` with fields:
    - Text: `TransactionId`, `Otp`.
    - Files (optional): `SmileImage`, `BlinkImage` (filename + MIME; JPEG/PNG supported).
  - Verify status: GET `v1/transaction/CPQRCPaymentStatus/{paymentReference}`.
  - Resend OTP: GET `v1/transaction/ResendTransactionOTP/{transactionId}`.

- **Data storage**
  - `CBSDKDataStorage.shared.cpqrcValidationData` (from validate) drives routing and provides `transactionId`.
  - `smileFacePath`/`blinkFacePath` persist until confirmation is attempted.

- **Error handling**
  - Fatal HTTP (401/444/500/501) are closed centrally by `APIHandler` (facade forwards `onFailed`).
  - Non-fatal errors are surfaced to VC to show inline UI (e.g., popup) without closing SDK.
  - Coordinator ensures user-driven cancellation routes through `closeSDKSuccess()` to trigger `onUserCancel`.

## Error Handling
- Errors funnel through `SDKError` with factories (`unauthorized`, `network`, `server`, etc.).
- APIHandler centralizes FATAL closures only for: 401, 444, 500, 501.
  - These trigger `CashBabaSDK.shared.closeSdkOnFailed(message)`; host should dismiss UI via `SDKPresenter`/Coordinator wrapping.
- Non-fatal errors (e.g., 400/404/409/422) are surfaced to the caller without closing:
  - `WebServiceHandler` decodes to specific response model (or `BaseResponse`) and completes with `.failure`.
  - ViewControllers (e.g., `PINSetupVC`, `OTPVerificationVC`) display inline UI (popup/alert/label) and keep SDK open.
- Facade dispatches completions on main thread for UI safety.

### When does the SDK close?
- Centralized close conditions (from APIHandler):
  - 401 Unauthorized
  - 444 Business-fatal
  - 500/501 Server errors
- UI-initiated close:
  - Coordinator `closeSDK(withError:)` to dismiss and forward `onFailed`.
  - Coordinator `closeSDKSuccessWithResult(_:)` to dismiss and then call `onSuccess` with the success payload (used on HTTP 200 success for PIN flows).
  - Coordinator `closeSDKSuccess()` to dismiss and call `onUserCancel` (used for user-initiated back/close without payload).

### Screen-level handling examples
- PINSetupVC:
  - Success (200) → build `OnSuccessModel` and call `coordinator?.closeSDKSuccessWithResult(...)` (no success popup).
  - Failure (non-fatal) → show `CBErrorVC` popup; do not close SDK.
- ChangePINVC:
  - Success (200) → build `OnSuccessModel` and call `coordinator?.closeSDKSuccessWithResult(...)` (no success popup).
  - Failure (non-fatal) → show `CBErrorVC` popup; do not close SDK.
- OTPVerificationVC:
  - Mirrored behavior with PINSetupVC for verify/resend flows (non-fatal errors shown inline).

### Back navigation and callbacks (CoordinatorAccessible)
- Base rule: closing the SDK must route through the Coordinator so `onUserCancel`/`onFailed`/`onSuccess` fire back to the host app appropriately.
- Implementation pattern:
  - Protocol in `Routes.swift`:
    - `public protocol CoordinatorAccessible { var coordinator: Coordinating? { get } }`
  - All SDK VCs should conform and expose `weak var coordinator: Coordinating?`.
  - `BaseViewController.backButtonTapped()` logic:
    - If not root: `navigationController.popViewController(animated: true)`.
    - If root and `CoordinatorAccessible`: call helper `coordinatorCloseSDKSuccess()` which invokes `coordinator?.closeSDKSuccess()`.
    - Fallback: `dismiss(animated: true)` then invoke `CashBabaSDK.shared.onUserCancel?()`.
- Outcome: ExternalVC receives callbacks consistently; success flows use `closeSDKSuccessWithResult(_:)` to emit `onSuccess` with payload.

## Flow Scopes & Headers
- Scope header is set automatically in facade per flow.
- `wToken` must be set before protected flows; per-flow overloads set it automatically.
- `lang` header is kept in sync with `APIHandler.config.languageCode`.

## Session Expiry
- On auth success, `SessionTimerManager` starts with `expiresIn`.
- Facade also starts a one-shot timer and observes tick notifications.
- When expired, fires `onFailed("Session expired")` and the UI is expected to dismiss via coordinator.

## Extensibility To-Dos
- Confirm OTP field key casing with backend and adjust if needed.
- Adjust `SDKStartRouteDecider` mapping for TRANSFER/PAYMENT/CPQRC to exact entry screens.
- Ensure all VCs include `coordinator` property and transition via coordinator.
- Optional: add logging switches and retry/backoff, and unit tests with a mock transport.

## Quick Usage
```swift
// Load PEM and init SDK once
try CashBabaSDK.shared.initialize(environment: .demo, languageCode: "en", pemResourceName: "publickey.pem")

// Present SDK from host
let args = NavigationArgs(
  type: .SET_PIN,
  wToken: "<w-token>",
  languageCode: "en",
  environment: .demo,
  clientId: "cb_merchant_sdk",
  clientSecret: "Abcd@1234"
)
SDKPresenter.present(from: hostController, args: args, onSuccess: { result in
  // handle success
}, onFailed: { failure in
  // show failure.errorMessage
}, onUserCancel: {
  // user closed
})
```

