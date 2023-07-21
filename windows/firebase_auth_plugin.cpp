#include "firebase_auth_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h"
#include "utils.h"

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

using ::firebase::App;
using ::firebase::Future;
using ::firebase::auth::Auth;
using ::firebase::auth::Credential;
using ::firebase::auth::OAuthProvider;
using ::firebase::auth::User;

namespace firebase_windows {

const std::string kFirebaseAuthChannelName = "plugins.flutter.io/firebase_auth";

flutter::BinaryMessenger *binaryMessenger_ = nullptr;

#define AUTH_ERROR \
    X(kAuthErrorNone, = 0, "none") \
    X(kAuthErrorUnimplemented, = -1, "unimplemented") \
    X(kAuthErrorFailure, = 1, "failure") \
    X(kAuthErrorInvalidCustomToken, = 2, "invalid-custom-token") \
    X(kAuthErrorCustomTokenMismatch, = 3, "custom-token-mismatch") \
    X(kAuthErrorInvalidCredential, = 4, "invalid-credential") \
    X(kAuthErrorUserDisabled, = 5, "user-disabled") \
    X(kAuthErrorAccountExistsWithDifferentCredentials, = 6, "account-exists-with-different-credentials") \
    X(kAuthErrorOperationNotAllowed, = 7, "operation-not-allowed") \
    X(kAuthErrorEmailAlreadyInUse, = 8, "email-already-in-use") \
    X(kAuthErrorRequiresRecentLogin, = 9, "requires-recent-login") \
    X(kAuthErrorCredentialAlreadyInUse, = 10, "credential-already-in-use") \
    X(kAuthErrorInvalidEmail, = 11, "invalid-email") \
    X(kAuthErrorWrongPassword, = 12, "wrong-password") \
    X(kAuthErrorTooManyRequests, = 13, "too-many-requests") \
    X(kAuthErrorUserNotFound, = 14, "user-not-found") \
    X(kAuthErrorProviderAlreadyLinked, = 15, "provider-already-linked") \
    X(kAuthErrorNoSuchProvider, = 16, "no-such-provider") \
    X(kAuthErrorInvalidUserToken, = 17, "invalid-user-token") \
    X(kAuthErrorUserTokenExpired, = 18, "user-token-expired") \
    X(kAuthErrorNetworkRequestFailed, = 19, "network-request-failed") \
    X(kAuthErrorInvalidApiKey, = 20, "invalid-api-key") \
    X(kAuthErrorAppNotAuthorized, = 21, "app-not-authorized") \
    X(kAuthErrorUserMismatch, = 22, "user-mismatch") \
    X(kAuthErrorWeakPassword, = 23, "weak-password") \
    X(kAuthErrorNoSignedInUser, = 24, "no-signed-in-user") \
    X(kAuthErrorApiNotAvailable, = 25, "api-not-available") \
    X(kAuthErrorExpiredActionCode, = 26, "expired-action-code") \
    X(kAuthErrorInvalidActionCode, = 27, "invalid-action-code") \
    X(kAuthErrorInvalidMessagePayload, = 28, "invalid-message-payload") \
    X(kAuthErrorInvalidPhoneNumber, = 29, "invalid-phone-number") \
    X(kAuthErrorMissingPhoneNumber, = 30, "missing-phone-number") \
    X(kAuthErrorInvalidRecipientEmail, = 31, "invalid-recipient-email") \
    X(kAuthErrorInvalidSender, = 32, "invalid-sender") \
    X(kAuthErrorInvalidVerificationCode, = 33, "invalid-verification-code") \
    X(kAuthErrorInvalidVerificationId, = 34, "invalid-verification-id") \
    X(kAuthErrorMissingVerificationCode, = 35, "missing-verification-code") \
    X(kAuthErrorMissingVerificationId, = 36, "missing-verification-id") \
    X(kAuthErrorMissingEmail, = 37, "missing-email") \
    X(kAuthErrorMissingPassword, = 38, "missing-password") \
    X(kAuthErrorQuotaExceeded, = 39, "quota-exceeded") \
    X(kAuthErrorRetryPhoneAuth, = 40, "retry-phone-auth") \
    X(kAuthErrorSessionExpired, = 41, "session-expired") \
    X(kAuthErrorAppNotVerified, = 42, "app-not-verified") \
    X(kAuthErrorAppVerificationFailed, = 43, "app-verification-failed") \
    X(kAuthErrorCaptchaCheckFailed, = 44, "captcha-check-failed") \
    X(kAuthErrorInvalidAppCredential, = 45, "invalid-app-credential") \
    X(kAuthErrorMissingAppCredential, = 46, "missing-app-credential") \
    X(kAuthErrorInvalidClientId, = 47, "invalid-client-id") \
    X(kAuthErrorInvalidContinueUri, = 48, "invalid-continue-uri") \
    X(kAuthErrorMissingContinueUri, = 49, "missing-continue-uri") \
    X(kAuthErrorKeychainError, = 50, "keychain-error") \
    X(kAuthErrorMissingAppToken, = 51, "missing-app-token") \
    X(kAuthErrorMissingIosBundleId, = 52, "missing-ios-bundle-id") \
    X(kAuthErrorNotificationNotForwarded, = 53, "notification-not-forwarded") \
    X(kAuthErrorUnauthorizedDomain, = 54, "unauthorized-domain") \
    X(kAuthErrorWebContextAlreadyPresented, = 55, "web-context-already-presented") \
    X(kAuthErrorWebContextCancelled, = 56, "web-context-cancelled") \
    X(kAuthErrorDynamicLinkNotActivated, = 57, "dynamic-link-not-activated") \
    X(kAuthErrorCancelled, = 58, "cancelled") \
    X(kAuthErrorInvalidProviderId, = 59, "invalid-provider-id") \
    X(kAuthErrorWebInternalError, = 60, "web-internal-error") \
    X(kAuthErrorWebStorateUnsupported, = 61, "web-storate-unsupported") \
    X(kAuthErrorTenantIdMismatch, = 62, "tenant-id-mismatch") \
    X(kAuthErrorUnsupportedTenantOperation, = 63, "unsupported-tenant-operation") \
    X(kAuthErrorInvalidLinkDomain, = 64, "invalid-link-domain") \
    X(kAuthErrorRejectedCredential, = 65, "rejected-credential") \
    X(kAuthErrorPhoneNumberNotFound, = 66, "phone-number-not-found") \
    X(kAuthErrorInvalidTenantId, = 67, "invalid-tenant-id") \
    X(kAuthErrorMissingClientIdentifier, = 68, "missing-client-identifier") \
    X(kAuthErrorMissingMultiFactorSession, = 69, "missing-multi-factor-session") \
    X(kAuthErrorMissingMultiFactorInfo, = 70, "missing-multi-factor-info") \
    X(kAuthErrorInvalidMultiFactorSession, = 71, "invalid-multi-factor-session") \
    X(kAuthErrorMultiFactorInfoNotFound, = 72, "multi-factor-info-not-found") \
    X(kAuthErrorAdminRestrictedOperation, = 73, "admin-restricted-operation") \
    X(kAuthErrorUnverifiedEmail, = 74, "unverified-email") \
    X(kAuthErrorSecondFactorAlreadyEnrolled, = 75, "second-factor-already-enrolled") \
    X(kAuthErrorMaximumSecondFactorCountExceeded, = 76, "maximum-second-factor-count-exceeded") \
    X(kAuthErrorUnsupportedFirstFactor, = 77, "unsupported-first-factor") \
    X(kAuthErrorEmailChangeNeedsVerification, = 78, "email-change-needs-verification") \
    X(kAuthErrorInvalidEventHandler, = 79, "invalid-event-handler") \
    X(kAuthErrorFederatedProviderAreadyInUse, = 80, "federated-provider-aready-in-use") \
    X(kAuthErrorInvalidAuthenticatedUserData, = 81, "invalid-authenticated-user-data") \
    X(kAuthErrorFederatedSignInUserInteractionFailure, = 82, "federated-sign-in-user-interaction-failure") \
    X(kAuthErrorMissingOrInvalidNonce, = 83, "missing-or-invalid-nonce") \
    X(kAuthErrorUserCancelled, = 84, "user-cancelled") \
    X(kAuthErrorUnsupportedPassthroughOperation, = 85, "unsupported-passthrough-operation") \
    X(kAuthErrorTokenRefreshUnavailable, = 86, "token-refresh-unavailable")

#define X(a, b, c) a b,
enum AuthError { AUTH_ERROR };
#undef X

const char* GetAuthErrorName(AuthError value) {
  static std::map<AuthError, const char*> table;
  static bool isInit = false;
  if (isInit)
    return table[value];

  #define X(a, b, c) table[a] = c;
  AUTH_ERROR
  #undef X

  isInit = true;
  return table[value];
}

class AuthStateChangeListener : public firebase::auth::AuthStateListener {
 public:
  AuthStateChangeListener() = default;

