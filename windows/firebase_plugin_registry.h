#ifndef FLUTTER_PLUGIN_FIREBASE_PLUGIN_REGISTRY_H_
#define FLUTTER_PLUGIN_FIREBASE_PLUGIN_REGISTRY_H_

#include "firebase_plugin.h"

#include <flutter/encodable_value.h>

namespace firebase_windows {

class FirebasePluginRegistry {
 public:
  FirebasePluginRegistry(const FirebasePluginRegistry&) = delete;
  FirebasePluginRegistry& operator=(const FirebasePluginRegistry&) = delete;

  /**
   * Get the singleton instance of the plugin registry.
   *
   * @return FirebasePluginRegistry&
   */
  static FirebasePluginRegistry& getInstance();

  /**
   * Register a FlutterFire plugin with the plugin registry.
   *
   * @param firebase_plugin FirebasePlugin&
   */
  void RegisterFirebasePlugin(FirebasePlugin& firebase_plugin);
  
  /**
   * Each FlutterFire plugin implementing FirebasePlugin provides this method,
   * allowing it's constants to be initialized during
   * FirebaseCore.initializeApp in Dart. Here we call this method on each of
   * the registered plugins and gather their constants for use in Dart.
   *
   * Constants for specific plugins are stored using the Flutter plugins channel
   * name as the key.
   *
   * @param app Firebase App instance these constants relate to.
   * @return flutter::EncodableMap Map of plugins and their constants.
   */
  flutter::EncodableMap PluginConstantsForFIRApp(firebase::App* app);

 private:
  FirebasePluginRegistry() = default;

  std::map<std::string, FirebasePlugin*> registered_plugins;
};

}  // namespace firebase_windows

#endif  // FLUTTER_PLUGIN_FIREBASE_PLUGIN_REGISTRY_H_
