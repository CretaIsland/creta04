import 'package:creta_common/common/creta_color.dart';
import 'package:creta_common/common/creta_font.dart';
import 'package:flutter/material.dart';

import '../drawer_mixin.dart';

class HoverExpansionMenu extends StatefulWidget {
  final int initialMenuIndex;
  final List<TopMenuItem> menuItems;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HoverExpansionMenu({
    super.key,
    this.initialMenuIndex = -1,
    required this.menuItems,
    this.scaffoldKey,
  });

  @override
  HoverExpansionMenuState createState() => HoverExpansionMenuState();
}

class HoverExpansionMenuState extends State<HoverExpansionMenu> {
  late int _hoveredMenuIndex;

  @override
  void initState() {
    super.initState();
    _hoveredMenuIndex = widget.initialMenuIndex; // 초기 상태 설정
  }

  void _setHoveredMenuIndex(int index) {
    setState(() {
      _hoveredMenuIndex = index;
    });
  }

  void _clearHoveredMenuIndex() {
    setState(() {
      _hoveredMenuIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(widget.menuItems.length, (index) {
        return _buildMenuItem(index, widget.menuItems[index]);
      }),
    );
  }

  Widget _buildMenuItem(int index, TopMenuItem menuItem) {
    bool isHovered = _hoveredMenuIndex == index;

    return MouseRegion(
      onEnter: (_) => _setHoveredMenuIndex(index),
      onExit: (_) {
        // 마우스가 다른 메뉴로 이동했을 때만 메뉴를 닫음
        if (_hoveredMenuIndex == index) {
          _clearHoveredMenuIndex();
        }
      },
      child: Column(
        children: [
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(menuItem.iconData, color: CretaColor.primary),
            ),
            title: Text(menuItem.caption,
                style: CretaFont.logoStyle.copyWith(
                  fontSize: 32,
                  color: isHovered
                      ? CretaColor.primary
                      : CretaColor.text[400]!, // 확장된 경우와 축소된 경우에 다른 색상 적용
                )),
            trailing: IconButton(
              icon: Icon(
                isHovered ? Icons.expand_less : Icons.expand_more, // 열림 및 닫힘 상태에 따라 아이콘 변경
                color: isHovered ? CretaColor.primary : CretaColor.text[400]!,
              ),
              onPressed: _clearHoveredMenuIndex,
            ),
            tileColor: Colors.amber,
          ),

          // Container(
          //   //color: Colors.blue,
          //   padding: const EdgeInsets.all(16.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Row(
          //         children: [
          //           Icon(menuItem.iconData, color: Colors.white),
          //           const SizedBox(width: 8.0),
          //           Text(menuItem.caption,
          //               style: CretaFont.logoStyle.copyWith(
          //                 fontSize: 32,
          //                 color: isHovered
          //                     ? CretaColor.primary
          //                     : CretaColor.text[400]!, // 확장된 경우와 축소된 경우에 다른 색상 적용
          //               )),
          //         ],
          //       ),
          //       IconButton(
          //         icon: const Icon(Icons.close, color: Colors.white),
          //         onPressed: _clearHoveredMenuIndex,
          //       ),
          //     ],
          //   ),
          // ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: SizedBox(
              height: isHovered ? null : 0.0,
              child: isHovered
                  ? Column(
                      children: menuItem.subMenuItems
                          .map((item) => ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Icon(item.iconData, color: CretaColor.primary),
                                ),
                                title: Text(item.caption,
                                    style:
                                        CretaFont.buttonMedium.copyWith(color: CretaColor.primary)),
                                onTap: () {
                                  item.onPressed?.call();
                                  widget.scaffoldKey?.currentState?.closeDrawer();
                                },
                              ))
                          .toList(),
                    )
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}