  virtual void OnAuthStateChanged(Auth* auth) {  // NOLINT
    const User *user = auth->current_user();
    if (user) {
      Utils::LogD(
          "OnAuthStateChanged, current_user is '%s'",
          user->display_name().c_str());
      if (events_) {
        events_->Success(FirebaseAuthPlugin::ParseUserCredential(user));
      }
    } else {
      Utils::LogD("OnAuthStateChanged, current_user is null");
      if (events_) {
        events_->Success(
            flutter::EncodableValue(flutter::EncodableMap::map()));
      }
    }
  }

  void SetEventSink(
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
    events_ = std::move(events);
  }

 private:
  std::unique_ptr<
      flutter::EventSink<flutter::EncodableValue>>&& events_ = nullptr;
};

class IdTokenChangeListener : public firebase::auth::IdTokenListener {
 public:
  IdTokenChangeListener() = default;

  virtual void OnIdTokenChanged(Auth* auth) {  // NOLINT
    User *user = auth->current_user();
    if (user) {
      Utils::LogD(
          "OnIdTokenChanged, current_user is '%s'",
          user->display_name().c_str());
      if (events_) {
        events_->Success(FirebaseAuthPlugin::ParseUserCredential(user));
      }
    } else {
      Utils::LogD("OnIdTokenChanged, current_user is null");
      if (events_) {
        events_->Success(
            flutter::EncodableValue(flutter::EncodableMap::map()));
      }
    }
  }

