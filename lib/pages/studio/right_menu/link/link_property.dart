// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields

//import 'package:creta_studio_model/model/frame_model.dart';
//import 'package:creta_studio_model/model/page_model.dart';
import 'package:creta_studio_model/model/frame_model.dart';
import 'package:creta_studio_model/model/page_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hycop_multi_platform/hycop.dart';
import 'package:creta_common/common/creta_common_utils.dart';

import '../../../../data_io/contents_manager.dart';
import '../../../../data_io/frame_manager.dart';
import '../../../../design_system/buttons/creta_toggle_button.dart';
import '../../../../design_system/component/creta_proprty_slider.dart';
import 'package:creta_common/common/creta_color.dart';
import 'package:creta_common/common/creta_font.dart';
import '../../../../design_system/text_field/creta_text_field.dart';
import '../../../../lang/creta_studio_lang.dart';
import 'package:creta_common/model/app_enums.dart';
import 'package:creta_studio_model/model/book_model.dart';
import 'package:creta_studio_model/model/contents_model.dart';
import 'package:creta_studio_model/model/link_model.dart';
//import '../../book_main_page.dart';
import '../../book_main_page.dart';
import '../../studio_getx_controller.dart';
//import '../../studio_variables.dart';
import '../property_mixin.dart';

class LinkProperty extends StatefulWidget {
  final ContentsModel contentsModel;
  final LinkModel linkModel;
  final FrameManager frameManager;
  final BookModel? book;
  final void Function(Color) onColorChanged;
  final void Function(Color) onNameColorChanged;
  final void Function(Color) onCommentColorChanged;
  final void Function(double) onOpacityChanged;
  final void Function() onPosChanged;
  final void Function(double) onSizeChanged;
  final void Function(LinkIconType) onIconDataChanged;

  const LinkProperty({
    super.key,
    required this.linkModel,
    required this.contentsModel,
    required this.frameManager,
    required this.book,
    required this.onColorChanged,
    required this.onNameColorChanged,
    required this.onCommentColorChanged,
    required this.onOpacityChanged,
    required this.onPosChanged,
    required this.onSizeChanged,
    required this.onIconDataChanged,
  });

  @override
  State<LinkProperty> createState() => _LinkPropertyState();
}

class _LinkPropertyState extends State<LinkProperty> with PropertyMixin {
  // ignore: unused_field
  ContentsManager? _contentsManager;

  // ignore: unused_field
  static bool _isLinkControlOpen = false;

  // ignore: unused_field
  OffsetEventController? _linkSendEvent;
  // ignore: unused_field
  BoolEventController? _linkReceiveEvent;

  static bool _isShapeOpen = true;
  static bool _isSizeOpen = true;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    logger.finest('_LinkPropertyState.initState');

    super.initMixin();
    super.initState();

    final OffsetEventController linkSendEvent = Get.find(tag: 'on-link-to-link-widget');
    _linkSendEvent = linkSendEvent;
    final BoolEventController linkReceiveEvent = Get.find(tag: 'link-widget-to-property');
    _linkReceiveEvent = linkReceiveEvent;

