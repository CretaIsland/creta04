import 'package:flutter/material.dart';
import 'package:hycop/common/util/logger.dart';
import 'package:creta_common/model/app_enums.dart';
import '../creta_abs_player.dart';

class CretaDocPlayer extends CretaAbsPlayer {
  CretaDocPlayer({
        required super.frameKey,

    required super.keyString,
    required super.model,
    required super.acc,
    super.onAfterEvent,
  });

  // @override
  // Future<void> mute() async {
  //   model!.mute.set(!model!.mute.value);
  // }

  @override
  Future<void> play({bool byManual = false}) async {
    //logger.fine('text play');
    model!.setPlayState(PlayState.start);
    if (byManual) {
      model!.setManualState(PlayState.start);
    }
  }

  @override
  Future<void> pause({bool byManual = false}) async {
    model!.setPlayState(PlayState.pause);
  }

  @override
  void stop() {
    logger.fine("doc player stop   ,${model!.name}");
    //widget.wcontroller!.dispose();
    super.stop();
    model!.setPlayState(PlayState.stop);
  }

  @override
  Future<void> afterBuild() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      onAfterEvent?.call(Duration.zero, Duration.zero);
    });
  }
}