  void SetEventSink(
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
    events_ = std::move(events);
  }

 private:
  std::unique_ptr<
      flutter::EventSink<flutter::EncodableValue>>&& events_ = nullptr;
};

template <typename T = flutter::EncodableValue>
class AuthStateChannelStreamHandler : public flutter::StreamHandler<T> {
 public:
  AuthStateChannelStreamHandler(Auth *auth) : auth_(auth) {}
  virtual ~AuthStateChannelStreamHandler() = default;

  virtual std::unique_ptr<flutter::StreamHandlerError<T>> OnListenInternal(
      const T* arguments,
      std::unique_ptr<flutter::EventSink<T>>&& events) override {
    listener_.SetEventSink(std::move(events));
    auth_->AddAuthStateListener(&listener_);
    return nullptr;
  }

  virtual std::unique_ptr<flutter::StreamHandlerError<T>> OnCancelInternal(
      const T* arguments) override {
    if (&listener_) {
      auth_->RemoveAuthStateListener(&listener_);
    }
    (void)listener_;
    return nullptr;
  }

 private:
  Auth *auth_;
  AuthStateChangeListener listener_;
};

template <typename T = flutter::EncodableValue>
class IdTokenChannelStreamHandler : public flutter::StreamHandler<T> {
 public:
  IdTokenChannelStreamHandler(Auth *auth) : auth_(auth) {}
  virtual ~IdTokenChannelStreamHandler() = default;

  virtual std::unique_ptr<flutter::StreamHandlerError<T>> OnListenInternal(
      const T* arguments,
      std::unique_ptr<flutter::EventSink<T>>&& events) override {
    listener_.SetEventSink(std::move(events));
    auth_->AddIdTokenListener(&listener_);
    return nullptr;
  }

  virtual std::unique_ptr<flutter::StreamHandlerError<T>> OnCancelInternal(
      const T* arguments) override {
    if (&listener_) {
      auth_->RemoveIdTokenListener(&listener_);
    }
    (void)listener_;
    return nullptr;
  }

