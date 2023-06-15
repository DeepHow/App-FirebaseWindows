#ifndef FLUTTER_PLUGIN_UTILS_H_
#define FLUTTER_PLUGIN_UTILS_H_

#include <iostream>

namespace firebase_windows {

class Utils {
 public:
  static void LogD(const char* format, ...);

  static void LogE(const char* format, ...);

  Utils() = delete;

  virtual ~Utils() = delete;

  // Disallow copy and assign.
  Utils(const Utils&) = delete;
  Utils& operator=(const Utils&) = delete;

 private:
  inline static const std::string TAG = "[C++] ";
};

}  // namespace firebase_windows

#endif  // FLUTTER_PLUGIN_UTILS_H_
