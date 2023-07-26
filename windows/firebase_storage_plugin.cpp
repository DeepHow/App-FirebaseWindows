#include "firebase_plugin_registry.h"
#include "firebase_storage_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h"
#include "firebase/auth.h"
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
using ::firebase::storage::Controller;
using ::firebase::storage::Error;
using ::firebase::storage::Listener;
using ::firebase::storage::Metadata;
using ::firebase::storage::Storage;
using ::firebase::storage::StorageReference;

namespace firebase_windows {
namespace {

const std::string kFirebaseStorageChannelName = "plugins.flutter.io/firebase_storage";

std::unique_ptr<
    flutter::MethodChannel<flutter::EncodableValue>,
    std::default_delete<
        flutter::MethodChannel<
            flutter::EncodableValue>>> channel = nullptr;

}  // namespace

#define STORAGE_ERROR \
    X(kErrorNone, "none") \
    X(kErrorUnknown, "unknown") \
    X(kErrorObjectNotFound, "object-not-found") \
    X(kErrorBucketNotFound, "bucket-not-found") \
    X(kErrorProjectNotFound, "project-not-found") \
    X(kErrorQuotaExceeded, "quota-exceeded") \
    X(kErrorUnauthenticated, "unauthenticated") \
    X(kErrorUnauthorized, "unauthorized") \
    X(kErrorRetryLimitExceeded, "retry-limit-exceeded") \
    X(kErrorNonMatchingChecksum, "invalid-checksum") \
    X(kErrorDownloadSizeExceeded, "download-size-exceeded") \
    X(kErrorCancelled, "canceled")

#define X(a, b) a,
enum StorageError { STORAGE_ERROR };
#undef X

#define X(a, b) b,
char* ErrorCode[] { STORAGE_ERROR };
#undef X

const char* GetStorageErrorName(StorageError code) {
  return ErrorCode[code];
}

class TaskListener : public Listener {
 public:
  TaskListener(const int &handle) : handle_(handle) {}
  virtual ~TaskListener() = default;

  void OnProgress(Controller* controller) {
    channel->InvokeMethod(
        "Task#onProgress",
        std::make_unique<flutter::EncodableValue>(
            FirebaseStoragePlugin::ParseTaskState(controller, handle_)));
  }
  
  void OnPaused(Controller* controller) {
    channel->InvokeMethod(
        "Task#onPaused",
        std::make_unique<flutter::EncodableValue>(
            FirebaseStoragePlugin::ParseTaskState(controller, handle_)));
  }
  
  void OnSuccess(const Metadata* metadata) {
    channel->InvokeMethod(
        "Task#onSuccess",
        std::make_unique<flutter::EncodableValue>(
            FirebaseStoragePlugin::ParseTaskState(metadata, handle_)));
  }

 private:
  const int handle_;
};

// static
flutter::EncodableMap FirebaseStoragePlugin::ParseTaskState(
    const Controller* controller, const int &handle) {
  auto reference = controller->GetReference();
  return ParseTaskState(
      &reference,
      controller->bytes_transferred(),
      controller->total_byte_count(),
      handle);
}

// static
flutter::EncodableMap FirebaseStoragePlugin::ParseTaskState(
    const Metadata* metadata, const int &handle) {
  auto reference = metadata->GetReference();
  return ParseTaskState(
      &reference, metadata->size_bytes(), metadata->size_bytes(), handle);
}

// static
flutter::EncodableMap FirebaseStoragePlugin::ParseTaskState(
    const StorageReference *reference_ptr,
    const int64_t &bytes_transferred,
    const int64_t &total_bytes,
    const int &handle) {
  auto reference = *reference_ptr;
  auto output = flutter::EncodableMap::map();

  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("snapshot"),
      flutter::EncodableValue(ParseTaskSnapshot(
          bytes_transferred, total_bytes, reference.full_path()))));
  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("appName"),
      flutter::EncodableValue(reference.storage()->app()->name())));
  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("bucket"),
      flutter::EncodableValue(reference.bucket().c_str())));
  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("handle"),
      flutter::EncodableValue(handle)));

  return output;
}

// static
flutter::EncodableMap FirebaseStoragePlugin::ParseTaskSnapshot(
    const int64_t &bytes_transferred,
    const int64_t &total_bytes,
    const std::string &path) {
  auto output = flutter::EncodableMap::map();

  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("bytesTransferred"),
      flutter::EncodableValue(bytes_transferred)));
  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("totalBytes"),
      flutter::EncodableValue(total_bytes)));
  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("path"),
      flutter::EncodableValue(path.c_str())));

  return output;
}

