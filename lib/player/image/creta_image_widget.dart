// ignore: implementation_imports
// ignore_for_file: prefer_final_fields, depend_on_referenced_packages, must_be_immutable

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hycop/common/util/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:creta_common/common/creta_common_utils.dart';
import 'package:hycop/hycop.dart';

import '../../data_io/key_handler.dart';
import 'package:creta_common/model/app_enums.dart';
import '../../pages/studio/studio_variables.dart';
import '../creta_abs_media_widget.dart';
import 'creta_image_player.dart';

class CretaImageWidget extends CretaAbsMediaWidget {
  CretaImageWidget({super.key, required super.player, super.timeExpired});

  @override
  CretaImageWidgetState createState() => CretaImageWidgetState();
}

class CretaImageWidgetState extends CretaState<CretaImageWidget>
    with SingleTickerProviderStateMixin {
  //bool _showChild = true;

  Future<bool> _removeChild() async {
    if (widget.timeExpired == null) return Future.value(false);
    bool retval = await widget.timeExpired!.call(widget);
    // setState(() {
    //   // expired 되면 다시 그리도록 하기 위해서이다.
    // });
    return retval;
  }

  @override
  Widget build(BuildContext context) {
    return RealImageWidget(
      key: GlobalKey(), // 계속 새로 그리도록 하기 위해  GlobalKey 를 사용한다.  새로 그리지 않으면, timer 가 동작하지 않는다.
      // 그래는 고정 key 를 가지기 때문에 CretaImageWidget 으로 한번 감싸준것임.
      player: widget.player as CretaImagePlayer,
      timeExpired: _removeChild,
    );
  }
}

class RealImageWidget extends StatefulWidget {
  final Future<bool> Function()? timeExpired;
  final CretaImagePlayer player;

  const RealImageWidget({super.key, required this.player, this.timeExpired});

  @override
  RealImageWidgetState createState() => RealImageWidgetState();
}

class RealImageWidgetState extends CretaState<RealImageWidget> with SingleTickerProviderStateMixin {
  Timer? aniTimer;
  bool animateFlag = false;

  DateTime? startTime;
  DateTime? endTime;

  void startTimer() {
    if (widget.timeExpired == null) return;
    if (widget.player.model == null) return;
    if (widget.player.model!.playTime.value < 0) return;

    startTime = DateTime.now();

    logger.info(
        "타임머가 시작되었다 =============${widget.player.model?.name}, ${widget.player.model?.playTime.value}, $startTime");
    // _timer ??=
    //Timer.periodic(const Duration(milliseconds: StudioConst.playTimerInterval), (timer) async {
    //     Timer.periodic(Duration(milliseconds: widget.player.model!.playTime.value.ceil()), (timer) async {
    //   endTime = DateTime.now();
    //   logger.info(
    //       "타임머가 Expired 되었다. =============${widget.player.model!.name}, ${endTime!.difference(startTime!).inMilliseconds}");
    //   isTimerAvailable = true;
    //   isTimerAvailable = await widget.timeExpired!.call(this);
    // });
    // widget.timeExpired!.call(widget).then((onValue) {
    //   widget.isTimerAvailable = onValue;
    // });
    Future.delayed(Duration(milliseconds: widget.player.model!.playTime.value.ceil())).then((t) {
      if (!mounted) {
        // delay 중인데, widget 이 dispose 에 들어간다면,  startTime 이 null 이 될 수 있다.
        logger.info('마운트가 해제되었다......................................');
        return;
      }
      if (startTime == null) {
        // delay 중인데, widget 이 dispose 에 들어간다면,  startTime 이 null 이 될 수 있다.
        logger.info('startTime 이 null 이다.   도대체 왜 이게 널일까???');
        return;
      }
      endTime = DateTime.now();

      logger.info(
          "타임머가 Expired 되었다. =============${widget.player.model?.name}, ${endTime?.difference(startTime!).inMilliseconds}");
      //widget.isTimerAvailable = true;

      widget.timeExpired?.call();
    });
  }

  void stopTimer() {
    logger.info("타임머가 종료되었다 =============${widget.player.model?.name}");
    //widget.isTimerAvailable = false;
    //_timer?.cancel();
    //_timer = null;
    startTime = null;
    endTime = null;
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    if (widget.player.model!.imageAniType.value == ImageAniType.move) {
      aniTimer ??= Timer.periodic(const Duration(seconds: 4), (t) {
        setState(() {
          animateFlag = !animateFlag;
        });
      });
    }
    afterBuild(); // timer will be started
  }

