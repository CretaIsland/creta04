import 'package:flutter/material.dart';

import '../../design_system/buttons/creta_transparent_button.dart';
import 'package:creta_common/common/creta_color.dart';
import 'package:creta_common/common/creta_font.dart';
import '../../lang/creta_studio_lang.dart';
import 'studio_constant.dart';
import 'studio_variables.dart';

class BookPreviewMenu extends StatefulWidget {
  static bool previewMenuPressed = false;
  final int pageNo;
  final int totalPage;
  final void Function() goBackProcess;
  final void Function() muteFunction;
  final void Function() playFunction;
  final Future<void> Function() gotoNext;
  final Future<void> Function() gotoPrev;
  final bool? isPublishedMode;
  final Function? toggleFullscreen;
  const BookPreviewMenu({
    super.key,
    required this.pageNo,
    required this.totalPage,
    required this.goBackProcess,
    required this.muteFunction,
    required this.playFunction,
    required this.gotoNext,
    required this.gotoPrev,
    this.isPublishedMode,
    this.toggleFullscreen,
  });

  @override
  State<BookPreviewMenu> createState() => _BookPreviewMenuState();
}

class _BookPreviewMenuState extends State<BookPreviewMenu> {
  bool _isHover = false;
  bool _buttonIsBusy = false;

  void _toggleFullscreen() {
    widget.toggleFullscreen?.call();
  }

  //mounted 가 되어있는 경우만  setStaTe를 호출하도록 setState를 오버라이드한다.
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      bottom: 0,
      child: MouseRegion(
        onExit: (val) {
          setState(() {
            _isHover = false;
          });
        },
        onEnter: (val) {
          setState(() {
            _isHover = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          width: StudioVariables.workWidth,
          height: LayoutConst.previewMenuHeight,
          color: CretaColor.text.withOpacity(_isHover ? 0.25 : 0.0),
          child: _isHover
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CretaTrasparentButton(
                          onPressed: widget.muteFunction,
                          icon1: Icons.volume_off_outlined,
                          icon2: Icons.volume_up_outlined,
                          iconSize: 20,
                          toggleValue: StudioVariables.isMute,
                        ),
                        const SizedBox(width: 15),
                        CretaTrasparentButton(
                          toggleValue: StudioVariables.stopPaging, //StudioVariables.isAutoPlay,
                          icon1: Icons.push_pin_outlined,
                          icon2: Icons.repeat_outlined,
                          onPressed: widget.playFunction,
                          iconSize: 20,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Visibility(
                          visible: !_buttonIsBusy,
                          child: CretaTrasparentButton(
                            tooltip: CretaStudioLang['gotoBackward'] ?? 'backward',
                            onPressed: () async {
                              setState(() {
                                _buttonIsBusy = true;
                              });
                              await widget.gotoPrev();
                              await Future.delayed(const Duration(milliseconds: 300)); // 연타를 막는다.
                              setState(() {
                                _buttonIsBusy = false;
                              });
                            },
                            icon1: Icons.arrow_back_ios_new_outlined,
                            icon2: Icons.arrow_back_ios_new_outlined,
                            toggleValue: true,
                            iconSize: 20,
                            doToggle: false,
                          ),
                        ),
                        Text(
                          _pageNoString(),
                          style: CretaFont.buttonLarge.copyWith(color: Colors.white),
                        ),
                        Visibility(
                          visible: !_buttonIsBusy,
                          child: CretaTrasparentButton(
                            tooltip: CretaStudioLang['gotoForward'] ?? 'forward',
                            onPressed: () async {
                              setState(() {
                                _buttonIsBusy = true;
                              });
                              await widget.gotoNext();
                              await Future.delayed(const Duration(milliseconds: 300)); // 연타를 막는다.
                              setState(() {
                                _buttonIsBusy = false;
                              });
                            },
                            icon1: Icons.arrow_forward_ios_outlined,
                            icon2: Icons.arrow_forward_ios_outlined,
                            toggleValue: true,
                            iconSize: 20,
                            doToggle: false,
                          ),
                        ),
                      ],
                    ),
                    (widget.isPublishedMode ?? false)
                        ? CretaTrasparentButton(
                            onPressed: _toggleFullscreen,
                            icon1: StudioVariables.isFullscreen
                                ? Icons.fullscreen_exit_outlined
                                : Icons.fullscreen_outlined,
                            icon2: StudioVariables.isFullscreen
                                ? Icons.fullscreen_exit_outlined
                                : Icons.fullscreen_outlined,
                            toggleValue: StudioVariables.isPreview,
                            iconSize: 20,
                            doToggle: false,
                          )
                        : CretaTrasparentButton(
                            tooltip: CretaStudioLang['gobackToStudio']!,
                            onPressed: widget.goBackProcess,
                            icon1: Icons.logout_outlined,
                            icon2: Icons.logout_outlined,
                            toggleValue: StudioVariables.isPreview,
                            iconSize: 20,
                            doToggle: false,
                          ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  String _pageNoString() {
    String pageNo = widget.pageNo < 10 ? '0${widget.pageNo}' : '${widget.pageNo}';
    String totalPage = widget.totalPage < 10 ? '0${widget.totalPage}' : '${widget.totalPage}';
    return ' $pageNo / $totalPage ';
  }
}
