// ignore: implementation_imports
// ignore_for_file: prefer_final_fields, depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hycop/common/util/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'package:creta_common/model/app_enums.dart';
import '../../pages/studio/studio_variables.dart';
import '../creta_abs_player.dart';

// ignore: must_be_immutable
class CretaVideoPlayer extends CretaAbsPlayer {
  CretaVideoPlayer({
    required super.keyString,
    required super.onAfterEvent,
    required super.model,
    required super.acc,
  }) {
    //logger.info("CretaVideoPlayer(isAutoPlay=${StudioVariables.isAutoPlay})");
  }

  VideoPlayerController? wcontroller;
  VideoEventType prevEvent = VideoEventType.unknown;
  Size? _outSize;
  Size? getSize() => _outSize;
  //bool _isMute = false;
  bool _isInitComplete = false;
  //Future<bool>? isInitialized() => isInitComplete;

  @override
  Future<bool> init() async {
    if (_isInitComplete) {
      //print("[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]");
      // 이 controller 는 init 되었지만, widget 의 afterBuild 가 호출되지 않는 경우에 해당한다.
      // logger.info('!!!!!! CretaVideoWidget build  : already initialized 2!!!!!');
      // if (model!.isState(PlayState.start) == false) {
      //   playVideoSafe();
      // } // init 가 이미 되어 있으면 play 해주어야 한다.  await 하면 안된다.
      //print("[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]");
      return true;
    }

    String uri = model!.getURI();
    String errMsg = '${model!.name} uri is null';
    if (uri.isEmpty) {
      logger.severe(errMsg);
    }
    logger.info('initVideo(${model!.name},$uri)');

    //wcontroller = VideoPlayerController.network(uri,
    wcontroller = VideoPlayerController.networkUrl(
      Uri.parse(uri),
      formatHint: VideoFormat.hls,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    await wcontroller!.initialize();

    //.then((_) {
    logger.info('initialize complete(${model?.name}, ${acc.getAvailLength()})');
    if (StudioVariables.isMute == false && model!.mute.value == false) {
      await wcontroller!.setVolume(model!.volume.value);
    } else {
      await wcontroller!.setVolume(0.0);
    }
    model!.aspectRatio.set(wcontroller!.value.aspectRatio, noUndo: true, save: false);
    model!.videoPlayTime
        .set(wcontroller!.value.duration.inMilliseconds.toDouble(), noUndo: true, save: false);
    await wcontroller!.setLooping(false);
    await wcontroller!.seekTo(Duration.zero); //skpark 2023.11.24 제일앞으로 보낸다.

    wcontroller!.onAfterVideoEvent = (event, position, duration) async {
      if (event.eventType == VideoEventType.completed) {
        model?.setPlayState(PlayState.end);
        //   //skpark 2023.11.24 제일앞으로 보낸다.
        //   // 아래 문장을 하지 않으면, complete 가 계속오게 되는데,  이게 전에는 안그랬는데,
        //   // 갑자기 계속 오기 시작한다
        //   // // 화면이 제일 처음으로 자꾸 돌아가고, 그 다음 다음 동영상으로 넘어가는 문제가 있어서 다시 뺌..
        //   //wcontroller!.seekTo(Duration.zero);
        logger.info(
            'onAfterVideoEvent : video play completed(${model?.name},postion=$position, duration=$duration)');

        onAfterEvent?.call(position, duration);
      }
      prevEvent = event.eventType;
    };

    if (_outSize == null) {
      _outSize = getOuterSize(wcontroller!.value.aspectRatio);
      await acc.resizeFrame(wcontroller!.value.aspectRatio, _outSize!, true);
    }
    logger.info('initialize complete(${_outSize?.width},${_outSize?.height})');
    _isInitComplete = true;
    await playVideoSafe(); //한번 플레이해주어야 한다.
    return _isInitComplete;
  }

  @override
  int getPosition() {
    if (isInit() == false) {
      return -1;
    }
    return wcontroller!.value.position.inMilliseconds;
  }

  @override
  int getDuration() {
    if (isInit() == false) {
      return -1;
    }
    return wcontroller!.value.duration.inMilliseconds;
  }

  @override
  bool isInit() {
    return wcontroller != null && wcontroller!.value.isInitialized;
  }

  @override
  void stop() {
    //print("video player stop,${model!.name}-------------------------------------------");
    logger.info("video player stop,${model!.name}");
    //widget.wcontroller!.dispose();
    super.stop();
    model!.setPlayState(PlayState.stop);
  }

  @override
  Future<void> play({bool byManual = false}) async {
    // //skpark 2024.03.14 init 되기전에 플레이되는 것을 막음
    // while (wcontroller!.value.isInitialized == false) {
    //   await Future.delayed(const Duration(milliseconds: 100));
    // }
    logger.info('play  ${model!.name}');
    model!.setPlayState(PlayState.start);
    try {
      await wcontroller!.play();
    } catch (e) {
      logger.severe('play error ${model!.name} : $e');
    }
  }

  @override
  Future<void> pause({bool byManual = false}) async {
    // while (model!.state == PlayState.disposed) {
    //   await Future.delayed(const Duration(milliseconds: 100));
    // }
    logger.info("video player pause,${model!.name}-------------------------------------------");
    logger.info('pause ${model!.name}');
    model!.setPlayState(PlayState.pause);
    await wcontroller!.pause();
  }

  @override
  Future<void> globalPause() async {
    // while (model!.state == PlayState.disposed) {
    //   await Future.delayed(const Duration(milliseconds: 100));
    // }
    logger.info('globalPause');
    model!.setPlayState(PlayState.globalPause);
    await wcontroller!.pause();
  }

  @override
  Future<void> globalResume() async {
    // while (model!.state == PlayState.disposed) {
    //   await Future.delayed(const Duration(milliseconds: 100));
    // }
    PlayState prevState = model!.playState;
    if (prevState == PlayState.globalPause) {
      logger.info('globalResume');
      model!.resumeState();
      if (model!.playState == PlayState.start) {
        await wcontroller!.play();
      }
    }
  }

  @override
  Future<void> resume({bool byManual = false}) async {
    // while (model!.state == PlayState.disposed) {
    //   await Future.delayed(const Duration(milliseconds: 100));
    // }
    logger.info('resume');
    PlayState prevState = model!.playState;
    model!.resumeState();
    if (prevState == PlayState.pause && model!.playState == PlayState.start) {
      await wcontroller!.play();
    }
  }

  // @override
  // Future<void> close() async {
  //   model?.setPlayState(PlayState.none);
  //   logger.info("videoController close()");
  //   await wcontroller?.dispose();
  //   wcontroller = null;
  // }

  @override
  Future<void> mute() async {
    if (model!.mute.value) {
      await wcontroller!.setVolume(1.0);
    } else {
      await wcontroller!.setVolume(0.0);
    }
    model!.mute.set(!model!.mute.value);
  }

  @override
  Future<void> rewind() async {
    //print('rewind');
    await wcontroller!.seekTo(Duration.zero);
  }

  @override
  Future<void> resumeSound() async {
    await wcontroller!.setVolume(model!.volume.value);
  }

  @override
  Future<void> setSound(double val) async {
    await wcontroller!.setVolume(val);
    model!.volume.set(val);
  }

  @override
  Future<void> setLooping(bool val) async {
    await wcontroller?.setLooping(val);
  }

  // @override
  // Future<void> afterBuild() async {
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
  //     logger.info('afterBuild video');
  //     // if (wcontroller != null && model != null) {
  //     //   logger.info('video : ${model!.name}');
  //     //   model!.aspectRatio.set(wcontroller!.value.aspectRatio, noUndo: true, save: false);
  //     // }
  //     // super.afterBuild();
  //     logger.info('afterBuild video end');
  //   });
  // }

  Future<void> playVideoSafe() async {
    if (wcontroller!.value.isInitialized == false) {
      logger.severe('!!!!!!!! Already initialize but, initialize is false !!!!!!!!');
      await wcontroller!.dispose();
      logger.severe('!!!!!!!! init again start, name=${model!.name}');
      _isInitComplete = false;
      await init();
      logger.severe('!!!!!!!! init again end, state = ${model!.playState}');
    }
    logger.info(
        'playVideoSafe ${model!.name} state = ${model!.playState} ${model!.isPauseTimer}, ${acc.playManager!.isCurrentModel(model!.mid)}');
    if (StudioVariables.isAutoPlay &&
        //model!.isState(PlayState.start) == false &&
        acc.playManager!.isCurrentModel(model!.mid) && // preview 모드에서 백그라운드 페이지가 실행되지 않도록 막기위해
        model!.isPauseTimer == false) {
      logger.info('playVideo video ${model!.name} state = ${model!.playState}');
      // 딜레이할 필요가 있다.
      await Future.delayed(const Duration(milliseconds: 149)); // build 할 시간적 여유를 주기 위함이다.
      await play(); //awat를 못한다....이거 문제임...
    }
    buttonIdle();
    return;
  }
}
