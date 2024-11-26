//import 'package:flutter/cupertino.dart';
// ignore: avoid_web_libraries_in_flutter
import 'upload_file_io.dart' if (dart.library.html) 'upload_file_web.dart';

import 'package:creta04/design_system/uploading_popup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:hycop_multi_platform/common/util/logger.dart';

import 'package:creta_studio_model/model/contents_model.dart';
//import 'package:dotted_border/dotted_border.dart';

class DropZoneWidget extends StatefulWidget {
  final ValueChanged<List<ContentsModel>> onDroppedFile;
  final String bookMid;
  final String parentId;
  final Widget? child;
  final Color bgColor;

  const DropZoneWidget(
      {super.key,
      required this.onDroppedFile,
      required this.bookMid,
      required this.parentId,
      this.child,
      this.bgColor = Colors.black});
  @override
  DropZoneWidgetState createState() => DropZoneWidgetState();
}

class DropZoneWidgetState extends State<DropZoneWidget> {
  //controller to hold data of file dropped by user
  late DropzoneViewController controller;
  // a variable just to update UI color when user hover or leave the drop zone
  bool highlight = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final colorBackground = highlight ? widget.bgColor : Colors.transparent;
    //return ClipRRect(
    //child:
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (kIsWeb)
          IgnorePointer(
            //child: SizedBox.shrink(),
            child: DropzoneView(
              onCreated: (controller) => this.controller = controller,
              //onDrop: uploadedFile,
              onDropMultiple: (list) async {
                if (list == null) return;
                logger.fine('onDropMultiple -------------- ${list.length}');
                List<ContentsModel> contentsList = [];
                UploadingPopup.setUploadFileCount(list.length);
                for (var event in list.reversed) {
                  logger.fine('onDropMultiple -------------- ${event.name}');
                  contentsList.add(await uploadedFile(event, widget.bookMid));
                }

                widget.onDroppedFile(contentsList);
                setState(() {
                  highlight = false;
                });
              },
              onHover: () => setState(() => highlight = true),
              onLeave: () => setState(() => highlight = false),
              onLoaded: () => logger.fine('Zone Loaded'),
              onError: (err) => logger.fine('run when error found : $err'),
            ),
          ),
        if (highlight) IgnorePointer(child: Container(color: colorBackground.withOpacity(0.25))),
      ],
      //),
    );
  }

  // Future<ContentsModel> uploadedFile(dynamic event, String bookMid) async {
  //   // this method is called when user drop the file in drop area in flutter
  //   //if (kIsWeb) {
  //   file_io.File file = event as file_io.File;
  //   final name = event.name;
  //   final mime = await controller.getFileMIME(event);
  //   final byte = await controller.getFileSize(event);
  //   final url = await controller.createFileUrl(event);
  //   //final blob = await controller.getFileData(event);

  //   logger.fine('Name : $name');
  //   logger.fine('Mime: $mime');

  //   logger.fine('Size : ${byte / (1024 * 1024)}');
  //   logger.fine('URL: $url');

  //   // update the data model with recent file uploaded
  //   final droppedFile = ContentsModel.withFileDynamic(widget.parentId, bookMid,
  //       name: name, mime: mime, bytes: byte, url: url, event: file);
  //   //Update the UI
  //   return droppedFile;
  // }
  //}
}
