import 'dart:typed_data';

import 'pdf_download_mobile.dart'
    if (dart.library.html) 'pdf_download_web.dart';

Future<void> downloadPdf({
  required Uint8List bytes,
  required String filename,
}) async {
  await downloadPdfPlatform(
    bytes: bytes,
    filename: filename,
  );
}