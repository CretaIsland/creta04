// ignore_for_file: depend_on_referenced_packages, avoid_web_libraries_in_flutter

import 'package:creta04/design_system/component/shape/creta_clipper.dart';
import 'package:creta_common/model/creta_model.dart';
//import 'package:creta04/pages/studio/containees/frame/camera_frame.dart';  // hycop_multi_platform 에서 제외됨

import 'package:creta04/pages/studio/right_menu/frame/transition_types.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:get/get.dart';
import 'package:hycop_multi_platform/hycop.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
//import 'package:hycop_multi_platform/common/util/logger.dart';
import 'package:creta_common/common/creta_common_utils.dart';
import 'package:creta_common/common/creta_snippet.dart';

import 'package:creta04/design_system/component/creta_texture_widget.dart';
import '../../../../data_io/key_handler.dart';
import '../../../../data_io/contents_manager.dart';
import '../../../../data_io/depot_manager.dart';
import '../../../../data_io/frame_manager.dart';
import '../../../../data_io/link_manager.dart';
import '../../../../design_system/component/autoSizeText/creta_auto_size_text.dart';
import '../../../../design_system/component/snippet.dart';
import 'package:creta_common/common/creta_color.dart';
import '../../../../design_system/drag_and_drop/drop_zone_widget.dart';
import 'package:creta_common/model/app_enums.dart';
import 'package:creta_studio_model/model/contents_model.dart';
import 'package:creta_studio_model/model/depot_model.dart';
import 'package:creta_studio_model/model/frame_model.dart';
import '../../../../model/frame_model_util.dart';
import 'package:creta_studio_model/model/page_model.dart';
import '../../../../player/creta_play_manager.dart';
//import '../../book_main_page.dart';    // hycop_multi_platform 에서 제외됨
import '../../left_menu/depot/depot_display.dart';
//import '../../left_menu/music/music_player_frame.dart';    // hycop_multi_platform 에서 제외됨
import '../../page_index_dialog.dart';
import '../../studio_getx_controller.dart';
import '../../studio_snippet.dart';
import '../../studio_variables.dart';
import '../containee_mixin.dart';
//import '../contents/contents_main.dart';
import '../contents/link_widget.dart';
import 'frame_play_mixin.dart';
import 'on_frame_menu.dart';

class FrameEach extends StatefulWidget {
  final FrameManager frameManager;
  final PageModel pageModel;
  final FrameModel model;
  //final double applyScale;
  final double width;
  final double height;
  final Offset frameOffset;
  const FrameEach({
    super.key,
    required this.frameManager,
    required this.pageModel,
    required this.model,
    //required this.applyScale,
    required this.width,
    required this.height,
    required this.frameOffset,
  });

  @override
  State<FrameEach> createState() => FrameEachState();
}

class FrameEachState extends CretaState<FrameEach> with ContaineeMixin, FramePlayMixin {
  ContentsManager? _contentsManager;
  CretaPlayManager? _playManager;
  late double _width;
  // ignore: unused_field
  bool _onceInited = false;

  Future<bool>? _isInitialized;
  //final bool _isHover = false;
  bool _isShowBorder = false;
  // ignore: prefer_final_fields

  //OffsetEventController? _linkSendEvent;
  FrameEachEventController? _linkReceiveEvent;
  ContentsEventController? _contentsReceiveEvent;

  //late GlobalObjectKey<ContentsMainState> contentsMainKey;
  //bool _isLinkEnter = false;

  @override
  void dispose() {
    super.dispose();
    //_playManager = null;  // playManager 를  dispose 해서는 안됨.
    logger.fine('======================================================');
    logger.fine('FrameEach is disposed');
    logger.fine('======================================================');
    //logger.fine('==========================FrameEach dispose================');
  }

  @override
  void didUpdateWidget(FrameEach oldWidget) {
    //print('didUpdateWidget FrameEach');
    super.didUpdateWidget(oldWidget);
    if (_width != oldWidget.width) {
      _width = _width;
    }
  }

