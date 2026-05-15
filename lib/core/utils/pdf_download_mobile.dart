import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadPdfPlatform({
  required Uint8List bytes,
  required String filename,
}) async {
  try {
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');

    await file.writeAsBytes(bytes);

    final result = await OpenFilex.open(file.path);

    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  } catch (e) {
    throw Exception('Failed to open PDF: $e');
  }
}