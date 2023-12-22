#include <emscripten/wasmfs.h>
#include <emscripten.h>
#include <emscripten/console.h>
#include <archive.h>
#include <archive_entry.h>
void extractModel(const char* filename) {
  archive* src {archive_read_new()};
  archive_entry* entry {};
  archive_read_support_filter_all(src);
  archive_read_support_format_all(src);
  archive_read_open_filename(src, filename, 10240);
  emscripten_console_log(archive_error_string(src));
  archive_read_free(src);
  return;
  while (archive_read_next_header(src, &entry))
  {
    archive_read_extract(src, entry, ARCHIVE_EXTRACT_UNLINK);
  }
}
void onerror(const char* filename) {
  emscripten_console_errorf("Couldn't fetch to %s", filename);
}
int main() {
  Backend* opfs {wasmfs_create_opfs_backend()};
  wasmfs_create_directory("opfs", 0777, opfs);
  emscripten_async_wget("../model.tzst", "opfs/model.tzst", extractModel, onerror);
}