  @override
  void initState() {
    super.initState();
    _isInitialized = initChildren();
    if (_contentsManager!.onceDBGetComplete == true) {
      _contentsManager!.createLinkContentsManagerMap(); // link 와 contentsMangaer 의 Map 까지 추가해야 한다.
    }
    // final OffsetEventController sendEvent = Get.find(tag: 'frame-each-to-on-link');
    // _linkSendEvent = sendEvent;
    final FrameEachEventController linkReceiveEvent = Get.find(tag: 'to-FrameEach');
    _linkReceiveEvent = linkReceiveEvent;
    // contentsMainKey = GlobalObjectKey<ContentsMainState>(
    //     'ContentsMain${widget.pageModel.mid}/${widget.model.mid}');

    final ContentsEventController contentsReceiveEvent = Get.find(tag: 'contents-property-to-main');
    //final ContentsEventController sendEvent = Get.find(tag: 'contents-main-to-property');
    _contentsReceiveEvent = contentsReceiveEvent;
    //_sendEvent = sendEvent;

    _width = widget.width;

    afterBuild();
  }

  Future<void> afterBuild() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<bool> initChildren() async {
    setFrameManager(widget.frameManager);
    if (frameManager == null) {
      logger.severe('frame manager is null');
      return false;
    }
    _contentsManager = frameManager!.findOrCreateContentsManager(widget.model);
    // playManager 는 반드시 데이터를 가져오기 전에 해야 한다.
    _playManager =
        CretaPlayManager.getManager(_contentsManager!.parentMid!, _contentsManager!, frameManager!);
    _contentsManager!.setPlayManager(_playManager!);
    logger.fine('======================================================');
    logger.fine('playManager is created : ${_contentsManager!.parentMid!}');
    logger.fine('======================================================');

    if (_contentsManager!.onceDBGetComplete == false) {
      try {
        await _contentsManager!.getContents(); // link 와 contentsMangaer 의 Map 까지 추가해야 한다.
      } catch (e) {
        logger.severe('contentsManager getContents *(*(*()*)(***()*(**()))) error $e');
      }
      //await _contentsManager!.getContents();

      _contentsManager!.addRealTimeListen(widget.model.mid);
      _contentsManager!.reOrdering();
      _contentsManager!.createLinkContentsManagerMap(); // link 와 contentsMangaer 의 Map 까지 추가해야 한다.
    }
    //print('frame initChildren(${_contentsManager!.getAvailLength()})');

    return true;
  }

  // void invalidateContentsMain() {
  //   // 프레임에서 콘텐츠 영역만 invalidate 를 시킨다.
  //   contentsMainKey.currentState?.invalidate();
  // }

