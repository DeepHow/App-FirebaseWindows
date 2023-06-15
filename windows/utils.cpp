#include "utils.h"

#include <stdarg.h>

namespace firebase_windows {

void Utils::LogD(const char* format, ...) {
  #ifdef _DEBUG
    std::string fmt = TAG + format;
    va_list list;
    va_start(list, format);
    vprintf(fmt.c_str(), list);
    va_end(list);
    printf("\n");
    fflush(stdout);
  #endif
}

void Utils::LogE(const char* format, ...) {
  std::string fmt = TAG + "Error: " + format;
  va_list list;
  va_start(list, format);
  vprintf(fmt.c_str(), list);
  va_end(list);
  printf("\n");
  fflush(stdout);
}

}  // namespace firebase_windows