  Future<void> afterBuild() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        logger.info('afterBuild=====================================');
        if (widget.player.shouldBePlay()) {
          startTimer();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    stopTimer();
    widget.player.stop();
    aniTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final CretaImagePlayer player = widget.player;

    if (StudioVariables.isAutoPlay) {
      player.model!.setPlayState(PlayState.start);
    } else {
      player.model!.setPlayState(PlayState.pause);
    }
    //Size outSize = widget.getOuterSize(widget.model!.aspectRatio.value);

    double topLeft = player.acc.frameModel.getRealradiusLeftTop(StudioVariables.applyScale);
    double topRight = player.acc.frameModel.getRealradiusRightTop(StudioVariables.applyScale);
    double bottomLeft = player.acc.frameModel.getRealradiusLeftBottom(StudioVariables.applyScale);
    double bottomRight = player.acc.frameModel.getRealradiusRightBottom(StudioVariables.applyScale);

    String uri = player.model!.getURI();
    String errMsg = '${player.model!.name} uri is null';
    if (uri.isEmpty) {
      logger.fine(errMsg);
    }
    logger.fine("uri=<$uri>");
    player.buttonIdle();

    // return ClipRRect(
    //   borderRadius: BorderRadius.only(
    //     topRight: Radius.circular(topRight),
    //     topLeft: Radius.circular(topLeft),
    //     bottomRight: Radius.circular(bottomRight),
    //     bottomLeft: Radius.circular(bottomLeft),
    //   ),
    //   child: SizedBox.expand(
    //     child: FittedBox(
    //       alignment: Alignment.center,
    //       fit: BoxFit.cover,
    //       child: SizedBox(
    //         width: outSize.width,
    //         height: outSize.height,
    //         child: uri.isEmpty
    //             ? noImage(errMsg)
    //             : Image.network(
    //                 uri,
    //                 fit: BoxFit.cover,
    //                 errorBuilder: (context, error, stackTrace) {
    //                   errMsg = '${widget.model!.name} ${error.toString()}';
    //                   logger.fine(errMsg);
    //                   return noImage(errMsg);
    //                 },
    //               ),
    //       ),
    //     ),
    //   ),
    // );

    Size size = player.acc.getRealSize();

    Widget drawImage = Center(
      child: Container(
        // width: size.width,
        // height: size.height,
        decoration: BoxDecoration(
            //shape: BoxShape.circle,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topLeft),
              topRight: Radius.circular(topRight),
              bottomLeft: Radius.circular(bottomLeft),
              bottomRight: Radius.circular(bottomRight),
            ),
            //image: DecorationImage(fit: BoxFit.fill, image: NetworkImage(widget.model!.url))),
            //image: DecorationImage(fit: BoxFit.fill, image: NetworkImage(uri))),

            image: DecorationImage(
                fit: player.model!.fit.value.toBoxFit(),
                image: CachedNetworkImageProvider(uri, cacheKey: uri))),
        //image: DecorationImage(fit: BoxFit.fill, image: CachedNetworkImageProvider(uri, cacheKey: uri))),
      ),
    );

    double angle = player.model!.angle.value;
    Widget angleImage = angle > 0
        ? Transform.rotate(
            angle: CretaCommonUtils.degreeToRadian(angle),
            child: drawImage,
          )
        : drawImage;

    Widget flipImage = player.model!.isFlip.value == true
        ? Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi), //  좌우를 반전시킨다.
            child: angleImage,
          )
        : angleImage;

    if (player.model!.imageAniType.value == ImageAniType.move) {
      return OverflowBox(
        maxHeight: size.height * 1.5,
        maxWidth: size.width * 1.5,
        child: AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOutCubic,
          width: animateFlag ? size.width : size.width * 1.5,
          height: animateFlag ? size.height : size.height * 1.5,
          child: flipImage,

          // child: Stack(
          //   children: [
          //     Transform.translate(
          //       offset: const Offset(5, 5),
          //       child: ClipRRect(
          //         borderRadius: BorderRadius.circular(3),
          //         child: Opacity(
          //           opacity: 0.5,
          //           child: drawImage,
          //         ),
          //       ),
          //     ),
          //     Positioned.fill(
          //       child: BackdropFilter(
          //         filter: ImageFilter.blur(
          //           sigmaX: 3,
          //           sigmaY: 3,
          //         ),
          //         child: Container(color: Colors.transparent),
          //       ),
          //     ),
          //     ClipRRect(
          //       borderRadius: BorderRadius.circular(3),
          //       child: drawImage,
          //     ),
          //   ],
          // ),
        ),
      );
    }

    return flipImage;
  }
}
