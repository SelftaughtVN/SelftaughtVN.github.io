#include <filesystem>
#include <atomic>
#include <string_view>
#include <thread>

#include <emscripten/wasmfs.h>
#include <emscripten/console.h>
#include <AL/al.h>
#include <AL/alc.h>
#include <libarchive/include>

namespace fs = std::filesystem;
using namespace emscripten;
class ASRE {
  VoskRecognizer* recognizer{};
  ALCDevice* mic{};
  atomic_flag done{false};
  atomic_flag control{};
  std::vector<std::string_view> msgQueue
public:

}