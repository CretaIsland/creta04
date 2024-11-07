//import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:creta04/pages/studio/containees/contents/animated_link_icon.dart';
import 'package:creta04/pages/studio/studio_variables.dart';
import 'package:creta_common/common/creta_font.dart';
import 'package:creta_common/lang/creta_lang.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hycop/common/util/logger.dart';
import 'package:hycop/hycop/absModel/abs_ex_model.dart';
import 'package:hycop/hycop/enum/model_enums.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

import '../../../../data_io/contents_manager.dart';
import '../../../../data_io/frame_manager.dart';
import '../../../../data_io/link_manager.dart';
import '../../../../design_system/buttons/creta_button_wrapper.dart';
import '../../../../design_system/component/creta_right_mouse_menu.dart';
import 'package:creta_common/common/creta_color.dart';
import '../../../../design_system/component/shape/triangle_container.dart';
import '../../../../design_system/menu/creta_popup_menu.dart';
//import 'package:creta_common/lang/creta_lang.dart';
import '../../../../lang/creta_studio_lang.dart';
import 'package:creta_common/model/app_enums.dart';
import 'package:creta_studio_model/model/book_model.dart';
import 'package:creta_studio_model/model/contents_model.dart';
import 'package:creta_studio_model/model/frame_model.dart';
import 'package:creta_studio_model/model/link_model.dart';
import 'package:creta_studio_model/model/page_model.dart';
import '../../../../player/creta_play_manager.dart';
import '../../book_main_page.dart';
import '../../book_preview_menu.dart';
import '../../left_menu/left_menu_page.dart';
import '../../studio_constant.dart';
import '../../studio_getx_controller.dart';
import '../containee_nofifier.dart';
import '../frame/on_link_cursor.dart';
import '../frame/sticker/draggable_stickers.dart';
import '../frame/sticker/stickerview.dart';
import 'play_buttons.dart';

class LinkWidget extends StatefulWidget {
  final double applyScale;
  final FrameManager frameManager;
  final ContentsManager contentsManager;
  final CretaPlayManager playManager;
  final ContentsModel contentsModel;
  final FrameModel frameModel;
  final Offset frameOffset;
  final void Function() onFrameShowUnshow;
  final void Function() showContentsIndex;

  const LinkWidget({
    super.key,
    required this.applyScale,
    required this.frameManager,
    required this.contentsManager,
    required this.playManager,
    required this.contentsModel,
    required this.frameModel,
    required this.frameOffset,
    required this.onFrameShowUnshow,
    required this.showContentsIndex,
  });

  @override
  State<LinkWidget> createState() => _LinkWidgetState();
}

class _LinkWidgetState extends State<LinkWidget> {
  LinkManager? _linkManager;
  OffsetEventController? _linkReceiveEvent;
  OffsetEventController? _linkSendEvent;
  FrameEventController? _sendEvent;
  ContentsEventController? _contentsReceiveEvent;

  //BoolEventController? _lineDrawSendEvent;
  bool _isMove = false;
  Offset _position = Offset.zero;
  Offset _prev = Offset.zero;
  bool _isHover = false;
  BookModel? _bookModel;
  int _linkCount = 0;
  bool _isLinkEditMode = false;

  Size _frameSize = Size.zero;
  bool _isShowMenu = true;

  final double _buttonSize = 20;
  final double _margin = 10;

  @override
  void initState() {
    super.initState();
    _linkManager = widget.contentsManager.findLinkManager(widget.contentsModel.mid);
    final OffsetEventController linkReceiveEvent = Get.find(tag: 'on-link-to-link-widget');
    _linkReceiveEvent = linkReceiveEvent;
    final OffsetEventController linkSendEvent = Get.find(tag: 'frame-each-to-on-link');
    _linkSendEvent = linkSendEvent;
    final FrameEventController sendEvent = Get.find(tag: 'frame-property-to-main');
    _sendEvent = sendEvent;

    final ContentsEventController contentsReceiveEvent = Get.find(tag: 'play-to-link');
    _contentsReceiveEvent = contentsReceiveEvent;

    // final BoolEventController lineDrawSendEvent = Get.find(tag: 'draw-link');
    // _lineDrawSendEvent = lineDrawSendEvent;
    _bookModel = BookMainPage.bookManagerHolder?.onlyOne() as BookModel?;
  }