flutter::EncodableMap FirebaseStoragePlugin::ParseTaskError(
    const int &handle) {
  auto output = flutter::EncodableMap::map();

  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("handle"),
      flutter::EncodableValue(handle)));

  return output;
}

flutter::EncodableMap FirebaseStoragePlugin::ParseTaskError(
    const std::string &error_code,
    const std::string &error_message,
    const int &handle) {
  auto output = flutter::EncodableMap::map();

  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("error"),
      flutter::EncodableValue(ParseErrorDetails(error_code, error_message))));
  output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
      flutter::EncodableValue("handle"),
      flutter::EncodableValue(handle)));

  return output;
}

flutter::EncodableMap FirebaseStoragePlugin::ParseErrorDetails(
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

// static
void FirebaseStoragePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), kFirebaseStorageChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FirebaseStoragePlugin>();

  auto firebase_plugin = plugin.get();
  FirebasePluginRegistry::getInstance()
      .RegisterFirebasePlugin(*firebase_plugin);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
    plugin_pointer->HandleMethodCall(call, std::move(result));
  });

  registrar->AddPlugin(std::move(plugin));
}

FirebaseStoragePlugin::FirebaseStoragePlugin() {}

FirebaseStoragePlugin::~FirebaseStoragePlugin() {}

flutter::EncodableMap FirebaseStoragePlugin::PluginConstantsForFIRApp(
    App* app) {
  return flutter::EncodableMap::map();
}

std::string FirebaseStoragePlugin::FlutterChannelName() {
  return kFirebaseStorageChannelName;
}

void FirebaseStoragePlugin::ReferenceGetDownloadURL(
    const flutter::EncodableMap *arguments,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto *app_name = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("appName"))->second));
  auto *bucket = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("bucket"))->second));
  auto *path = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("path"))->second));

  Utils::LogD(
      "Calling Storage::ReferenceGetDownloadURL()..., app_name: %s, bucket: %s, path: %s",
      app_name->c_str(), bucket->c_str(), path->c_str());

  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> shared_result =
      std::move(result);
  App *app = App::GetInstance(app_name->c_str());
  Storage *storage = Storage::GetInstance(app);
  StorageReference ref = storage->GetReference(path->c_str());

  Future<std::string> future = ref.GetDownloadUrl();
  future.OnCompletion(
      [&, result=shared_result](const Future<std::string> &completed_future) {
    if (completed_future.error() == 0) {
      Utils::LogD("  Storage::ReferenceGetDownloadURL() completed.");
      auto output = flutter::EncodableMap::map();
      output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
          flutter::EncodableValue("downloadURL"),
          flutter::EncodableValue(completed_future.result()->c_str())));
      result->Success(output);
    } else {
      Utils::LogE(
          "  Storage::ReferenceGetDownloadURL() completed with error: %d, `%s`",
          completed_future.error(), completed_future.error_message());
      const char *error_code = GetStorageErrorName(
          static_cast<StorageError>(completed_future.error()));
      result->Error(
          error_code,
          completed_future.error_message(),
          ParseErrorDetails(error_code, completed_future.error_message()));
    }
  });
}

