// ignore: implementation_imports
// ignore_for_file: prefer_final_fields, depend_on_referenced_packages

import 'dart:math';

//import 'package:creta_common/model/app_enums.dart';
import 'package:creta_common/model/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:hycop/common/util/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:creta_common/common/creta_common_utils.dart';
import 'package:creta_common/common/creta_snippet.dart';

import '../../data_io/key_handler.dart';
import '../../design_system/component/snippet.dart';
import 'package:creta_studio_model/model/contents_model.dart';
import 'package:creta_studio_model/model/frame_model.dart';
import '../../pages/studio/studio_variables.dart';
import '../creta_abs_media_widget.dart';
import 'creta_video_player.dart';

// ignore: must_be_immutable
class CretaVideoWidget extends CretaAbsMediaWidget {
  CretaVideoWidget({super.key, required super.player, super.timeExpired});

  @override
  State<CretaVideoWidget> createState() => CretaVideoPlayerWidgetState();
}

class CretaVideoPlayerWidgetState extends CretaState<CretaVideoWidget> {
  bool isMute = false;
  //Future<bool>? _isInitialized;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    logger.info('CretaVideoWidget initState ************************************');
    super.initState();
    afterBuild();
  }

  //build 후 호출되는 함수
  Future<void> afterBuild() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final CretaVideoPlayer player = widget.player as CretaVideoPlayer;

      if (player.isInit()) {
        if (player.getPlayState() != PlayState.start) {
          logger.info('afterBuild player start !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          player.playVideoSafe();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    logger.info(
        '********************* CretaVideoWidget dispose VideoPlayer${widget.player.model!.name}');
    widget.player.stop();
  }

  @override
  Widget build(BuildContext context) {
    final CretaVideoPlayer player = widget.player as CretaVideoPlayer;
    // if (player.isInit()) {
    //   logger.info('!!!!!! CretaVideoWidget build  : already initialized !!!!!');
    //   return IgnorePointer(
    //     child: getClipRect(
    //       player.getSize()!,
    //       player.acc.frameModel,
    //       player.model,
    //       // Container(
    //       //   color: Colors.amberAccent,
    //       // )

    //       VideoPlayer(key: GlobalObjectKey('VideoPlayer${player.keyString}'), player.wcontroller!),
    //       //VideoPlayer(key: GlobalKey(), player.wcontroller!),
    //     ),
    //   );
    // }
    logger.info('!!!!!! CretaVideoWidget build  : first time initialized !!!!!');
    return FutureBuilder(
        //future: player.waitInitVideo(),
        future: player.init(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData == false) {
            //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
            if (player.isInit() == false) {
              return CretaSnippet.showWaitSign();
            }
            return const SizedBox.shrink();
          }
          if (snapshot.hasError) {
            //error가 발생하게 될 경우 반환하게 되는 부분
            return Snippet.errMsgWidget(snapshot);
          }
          Size? outSize = player.getSize();
          if (outSize == null) {
            return const SizedBox.shrink();
          }
          return IgnorePointer(
            child: getClipRect(
              outSize,
              player.acc.frameModel,
              player.model,
              VideoPlayer(
                  key: GlobalObjectKey('VideoPlayer${player.keyString}'), player.wcontroller!),
            ),
          );
        });
  }

  Widget getClipRect(Size outSize, FrameModel frameModel, ContentsModel? model, Widget child) {
    Widget angleImage = model != null && model.angle.value > 0
        ? Transform.rotate(
            angle: CretaCommonUtils.degreeToRadian(model.angle.value),
            child: child,
          )
        : child;

    return ClipRRect(
      //clipper: MyContentsClipper(),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(frameModel.getRealradiusRightTop(StudioVariables.applyScale)),
        topLeft: Radius.circular(frameModel.getRealradiusLeftTop(StudioVariables.applyScale)),
        bottomRight:
            Radius.circular(frameModel.getRealradiusRightBottom(StudioVariables.applyScale)),
        bottomLeft: Radius.circular(frameModel.getRealradiusLeftBottom(StudioVariables.applyScale)),
      ),
      child: SizedBox.expand(
          child: FittedBox(
        alignment: Alignment.center,
        fit: model != null ? model.fit.value.toBoxFit() : BoxFit.cover,
        child: SizedBox(
          //width: realSize.width,
          //height: realSize.height,
          width: outSize.width,
          height: outSize.height,
          child: model != null && model.isFlip.value
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: angleImage,
                )
              : angleImage,
        ),
      )),
    );
  }
}