 private:
  Auth *auth_;
  IdTokenChangeListener listener_;
};

// static
void FirebaseAuthPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  binaryMessenger_ = registrar->messenger();
  
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), kFirebaseAuthChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FirebaseAuthPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FirebaseAuthPlugin::FirebaseAuthPlugin() {}

FirebaseAuthPlugin::~FirebaseAuthPlugin() {}

flutter::EncodableMap FirebaseAuthPlugin::ParseFirebaseUser(const User *user) {
  auto output = flutter::EncodableMap::map();
  auto metadata = flutter::EncodableMap::map();

  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("displayName"),
      flutter::EncodableValue(user->display_name().c_str())));
  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("email"),
      flutter::EncodableValue(user->email().c_str())));
  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("emailVerified"),
      flutter::EncodableValue(user->is_email_verified())));
  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("isAnonymous"),
      flutter::EncodableValue(user->is_anonymous())));

  int64_t creation_timestamp = static_cast<std::make_signed_t<uint64_t>>(
      user->metadata().creation_timestamp);
  int64_t last_sign_in_timestamp = static_cast<std::make_signed_t<uint64_t>>(
      user->metadata().last_sign_in_timestamp);

  metadata.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("creationTime"),
      flutter::EncodableValue(creation_timestamp)));
  metadata.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("lastSignInTime"),
      flutter::EncodableValue(last_sign_in_timestamp)));

  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("metadata"),
      flutter::EncodableValue(metadata)));
  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("providerData"),
      flutter::EncodableValue(flutter::EncodableList())));
  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("uid"),
      flutter::EncodableValue(user->uid().c_str())));

  return output;
}

flutter::EncodableMap FirebaseAuthPlugin::ParseUserCredential(
    const User *user) {
  auto output = flutter::EncodableMap::map();

  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("user"),
      flutter::EncodableValue(ParseFirebaseUser(user))));

  return output;
}

flutter::EncodableMap FirebaseAuthPlugin::ParseTokenResult(
    const std::string *token) {
  auto output = flutter::EncodableMap::map();

  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("token"),
      flutter::EncodableValue(token->c_str())));

  return output;
}

flutter::EncodableMap FirebaseAuthPlugin::ParseErrorDetails(
    const std::string &error_code,
    const std::string &error_message) {
  auto output = flutter::EncodableMap::map();

  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("code"),
      flutter::EncodableValue(error_code.c_str())));
  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("message"),
      flutter::EncodableValue(error_message.c_str())));

  return output;
}

void FirebaseAuthPlugin::RegisterIdTokenListener(
    const flutter::EncodableMap *arguments,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto *app_name = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("appName"))->second));

  const std::string name = kFirebaseAuthChannelName + "/id-token/" + app_name->c_str();

  auto channel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
      binaryMessenger_, name, &flutter::StandardMethodCodec::GetInstance());

  App *app = App::GetInstance(app_name->c_str());
  auto handler = new IdTokenChannelStreamHandler<>(Auth::GetAuth(app));
  auto _obj_stm_handle =
      static_cast<flutter::StreamHandler<flutter::EncodableValue>*>(handler);
  std::unique_ptr<flutter::StreamHandler<flutter::EncodableValue>> _ptr {_obj_stm_handle};
  channel->SetStreamHandler(std::move(_ptr));

  result->Success(flutter::EncodableValue(name));
}

void FirebaseAuthPlugin::RegisterAuthStateListener(
    const flutter::EncodableMap *arguments,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto *app_name = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("appName"))->second));

  const std::string name = kFirebaseAuthChannelName + "/auth-state/" + app_name->c_str();

  auto channel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
      binaryMessenger_, name, &flutter::StandardMethodCodec::GetInstance());

  App *app = App::GetInstance(app_name->c_str());
  auto handler = new AuthStateChannelStreamHandler<>(Auth::GetAuth(app));
  auto _obj_stm_handle =
      static_cast<flutter::StreamHandler<flutter::EncodableValue>*>(handler);
  std::unique_ptr<flutter::StreamHandler<flutter::EncodableValue>> _ptr {_obj_stm_handle};
  channel->SetStreamHandler(std::move(_ptr));

  result->Success(flutter::EncodableValue(name));
}