    _contentsManager = widget.frameManager.getContentsManager(widget.contentsModel.parentMid.value);
  }

  @override
  void dispose() {
    //_scrollController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //FrameModel frameModel = _contentsManager!.frameModel;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(children: [
        //_linkControl(),

        propertyCard(
          //padding: horizontalPadding,
          isOpen: _isSizeOpen,
          onPressed: () {
            setState(() {
              _isSizeOpen = !_isSizeOpen;
            });
          },
          titleWidget: Text(CretaStudioLang['linkProp']!, style: CretaFont.titleSmall),
          onDelete: () {},
          hasRemoveButton: false,
          bodyWidget: Column(
            children: [
              _whereToLink(),
              _position(),
              propertyLine(
                topPadding: 10,
                name: CretaStudioLang['noIconClickContents'] ?? '아이콘 없이 콘텐츠 클릭으로 연결',
                widget: CretaToggleButton(
                  width: 54 * 0.75,
                  height: 28 * 0.75,
                  defaultValue: widget.linkModel.noIcon.value,
                  onSelected: (val) {
                    // 이경우 콘텐츠는 1개의 링크만 존재해야함.
                    widget.linkModel.noIcon.set(val);
                    widget.onPosChanged();
                    setState(() {});
                  },
                ),
              ),
              Visibility(
                visible: !widget.linkModel.noIcon.value,
                child: propertyLine(
                  // 아이콘 색
                  name: CretaStudioLang['linkColor']!,
                  widget: colorIndicator(
                    widget.linkModel.bgColor.value,
                    1.0,
                    onColorChanged: (color) {
                      widget.onColorChanged(color);
                      setState(() {});
                    },
                    onClicked: () {},
                  ),
                ),
              ),
              Visibility(
                visible: !widget.linkModel.noIcon.value,
                child: CretaPropertySlider(
                  // 아이콘 투명도
                  key: GlobalKey(),
                  name: CretaStudioLang['opacity']!,
                  min: 0,
                  max: 100,
                  value: CretaCommonUtils.validCheckDouble(
                      widget.linkModel.bgColor.value.opacity, 0, 1),
                  valueType: SliderValueType.reverse,
                  onChannged: widget.onOpacityChanged,
                  onChanngeComplete: widget.onOpacityChanged,
                  //onChanngeComplete: onOpacityChangeComplete,
                  postfix: '%',
                ),
              ),
              Visibility(
                visible: !widget.linkModel.noIcon.value,
                child: CretaPropertySlider(
                  // 아이콘 크기
                  key: GlobalKey(),
                  name: CretaStudioLang['linkIconSize']!,
                  min: 0,
                  max: 50,
                  value: widget.linkModel.iconSize.value,
                  valueType: SliderValueType.normal,
                  onChannged: widget.onSizeChanged,
                  onChanngeComplete: widget.onSizeChanged,
                  //onChanngeComplete: onSpreadChangeComplete,
                ),
              ),
              propertyLine(
                name: CretaStudioLang['linkClass']!,
                widget: CretaTextField(
                  width: 200,
                  height: 40,
                  hintText: 'comment here',
                  textFieldKey: GlobalKey(),
                  value: widget.linkModel.comment.value,
                  onEditComplete: ((value) {
                    logger.info('onEditComplete');
                    widget.linkModel.comment.set(value);
                    widget.onPosChanged();
                  }),
                ),
              ),
              propertyLine(
                topPadding: 10,
                name: CretaStudioLang['showLinkName'] ?? '이름 보이기',
                widget: Row(
                  children: [
                    CretaToggleButton(
                      width: 54 * 0.75,
                      height: 28 * 0.75,
                      defaultValue: widget.linkModel.showName.value,
                      onSelected: (val) {
                        widget.linkModel.showName.set(val);
                        widget.onPosChanged();
                        //setState(() {});
                      },
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text("/ ${CretaStudioLang['color'] ?? '색'}")),
                    colorIndicator(
                      widget.linkModel.nameBgColor.value,
                      1.0,
                      onColorChanged: (color) {
                        widget.onNameColorChanged(color);
                        setState(() {});
                      },
                      onClicked: () {},
                    ),
                  ],
                ),
              ),
              propertyLine(
                topPadding: 10,
                name: CretaStudioLang['showLinkComment'] ?? '내용 보이기',
                widget: Row(
                  children: [
                    CretaToggleButton(
                      width: 54 * 0.75,
                      height: 28 * 0.75,
                      defaultValue: widget.linkModel.showComment.value,
                      onSelected: (val) {
                        widget.linkModel.showComment.set(val);
                        widget.onPosChanged();
                        //setState(() {});
                      },
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text("/ ${CretaStudioLang['color'] ?? '색'}")),
                    colorIndicator(
                      widget.linkModel.commentBgColor.value,
                      1.0,
                      onColorChanged: (color) {
                        widget.onCommentColorChanged(color);
                        setState(() {});
                      },
                      onClicked: () {},
                    ),
                  ],
                ),
              ),

              // propertyLine(
              //   name: CretaStudioLang['linkNameColor'] ?? '링크 이름 색',
              //   widget: colorIndicator(
              //     widget.linkModel.nameBgColor.value,
              //     1.0,
              //     onColorChanged: (color) {
              //       widget.onNameColorChanged(color);
              //       setState(() {});
              //     },
              //     onClicked: () {},
              //   ),
              // ),
              //  propertyLine(
              //   name: CretaStudioLang['linkCommentColor'] ?? '링크 내용 색',
              //   widget: colorIndicator(
              //     widget.linkModel.commentBgColor.value,
              //     1.0,
              //     onColorChanged: (color) {
              //       widget.onCommentColorChanged(color);
              //       setState(() {});
              //     },
              //     onClicked: () {},
              //   ),
              // ),
            ],
          ),
        ),

        propertyDivider(),
        Visibility(
          visible: !widget.linkModel.noIcon.value,
          child: _shape(),
        ),
      ]),
    );
    //});
  }

  IconData _getLinkTypeIcon(String classString) {
    IconData iconData = Icons.link;
    if (classString == 'page') {
      iconData = Icons.menu_book;
    } else if (classString == 'frame') {
      iconData = Icons.space_dashboard_outlined;
    } else if (classString == 'contents') {
      iconData = Icons.photo;
    }
    return iconData;
  }

  String _getLinkObjectName(String classString, String classMid) {
    if (classString == 'page') {
      PageModel? model = BookMainPage.pageManagerHolder!.getModel(classMid) as PageModel?;
      if (model != null) {
        return model.name.value;
      }
    } else if (classString == 'frame') {
      FrameModel? model = widget.frameManager.getModel(classMid) as FrameModel?;
      if (model != null) {
        return model.name.value;
      }
    } else if (classString == 'contents') {
      // 아직 ContentsType 이 없음.
      ContentsModel? model = widget.frameManager.findContentsModel(classMid);
      if (model != null) {
        return model.name;
      }
    }
    return 'unknown';
  }

  Widget _whereToLink() {
    return propertyLine(
      topPadding: 24,
      name: CretaStudioLang['whereToLink'] ?? '링크된 곳',
      widget: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          children: [
            Icon(_getLinkTypeIcon(widget.linkModel.connectedClass)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(
                width: 220,
                child: Text(
                  _getLinkObjectName(
                      widget.linkModel.connectedClass, widget.linkModel.connectedMid),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _position() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 97,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CretaStudioLang['posX']!,
                  style: titleStyle,
                ),
                CretaTextField.xshortNumber(
                  defaultBorder: Border.all(color: CretaColor.text[100]!),
                  width: 45,
                  limit: 5,
                  textFieldKey: GlobalKey(),
                  value: widget.linkModel.posX.value.round().toString(),
                  hintText: '',
                  onEditComplete: ((value) {
                    logger.info('onEditComplete');
                    widget.linkModel.posX.set(int.parse(value).toDouble());
                    widget.onPosChanged();
                  }),
                  minNumber: 0,
                ),
              ],
            ),
          ),
          SizedBox(width: 64),
          SizedBox(
            width: 97,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CretaStudioLang['posY']!,
                  style: titleStyle,
                ),
                CretaTextField.xshortNumber(
                  defaultBorder: Border.all(color: CretaColor.text[100]!),
                  width: 45,
                  limit: 5,
                  textFieldKey: GlobalKey(),
                  value: widget.linkModel.posY.value.round().toString(),
                  //value: widget.model.posY.value.toString(),
                  hintText: '',
                  minNumber: 0,
                  onEditComplete: ((value) {
                    widget.linkModel.posY.set(int.parse(value).toDouble());
                    widget.onPosChanged();
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shape() {
    // 아이콘 모양
    return propertyCard(
      isOpen: _isShapeOpen,
      onPressed: () {
        setState(() {
          _isShapeOpen = !_isShapeOpen;
        });
      },
      titleWidget: Text(CretaStudioLang['shape']!, style: CretaFont.titleSmall),
      trailWidget: widget.linkModel.iconData.value == LinkIconType.none
          ? const SizedBox.shrink()
          : IconButton(
              icon: Icon(LinkIconType.toIcon(widget.linkModel.iconData.value)),
              iconSize: 24,
              onPressed: () {},
              color: CretaColor.primary,
            ),
      hasRemoveButton: false,
      onDelete: () {},
      bodyWidget: _shapeListView(
        onShapeTapPressed: (value) {
          setState(() {
            widget.linkModel.iconData.set(value);
          });
          widget.onIconDataChanged(value); // _sendEvent!.sendEvent(widget.model);;
        },
      ),
    );
  }

  Widget _shapeListView({required void Function(LinkIconType value) onShapeTapPressed}) {
    List<Widget> shapeList = [];

    for (int i = 1; i < LinkIconType.end.index; i++) {
      LinkIconType gType = LinkIconType.values[i];
      bool isSelected = (widget.linkModel.iconData.value == gType);

      shapeList.add(IconButton(
        icon: Icon(LinkIconType.toIcon(gType)),
        iconSize: 36,
        onPressed: () {
          onShapeTapPressed(gType);
        },
        color: isSelected ? CretaColor.primary : CretaColor.text[400],
      ));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      //child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: gradientList),
      child: Wrap(children: shapeList),
    );
  }

  // Widget _linkControl() {
  //   bool isLinkEditMode = widget.contentsModel.isLinkEditMode;
  //   return StreamBuilder<bool>(
  //       stream: _linkReceiveEvent!.eventStream.stream,
  //       builder: (context, snapshot) {
  //         if (snapshot.data != null && snapshot.data is bool) {
  //           if (snapshot.data != null) {
  //             isLinkEditMode = snapshot.data!;
  //           }
  //         }
  //         logger.fine('_linkControl ($isLinkEditMode)');
  //         // if (offset == Offset.zero) {
  //         //   return const SizedBox.shrink();
  //         // }
  //         return Padding(
  //           padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 5),
  //           child: propertyCard(
  //             isOpen: _isLinkControlOpen,
  //             onPressed: () {
  //               setState(() {
  //                 _isLinkControlOpen = !_isLinkControlOpen;
  //               });
  //             },
  //             titleWidget: Text(CretaStudioLang['linkControl']!, style: CretaFont.titleSmall),
  //             //trailWidget: isColorOpen ? _gradationButton() : _colorIndicator(),
  //             trailWidget: _linkToggle(isLinkEditMode),
  //             hasRemoveButton: false,
  //             onDelete: () {},
  //             bodyWidget: _linkControlBody(isLinkEditMode),
  //           ),
  //         );
  //       });
  // }

  // Widget _linkControlBody(bool isLinkEditMode) {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 16.0),
  //     child: propertyLine(
  //       // 링크 편집 모드
  //       name: CretaStudioLang['linkControl']!,
  //       widget: _linkToggle(isLinkEditMode),
  //     ),
  //   );
  // }

  // Widget _linkToggle(bool isLinkEditMode) {
  //   logger.fine('_linkToggle ($isLinkEditMode)');
  //   return CretaToggleButton(
  //     key: GlobalObjectKey('_linkToggle$isLinkEditMode${widget.contentsModel.mid}'),
  //     width: 54 * 0.75,
  //     height: 28 * 0.75,
  //     defaultValue: isLinkEditMode,
  //     onSelected: (value) {
  //       widget.contentsModel.isLinkEditMode = value;
  //       if (widget.contentsModel.isLinkEditMode == true) {
  //         StudioVariables.isAutoPlay = true;
  //       }
  //       _linkSendEvent!.sendEvent(Offset(1, 1));
  //       setState(() {});
  //     },
  //   );
  // }
}
