#include "asre.h"


void extract() {
  std::string path{"opfs/"};
  archive* src {archive_read_new()};
  archive_entry* entry {};
  archive_read_support_filter_all(src);
  archive_read_support_format_all(src);
  archive_read_open_filename(src,"opfs/model.tzst",10240);
  while (archive_read_next_header(src, &entry) == ARCHIVE_OK) {
    path+= archive_entry_pathname(entry);
    archive_entry_set_pathname(entry, path.c_str());
    path="opfs/";
    archive_read_extract(src, entry, ARCHIVE_EXTRACT_UNLINK);
  }
  archive_read_free(src);
}
bool check() { //For now it just check for the files
  return fs::exists("opfs/model/am/final.mdl") &&
    fs::exists("opfs/model/conf/mfcc.conf") &&
    fs::exists("opfs/model/conf/model.conf") &&
    fs::exists("opfs/model/graph/phones/word_boundary.int") &&
    fs::exists("opfs/model/graph/Gr.fst") &&
    fs::exists("opfs/model/graph/HCLr.fst") &&
    fs::exists("opfs/model/graph/disambig_tid.int") &&
    fs::exists("opfs/model/ivector/final.dubm") &&
    fs::exists("opfs/model/ivector/final.ie") &&
    fs::exists("opfs/model/ivector/final.mat") &&
    fs::exists("opfs/model/ivector/global_cmvn.stats") && 
    fs::exists("opfs/model/ivector/online_cmvn.conf") &&
    fs::exists("opfs/model/ivector/splice.conf");
} 
int main() {
  Backend* opfs {wasmfs_create_opfs_backend()};
    wasmfs_create_directory("opfs", 0777, opfs);
    if(!check()) {
      if(emscripten_wget("assets/model.tzst","opfs/model.tzst") == 1) {
        emscripten_console_errorf("Unable to fetch");
        return 1;
      }
      extract();
      fs::remove("opfs/model.tzst");
    }
    VoskModel* model {vosk_model_new("opfs/model")};
    VoskRecognizer* rec {vosk_recognizer_new(model, static_cast<float>(MAIN_THREAD_EM_ASM_INT({
      ctx = new (window.AudioContext || window.webkitAudioContext)();
      sr = ctx.sampleRate;
      ctx.close();
      return sr;
    })))};
    vosk_recognizer_free(rec);
    emscripten_console_log("WE DID IT!");
}
