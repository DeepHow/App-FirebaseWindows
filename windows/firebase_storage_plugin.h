#ifndef FLUTTER_PLUGIN_FIREBASE_STORAGE_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_STORAGE_PLUGIN_H_

#include "firebase/storage.h"

#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace firebase_windows {

class FirebaseStoragePlugin : public flutter::Plugin {
 public:
  std::map<int, ::firebase::storage::Controller*> task_controllers;

  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FirebaseStoragePlugin();

  virtual ~FirebaseStoragePlugin();

  // Disallow copy and assign.
  FirebaseStoragePlugin(const FirebaseStoragePlugin&) = delete;
  FirebaseStoragePlugin& operator=(const FirebaseStoragePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  static flutter::EncodableMap ParseTaskState(
      const ::firebase::storage::Controller* controller,
      const int &handle);

  static flutter::EncodableMap ParseTaskState(
      const ::firebase::storage::Metadata* metadata,
      const int &handle);

 private:
  static flutter::EncodableMap ParseTaskState(
      const ::firebase::storage::StorageReference *reference_ptr,
      const int64_t &bytes_transferred,
      const int64_t &total_bytes,
      const int &handle);

  static flutter::EncodableMap ParseTaskSnapshot(
      const int64_t &bytes_transferred,
      const int64_t &total_bytes,
      const std::string &path);

  flutter::EncodableMap ParseTaskError(const int &handle);

  flutter::EncodableMap ParseTaskError(
      const std::string &error_code,
      const std::string &error_message,
      const int &handle);

  flutter::EncodableMap ParseErrorDetails(
      const std::string &error_code,
      const std::string &error_message);

  void ReferenceGetDownloadURL(
      const flutter::EncodableMap *arguments,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void TaskStartPutFile(
      const flutter::EncodableMap *arguments,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void TaskCancel(
      const flutter::EncodableMap *arguments,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace firebase_windows

#endif  // FLUTTER_PLUGIN_FIREBASE_STORAGE_PLUGIN_H_
