#include "firebase_plugin_registry.h"

namespace firebase_windows {

// static
FirebasePluginRegistry& FirebasePluginRegistry::getInstance() {
  static FirebasePluginRegistry instance;
  return instance;
}

void FirebasePluginRegistry::RegisterFirebasePlugin(
    FirebasePlugin& firebase_plugin) {
  // Store the plugin delegate for later usage.
  registered_plugins.insert(std::pair<std::string, FirebasePlugin*>(
      firebase_plugin.FlutterChannelName(), &firebase_plugin));
}

flutter::EncodableMap FirebasePluginRegistry::PluginConstantsForFIRApp(
    firebase::App* app) {
  auto output = flutter::EncodableMap::map();
  for (std::pair<const std::string, FirebasePlugin*> plugin_pair :
       registered_plugins) {
    auto plugin = plugin_pair.second;
    output.insert(std::pair<flutter::EncodableValue, flutter::EncodableValue>(
        flutter::EncodableValue(plugin->FlutterChannelName().c_str()),
        flutter::EncodableValue(plugin->PluginConstantsForFIRApp(app))));
  }
  return output;
}

}  // namespace firebase_windows
