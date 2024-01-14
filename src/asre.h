#include <filesystem>
#include <atomic>
#include <thread>
#include <queue>

#include <emscripten/bind.h>
#include <emscripten/wasmfs.h>
#include <emscripten/console.h>
#include <emscripten.h>
#include <AL/al.h>
#include <AL/alc.h>
#include <archive.h>
#include <archive_entry.h>
#include <vosk_api.h>

namespace fs = std::filesystem;
using namespace emscripten;
struct Message {
  int type{}; // 0: ready, 1: partialResult, 2: result, 3: done
  const std::string content{};
  Message(int type, const std::string content) : type(type), content(std::move(content)) {};
  Message(int type): type(type) {};
};
class ASRE {
  VoskRecognizer* recognizer{};
  ALCdevice* mic{};
  std::atomic_flag done {false};
  std::atomic_flag controller{false};
  static bool extractModel(const char* target, const char* destination);
  static bool checkModel(const std::string& path);
  void main();
public:
  ASRE(std::string url, const float sampleRate, const bool refetch);
  void start();
  void stop();
  void deinit();
  std::queue<Message> msgQueue{};
};

EMSCRIPTEN_BINDINGS() {
  class_<ASRE>("__ASRE__") // Export as __ASRE__ to hide from user
  .constructor<std::string, const float, const bool>(allow_raw_pointers())
  .function("start", &ASRE::start, allow_raw_pointers())
  .function("stop", &ASRE::stop, allow_raw_pointers())
  .function("deinit", &ASRE::deinit, allow_raw_pointers());
}