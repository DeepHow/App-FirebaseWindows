#ifndef FLUTTER_PLUGIN_FIREBASE_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_PLUGIN_H_

#include "firebase/app.h"

#include <flutter/encodable_value.h>

namespace firebase_windows {

class FirebasePlugin {
 public:
  FirebasePlugin(const FirebasePlugin&) = delete;
  FirebasePlugin& operator=(const FirebasePlugin&) = delete;
  virtual ~FirebasePlugin() {}
  
  /**
   * FlutterFire plugins implementing FirebasePlugin must provide this
   * method to provide it's constants that are initialized during
   * FirebaseCore.initializeApp in Dart.
   *
   * @param app A helper providing application context and methods for
   *     registering callbacks.
   */
  virtual flutter::EncodableMap PluginConstantsForFIRApp(
      firebase::App* app) = 0;

  /**
   * FlutterFire plugins implementing FirebasePlugin must provide this method
   * to provide its main method channel name, used by
   * FirebaseCore.initializeApp in Dart to identify constants specific to a
   * plugin.
   */
  virtual std::string FlutterChannelName() = 0;

 protected:
  FirebasePlugin() = default;
};

}  // namespace firebase_windows

#endif  // FLUTTER_PLUGIN_FIREBASE_PLUGIN_H_
