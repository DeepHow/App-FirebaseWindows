// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "firebase_core_plugin.h"
#include "firebase_plugin_registry.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h"
#include "firebase/auth.h"
#include "firebase/storage.h"
#include "firebase/util.h"
#include "messages.g.h"
#include "utils.h"

#include <flutter/plugin_registrar_windows.h>

#include <future>
#include <iostream>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

using ::firebase::App;
using ::firebase::auth::Auth;
using ::firebase::storage::Storage;

namespace firebase_windows {

// static
void FirebaseCorePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<FirebaseCorePlugin>();

  FirebaseCoreHostApi::SetUp(registrar->messenger(), plugin.get());
  FirebaseAppHostApi::SetUp(registrar->messenger(), plugin.get());

  auto firebase_plugin = plugin.get();
  FirebasePluginRegistry::getInstance()
      .RegisterFirebasePlugin(*firebase_plugin);

  registrar->AddPlugin(std::move(plugin));
}

FirebaseCorePlugin::FirebaseCorePlugin() {}

FirebaseCorePlugin::~FirebaseCorePlugin() = default;

// Convert a Pigeon FirebaseOptions to a Firebase Options.
firebase::AppOptions PigeonFirebaseOptionsToAppOptions(
    const PigeonFirebaseOptions &pigeon_options) {
  firebase::AppOptions options;
  options.set_api_key(pigeon_options.api_key().c_str());
  options.set_app_id(pigeon_options.app_id().c_str());
  if (pigeon_options.database_u_r_l() != nullptr) {
    options.set_database_url(pigeon_options.database_u_r_l()->c_str());
  }
  if (pigeon_options.tracking_id() != nullptr) {
    options.set_ga_tracking_id(pigeon_options.tracking_id()->c_str());
  }
  options.set_messaging_sender_id(pigeon_options.messaging_sender_id().c_str());

  options.set_project_id(pigeon_options.project_id().c_str());

  if (pigeon_options.storage_bucket() != nullptr) {
    options.set_storage_bucket(pigeon_options.storage_bucket()->c_str());
  }
  return options;
}

// Convert a AppOptions to PigeonInitializeOption
PigeonFirebaseOptions optionsFromFIROptions(
    const firebase::AppOptions &options) {
  PigeonFirebaseOptions pigeon_options = PigeonFirebaseOptions();
  pigeon_options.set_api_key(options.api_key());
  pigeon_options.set_app_id(options.app_id());
  if (options.database_url() != nullptr) {
    pigeon_options.set_database_u_r_l(options.database_url());
  }
  pigeon_options.set_tracking_id(nullptr);
  pigeon_options.set_messaging_sender_id(options.messaging_sender_id());
  pigeon_options.set_project_id(options.project_id());
  if (options.storage_bucket() != nullptr) {
    pigeon_options.set_storage_bucket(options.storage_bucket());
  }
  return pigeon_options;
}

// Convert a firebase::App to PigeonInitializeResponse
PigeonInitializeResponse AppToPigeonInitializeResponse(const App &app) {
  PigeonInitializeResponse response = PigeonInitializeResponse();
  response.set_name(app.name());
  response.set_options(optionsFromFIROptions(app.options()));
  response.set_plugin_constants(
      FirebasePluginRegistry::getInstance()
      .PluginConstantsForFIRApp(App::GetInstance(app.name())));
  return response;
}

flutter::EncodableMap FirebaseCorePlugin::PluginConstantsForFIRApp(App* app) {
  return flutter::EncodableMap::map();
}

std::string FirebaseCorePlugin::FlutterChannelName() {
  return "dev.flutter.pigeon.FirebaseCoreHostApi.initializeApp";
}

void FirebaseCorePlugin::InitializeApp(
    const std::string &app_name,
    const PigeonFirebaseOptions &initialize_app_request,
    std::function<void(ErrorOr<PigeonInitializeResponse> reply)> result) {
  // Create an app
  App *app;
  app = App::Create(PigeonFirebaseOptionsToAppOptions(initialize_app_request),
                    app_name.c_str());

  // Use ModuleInitializer to initialize Firebase modules, ensuring no
  // dependencies are missing.
  const firebase::ModuleInitializer::InitializerFn initializers[] = {
      [](::firebase::App* app, void*) {
        Utils::LogD("Attempt to initialize Firebase Auth.");
        ::firebase::InitResult init_result;
        Auth::GetAuth(app, &init_result);
        return init_result;
      },
      [](::firebase::App* app, void*) {
        Utils::LogD("Attempt to initialize Cloud Storage.");
        ::firebase::InitResult init_result;
        Storage::GetInstance(app, &init_result);
        return init_result;
      }
  };

  ::firebase::ModuleInitializer initializer;
  initializer.Initialize(app, nullptr, initializers,
                         sizeof(initializers) / sizeof(initializers[0]));
                         
  initializer.InitializeLastResult().OnCompletion(
      [result, app](const ::firebase::Future<void> &completed_future) {
        // Send back the result to Flutter
        result(AppToPigeonInitializeResponse(*app));
      });
}

void FirebaseCorePlugin::InitializeCore(
    std::function<void(ErrorOr<flutter::EncodableList> reply)> result) {
  // TODO: Missing function to get the list of currently initialized apps
  std::vector<PigeonInitializeResponse> initializedApps;

  flutter::EncodableList encodableList;

  // Insert the contents of the vector into the EncodableList
  // for (const auto &item : initializedApps) {
  //  encodableList.push_back(flutter::EncodableValue(item));
  //}
  result(flutter::EncodableList());
}

void FirebaseCorePlugin::OptionsFromResource(
    std::function<void(ErrorOr<PigeonFirebaseOptions> reply)> result) {}

void FirebaseCorePlugin::SetAutomaticDataCollectionEnabled(
    const std::string &app_name, bool enabled,
    std::function<void(std::optional<FlutterError> reply)> result) {
  App *firebaseApp = App::GetInstance(app_name.c_str());
  if (firebaseApp != nullptr) {
    // TODO: Missing method
  }
  result(std::nullopt);
}

void FirebaseCorePlugin::SetAutomaticResourceManagementEnabled(
    const std::string &app_name, bool enabled,
    std::function<void(std::optional<FlutterError> reply)> result) {
  App *firebaseApp = App::GetInstance(app_name.c_str());
  if (firebaseApp != nullptr) {
    // TODO: Missing method
  }

  result(std::nullopt);
}

void FirebaseCorePlugin::Delete(
    const std::string &app_name,
    std::function<void(std::optional<FlutterError> reply)> result) {
  App *firebaseApp = App::GetInstance(app_name.c_str());
  if (firebaseApp != nullptr) {
    // TODO: Missing method
  }

  result(std::nullopt);
}

}  // namespace firebase_windows
