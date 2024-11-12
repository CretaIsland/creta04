import 'package:creta_studio_model/model/contents_model.dart';
import 'package:hycop_multi_platform/common/util/logger.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:io' as file_io;

import 'drop_zone_widget.dart';

extension UploadExt on DropZoneWidgetState {
  Future<ContentsModel> uploadedFile(dynamic event, String bookMid) async {
    // this method is called when user drop the file in drop area in flutter
    //if (kIsWeb) {
    file_io.File file = event as file_io.File;
    final name = event.path;
    final mime = await controller.getFileMIME(event);
    final byte = await controller.getFileSize(event);
    final url = await controller.createFileUrl(event);
    //final blob = await controller.getFileData(event);

    logger.fine('Name : $name');
    logger.fine('Mime: $mime');

    logger.fine('Size : ${byte / (1024 * 1024)}');
    logger.fine('URL: $url');

    // update the data model with recent file uploaded
    final droppedFile = ContentsModel.withFileDynamic(widget.parentId, bookMid,
        name: name, mime: mime, bytes: byte, url: url, event: file);
    //Update the UI
    return droppedFile;
  }
}
