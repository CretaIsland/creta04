import 'package:creta_common/common/creta_font.dart';
import 'package:creta_common/model/creta_model.dart';
import 'package:creta_studio_model/model/page_model.dart';
import 'package:flutter/material.dart';

class PageIndexDialog extends StatelessWidget {
  final List<CretaModel> pageList;
  final Function(int) onSelected;

  const PageIndexDialog({super.key, required this.pageList, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    double height = pageList.length * 50.0;
    if (height > 600) {
      height = 600;
    }
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: 130,
        height: height,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: pageList.length,
          itemBuilder: (context, index) {
            PageModel page = pageList[index] as PageModel;
            return ListTile(
              title: Text(page.name.value,
                  overflow: TextOverflow.ellipsis, style: CretaFont.bodyMedium),
              onTap: () {
                onSelected(index);
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            );
          },
        ),
      ),
    );
  }
}