void FirebaseStoragePlugin::TaskStartPutFile(
    const flutter::EncodableMap *arguments,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto *app_name = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("appName"))->second));
  auto *bucket = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("bucket"))->second));
  auto *handle_ptr = std::get_if<int32_t>(
      &(arguments->find(flutter::EncodableValue("handle"))->second));
  int handle = *handle_ptr;
  auto *path = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("path"))->second));
  auto *filePath = std::get_if<std::string>(
      &(arguments->find(flutter::EncodableValue("filePath"))->second));
  auto *metadata = std::get_if<flutter::EncodableMap>(
      &(arguments->find(flutter::EncodableValue("metadata"))->second));

  // Metadata
  auto *cache_control = std::get_if<std::string>(
      &(metadata->find(flutter::EncodableValue("cacheControl"))->second));
  auto *content_disposition = std::get_if<std::string>(
      &(metadata->find(flutter::EncodableValue("contentDisposition"))->second));
  auto *content_encoding = std::get_if<std::string>(
      &(metadata->find(flutter::EncodableValue("contentEncoding"))->second));
  auto *content_language = std::get_if<std::string>(
      &(metadata->find(flutter::EncodableValue("contentLanguage"))->second));
  auto *content_type = std::get_if<std::string>(
      &(metadata->find(flutter::EncodableValue("contentType"))->second));

  Utils::LogD(
      "Calling Storage::TaskStartPutFile()..., app_name: %s, bucket: %s, path: %s, filePath: %s, handle: %d",
      app_name->c_str(), bucket->c_str(), path->c_str(), filePath->c_str(), handle);

  App *app = App::GetInstance(app_name->c_str());
  Storage *storage = Storage::GetInstance(app);
  StorageReference ref = storage->GetReference(path->c_str());

  Metadata metadata_;
  if (cache_control) metadata_.set_cache_control(cache_control->c_str());
  if (content_disposition) metadata_.set_content_disposition(content_disposition->c_str());
  if (content_encoding) metadata_.set_content_encoding(content_encoding->c_str());
  if (content_language) metadata_.set_content_language(content_language->c_str());
  if (content_type) metadata_.set_content_type(content_type->c_str());

  TaskListener *listener = new TaskListener(handle);
  Controller *controller = new Controller();
  task_controllers.insert(std::pair<int, Controller*>(handle, controller));

  Future<Metadata> future = ref.PutFile(
      filePath->c_str(), metadata_, listener, controller);
  future.OnCompletion(
      [&, listener, handle](const Future<Metadata> &completed_future) {
    if (completed_future.error() == 0) {
      Utils::LogD("  Storage::TaskStartPutFile() completed.");
      listener->OnSuccess(completed_future.result());
    } else {
      Utils::LogE(
          "  Storage::TaskStartPutFile() completed with error: %d, `%s`",
          completed_future.error(), completed_future.error_message());

      if (completed_future.error() == Error::kErrorCancelled) {
        channel->InvokeMethod(
            "Task#onCanceled",
            std::make_unique<flutter::EncodableValue>(ParseTaskError(handle)));
      } else {
        const char *error_code = GetStorageErrorName(
            static_cast<StorageError>(completed_future.error()));
        channel->InvokeMethod(
            "Task#onFailure",
            std::make_unique<flutter::EncodableValue>(ParseTaskError(
                error_code,
                completed_future.error_message(),
                handle)));
      }
    }
    task_controllers.erase(handle);
  });

  result->Success();
}

void FirebaseStoragePlugin::TaskCancel(
    const flutter::EncodableMap *arguments,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto *handle_ptr = std::get_if<int32_t>(
      &(arguments->find(flutter::EncodableValue("handle"))->second));
  int handle = *handle_ptr;
  Utils::LogD("Calling Storage::TaskCancel()..., handle: %d", handle);

  auto output = flutter::EncodableMap::map();

  auto iterator = task_controllers.find(handle);
  if (iterator != task_controllers.end()) {
    Controller *controller = iterator->second;
    auto bytes_transferred = controller->bytes_transferred();
    auto total_bytes = controller->total_byte_count();
    auto reference = controller->GetReference();
    output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
        flutter::EncodableValue("status"),
        flutter::EncodableValue(controller->Cancel())));
    output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
        flutter::EncodableValue("snapshot"),
        flutter::EncodableValue(ParseTaskSnapshot(
            bytes_transferred, total_bytes, reference.full_path()))));
  } else {
    Utils::LogE("  Storage::TaskCancel() controller not found");
    output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
        flutter::EncodableValue("status"),
        flutter::EncodableValue(false)));
  }

  result->Success(flutter::EncodableValue(output));
}

void FirebaseStoragePlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare(
      "Reference#getDownloadURL") == 0) {
    ReferenceGetDownloadURL(
        std::get_if<flutter::EncodableMap>(method_call.arguments()),
        std::move(result));
  } else if (method_call.method_name().compare(
      "Task#startPutFile") == 0) {
    TaskStartPutFile(
        std::get_if<flutter::EncodableMap>(method_call.arguments()),
        std::move(result));
  } else if (method_call.method_name().compare(
      "Task#cancel") == 0) {
    TaskCancel(
        std::get_if<flutter::EncodableMap>(method_call.arguments()),
        std::move(result));
  } else {
    result->NotImplemented();
  }
}

}  // namespace firebase_windows
