// ignore_for_file: prefer_final_fields
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hycop/hycop.dart';

import '../pages/studio/studio_constant.dart';
import 'creta_abs_player.dart';

// ignore: must_be_immutable
abstract class CretaAbsMediaWidget extends StatefulWidget {
  final Future<bool> Function(CretaAbsMediaWidget widget)? timeExpired;
  final CretaAbsPlayer player;
  CretaAbsMediaWidget({super.key, required this.player, this.timeExpired});

  Timer? _timer;
  bool isTimerAvailable = false;

  void startTimer() {
    if (timeExpired == null) return;

    logger.fine("타임머가 시작되었다 =============");
    _timer ??=
        Timer.periodic(const Duration(milliseconds: StudioConst.playTimerInterval), (timer) async {
      isTimerAvailable = true;
      isTimerAvailable = await timeExpired!.call(this);
    });
  }

  void stopTimer() {
    logger.fine("타임머가 종료되었다 =============");
    isTimerAvailable = false;
    _timer?.cancel();
    _timer = null;
  }

  //build 후 호출되는 함수
  Future<void> afterBuild() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      startTimer();
    });
  }
}

// ignore: must_be_immutable
class CretaEmptyPlayerWidget extends CretaAbsMediaWidget {
  CretaEmptyPlayerWidget({super.key, required super.player, super.timeExpired});

  @override
  State<CretaEmptyPlayerWidget> createState() => CretaEmptyPlayerWidgetState();
}

class CretaEmptyPlayerWidgetState extends State<CretaEmptyPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
