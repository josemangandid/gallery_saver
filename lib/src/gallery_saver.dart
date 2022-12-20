
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

typedef DownloadProgress = void Function(
    int total, int downloaded, double progress);


class GallerySaver {

  static const String _channelName = 'gallery_saver';

  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<bool> downloadFile(
      String url, FileType fileType, String path, String albumName, bool toDcim, DownloadProgress downloadProgress) async {
    bool isCompleted = false;
    final completer = Completer<Uint8List>();
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    final response = client.send(request);
    int downloadedBytes = 0;
    List<List<int>> chunkList = [];

    response.asStream().listen((http.StreamedResponse streamedResponse) {
      streamedResponse.stream.listen((chunk) {
        final contentLength = streamedResponse.contentLength ?? 0;
        final progress = (downloadedBytes / contentLength) * 100;
        downloadProgress(contentLength, downloadedBytes, progress);

        chunkList.add(chunk);
        downloadedBytes += chunk.length;
      },
          onDone: (){
            final contentLength = streamedResponse.contentLength ?? 0;
            final progress = (downloadedBytes / contentLength) + 100;
            downloadProgress(contentLength, downloadedBytes, progress);
            int start = 0;
            final bytes = Uint8List(contentLength);

            for(var chunk in chunkList){
              bytes.setRange(start, start + chunk.length, chunk);
              start += chunk.length;
            }

            completer.complete(bytes);
          },
          onError: (error) => completer.completeError(error));
    });

    isCompleted = await _saveFile(await completer.future, path, fileType, albumName, toDcim );
    return isCompleted;
  }

  static Future<bool> _saveFile(Uint8List  bytes, String path, FileType fileType, String albumName, bool toDcim) async {
    File file = File(path);
    await file.writeAsBytes(bytes);
    String fileMethod = "";
    switch(fileType){
      case FileType.video:
        fileMethod = "saveVideo";
        break;
      case FileType.image:
        fileMethod = "saveImage";
        break;
      default:
        fileMethod = "saveVideo";
    }
    return await _channel.invokeMethod(
      fileMethod,
      <String, dynamic>{'path': path, 'albumName': albumName, 'toDcim': toDcim},
    ) ?? false;
  }

}