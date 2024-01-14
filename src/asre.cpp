#include "asre.h"
bool ASRE::extractModel(const char* target, const char* destination) {
  std::string dst{destination};
  dst += "/";
  archive* src {archive_read_new()};
  archive_entry* entry {};
  archive_read_support_filter_all(src);
  archive_read_support_format_all(src);
  archive_read_open_filename(src, target,22480);
  if(archive_errno(src) != 0) return false;
  while (archive_read_next_header(src, &entry) == ARCHIVE_OK) {
    dst+= archive_entry_pathname(entry);
    archive_entry_set_pathname(entry, dst.c_str());
    dst=destination;
    dst+="/";
    if(archive_errno(src) != 0) return false;
    archive_read_extract(src, entry, ARCHIVE_EXTRACT_UNLINK);
  }
  archive_read_free(src);
  return true;
}
bool ASRE::checkModel(const std::string& path) {
  return fs::exists(path + "/am/final.mdl") &&
    fs::exists(path + "/conf/mfcc.conf") &&
    fs::exists(path + "/conf/model.conf") &&
    fs::exists(path + "/graph/phones/word_boundary.int") &&
    fs::exists(path + "/graph/Gr.fst") &&
    fs::exists(path + "/graph/HCLr.fst") &&
    fs::exists(path + "/graph/disambig_tid.int") &&
    fs::exists(path + "/ivector/final.dubm") &&
    fs::exists(path + "/ivector/final.ie") &&
    fs::exists(path + "/ivector/final.mat") &&
    fs::exists(path + "/ivector/global_cmvn.stats") && 
    fs::exists(path + "/ivector/online_cmvn.conf") &&
    fs::exists(path + "/ivector/splice.conf");
} 
void ASRE::start() {
  this->controller.test_and_set(std::memory_order_relaxed);
  this->controller.notify_all();
}
void ASRE::stop() {
  this->controller.clear(std::memory_order_relaxed);
  this->controller.notify_all();
}
void ASRE::deinit() {
  this->done.test_and_set(std::memory_order_relaxed);
  this->done.notify_all();
  this->stop();
}
ASRE::ASRE(std::string url, const float sampleRate, const bool refetch) {
  this->mic = alcCaptureOpenDevice("Emscripten OpenAL capture",static_cast<int>(sampleRate), AL_FORMAT_MONO16, 22480);
  if(alcGetError(this->mic) != 0) {
    emscripten_console_error("Unable to initialize microphone");
    return;
  }
  std::thread t{[this](const std::string& url, const float sampleRate, const bool refetch){
    if(wasmfs_create_directory("opfs", 0777, wasmfs_create_opfs_backend()) != 0) {
      emscripten_console_error("Unable to initialize OPFS backend");
      return;
    }
    if(!this->checkModel("opfs/model") || refetch) {
      if(emscripten_wget(url.c_str(), "opfs/model.tzst") == 1) {
        emscripten_console_errorf("Unable to fetch: %s", url.c_str());
        return;
      }
      this->extractModel("opfs/model.tzst", "opfs");
      fs::remove("opfs/model.tzst");
    }
    vosk_set_log_level(-1);
    this->recognizer = vosk_recognizer_new(vosk_model_new("opfs/model"), sampleRate);
    if(this->recognizer == nullptr) {
      emscripten_console_error("Unable to initialize recognizer");
      return;
    } 
    this->main();
  },std::move(url), sampleRate, refetch};
  t.detach();
}
void ASRE::main() {
  char buffer[22480];
  int sample{};
  while(!this->done.test()) {
    this->msgQueue.emplace(0);
    this->controller.wait(this->done.test(std::memory_order_relaxed), std::memory_order_relaxed);
    alcCaptureStart(this->mic);
    while(this->controller.test()) {
      alcGetIntegerv(this->mic, ALC_CAPTURE_SAMPLES, sizeof(int), &sample);
      alcCaptureSamples(this->mic, buffer, sample);
      switch(vosk_recognizer_accept_waveform(this->recognizer, buffer, 22480)) {
        case 0: 
          this->msgQueue.emplace(2, vosk_recognizer_result(this->recognizer));
          break;
        case 1: 
          this->msgQueue.emplace(1, vosk_recognizer_partial_result(this->recognizer));
          break;
        default:
          emscripten_console_error("Recognition error");
      }
    }
    alcCaptureStop(this->mic);
  }
  vosk_recognizer_free(this->recognizer);
  alcCaptureCloseDevice(this->mic);
  this->msgQueue.emplace(3);
}