  @override
  Widget build(BuildContext context) {
    //print('build FrameEach');

    _width = widget.width;

    // if (_playManager == null) {
    //   logger.severe('_playManager is null');
    // }
    // if (StudioVariables.isPreview) {
    //   if (widget.pageModel.mid == BookMainPage.pageManagerHolder!.getSelectedMid()) {
    //     // 현재 선택된 페이지만 start 한다.
    //     //_playManager?.start();
    //   } else {
    //     //_playManager?.stop();
    //   }
    // } else {
    //   //_playManager?.start();
    // }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ContentsManager>.value(
          value: _contentsManager!,
        ),
        ChangeNotifierProvider<CretaPlayManager>.value(
          value: _playManager!,
        ),
      ],
      //child: _isInitialized ? _frameDropZone() : _futureBuilder(),
      child: (StudioVariables.isPreview == true)
          ? _frameBody2()
          : _futureBuilder(), //skpark 이부분 다시 테스트해봐야함. 과연 previewMode 에서는 정말로 wait 를 하지 않아도 되는가??? 그럴리가....한번되면 안해도 되게..
    );
  }

  // Future<bool> _waitInit() async {
  //   //await widget.init();
  //   //bool isReady = widget.wcontroller!.value.isInitialized;
  //   while (!_isInitialized) {
  //     await Future.delayed(const Duration(milliseconds: 100));
  //   }
  //   return true;
  // }

  Widget _futureBuilder() {
    _onceInited = true;
    return FutureBuilder<bool>(
        initialData: false,
        //future: _waitInit(),
        future: _isInitialized,
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
            return CretaSnippet.showWaitSign();
          }
          if (snapshot.hasError) {
            //error가 발생하게 될 경우 반환하게 되는 부분
            return Snippet.errMsgWidget(snapshot);
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return _frameDropZone();
          }
          return const SizedBox.shrink();
        });
  }

  Widget _frameDropZone() {
    logger.fine('_frameDropZone...');

    _isShowBorder = showBorder(widget.model, widget.pageModel, _contentsManager!, true);
    // Widget frameBody = Stack(
    //   alignment: Alignment.center,
    //   children: [
    //     _applyAnimate(widget.model),
    //     OnFrameMenu(
    //       key: GlobalObjectKey('OnFrameMenu${widget.model.mid}'),
    //       playTimer: _playManager,
    //       model: widget.model,
    //     ),
    //   ],
    // );

    Widget dropTarget = Center(
      child: FrameModelUtil.isDropAble(widget.model)
          ? DragTarget<CretaModel>(
              // 보관함에서 끌어다 넣기
              builder: (context, candidateData, rejectedData) {
                //print('drop depotModel length = ${candidateData.length}');
                return DropZoneWidget(
                  // 파일에서 끌어다 넣기
                  bookMid: widget.model.realTimeKey,
                  parentId: '',
                  onDroppedFile: (modelList) {
                    _onDropFrame(widget.model.mid, modelList);
                  },
                  child: _frameBody1(),
                );
              },
              onMove: (data) {
                //print('onMove');
                if (widget.model.dragOnMove == false) {
                  widget.model.dragOnMove = true;
                  frameManager!.invalidateContentsMain(widget.pageModel.mid, widget.model.mid);
                }
              },
              onLeave: (data) {
                //print('onLeave');
                if (widget.model.dragOnMove == true) {
                  widget.model.dragOnMove = false;
                  frameManager!.invalidateContentsMain(widget.pageModel.mid, widget.model.mid);
                }
              },
              onAcceptWithDetails: (details) async {
                if (details.data is DepotModel) {
                  //print('drop depotModel =${data.contentsMid}');
                  DepotManager? depotManager = DepotDisplay.getMyTeamManager(null);
                  if (depotManager != null) {
                    ContentsModel? newModel = await depotManager
                        .copyContents(details.data as DepotModel, frameId: widget.model.mid);
                    if (newModel != null) {
                      _onDropFrame(widget.model.mid, [newModel]);
                    }
                  }
                  widget.model.dragOnMove = false;
                  frameManager!.invalidateContentsMain(widget.pageModel.mid, widget.model.mid);
                } else if (details.data is ContentsModel) {
                  //print('drop gifModel =${data}');
                  _onDropFrame(widget.model.mid, [details.data as ContentsModel]);
                }
              },
              onWillAcceptWithDetails: (data) {
                return widget.model.frameType == FrameType.none;
              },
            )
          : _frameBody1(),
    );

    return dropTarget;
  }

  Widget _frameBody1() {
    //logger.fine('================angle=${widget.model.angle.value}');

    if (widget.model.shouldInsideRotate()) {
      return Transform(
        key: GlobalObjectKey('Transform${widget.pageModel.mid}/${widget.model.mid}'),
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(1.0)
          ..rotateZ(CretaCommonUtils.degreeToRadian(widget.model.angle.value)),
        child: _frameBody2(),
      );
    }
    return _frameBody2();
  }

  // Widget _frameBody2() {
  //   logger.fine('frameBody2----------${LinkParams.isLinkNewMode}---------');
  //   if (LinkParams.isLinkNewMode == true) {
  //     return MouseRegion(
  //       cursor: SystemMouseCursors.none,
  //       onEnter: (event) {
  //         setState(() {
  //           logger.fine('_isLinkEnter');
  //           _isLinkEnter = true;
  //         });
  //       },
  //       onExit: (event) {
  //         logger.fine('_isLinkExit');
  //         setState(() {
  //           _isLinkEnter = false;
  //         });
  //       },
  //       onHover: (event) {
  //         logger.fine('sendEvent ${event.position}');
  //         _linkSendEvent?.sendEvent(event.position);
  //       },
  //       child: _frameBody3(),
  //     );
  //   }
  //   return _frameBody3();
  // }

  Widget _frameBody2() {
    if (_contentsManager == null) {
      return const SizedBox.shrink();
    }
    //print('FrameEach done================++++++++++++++++++++++++++++++++++++');
    if (StudioVariables.isPreview) {
      return _applyAnimate(widget.model);
    }
    logger.fine('_frameBody2 ${widget.model.name.value}');
    logger.fine('_frameBody2 ${widget.model.isShow.value}');
    logger.fine('_frameBody2 ${widget.model.mid}');
    return StreamBuilder<bool>(
        stream: _linkReceiveEvent!.eventStream.stream,
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.data is bool) {
            logger.fine('_frameBody3 _linkReceiveEvent (AutoPlay=$snapshot.data)');
          }
          //return _applyAnimate(widget.model);
          int orderIndex = frameManager!.getOrderIndex(widget.model.order.value);
          //print('newOrder=${widget.model.order.value}, $orderIndex');
          return Stack(
            alignment: Alignment.center,
            children: [
              _applyAnimate(widget.model),
              //     LinkParams.isLinkNewMode &&
              //             StudioVariables.isPreview == false &&
              //             _isLinkEnter == true &&
              //             _contentsManager!.length() > 0
              //         ? _onLinkNewCursor()
              //         : const SizedBox.shrink(),
              (LinkParams.isLinkNewMode == false && StudioVariables.isPreview == false)
                  ? IgnorePointer(
                      child: OnFrameMenu(
                        // key: GlobalObjectKey(
                        //     //'OnFrameMenu${widget.pageModel.mid}/${widget.model.mid}/${DraggableStickers.isFrontBackHover}'),
                        //     'OnFrameMenu${widget.pageModel.mid}/${widget.model.mid}'),
                        //playTimer: playManager,
                        orderIndex: orderIndex,
                        model: widget.model,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
            //     //     : StudioVariables.isPreview == false &&
            //     //             _isLinkEnter == true &&
            //     //             _contentsManager!.length() > 0
            //     //         ? _onLinkNewCursor()
            //     //         : const SizedBox.shrink(),
            //],
          );
        });
  }

  Future<void> _onDropFrame(String frameId, List<ContentsModel> contentsModelList) async {
    // 콘텐츠 매니저를 생성한다.
    FrameModel? frameModel = frameManager!.getModel(frameId) as FrameModel?;
    if (frameModel == null) {
      logger.severe('target frameModel is not founded');
      return;
    }

    await ContentsManager.createContents(
        frameManager, contentsModelList, frameModel, widget.pageModel, isResizeFrame: false,
        onUploadComplete: (model) {
      // hycop_multi_platform 에서 제외됨
      // if (model.isMusic()) {
      //   GlobalObjectKey<MusicPlayerFrameState>? musicKey =
      //       BookMainPage.musicKeyMap[widget.model.mid];
      //   if (musicKey != null) {
      //     musicKey.currentState!.addMusic(model);
      //   } else {
      //     debugPrint('musicKey is INVALID');
      //   }
      // }
    });
  }

  Widget _applyAnimate(FrameModel model) {
    List<AnimationType> animations = AnimationType.toAniListFromInt(model.transitionEffect.value);
    logger.finest('transitionEffect=${model.order.value}:${model.transitionEffect.value}');
    if (animations.isEmpty) {
      return _isShowBorder ? _dottedShapeBox(model) : _shapeBox(model);
    }

    return getAnimation(
      _isShowBorder ? _dottedShapeBox(model) : _shapeBox(model),
      animations,
      model.mid,
      duration: Duration(milliseconds: model.aniDuration.value),
      delay: Duration(milliseconds: model.aniDelay.value),
      repeat: model.aniRepeat.value,
      reverse: model.aniReverse.value,
    );
  }

  Widget _dottedShapeBox(FrameModel model) {
    return DottedBorder(
      dashPattern: const [6, 6],
      strokeWidth: 2,
      strokeCap: StrokeCap.round,
      color: CretaColor.text[700]!,
      child: _shapeBox(model),
    );
  }

  Widget _shapeBox(FrameModel model) {
    //return _textureBox(model);
    return _textureBox(model).asShape(
      mid: model.mid,
      shapeType: model.shape.value,
      offset: CretaCommonUtils.getShadowOffset(
          model.shadowDirection.value, model.shadowOffset.value * StudioVariables.applyScale),
      shadowBlur: model.shadowBlur.value,
      shadowSpread: model.shadowSpread.value * StudioVariables.applyScale,
      shadowOpacity: model.isNoShadow() ? 0 : model.shadowOpacity.value,
      shadowColor: model.isNoShadow() ? Colors.transparent : model.shadowColor.value,
      // width: _width,
      // height: widget.height,
      strokeWidth: (model.borderWidth.value * StudioVariables.applyScale).ceilToDouble(),
      strokeColor: model.borderColor.value,
      radiusLeftBottom: model.getRealradiusLeftBottom(StudioVariables.applyScale),
      radiusLeftTop: model.getRealradiusLeftTop(StudioVariables.applyScale),
      radiusRightBottom: model.getRealradiusRightBottom(StudioVariables.applyScale),
      radiusRightTop: model.getRealradiusRightTop(StudioVariables.applyScale),
      borderCap: model.borderCap.value,
      applyScale: StudioVariables.applyScale,
      glowSize: model.glowSize.value,
    );
  }

  Widget _textureBox(FrameModel model) {
    logger.finest('mid=${model.mid}, ${model.textureType.value}');
    if (model.textureType.value == TextureType.glass) {
      logger.finest('frame Glass!!!');
      double opacity = model.opacity.value;
      Color bgColor1 = model.bgColor1.value;
      Color bgColor2 = model.bgColor2.value;
      GradationType gradationType = model.gradationType.value;
      return _frameBox(model, false).asCretaGlass(
        height: widget.height,
        width: _width,
        gradient: StudioSnippet.gradient(
            gradationType, bgColor1.withOpacity(opacity), bgColor2.withOpacity(opacity / 2)),
        opacity: opacity,
        bgColor1: bgColor1,
        bgColor2: bgColor2,
        //clipBorderRadius: _getBorderRadius(model),
        //radius: _getBorderRadius(model, addRadius: model.borderWidth.value * 0.7),
        //border: _getBorder(model),
        //borderStyle: model.borderType.value,
        //borderWidth: model.borderWidth.value,
        //boxShadow: _getShadow(model),
      );
    }
    return _frameBox(model, true);
  }

  // Widget _shadowBox(FrameModel model, bool useColor) {
  //   if (model.isNoShadow() == false && model.shadowIn.value == true) {
  //     return InnerShadow(
  //       shadows: [
  //         Shadow(
  //           shadowBlur:
  //               model.shadowBlur.value > 0 ? model.shadowBlur.value : model.shadowSpread.value,
  //           color: model.shadowOpacity.value == 1
  //               ? model.shadowColor.value
  //               : model.shadowColor.value.withOpacity(model.shadowOpacity.value),
  //           offset: CretaCommonUtils.getShadowOffset(
  //               (180 + model.shadowDirection.value) % 360, model.shadowOffset.value),
  //         ),
  //       ],
  //       child: _frameBox(model, useColor),
  //     );
  //   }
  //   return _frameBox(model, useColor);
  // }

  Widget _frameBox(FrameModel model, bool useColor) {
    return Container(
      //key: ValueKey('Container${model.mid}'),
      decoration: useColor ? _frameDeco(model) : null,
      //color: Colors.transparent,
      width: double.infinity,
      height: double.infinity,
      child: _contentsMain(model),
    );
  }

  Widget _contentsMain(FrameModel model) {
    // if (model.isTextType() && model.isEditMode) {
    //   return InstantEditor(
    //     frameModel: model,
    //     frameManager: widget.frameManager,
    //     onEditComplete: () {
    //       setState(
    //         () {
    //           //_isEditorAlreadyExist = false;
    //           model.isEditMode = false;
    //         },
    //       );
    //       widget.frameManager.notify();
    //     },
    //   );
    // }

    if (model.isWeatherTYpe()) {
      return weatherFrame(model: model, width: _width, height: widget.height);
    }
    if (model.isWatchTYpe()) {
      return watchFrame(
        contentsManager: _contentsManager,
        model: model,
        context: context,
        applyScale: StudioVariables.applyScale,
        isThumbnail: false,
        width: _width,
        height: widget.height,
        timeChanged: () {
          setState(() {});
        },
        child: _childContents(model),
      );
    }
    // if (model.nextContentTypes.value != NextContentTypes.none) {
    //   return TransExampleBox(
    //     frameManager: frameManager!,
    //     model: model,
    //     nextContentTypes: widget.model.nextContentTypes.value,
    //     name: '',
    //     selectedType: false,
    //     onTypeSelected: () {},
    //   );
    // }
    if (model.nextContentTypes.value != NextContentTypes.none) {
      return TransitionTypes(
        // 콘텐츠 넘김 효과, 카로셀등을 말함.
        key: ValueKey('Frame${model.mid}'),
        width: _width,
        height: widget.height,
        frameManager: frameManager!,
        model: model,
        nextContentTypes: model.nextContentTypes.value,
        name: '',
      );
    }
    if (model.isStickerType()) {
      return stickerFrame(model);
    }
    if (model.isTimelineType()) {
      return timelineFrame(model);
    }
// hycop_multi_platform 에서 제외됨
    // if (model.isCameraType()) {
    //   return CameraFrame(model: model);
    // }
    //구글맵 임시로 사용안함.
    // if (model.isMapType()) {
    //   return mapFrame(model);
    // }
    if (model.isDateTimeType()) {
      return dateTimeFrame(
        frameModel: model,
        child: _childContents(model),
        frameManager: frameManager!,
        frameMid: model.mid,
      );
    }
    if (model.isNewsType()) {
      return newsFrame(
        frameModel: model,
        width: _width,
        height: widget.height,
      );
    }

    if (model.isCurrencyXchangeType()) {
      return currencyXchangeFrame(
        frameModel: model,
        width: _width,
        height: widget.height,
      );
    }

    if (model.isDailyQuoteType()) {
      return dailyQuoteFrame(
        frameModel: model,
        width: _width,
        height: widget.height,
      );
    }

    if (model.isDailyWordType()) {
      return dailyWordFrame(
        frameModel: model,
        width: _width,
        height: widget.height,
      );
    }

    //print('ClipRect');
    return _childContents(model);
    // child: Image.asset(
    //   'assets/creta_default.png',
    //   fit: BoxFit.cover,
    // ),
  }

  // Widget _childContents(FrameModel model) {
  //   return ClipRect(
  //     clipBehavior: Clip.hardEdge,
  //     child: ContentsMain(
  //       key: frameManager!.registerContentMainKeyHandlerKey(widget.pageModel.mid, widget.model.mid),
  //       frameModel: model,
  //       frameOffset: widget.frameOffset,
  //       pageModel: widget.pageModel,
  //       frameManager: frameManager!,
  //       contentsManager: _contentsManager!,
  //       applyScale: StudioVariables.applyScale,
  //     ),
  //   );
  // }

  bool _isURINotNull(ContentsModel model) {
    //print('_isURINotNull(${model.mid}, ${model.remoteUrl})');
    return model.url.isNotEmpty || (model.remoteUrl != null && model.remoteUrl!.isNotEmpty);
  }

  Widget _childContents(FrameModel frameModel) {
    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: Consumer<ContentsManager>(builder: (context, contentsManager, child) {
        //int contentsCount = contentsManager.getShowLength();
        int contentsCount = contentsManager.getShowLength();
        //print('Consumer<ContentsManager> ContentsMain = $contentsCount');
        return Consumer<CretaPlayManager>(builder: (context, playManager, child) {
          logger.info('Consumer<CretaPlayManager>');
          return StreamBuilder<AbsExModel>(
              stream: _contentsReceiveEvent!.eventStream.stream,
              builder: (context, snapshot) {
                //print('snapshot.data=${snapshot.data}');
                //print('snapshot.data is ContentsModel=${snapshot.data is ContentsModel}');
                if (snapshot.data != null && snapshot.data is ContentsModel) {
                  ContentsModel model = snapshot.data! as ContentsModel;
                  contentsManager.updateModel(model);
                  logger.fine('model updated ${model.name}, ${model.url}');
                }
                logger.fine('StreamBuilder<AbsExModel> $contentsCount');
                if (contentsCount == 0) {
                  logger.fine('current model is null');
                  return const SizedBox.shrink();
                }
                //skpark 2024.01.19 현재 돌고 있는 것을 가져오면 안되고, contentsManager 에서 가져와야 한다.
                //ContentsModel? model = playManager.getCurrentModel();
                ContentsModel? model = contentsManager.getSelected() as ContentsModel?;
                model ??= playManager.getCurrentModel(); // null 인경우는 playManager 에서 가져온다.
                if (model != null && _isURINotNull(model)) {
                  //print('event received (1)=======================${model.autoSizeType.value}=');
                  LinkManager? linkManager = contentsManager.findLinkManager(model.mid);
                  if (linkManager != null) {
                    //if (linkManager != null && linkManager.getAvailLength() > 0) {
                    return Stack(
                      children: [
                        _createPlayerWidget(model, playManager),
                        if (model.contentsType != ContentsType.document &&
                            model.contentsType != ContentsType.pdf &&
                            model.contentsType != ContentsType.music)
                          LinkWidget(
                            key: GlobalObjectKey('LinkWidget${widget.pageModel.mid}/${model.mid}'),
                            applyScale: StudioVariables.applyScale,
                            frameManager: frameManager!,
                            frameOffset: widget.frameOffset,
                            contentsManager: contentsManager,
                            playManager: playManager,
                            contentsModel: model,
                            frameModel: frameModel,
                            onFrameShowUnshow: () {
                              logger.fine('onFrameShowUnshow');
                              widget.frameManager.notify();
                            },
                            showContentsIndex: () async {
                              //print('showContentsIndex in frame_each');

                              ContentsManager? contentsManager =
                                  frameManager!.getContentsManager(frameModel.mid);
                              if (contentsManager != null) {
                                List<CretaModel> contentsList =
                                    contentsManager.getOrdered().toList();

                                await showGeneralDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel:
                                      MaterialLocalizations.of(context).modalBarrierDismissLabel,
                                  barrierColor: Colors.black54,
                                  transitionDuration: const Duration(milliseconds: 200),
                                  pageBuilder: (BuildContext buildContext, Animation animation,
                                      Animation secondaryAnimation) {
                                    return Align(
                                      alignment: Alignment.topRight,
                                      child: PageIndexDialog(
                                        modelList: contentsList,
                                        onSelected: (int index) {
                                          ContentsModel contentsModel =
                                              contentsList[index] as ContentsModel;
                                          //print('goto contentsModel.name=${contentsModel.name}');

                                          if (contentsManager.isSelected(contentsModel.mid) ==
                                              true) {
                                            return;
                                          }

                                          contentsManager.playManager?.releasePause();
                                          contentsManager.goto(contentsModel.order.value);
                                          contentsManager.setSelectedMid(contentsModel.mid,
                                              doNotify: true); // 현재 선택된 것이 무엇인지 확실시,
                                        },
                                      ),
                                    );
                                  },
                                  transitionBuilder:
                                      (context, animation, secondaryAnimation, child) {
                                    return Align(
                                      alignment: Alignment.topRight,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.6, -0.3),
                                          end: const Offset(0.4, -0.3),
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                );

                                widget.frameManager.notify();
                              } else {
                                logger.severe('contentsManager is null');
                              }
                            },
                          ),
                        if (frameModel.dragOnMove == true)
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black.withOpacity(0.25),
                          ),
                      ],
                    );
                  }
                  return _createPlayerWidget(model, playManager);
                }

                // ignore: sized_box_for_whitespace
                if (model != null && model.isText() == true) {
                  //print('event received (2) =======================${model.autoSizeType.value}=');
                  if (model.isAutoFontSize()) {
                    logger.info('ContentsMain fontSizeNotifier');
                    CretaAutoSizeText.fontSizeNotifier?.stop(); // rightMenu 에 전달
                  }
                }
                return const SizedBox.shrink();
                // return Container(
                //   width: double.infinity,
                //   height: double.infinity,
                //   color: Colors.transparent,
                //   child: Center(
                //     child: Text(
                //       '${widget.frameModel.order.value} : $contentsCount',
                //       style: CretaFont.titleLarge,
                //     ),
                //   ),
                // );
              });
        });
      }),
    );
  }

  Widget _createPlayerWidget(ContentsModel model, CretaPlayManager playManager) {
    if (model.opacity.value < 1) {
      return Opacity(
        opacity: model.opacity.value,
        child: playManager.createWidget(model),
      );
    }
    return playManager.createWidget(model);
  }

  BoxDecoration _frameDeco(FrameModel model) {
    double opacity = model.opacity.value;
    Color bgColor1 = model.bgColor1.value;
    Color bgColor2 = model.bgColor2.value;
    GradationType gradationType = model.gradationType.value;

    return BoxDecoration(
      color: opacity == 1 ? bgColor1 : bgColor1.withOpacity(opacity),
      //boxShadow: StudioSnippet.basicShadow(),
      gradient: StudioSnippet.gradient(gradationType, bgColor1, bgColor2),
      //borderRadius: _getBorderRadius(model),
      //border: _getBorder(model),
      //boxShadow: model.isNoShadow() == true ? null : [_getShadow(model)],
    );
  }

  // BoxShadow _getShadow(FrameModel model) {
  //   return BoxShadow(
  //     color: model.shadowColor.value
  //         .withOpacity(CretaCommonUtils.validCheckDouble(model.shadowOpacity.value, 0, 1)),
  //     offset: CretaCommonUtils.getShadowOffset(model.shadowDirection.value, model.shadowOffset.value),
  //     shadowBlur: model.shadowBlur.value,
  //     spreadRadius: model.shadowSpread.value,
  //     //blurStyle: widget.shadowIn ? BlurStyle.inner : BlurStyle.normal,
  //   );
  // }

  // BoxBorder? _getBorder(FrameModel model) {
  //   if (model.borderColor.value == Colors.transparent ||
  //       model.borderWidth.value == 0 ||
  //       model.borderType.value == 0) {
  //     return null;
  //   }

  //   BorderSide bs = BorderSide(
  //       color: model.borderColor.value,
  //       width: model.borderWidth.value,
  //       style: BorderStyle.solid,
  //       strokeAlign: CretaCommonUtils.borderPosition(model.borderPosition.value));

  //   if (model.borderType.value > 1) {
  //     return RDottedLineBorder(
  //       dottedLength: CretaCommonUtils.borderStyle[model.borderType.value - 1][0],
  //       dottedSpace: CretaCommonUtils.borderStyle[model.borderType.value - 1][1],
  //       bottom: bs,
  //       top: bs,
  //       left: bs,
  //       right: bs,
  //     );
  //   }
  //   return Border.all(
  //     color: model.borderColor.value,
  //     width: model.borderWidth.value,
  //     style: BorderStyle.solid,
  //     strokeAlign: CretaCommonUtils.borderPosition(model.borderPosition.value),
  //   );
  // }

  // BorderRadius? _getBorderRadius(FrameModel model, {double addRadius = 0}) {
  //   double lt = model.radiusLeftTop.value + addRadius;
  //   double rt = model.radiusRightTop.value + addRadius;
  //   double rb = model.radiusRightBottom.value + addRadius;
  //   double lb = model.radiusLeftBottom.value + addRadius;
  //   if (lt == rt && rt == rb && rb == lb) {
  //     if (lt == 0) {
  //       return BorderRadius.zero;
  //     }
  //     return BorderRadius.all(Radius.circular(model.radiusLeftTop.value));
  //   }
  //   return BorderRadius.only(
  //     topLeft: Radius.circular(lt),
  //     topRight: Radius.circular(rt),
  //     bottomLeft: Radius.circular(lb),
  //     bottomRight: Radius.circular(rb),
  //   );
  // }
}
