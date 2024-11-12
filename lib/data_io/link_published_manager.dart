import 'package:creta04/data_io/page_published_manager.dart';
import 'package:creta_studio_model/model/contents_model.dart';
import 'package:hycop_multi_platform/hycop/absModel/abs_ex_model.dart';
import 'package:hycop_multi_platform/hycop/database/abs_database.dart';

import 'package:creta_studio_model/model/frame_model.dart';
import 'package:creta_studio_model/model/link_model.dart';
import 'package:creta_common/model/creta_model.dart';
//import 'contents_manager.dart';
import 'contents_published_manager.dart';
import 'frame_published_manager.dart';
import 'link_manager.dart';
import 'package:creta_user_io/data_io/creta_manager.dart';

class LinkPublishedManager extends CretaManager {
  final LinkManager? linkManager;
  LinkPublishedManager(this.linkManager) : super('creta_link_published', null);

  static List<LinkModel> newLinkList = []; // linkCopy 시에 필요하다.

  @override
  CretaModel cloneModel(CretaModel src) {
    LinkModel retval = newModel(src.mid) as LinkModel;
    src.copyTo(retval);
    return retval;
  }

  @override
  AbsExModel newModel(String mid) => LinkModel(mid, '');

  @override
  Future<int> copyBook(String newBookMid, String? newParentMid) async {
    lock();
    int counter = 0;
    for (var ele in linkManager!.modelList) {
      if (ele.isRemoved.value == true) {
        continue;
      }
      await makeCopy(newBookMid, ele, newParentMid) as LinkModel;
      counter++;
    }
    unlock();
    return counter;
  }

  @override
  Future<AbsExModel> makeCopy(String newBookMid, AbsExModel src, String? newParentMid) async {
    // 이미, publish 되어 있다면, 해당 mid 를 가져와야 한다.
    LinkModel newOne = newModel('') as LinkModel;

    // creat_book_published data 를 만든다.
    newOne.copyFrom(src, newMid: newOne.mid, pMid: newParentMid ?? newOne.parentMid.value);
    newOne.setRealTimeKey(newBookMid);
    //print('makeCopy : newMid=${newOne.mid}, parent=$newParentMid');

    newLinkList.add(newOne);

    // LinkModel oldOne = src as LinkModel;

    // //print('connectedClass = ${newOne.connectedClass}, ${oldOne.connectedClass}');

    // if (newOne.connectedClass == 'page') {
    //   newOne.connectedMid = PagePublishedManager.oldNewMap[oldOne.connectedMid] ?? '';
    //   //print('page link connectedMid = ${oldOne.connectedMid} --> ${newOne.connectedMid}');
    // } else if (newOne.connectedClass == 'frame') {
    //   FrameModel? frame = FramePublishedManager.findNew(oldOne.connectedMid);
    //   if (frame != null) {
    //     newOne.connectedMid = frame.mid;
    //   } else {
    //     newOne.connectedMid = '';
    //   }
    // } else if (newOne.connectedClass == 'contents') {
    //   ContentsModel? contents = ContentsPublishedManager.findNew(oldOne.connectedMid);
    //   if (contents != null) {
    //     newOne.connectedParentMid = contents.parentMid.value;
    //     newOne.connectedMid = contents.mid;
    //   } else {
    //     newOne.connectedParentMid = '';
    //     newOne.connectedMid = '';
    //   }
    // }

    // await createToDB(newOne);
    return newOne;
  }

  static Future<void> updateConnectedMid() async {
    for (var newOne in newLinkList) {
      String oldConnectedMid = newOne.connectedMid;
      if (newOne.connectedClass == 'page') {
        newOne.connectedMid = PagePublishedManager.oldNewMap[oldConnectedMid] ?? '';
        //print('page link connectedMid = ${oldOne.connectedMid} --> ${newOne.connectedMid}');
      } else if (newOne.connectedClass == 'frame') {
        FrameModel? frame = FramePublishedManager.findNew(oldConnectedMid);
        if (frame != null) {
          newOne.connectedMid = frame.mid;
        } else {
          newOne.connectedMid = '';
        }
      } else if (newOne.connectedClass == 'contents') {
        ContentsModel? contents = ContentsPublishedManager.findNew(oldConnectedMid);
        if (contents != null) {
          newOne.connectedParentMid = contents.parentMid.value;
          newOne.connectedMid = contents.mid;
        } else {
          newOne.connectedParentMid = '';
          newOne.connectedMid = '';
        }
      }
      LinkPublishedManager dummyLinkManager = LinkPublishedManager(null);
      await dummyLinkManager.createToDB(newOne);
    }
    PagePublishedManager.oldNewMap.clear();
    FramePublishedManager.oldNewMap.clear();
    ContentsPublishedManager.oldNewMap.clear();
    newLinkList.clear();
  }

  @override
  Future<void> removeChild(String parentMid) async {
    Map<String, QueryValue> query = {};
    query['parentMid'] = QueryValue(value: parentMid);
    query['isRemoved'] = QueryValue(value: false);
    // ignore: unused_local_variable
    final retval = await queryFromDB(query);
    for (var ele in retval) {
      //print('removeChild ${ele.mid}');

      ele.isRemoved.set(true, save: false, noUndo: true);
      await setToDB(ele as CretaModel);
      // LinkPublishedManager childManager = LinkPublishedManager(null);
      // childManager.removeChild(ele.parentMid.value);
      // 여기서 Link 도 훗날 지워줘야 한다.
    }
    modelList.clear();
  }
}
