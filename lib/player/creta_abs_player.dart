// ignore_for_file: prefer_final_fields
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:blobs/blobs.dart';
import 'package:hycop_multi_platform/common/util/logger.dart';
import 'package:hycop_multi_platform/hycop/absModel/abs_ex_model.dart';

import '../data_io/contents_manager.dart';
import 'package:creta_common/model/app_enums.dart';
import 'package:creta_studio_model/model/contents_model.dart';

import '../pages/studio/book_main_page.dart';
import '../pages/studio/studio_variables.dart';

// Image 의 progress bar 전진을 위한 도구
ProgressNotifier? progressHolder;

class ProgressNotifier extends ChangeNotifier {
  double progress = 0.0;
  String mid = '';
  void setProgress(double val, String pmid) {
    progress = val;
    mid = pmid;
    notifyListeners();
  }
}

// ignore: must_be_immutable
abstract class CretaAbsPlayer extends ChangeNotifier {
  final String keyString;
  final ContentsModel? model;
  final ContentsManager acc;

  //BasicOverayWidget? videoProgress;

  CretaAbsPlayer({
    required this.keyString,
    required this.onAfterEvent,
    required this.acc,
    this.model,
    //this.videoProgress,
  });

  Future<void> Function(Duration, Duration)? onAfterEvent;

  void notify() => notifyListeners();

  Future<bool> init() async {
    return true;
  } // video player only

  Future<void> play({bool byManual = false}) async {}
  Future<void> pause({bool byManual = false}) async {}
  Future<void> resume({bool byManual = false}) async {}

  Future<void> globalPause() async {}
  Future<void> globalResume() async {}

  Future<void> mute() async {}
  Future<void> setSound(double val) async {}
  Future<void> resumeSound() async {}
  void stop() {}
  Future<void> next() async {}
  Future<void> prev() async {}
  Future<void> rewind() async {}
  Future<void> setLooping(bool val) async {}

  bool isInit() {
    return true;
  }

  void buttonIdle() {
    acc.playManager?.setIsNextButtonBusy(false);
    acc.playManager?.setIsPrevButtonBusy(false);
  }

  PlayState getPlayState() => model!.playState;

  ContentsModel getModel() => model!;

  Future<void> afterBuild() async {
    //if (model == null) return;
    //model!.setPlayState(PlayState.init);
    // if (model!.isDynamicSize.value) {
    //   model!.isDynamicSize.set(false, noUndo: true, save: false);
    //   acc.resizeFrame(
    //     model!.aspectRatio.value,
    //     model!.width.value,
    //     model!.height.value,
    //     initPosition: false,
    //   );
    // }
    // if (selectedModelHolder != null && pageManagerHolder != null) {
    //   if (await selectedModelHolder!.isSelectedModel(model!)) {
    //     pageManagerHolder!.setAsContents();
    //   }
    // }
    // if (accManagerHolder != null) {
    //   accManagerHolder!.resizeMenu(model!.contentsType);
    // }
  }

  Size getOuterSize(double srcRatio) {
    Size realSize = acc.getRealSize();
    // aspectorRatio 는 실제 비디오의  넓이/높이 이다.
    //double videoRatio = wcontroller!.value.aspectRatio;

    double outerWidth = realSize.width;
    double outerHeight = realSize.height;

    if (!acc.frameModel.isAutoFit.value) {
      if (srcRatio >= 1.0) {
        outerWidth = srcRatio * outerWidth;
        outerHeight = outerWidth * (1.0 / srcRatio);
      } else {
        outerHeight = (1.0 / srcRatio) * outerHeight;
        outerWidth = srcRatio * outerHeight;
      }
    }
    logger.fine(
        'getOuterSize  autoFit=${acc.frameModel.isAutoFit.value},w=$outerWidth,h=$outerHeight');
    return Size(outerWidth, outerHeight);
  }

  Widget getBlob(Size outSize, Widget child) {
    return Blob.animatedRandom(
        size: sqrt(acc.getRealSize().width * acc.getRealSize().height),
        duration: const Duration(microseconds: 100),
        edgesCount: 5,
        minGrowth: 4,
        styles: BlobStyles(color: Colors.green, fillType: BlobFillType.stroke, strokeWidth: 2),
        child: child);
  }

  int getPosition() {
    // for video player only
    return -1;
  }

  int getDuration() {
    // for video player only
    return -1;
  }

  bool shouldBePlay() {
    AbsExModel? selectedPage = BookMainPage.pageManagerHolder!.getSelected();
    logger.info('selectedPage = ${(selectedPage == null ? ' null' : selectedPage.mid)}');
    logger.info(
        'shouldBePlay ${model!.name} ${model!.isPauseTimer}, ${acc.playManager!.isCurrentModel(model!.mid)}');
    return (StudioVariables.isAutoPlay &&
        //model!.isState(PlayState.start) == false &&
        selectedPage != null &&
        selectedPage.mid == acc.pageModel.mid && // preview 모드에서 백그라운드 페이지가 실행되지 않도록 막기위해
        //acc.playManager!.isCurrentModel(model!.mid) &&
        model!.isPauseTimer == false);
  }
}

class CretaEmptyPlayer extends CretaAbsPlayer {
  CretaEmptyPlayer({
    required super.keyString,
    required super.onAfterEvent,
    required super.acc,
  });
}
