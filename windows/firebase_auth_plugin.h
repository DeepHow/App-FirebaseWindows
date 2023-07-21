#ifndef FLUTTER_PLUGIN_FIREBASE_AUTH_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_AUTH_PLUGIN_H_

#include "firebase/auth.h"

#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace firebase_windows {

class FirebaseAuthPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FirebaseAuthPlugin();

  virtual ~FirebaseAuthPlugin();

  // Disallow copy and assign.
  FirebaseAuthPlugin(const FirebaseAuthPlugin&) = delete;
  FirebaseAuthPlugin& operator=(const FirebaseAuthPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  static flutter::EncodableMap ParseFirebaseUser(
      const firebase::auth::User *user);

  static flutter::EncodableMap ParseUserCredential(
      const firebase::auth::User *user);

 private:
  flutter::EncodableMap ParseTokenResult(const std::string *token);

  flutter::EncodableMap ParseErrorDetails(const std::string &error_code,
                                          const std::string &error_message);

  void RegisterIdTokenListener(
      const flutter::EncodableMap *arguments,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void RegisterAuthStateListener(
      const flutter::EncodableMap *arguments,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void SignInWithCredential(
      const flutter::EncodableMap *arguments,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void SignInWithCustomToken(
      const flutter::EncodableMap *arguments,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void SignInWithEmailAndPassword(
      const flutter::EncodableMap *arguments,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void SignOut(
      const flutter::EncodableMap *arguments,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void GetIdToken(
      const flutter::EncodableMap *arguments,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace firebase_windows

#endif  // FLUTTER_PLUGIN_FIREBASE_AUTH_PLUGIN_H_