  @override
  Widget build(BuildContext context) {
    bool hasContents = widget.contentsManager.length() > 0;
    _frameSize = Size(widget.frameModel.width.value, widget.frameModel.height.value);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LinkManager>.value(
          value: _linkManager!,
        ),
      ],
      child: StreamBuilder<Offset>(
          stream: _linkReceiveEvent!.eventStream.stream,
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data is Offset) {
              _position = snapshot.data!;
            }
            //logger.fine('_linkReceiveEvent ($_position) ${LinkParams.isLinkNewMode}');
            return Consumer<LinkManager>(builder: (context, linkManager, child) {
              // LinkManager? linkManager =
              //     widget.contentsManager.findLinkManager(widget.contentsModel.mid);
              // if (linkManager == null) {
              //   return const SizedBox.shrink();
              // }
              bool showLinkCursor = _showLinkCursor(hasContents);

              return
                  //StudioVariables.isPreview == true
                  //    ? _drawAll(linkManager, showLinkCursor)
                  //:
                  SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: MouseRegion(
                  //cursor: SystemMouseCursors.none,
                  cursor: StudioVariables.hideMouse
                      ? SystemMouseCursors.none
                      : LinkParams.isLinkNewMode
                          ? SystemMouseCursors.none
                          : MouseCursor.defer,
                  onEnter: ((event) {
                    setState(() {
                      _isHover = true;
                    });
                  }),
                  onExit: ((event) {
                    setState(() {
                      _isHover = false;
                    });
                  }),
                  onHover: (event) {
                    if (LinkParams.isLinkNewMode &&
                        StudioVariables.isPreview == false &&
                        hasContents) {
                      //logger.fine('sendEvent ${event.localPosition}');
                      _linkSendEvent?.sendEvent(event.localPosition);
                    }
                  },
                  child: _drawAll(linkManager, showLinkCursor),
                ),
              );
            });
          }),
    );
  }

  Widget _drawAll(LinkManager linkManager, bool showLinkCursor) {
    bool showVisibleButton = _showVisibleButton();
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isShowMenu &&
            showVisibleButton &&
            widget.frameModel.width.value * StudioVariables.applyScale > (4 * 36 + 200))
          _drawTitle(),
        ..._drawLinkCursor(linkManager),
        if (_showPlayButton() && _isShowMenu)
          PlayButton(
            key: GlobalObjectKey('PlayButton${widget.frameModel.mid}${widget.applyScale}'),
            applyScale: widget.applyScale,
            frameModel: widget.frameModel,
            playManager: widget.playManager,
            canMove: (_linkCount > 0),
          ),
        if (showLinkCursor) // 생성시 그려지는 것을 말한다.
          OnLinkCursor(
            key: GlobalObjectKey('OnLinkCursor${widget.frameModel.mid}'),
            //pageOffset: widget.frameManager.pageOffset,
            frameOffset: widget.frameOffset,
            frameManager: widget.frameManager,
            frameModel: widget.frameModel,
            contentsManager: widget.contentsManager,
            applyScale: widget.applyScale,
          ),
        if (showVisibleButton) _drawMenuButton(),
        if (showVisibleButton && _isShowMenu) _drawIndexButton(),
        if (showVisibleButton && _isShowMenu) _drawVisibleButton(),
        //if (showVisibleButton) _drawMaximizeButton(),
        //if (showVisibleButton) _drawStopNextContents(),
      ],
    );
  }

  bool _showLinkCursor(bool hasContents) {
    if (!_isHover) {
      return false;
    }
    if (!LinkParams.isLinkNewMode) {
      return false;
    }
    if (!hasContents) {
      return false;
    }
    if (StudioVariables.isPreview) {
      return false;
    }
    if (LinkParams.connectedClass == 'frame') {
      if (LinkParams.connectedMid == widget.frameModel.mid) {
        return false;
      }
    }
    return true;
  }

  Widget _drawTitle() {
    return Positioned(
      left: 12,
      top: 10,
      child: SizedBox(
        width: 200,
        child: Stack(
          children: [
            // 테두리를 그리는 Container
            Text(
              widget.contentsModel.name,
              style: CretaFont.bodyMedium.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = Colors.black, // 테두리 색상
              ),
              overflow: TextOverflow.ellipsis,
            ),
            // 실제 텍스트
            Text(
              widget.contentsModel.name,
              style: CretaFont.bodyMedium.copyWith(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  // Widget _drawTitle() {
  //   return Positioned(
  //     left: 0,
  //     top: 0,
  //     child: Container(
  //       width: 200,
  //       height: 36,
  //       //color: CretaColor.text[400]!.withOpacity(0.5),
  //       alignment: Alignment.centerLeft,
  //       child: Padding(
  //         padding: const EdgeInsets.only(left: 12.0),
  //         child: Text(
  //           widget.contentsModel.name,
  //           style: CretaFont.bodyMedium.copyWith(color: Colors.white),
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _drawMenuButton() {
    double posX =
        (widget.frameModel.width.value - (_isShowMenu ? 3 : 1) * (_buttonSize + _margin)) *
            widget.applyScale;
    double posY = _margin / 2 * widget.applyScale;

    return Positioned(
      left: posX,
      top: posY,
      child: SizedBox(
        width: _buttonSize,
        height: _buttonSize,
        child: BTN.fill_i_s(
          tooltip: CretaStudioLang['showContentsMenut'] ?? '모든 메뉴보이지 않기/보이기',
          onPressed: () {
            setState(() {
              _isShowMenu = !_isShowMenu;
            });
          },
          icon: _isShowMenu
              ? Icons.keyboard_double_arrow_right_outlined
              : Icons.keyboard_double_arrow_left_outlined,
          useTapUp: true,
          //icon2: Icons.featured_play_list_outlined,
          //toggleValue: StudioVariables.showPageIndex,
          //iconSize: 14,
          //doToggle: false,
        ),
      ),
    );
  }

  Widget _drawIndexButton() {
    double posX = (widget.frameModel.width.value - 2 * (_buttonSize + _margin)) * widget.applyScale;
    double posY = _margin / 2 * widget.applyScale;

    return Positioned(
      left: posX,
      top: posY,
      child: SizedBox(
        width: _buttonSize,
        height: _buttonSize,
        child: BTN.fill_i_s(
          tooltip: CretaStudioLang['showContentsIndex'] ?? '콘텐츠 목차 보기',
          onPressed: widget.showContentsIndex,
          icon: Icons.featured_play_list_outlined,
          useTapUp: true,
          //icon2: Icons.featured_play_list_outlined,
          //toggleValue: StudioVariables.showPageIndex,
          //iconSize: 14,
          //doToggle: false,
        ),
      ),
    );
  }

  Widget _drawVisibleButton() {
    double posX = (widget.frameModel.width.value - _buttonSize - _margin) * widget.applyScale;
    double posY = _margin / 2 * widget.applyScale;

    return Positioned(
        left: posX,
        top: posY,
        child: SizedBox(
          width: _buttonSize,
          height: _buttonSize,
          child: BTN.fill_i_s(
              tooltip: CretaStudioLang['showVisibleButton'] ?? '숨기기/보이기',
              useTapUp: true,
              icon: widget.frameModel.isShow.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              onPressed: () {
                BookMainPage.containeeNotifier!.setFrameClick(true);

                widget.frameModel.isShow.set(!widget.frameModel.isShow.value);
                widget.frameManager.changeOrderByIsShow(widget.frameModel);
                //widget.frameModel.isTempVisible = widget.frameModel.isShow.value;
                widget.onFrameShowUnshow.call();
              }),
        ));
  }

  // ignore: unused_element
  Widget _drawStopNextContents() {
    double posX = (widget.frameModel.width.value - 3 * (_buttonSize + _margin)) * widget.applyScale;
    double posY = _margin / 2 * widget.applyScale;

    return Positioned(
        left: posX,
        top: posY,
        child: SizedBox(
          width: _buttonSize,
          height: _buttonSize,
          child: BTN.fill_i_s(
              tooltip: CretaStudioLang['stopRolling'] ?? '고정/해제',
              useTapUp: true,
              icon: StudioVariables.stopNextContents == true
                  ? Icons.push_pin_outlined
                  : Icons.repeat_outlined,
              onPressed: () {
                setState(
                  () {
                    StudioVariables.stopNextContents = !StudioVariables.stopNextContents;
                  },
                );
              }),
        ));
  }

  // ignore: unused_element
  Widget _drawMaximizeButton() {
    double posX = (widget.frameModel.width.value - 2 * (_buttonSize + _margin)) * widget.applyScale;
    double posY = _margin / 2 * widget.applyScale;

    bool isFullScreen = widget.frameModel.isFullScreenTest(_bookModel!);

    return Positioned(
        left: posX,
        top: posY,
        child: SizedBox(
          width: _buttonSize,
          height: _buttonSize,
          child: BTN.fill_i_s(
              tooltip: CretaStudioLang['maximize'] ?? '최대화/되돌리기',
              useTapUp: true,
              icon: isFullScreen ? Icons.fullscreen_exit_outlined : Icons.fullscreen_outlined,
              onPressed: () {
                if (_bookModel == null) return;
                setState(() {
                  widget.frameModel.toggleFullscreen(isFullScreen, _bookModel!);
                  //logger.finest('sendEvent');
                  _sendEvent!.sendEvent(widget.frameModel);
                  _notifyToThumbnail();
                });
              }),
        ));
  }

  bool _showPlayButton() {
    //logger.fine('_showPlayButton(${LinkParams.isLinkNewMode})');
    if (!_isHover) return false;
    if (!_isPlayAble()) return false;
    if (LinkParams.isLinkNewMode) return false;
    if (_isLinkEditMode) return false;
    if (StudioVariables.hideMouse) return false;
    if (widget.frameModel.width.value * StudioVariables.applyScale < 96) return false;

    // Frame 이 선택된 경우에만 보이도록 수정한다.
    // if (CretaManager.frameSelectNotifier != null) {
    //   if (CretaManager.frameSelectNotifier!.selectedAssetId != widget.frameModel.mid) {
    //     return false;
    //   }
    // }
    //if (widget.contentsModel.contentsType == ContentsType.document) return false;
    DraggableStickers.isFrontBackHover = false;
    return true;
  }

  bool _showVisibleButton() {
    //logger.fine('_showPlayButton(${LinkParams.isLinkNewMode})');
    if (!_isHover) return false;
    //if (!_isPlayAble()) return false;
    if (LinkParams.isLinkNewMode) return false;
    if (_isLinkEditMode) return false;
    if (StudioVariables.isPreview == false) return false;
    if (StudioVariables.hideMouse) return false;
    //if (widget.contentsModel.contentsType == ContentsType.document) return false;

    // 화면 사이즈가 너무 작으면 나오지 않는다.
    if (widget.frameModel.width.value * StudioVariables.applyScale < 4 * 36) return false;
    if (widget.frameModel.height.value * StudioVariables.applyScale < 36) return false;
    return true;
  }

  List<Widget> _drawLinkCursor(LinkManager linkManager) {
    linkManager.reOrdering();
    int len = linkManager.getAvailLength();
    if (len == 0) {
      return [];
    }
    //logger.fine('^^^^^^^^^^^^^^^^^^drawEachLink----$len');
    return linkManager
        .orderMapIterator((model) => _drawEachLink(model as LinkModel, linkManager))
        .toList();
  }

  Widget _drawEachLink(LinkModel model, LinkManager linkManager) {
    model.iconKey = GlobalObjectKey('linkIcon${model.mid}');
    const double stickerOffset = LayoutConst.stikerOffset / 2;
    double posX = (model.posX.value - stickerOffset) * widget.applyScale;
    double posY = (model.posY.value - stickerOffset) * widget.applyScale;
    if (posX < 0 || posY < 0) {
      return const SizedBox.shrink();
    }
    _position = Offset(posX, posY);
    //print(
    //    '--------------------drawEachLink : $_position, ${widget.frameModel.width.value * widget.applyScale},${widget.frameModel.height.value * widget.applyScale}');
    _linkCount++;

    double nameWidth = 0;
    const double nameHeight = 20;
    Widget? nameWidget;
    //Widget? verticalLine;
    Widget? triangle;
    String text = '';
    Color textColor = model.nameBgColor.value;
    if (model.showName.value == true) {
      nameWidth += 100;
      text = model.name.value;
      textColor = model.nameBgColor.value;
    }
    if (model.showComment.value == true) {
      nameWidth += 100;
      if (text.isNotEmpty) {
        text += ' ';
      }
      text += model.comment.value;
      textColor = model.commentBgColor.value;
    }

    if (text.isNotEmpty) {
      double frameWidth = widget.frameModel.width.value * widget.applyScale;
      //double frameHeight = widget.frameModel.height.value * widget.applyScale;

      double pX = _position.dx - (nameWidth - model.iconSize.value - 4) / 2;
      double pY = _position.dy - 24;

      if (pX < 0) {
        // 이경우 좌측으로 벗어났다고 본다.
        pX = 0;
      } else if (pX + nameWidth > frameWidth) {
        // 이경우 우측으로 벗어났다고 본다.
        pX = frameWidth - nameWidth - 4;
      }

      double round = 10;
      nameWidget = Positioned(
        left: pX,
        top: pY,
        child: Container(
          width: nameWidth,
          height: nameHeight,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(round), // 둥근 모서리 추가
          ),
          child: Center(
            child: AutoSizeText(
              textAlign: TextAlign.center,
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              minFontSize: 8, // 최소 글자 크기 설정
              style: CretaFont.bodySmall.copyWith(color: textColor),
            ),
          ),
        ),
      );

      // 수직선 추가
      // verticalLine = Positioned(
      //   left: _position.dx + (model.iconSize.value + 4) / 2,
      //   top: _position.dy - 24 + nameHeight,
      //   child: Container(
      //     width: 2,
      //     height: 24 - (model.iconSize.value + 4) / 2, // 원하는 높이로 설정
      //     color: Colors.white.withOpacity(0.5), // 원하는 색상으로 설정
      //   ),
      // );

      const double triangleSize = 10;
      double triangleX = _position.dx + (model.iconSize.value + 4) / 2 - triangleSize / 2;
      if (triangleX + triangleSize + round > frameWidth) {
        triangleX = frameWidth - triangleSize - round;
      }
      triangle = Positioned(
        left: triangleX,
        top: pY + nameHeight,
        child: CustomPaint(
          size: Size(
            triangleSize,
            24 - (model.iconSize.value + 4) / 2,
          ), // 삼각형의 크기 설정
          painter: RevTrianglePainter(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    Widget linkIcon = Positioned(
      left: _position.dx,
      top: _position.dy,
      child:
          //StudioVariables.isPreview // || LinkParams.isLinkNewMode == false
          // ? _mainButton(model)
          // || (LinkParams.isLinkNewMode == false && widget.contentsModel.isLinkEditMode == false)
          //     ? GestureDetector(
          //         onSecondaryTapDown: (details) {
          //           if (StudioVariables.isPreview == true) return;
          //           linkManager.setSelectedMid(model.mid);
          //           _showRightMouseMenu(
          //               model, linkManager, details.globalPosition.dx, details.globalPosition.dy);
          //         },
          //         child: _mainButton(model))
          // :
          GestureDetector(
        onSecondaryTapDown: (details) {
          if (StudioVariables.isPreview == true) return;
          _showLinkProperty(linkManager, model);
          if (_linkManager != null) {
            _showRightMouseMenu(
              model,
              _linkManager!,
              details.globalPosition.dx,
              details.globalPosition.dy,
            );
          }
        },
        onTapUp: (details) {
          // print(
          //     'linkWidget onTapUp --------------------------------------${StudioVariables.isPreview}--');
          if (StudioVariables.isPreview == false) {
            _showLinkProperty(linkManager, model);
            // if (_linkManager != null) {
            //   _showRightMouseMenu(
            //     model,
            //     _linkManager!,
            //     details.globalPosition.dx,
            //     details.globalPosition.dy,
            //   );
            // }
          } else {
            _goto(model);
          }
        },
        onScaleStart: (details) {
          if (StudioVariables.isPreview == true) return;
          //print('linkWidget onScaleStart ----------------------------------------');
          _prev = details.localFocalPoint;
          setState(() {
            _isLinkEditMode = true;
            _isMove = true;
          });
        },
        onScaleUpdate: (details) {
          if (StudioVariables.isPreview == true) return;
          if (_isMove == false) return;

          double dx = (details.localFocalPoint.dx - _prev.dx) / widget.applyScale;
          double dy = (details.localFocalPoint.dy - _prev.dy) / widget.applyScale;
          _prev = details.localFocalPoint;

          double newPosx = model.posX.value + dx;
          double newPosy = model.posY.value + dy;

          double offset = (model.iconSize.value + widget.frameModel.borderWidth.value);

          if (newPosx < offset / 2) newPosx = offset / 2;
          if (newPosy < offset / 2) newPosy = offset / 2;
          if (newPosx > _frameSize.width - offset) newPosx = _frameSize.width - offset;
          if (newPosy > _frameSize.height - offset) newPosy = _frameSize.height - offset;

          // print('point=${details.localFocalPoint}, applyScale=${widget.applyScale}');
          // print('offset=$offset');
          // print('newPosx=$newPosx, newPosy=$newPosy');

          setState(() {
            _isLinkEditMode = false;

            model.posX.set(newPosx);
            model.posY.set(newPosy);
          });
        },
        onScaleEnd: (details) {
          if (StudioVariables.isPreview == true) return;
          _linkManager?.update(link: model).then((value) {
            setState(() {
              _isLinkEditMode = false;
              _isMove = false;
            });
            return value;
          });
        },
        child: Stack(
          //alignment: Alignment.bottomRight,
          children: [
            _mainButton(model),
            //if (widget.contentsModel.isLinkEditMode == true) _delButton(model, linkManager),
          ],
        ),
      ),
    );

    return nameWidget == null
        ? linkIcon
        : Stack(children: [
            linkIcon,
            triangle!,
            nameWidget,
          ]);
  }

  Widget _mainButton(LinkModel model) {
    double iconSize = model.iconSize.value;
    Widget normalWidget = Container(
      width: iconSize + 4,
      height: iconSize + 4,
      decoration: _getBoxDeco(model),
      alignment: Alignment.center,
      child: Icon(
        key: model.iconKey,
        LinkIconType.toIcon(model.iconData.value), //Icons.link_outlined,
        size: iconSize,
        color: _isMove ? CretaColor.primary : model.bgColor.value,
      ),
    );

    if (StudioVariables.isPreview == false) {
      return normalWidget;
    }

    return StreamBuilder<AbsExModel>(
        stream: _contentsReceiveEvent!.eventStream.stream,
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.data is ContentsModel) {
            ContentsModel contentsModel = snapshot.data! as ContentsModel;
            // print('==========================================================');
            // print('CretaPlayManager event received');
            // print('current contents is ${contentsModel.name}');
            // print('==========================================================');
            if (model.connectedMid == contentsModel.mid) {
              return AnimatedLinkIcon(linkModel: model);
            }
          }
          // ContentsModel? currentModel = LinkManager.getCurrentModel(model.mid);
          // if (model.connectedClass == 'contents') {
          //   // 문제는 처음에 widget 이 떳을 때는 target contents 가 아직 플레이되기 전이라는 것이다.
          //   // 따라서, 처음에는  currentModel  이 null  이어도 허용하는 방법이 있다.
          //   if (currentModel == null || currentModel.mid == model.connectedMid) {
          //     return AnimatedLinkIcon(linkModel: model);
          //   }
          // }
          if (model.connectedClass == 'contents') {
            if (LinkManager.isCurrentModel(model.mid, model.connectedMid)) {
              //ContentsModel? currentModel = LinkManager.getCurrentModel(model.mid);
              //print('================ ${currentModel != null ? currentModel.name : 'null'}');
              return AnimatedLinkIcon(linkModel: model);
            }
          }
          return normalWidget;
        });
  }

  BoxDecoration? _getBoxDeco(LinkModel model) {
    if (StudioVariables.isPreview == false) {
      if (model.mid == _linkManager!.getSelectedMid() &&
          widget.frameManager.isSelected(widget.frameModel.mid)) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(width: 1, color: CretaColor.text[700]!),
        );
      }
    }

    return null;
  }

  void _goto(LinkModel model) {
    //print('link button pressed ${model.connectedMid},${model.connectedClass}');
    // print('link button pressed ${widget.frameModel.mid},${widget.frameModel.isShow.value}');
    BookMainPage.containeeNotifier?.setFrameClick(true);

    //if (widget.contentsModel.isLinkEditMode == true) return;
    if (LinkParams.isLinkNewMode == true) return;

    const double stickerOffset = LayoutConst.stikerOffset / 2;
    double posX = (model.posX.value - stickerOffset) * widget.applyScale;
    double posY = (model.posY.value - stickerOffset) * widget.applyScale;

    if (model.connectedClass == 'page') {
      //print('connectedClass is page ----------------------');
      _openPage(model, posX, posY);
      return;
    }

    if (model.connectedClass == 'frame') {
      //print('connectedClass is frame ----------------------');
      _openFrame(model, posX, posY);
      return;
    }
    if (model.connectedClass == 'contents') {
      //print('connectedClass is contents ----------------------');
      _openContents(model, posX, posY); // 먼저 openFrame 을 하고, Contents가 있는 곳까지 넘어가야 한다.
    }
    return;
  }

  void _openPage(LinkModel model, double posX, double posY) {
    PageModel? pageModel =
        BookMainPage.pageManagerHolder!.getModel(model.connectedMid) as PageModel?;
    if (pageModel == null) {
      logger.severe('connected = ${model.connectedMid} not founded');
      return;
    }
    //print('connected = ${model.connectedMid} founded');

    pageModel.isTempVisible = true;
    LinkParams.linkSet(
      Offset(posX, posY),
      widget.frameOffset,
      model.connectedParentMid,
      model.connectedMid,
      'page',
      model.name.value,
      widget.frameManager.pageModel.mid,
    );
    //_lineDrawSendEvent?.sendEvent(isShow);
    //_linkManager?.notify();

    BookPreviewMenu.previewMenuPressed = true;
    BookMainPage.pageManagerHolder?.setSelectedMid(model.connectedMid);
  }

  void _openFrame(LinkModel model, double posX, double posY) {
    FrameModel? childModel = widget.frameManager.getModel(model.connectedMid) as FrameModel?;
    if (childModel == null) {
      logger.severe('connected = ${model.connectedMid} not founded');
      return;
    }
    // print('linkMid=${model.mid}');
    // print('connected=${model.connectedMid}');
    // print('childMid=${childModel.mid}');
    // print('frameMid=${widget.frameModel.mid}');
    // print('PageMid=${widget.frameModel.parentMid.value}');
    //print('connected = ${model.connectedMid} founded');

    childModel.isShow.set(!childModel.isShow.value, save: false, noUndo: true);
    if (childModel.isShow.value == true) {
      // child 모델이 안보이는 상태라면 나타나게 한다.
      //print('child model invisible case ----------------------');
      double order = widget.frameManager.getMaxOrder();
      if (childModel.order.value < order) {
        widget.frameManager.changeOrderByIsShow(childModel);
        widget.frameManager.reOrdering();
      }
      // 여기서 연결선을 연결한다....
      LinkParams.linkSet(
        Offset(posX, posY),
        widget.frameOffset,
        model.connectedParentMid,
        model.connectedMid,
        'frame',
        model.name.value,
        widget.frameManager.pageModel.mid,
      );
      // LinkParams.linkPostion = Offset(posX, posY);
      // LinkParams.orgPostion = widget.frameOffset;
      // LinkParams.connectedMid = model.connectedMid;
      // LinkParams.connectedClass = 'frame';
      // LinkParams.connectedName = model.name;
    } else {
      //print('child model visible case ----------------------');
      // child 모델이 보이는 상태라면 사라지게 한다.
      LinkParams.linkClear();
      widget.frameManager.changeOrderByIsShow(childModel);
      widget.frameManager.reOrdering();
    }
    model.showLinkLine = childModel.isShow.value;
    childModel.save();
    //_lineDrawSendEvent?.sendEvent(isShow);
    //print('link button pressed ${widget.frameModel.mid},${widget.frameModel.isShow.value}');
    widget.frameManager.notify();
    if (StudioVariables.isPreview == true) {
      //if (childModel.isShow.value == false) {
      //  // 보이는 상태라면 사라지게 한다.
      StickerViewState.clearOffStage(widget.frameManager.pageModel.mid);
      StickerViewState.offStageChanged = true;
      //} else {
      // // widget.frameManager.invalidateFrameEach(
      // //   childModel.parentMid.value,
      // //   childModel.mid,
      // // );
      //}
    }

    //_linkManager?.notify();
    return;
  }

  void _openContents(LinkModel model, double posX, double posY) {
    ContentsModel? contentsModel = widget.frameManager.findContentsModel(model.connectedMid);
    if (contentsModel == null) {
      logger.severe('connected = ${model.connectedMid} not founded');
      return;
    }
    FrameModel? childModel =
        widget.frameManager.getModel(contentsModel.parentMid.value) as FrameModel?;
    if (childModel == null) {
      logger.severe('connected frame = ${model.connectedMid} not founded');
      return;
    }
    // print('linkMid=${model.mid}');
    // print('connected=${model.connectedMid}');
    // print('childMid=${childModel.mid}');
    // print('frameMid=${widget.frameModel.mid}');
    // print('PageMid=${widget.frameModel.parentMid.value}');
    //print('connected = ${model.connectedMid} founded');

    if (childModel.isShow.value == false) {
      // child 모델이 안보이는 상태라면 나타나게 한다.
      //print('child model invisible case ----------------------');
      childModel.isShow.set(true, save: false, noUndo: true);
      double order = widget.frameManager.getMaxOrder();
      if (childModel.order.value < order) {
        widget.frameManager.changeOrderByIsShow(childModel);
        widget.frameManager.reOrdering();
      }
      // 여기서 연결선을 연결한다....
      LinkParams.linkSet(
        Offset(posX, posY),
        widget.frameOffset,
        model.connectedParentMid,
        model.connectedMid,
        'contents',
        model.name.value,
        widget.frameManager.pageModel.mid,
      );
      // LinkParams.linkPostion = Offset(posX, posY);
      // LinkParams.orgPostion = widget.frameOffset;
      // LinkParams.connectedMid = model.connectedMid;
      // LinkParams.connectedClass = 'frame';
      // LinkParams.connectedName = model.name;
    }
    model.showLinkLine = childModel.isShow.value;
    childModel.save();
    //_lineDrawSendEvent?.sendEvent(isShow);
    //print('link button pressed ${widget.frameModel.mid},${widget.frameModel.isShow.value}');
    widget.frameManager.notify();
    if (StudioVariables.isPreview == true) {
      //if (childModel.isShow.value == false) {
      //  // 보이는 상태라면 사라지게 한다.
      StickerViewState.clearOffStage(widget.frameManager.pageModel.mid);
      StickerViewState.offStageChanged = true;
      //} else {
      // // widget.frameManager.invalidateFrameEach(
      // //   childModel.parentMid.value,
      // //   childModel.mid,
      // // );
      //}
    }
    //_linkManager?.notify();
    // 여기까지가 Frame 을 보여준것이고, 이제 타겟 Contents 로 이동해야 한다.

    ContentsManager? contentsManager = widget.frameManager.getContentsManager(childModel.mid);

    contentsManager?.playManager?.releasePause();
    //print('----------------------------------------');
    contentsManager?.goto(contentsModel.order.value).then((v) {
      contentsManager.setSelectedMid(contentsModel.mid, doNotify: true); // 현재 선택된 것이 무엇인지 확실시,
    });
    //print('*******************************************${contentsModel.name}');
    return;
  }

  // 오른쪽 마우스 버튼 액션
  void _showRightMouseMenu(LinkModel model, LinkManager linkManager, double dx, double dy) {
    CretaRightMouseMenu.showMenu(
      title: 'linkRightMouseMenu',
      context: context,
      popupMenu: [
        CretaMenuItem(
            caption: CretaStudioLang['followLink'] ?? 'followLink',
            onPressed: () {
              _goto(model);
            }),
        CretaMenuItem(
            caption: CretaStudioLang['deleteLink']!,
            onPressed: () {
              linkManager.delete(link: model);
              LeftMenuPage.initTreeNodes();
              LeftMenuPage.treeInvalidate();
            }),
        CretaMenuItem(
            caption: CretaLang['properties']!,
            onPressed: () {
              //  링크 속성 메뉴를 누르면, 현재 Frame 이 seletct 된것으로 간주해야 한다.
              _showLinkProperty(linkManager, model);
            }),
        // CretaMenuItem(
        //     caption: widget.contentsModel.isLinkEditMode
        //         ? CretaStudioLang['linkControlOff']!
        //         : CretaStudioLang['linkControlOn']!,
        //     onPressed: () {
        //       widget.contentsModel.isLinkEditMode = !widget.contentsModel.isLinkEditMode;
        //       if (widget.contentsModel.isLinkEditMode == true) {
        //         StudioVariables.isAutoPlay = true;
        //       }
        //       _linkSendEvent!.sendEvent(const Offset(1, 1));
        //       setState(() {});
        //     }),
      ],
      itemHeight: 24,
      x: dx,
      y: dy,
      width: 180,
      //height: menuHeight,
      //textStyle: CretaFont.bodySmall,
      iconSize: 12,
      alwaysShowBorder: true,
      borderRadius: 8,
    );
  }

  void _showLinkProperty(LinkManager linkManager, LinkModel model) {
    logger.info('showLinkProperty ${model.connectedMid}, ${model.connectedClass},');
    logger.info('showLinkProperty ${widget.contentsModel.mid}, ${widget.frameModel.mid}');

    widget.frameManager.setSelectedMid(widget.frameModel.mid);
    widget.contentsManager.setSelectedMid(widget.contentsModel.mid);
    linkManager.setSelectedMid(model.mid);
    BookMainPage.containeeNotifier!.set(ContaineeEnum.Link, doNoti: true);

    LeftMenuPage.initTreeNodes();
    LeftMenuPage.treeInvalidate();
  }

  // Widget _delButton(LinkModel model, LinkManager linkManager) {
  //   const double iconSize = 10;
  //   return Positioned(
  //     right: 0,
  //     bottom: 0,
  //     child: GestureDetector(
  //       child: const Icon(Icons.close, size: iconSize, color: Colors.white),
  //       onLongPressDown: (detail) {
  //         logger.fine('delete button pressed ${model.mid}');
  //         linkManager.delete(link: model);
  //       },
  //     ),
  //   );
  // }

  bool _isPlayAble() {
    if (widget.contentsModel.contentsType == ContentsType.text) {
      return false;
    }
    if (widget.contentsModel.contentsType == ContentsType.pdf) {
      return false;
    }
    return true;
  }

  void _notifyToThumbnail() {
    BookMainPage.pageManagerHolder?.invalidateThumbnail(widget.frameModel.parentMid.value);
  }

  // Widget _drawOrder(bool hasContents) {
  //   if (_isHover && !hasContents) {
  //     return Text(
  //       '${widget.contentsModel.order.value}',
  //       style: CretaFont.titleELarge.copyWith(color: Colors.black),
  //     );
  //   }
  //   if (DraggableStickers.isFrontBackHover) {
  //     return Text(
  //       '${widget.contentsModel.order.value} : $hasContents',
  //       style: CretaFont.titleELarge.copyWith(color: Colors.white),
  //     );
  //   }
  //   if (DraggableStickers.isFrontBackHover) {
  //     return Text(
  //       '${widget.contentsModel.order.value} : $hasContents',
  //       style: CretaFont.titleLarge,
  //     );
  //   }
  //   return const SizedBox.shrink();
  // }
}