void FirebaseAuthPlugin::SignInWithCredential(
    const flutter::EncodableMap *arguments,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto *app_name = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("appName"))->second));
  auto *credential = std::get_if<flutter::EncodableMap>(
      &(arguments->find(flutter::EncodableValue("credential"))->second));

  auto *provider_id = std::get_if<std::string>(
      &(credential->find(flutter::EncodableValue("providerId"))->second));
  auto *id_token = std::get_if<std::string>(
      &(credential->find(flutter::EncodableValue("idToken"))->second));
  auto *access_token = std::get_if<std::string>(
      &(credential->find(flutter::EncodableValue("accessToken"))->second));
  Utils::LogD(
      "Calling Auth::SignInWithCredential()..., app_name: %s, provider_id: %s,\tid_token: %s,\taccess_token: %s",
      app_name->c_str(), provider_id->c_str(), id_token->c_str(), access_token->c_str());

  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> shared_result =
      std::move(result);
  App *app = App::GetInstance(app_name->c_str());
  Auth *auth = Auth::GetAuth(app);

  Credential oauth_credential = OAuthProvider::GetCredential(
      provider_id->c_str(), id_token->c_str(), access_token->c_str());
  Future<User*> future = auth->SignInWithCredential(oauth_credential);
  future.OnCompletion(
      [&, result=shared_result](const Future<User*> &completed_future) {
    if (completed_future.error() == 0) {
      const User* user = *(completed_future.result());
      Utils::LogD(
          "  Current user uid(%s) name(%s) already signed in.",
          user->uid().c_str(), user->display_name().c_str());
      result->Success(flutter::EncodableValue(ParseUserCredential(user)));
    } else {
      Utils::LogE(
          "  Auth::SignInWithCredential() completed with error: %d, `%s`",
          completed_future.error(), completed_future.error_message());
      const char *error_code = GetAuthErrorName(
          static_cast<AuthError>(completed_future.error()));
      result->Error(
          error_code,
          completed_future.error_message(),
          ParseErrorDetails(error_code, completed_future.error_message()));
    }
  });
}

void FirebaseAuthPlugin::SignInWithCustomToken(
    const flutter::EncodableMap *arguments,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto *app_name = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("appName"))->second));
  auto *token = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("token"))->second));
  Utils::LogD(
      "Calling Auth::SignInWithCustomToken()..., app_name: %s, token: %s",
      app_name->c_str(), token->c_str());
  
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> shared_result =
      std::move(result);
  App *app = App::GetInstance(app_name->c_str());
  Auth *auth = Auth::GetAuth(app);

  Future<User*> future = auth->SignInWithCustomToken(token->c_str());
  future.OnCompletion(
      [&, result=shared_result](const Future<User*> &completed_future) {
    if (completed_future.error() == 0) {
      const User* user = *(completed_future.result());
      Utils::LogD(
          "  Current user uid(%s) name(%s) already signed in.",
          user->uid().c_str(), user->display_name().c_str());
      result->Success(flutter::EncodableValue(ParseUserCredential(user)));
    } else {
      Utils::LogE(
          "  Auth::SignInWithCustomToken() completed with error: %d, `%s`",
          completed_future.error(), completed_future.error_message());
      const char *error_code = GetAuthErrorName(
          static_cast<AuthError>(completed_future.error()));
      result->Error(
          error_code,
          completed_future.error_message(),
          ParseErrorDetails(error_code, completed_future.error_message()));
    }
  });
}

void FirebaseAuthPlugin::SignInWithEmailAndPassword(
    const flutter::EncodableMap *arguments,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto *app_name = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("appName"))->second));
  auto *email = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("email"))->second));
  auto *password = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("password"))->second));
  Utils::LogD(
      "Calling Auth::SignInWithEmailAndPassword()..., app_name: %s, email: %s, password: %s",
      app_name->c_str(), email->c_str(), password->c_str());

  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> shared_result =
      std::move(result);
  App *app = App::GetInstance(app_name->c_str());
  Auth *auth = Auth::GetAuth(app);

  Future<User*> future =
      auth->SignInWithEmailAndPassword(email->c_str(), password->c_str());
  future.OnCompletion(
      [&, result=shared_result](const Future<User*> &completed_future) {
    if (completed_future.error() == 0) {
      const User* user = *(completed_future.result());
      Utils::LogD(
          "  Current user uid(%s) name(%s) already signed in.",
          user->uid().c_str(), user->display_name().c_str());
      result->Success(flutter::EncodableValue(ParseUserCredential(user)));
    } else {
      Utils::LogE(
          "  Auth::SignInWithEmailAndPassword() completed with error: %d, `%s`",
          completed_future.error(), completed_future.error_message());
      const char *error_code = GetAuthErrorName(
          static_cast<AuthError>(completed_future.error()));
      result->Error(
          error_code,
          completed_future.error_message(),
          ParseErrorDetails(error_code, completed_future.error_message()));
    }
  });
}

void FirebaseAuthPlugin::SignOut(const flutter::EncodableMap *arguments,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto *app_name = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("appName"))->second));
  Utils::LogD("Calling Auth::SignOut()..., app_name: %s",
      app_name->c_str());

  App *app = App::GetInstance(app_name->c_str());
  Auth *auth = Auth::GetAuth(app);

  auth->SignOut();
  result->Success();
}

void FirebaseAuthPlugin::GetIdToken(const flutter::EncodableMap *arguments,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto *app_name = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("appName"))->second));
  auto *force_refresh_ptr = std::get_if<bool>(
      &(arguments->find(flutter::EncodableValue("forceRefresh"))->second));
  bool force_refresh = *(force_refresh_ptr);
  Utils::LogD(
      "Calling User::GetToken()..., app_name: %s, force_refresh: %s",
      app_name->c_str(), force_refresh ? "true" : "false");

  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> shared_result =
      std::move(result);
  App *app = App::GetInstance(app_name->c_str());
  Auth *auth = Auth::GetAuth(app);

  Future<std::string> future = auth->current_user()->GetToken(force_refresh);
  future.OnCompletion(
      [&, result=shared_result](const Future<std::string> &completed_future) {
    if (completed_future.error() == 0) {
      result->Success(flutter::EncodableValue(
          ParseTokenResult(completed_future.result())));
    } else {
      Utils::LogE(
          "  User::GetToken() completed with error: %d, `%s`",
          completed_future.error(), completed_future.error_message());
      const char *error_code = GetAuthErrorName(
          static_cast<AuthError>(completed_future.error()));
      result->Error(
          error_code,
          completed_future.error_message(),
          ParseErrorDetails(error_code, completed_future.error_message()));
    }
  });
}

void FirebaseAuthPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare(
      "Auth#registerIdTokenListener") == 0) {
    RegisterIdTokenListener(
        std::get_if<flutter::EncodableMap>(method_call.arguments()),
        std::move(result));
  } else if (method_call.method_name().compare(
      "Auth#registerAuthStateListener") == 0) {
    RegisterAuthStateListener(
        std::get_if<flutter::EncodableMap>(method_call.arguments()),
        std::move(result));
  } else if (method_call.method_name().compare(
      "Auth#signInWithCredential") == 0) {
    SignInWithCredential(
        std::get_if<flutter::EncodableMap>(method_call.arguments()),
        std::move(result));
  } else if (method_call.method_name().compare(
      "Auth#signInWithCustomToken") == 0) {
    SignInWithCustomToken(
        std::get_if<flutter::EncodableMap>(method_call.arguments()),
        std::move(result));
  } else if (method_call.method_name().compare(
      "Auth#signInWithEmailAndPassword") == 0) {
    SignInWithEmailAndPassword(
        std::get_if<flutter::EncodableMap>(method_call.arguments()),
        std::move(result));
  } else if (method_call.method_name().compare(
      "Auth#signOut") == 0) {
    SignOut(
        std::get_if<flutter::EncodableMap>(method_call.arguments()),
        std::move(result));
  } else if (method_call.method_name().compare(
      "User#getIdToken") == 0) {
    GetIdToken(
        std::get_if<flutter::EncodableMap>(method_call.arguments()),
        std::move(result));
  } else {
    result->NotImplemented();
  }
}

}  // namespace firebase_windows
