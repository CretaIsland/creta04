import 'package:creta_common/common/creta_font.dart';
import 'package:creta_common/model/creta_model.dart';
import 'package:creta_studio_model/model/contents_model.dart';
import 'package:creta_studio_model/model/page_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hycop_multi_platform/hycop.dart';

class PageIndexDialog extends StatefulWidget {
  final List<CretaModel> modelList;
  final Function(int) onSelected;

  const PageIndexDialog({super.key, required this.modelList, required this.onSelected});

  @override
  State<PageIndexDialog> createState() => _PageIndexDialogState();
}

class _PageIndexDialogState extends State<PageIndexDialog> {
  int _selectedIndex = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      setState(() {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _selectedIndex = (_selectedIndex + 1) % widget.modelList.length;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _selectedIndex = (_selectedIndex - 1 + widget.modelList.length) % widget.modelList.length;
        } else if (event.logicalKey == LogicalKeyboardKey.enter) {
          widget.onSelected(_selectedIndex);
          Navigator.of(context).pop(); // 다이얼로그 닫기
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // double height = modelList.length * 50.0;
    // if (height > 600) {
    //   height = 600;
    // }
    final Size displaySize = MediaQuery.of(context).size;

    double height = displaySize.height * 0.29;
    const double width = 130;
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: SizedBox(
          width: width,
          height: height,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.modelList.length,
            itemBuilder: (context, index) {
              if (widget.modelList[index] is PageModel == true) {
                PageModel model = widget.modelList[index] as PageModel;
                return ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(model.name.value,
                      overflow: TextOverflow.ellipsis, style: CretaFont.bodyMedium),
                  selected: index == _selectedIndex,
                  selectedTileColor: Colors.grey.withOpacity(0.2), // 선택된 항목의 배경색
                  onTap: () {
                    widget.onSelected(index);
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                );
              }
              if (widget.modelList[index] is ContentsModel == true) {
                ContentsModel model = widget.modelList[index] as ContentsModel;
                return ListTile(
                  leading: Icon(model.getIcon()),
                  title: Text(model.name,
                      overflow: TextOverflow.ellipsis, style: CretaFont.bodyMedium),
                  selected: index == _selectedIndex,
                  selectedTileColor: Colors.grey.withOpacity(0.2), // 선택된 항목의 배경색
                  onTap: () {
                    widget.onSelected(index);
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                );
              }
              logger.severe('modelList[$index] is not PageModel or ContentsModel');
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
