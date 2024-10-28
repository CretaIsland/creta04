import 'package:creta_common/common/creta_font.dart';
import 'package:creta_common/model/creta_model.dart';
import 'package:creta_studio_model/model/contents_model.dart';
import 'package:creta_studio_model/model/page_model.dart';
import 'package:flutter/material.dart';
import 'package:hycop/hycop.dart';

class PageIndexDialog extends StatelessWidget {
  final List<CretaModel> modelList;
  final Function(int) onSelected;

  const PageIndexDialog({super.key, required this.modelList, required this.onSelected});

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
      child: SizedBox(
        width: width,
        height: height,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: modelList.length,
          itemBuilder: (context, index) {
            if (modelList[index] is PageModel == true) {
              PageModel model = modelList[index] as PageModel;
              return ListTile(
                leading: const Icon(Icons.menu_book),
                title: Text(model.name.value,
                    overflow: TextOverflow.ellipsis, style: CretaFont.bodyMedium),
                onTap: () {
                  onSelected(index);
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              );
            }
            if (modelList[index] is ContentsModel == true) {
              ContentsModel model = modelList[index] as ContentsModel;
              return ListTile(
                leading: Icon(model.getIcon()),
                title:
                    Text(model.name, overflow: TextOverflow.ellipsis, style: CretaFont.bodyMedium),
                onTap: () {
                  onSelected(index);
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              );
            }
            logger.severe('modelList[$index] is not PageModel or ContentsModel');
            return Container();
          },
        ),
      ),
    );
  }
}
