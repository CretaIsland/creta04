// ignore_for_file: use_build_context_synchronously

import 'package:creta04/design_system/component/snippet.dart';
import 'package:creta04/drawer_mixin.dart';
import 'package:creta_common/common/creta_color.dart';
import 'package:creta_common/common/creta_const.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import 'drawer_main.dart';
import 'pages/login/creta_account_manager.dart';
import 'pages/studio/studio_variables.dart';
import 'routes.dart';

class DrawerHandle extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isStudioEditor;
  const DrawerHandle({super.key, required this.scaffoldKey, this.isStudioEditor = false});

  @override
  State<DrawerHandle> createState() => DrawerHandleState();

  static GlobalObjectKey drawerMainKey = const GlobalObjectKey<DrawerHandleState>('DrawerHandle');
}

class DrawerHandleState extends State<DrawerHandle> with DrawerMixin {
  OverlayEntry? _overlayEntry;
  // List<double> subMenuWidth = [];
  // List<double> subMenuHeight = [];

  @override
  void initState() {
    super.initState();
    initMixin(context);

    // for (var item in topMenuItems) {
    //   int index = 0;
    //   for (var subItem in item.subMenuItems) {
    //     final textPainter = TextPainter(
    //       text: TextSpan(text: subItem.caption, style: const TextStyle(fontSize: 16.0)),
    //       maxLines: 1,
    //       textDirection: TextDirection.ltr,
    //     )..layout();
    //     if (textPainter.width > subMenuWidth[index]) {
    //       subMenuWidth[index] = textPainter.width;
    //     }
    //     index++;
    //   }
    // }
    invalidate = _invalidate;
  }

  void _invalidate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // print(
    //     '--------------------------${CretaAccountManager.getEnterprise!.imageUrl}-----------------------');
    return Drawer(
      //backgroundColor: CretaColor.primary,
      shadowColor: Colors.grey,
      surfaceTintColor: Colors.grey,
      elevation: 5,
      width: CretaConst.menuHandleWidth,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _shirinkWidget(),
        ),
      ),
    );
  }

  List<Widget> _shirinkWidget() {
    return [
      Expanded(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: CretaColor.primary,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: MouseRegion(
                      onEnter: (event) {
                        widget.isStudioEditor
                            ? widget.scaffoldKey.currentState?.closeDrawer()
                            : widget.scaffoldKey.currentState?.openDrawer();
                      },
                      child: Icon(
                        widget.isStudioEditor
                            ? Icons.keyboard_double_arrow_left_outlined
                            : Icons.keyboard_double_arrow_right_outlined,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    // child: BTN.fill_blue_i_l(
                    //   size: const Size(32, 32),
                    //   iconSize: 24,
                    //   icon: widget.isStudioEditor
                    //       ? Icons.keyboard_double_arrow_left_outlined
                    //       : Icons.keyboard_double_arrow_right_outlined,
                    //   onPressed: () {
                    //     widget.isStudioEditor
                    //         ? widget.scaffoldKey.currentState?.closeDrawer()
                    //         : widget.scaffoldKey.currentState?.openDrawer();
                    //   },
                    // ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Snippet.serviceTypeLogo(false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(topMenuItems.length, (index) {
              var topItem = topMenuItems[index];
              return MouseRegion(
                onEnter: (event) {
                  //_showSubMenu(context, event.position);
                  DrawerMain.expandedMenuItemIndex = index;
                  widget.scaffoldKey.currentState?.openDrawer();
                },
                //child: const Icon(Icons.arrow_drop_down_outlined),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
                  //child: Icon(topItem.iconData),
                  child: Icon(topItem.iconData),
                ),
                //), // Button effect color
              );
              // MouseRegion(
              //   onEnter: (event) {
              //     //_showSubMenu(context, event.position);
              //     DrawerMain.expandedMenuItemIndex = index;
              //     widget.isStudioEditor
              //         ? widget.scaffoldKey.currentState?.closeDrawer()
              //         : widget.scaffoldKey.currentState?.openDrawer();
              //   },
              //  child:
              // InkWell(
              //   // onHover: (event) {
              //   //   DrawerMain.expandedMenuItemIndex = index;
              //   //   widget.scaffoldKey.currentState?.openDrawer();
              //   // },
              //   //onTap: topItem.onPressed,
              //   hoverColor: Colors.grey[200], // Hover effect color
              //   splashColor: Colors.blue,
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              //     //child: Icon(topItem.iconData),
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Icon(topItem.iconData),
              //         MouseRegion(
              //           onEnter: (event) {
              //             //_showSubMenu(context, event.position);
              //             DrawerMain.expandedMenuItemIndex = index;
              //             widget.scaffoldKey.currentState?.openDrawer();
              //           },
              //           child: const Icon(Icons.arrow_drop_down_outlined),

              //         ),
              //       ],
              //     ),
              //     //), // Button effect color
              //   ),
              // );
              // return ListTile(
              //   title: Icon(topItem.iconData),
              //   onTap: topItem.onPressed,
              // );
            }),
            ListTile(
              title: const Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 4.0), //EdgeInsets.only(left: 4.0),
                child: Icon(Icons.exit_to_app),
              ), // 로그아웃 아이콘
              onTap: () {
                StudioVariables.selectedBookMid = '';
                CretaAccountManager.logout()
                    .then((value) => Routemaster.of(context).push(AppRoutes.login));
              },
              //),
            ),
          ],
        ),
      ),
      //const Spacer(),
      // Padding(
      //   padding: const EdgeInsets.only(bottom: 24.0),
      //   child: Center(child: _userInfoButton()),
      // ),
    ];
  }

  // ignore: unused_element
  void _showSubMenu(BuildContext context, Offset position) {
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _hideSubMenu();
        },
        child: Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy,
              child: Material(
                elevation: 4.0,
                child: Container(
                  width: 160,
                  height: 320,
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(4, (index) {
                      return ListTile(
                        title: Text('Sub Menu Item ${index + 1}'),
                        onTap: () {
                          // Handle sub menu item tap
                          _overlayEntry?.remove();
                        },
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSubMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

//Snippet.TooltipWrapper(
//preferredDirection: AxisDirection.up,
//fgColor: Colors.white,
//bgColor: Colors.grey[400]!,
//tooltip: topItem.caption,
// child:
//   MouseRegion(
// onEnter: (details) {
//   print('mouse enter....');
//   if (widget.scaffoldKey.currentState == null) {
//     print('scaffoldKey.currentState is null');
//     return;
//   }
//   DrawerMain.expandedMenuItemIndex = index;
//   widget.scaffoldKey.currentState?.openDrawer();
// },
// onExit: (details) {
//   print('mouse exit');
// },
// child:
