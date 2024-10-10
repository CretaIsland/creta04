// ignore_for_file: prefer_final_fields
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hycop/common/util/logger.dart';

import 'creta_abs_player.dart';

// ignore: must_be_immutable
abstract class CretaAbsMediaWidget extends StatefulWidget {
  final Future<bool> Function(CretaAbsMediaWidget widget)? timeExpired;
  final CretaAbsPlayer player;
  CretaAbsMediaWidget({super.key, required this.player, this.timeExpired}) {
    logger.info("new CretaAbsMediaWidget(${player.keyString}, ${player.model!.name})");
  }

  //bool isTimerAvailable = false;

  //Timer? _timer;
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
