import 'dart:ui';

import 'package:creta_studio_io/data_io/base_link_manager.dart';
import 'package:creta_studio_model/model/page_model.dart';
import 'package:hycop/hycop.dart';

//import 'package:creta_user_io/data_io/creta_manager.dart';
import 'package:creta_common/model/creta_model.dart';
import '../design_system/component/tree/flutter_treeview.dart' as tree;

import 'package:creta_studio_model/model/book_model.dart';
import 'package:creta_studio_model/model/contents_model.dart';
import 'package:creta_studio_model/model/frame_model.dart';
import 'package:creta_studio_model/model/link_model.dart';
//import 'package:creta_studio_model/model/page_model.dart';
import '../pages/studio/book_main_page.dart';
import '../pages/studio/book_preview_menu.dart';
import '../pages/studio/containees/containee_nofifier.dart';
import '../pages/studio/containees/frame/sticker/stickerview.dart';
import '../pages/studio/left_menu/left_menu_page.dart';
//import '../pages/studio/studio_constant.dart';
import '../pages/studio/studio_variables.dart';
import 'book_manager.dart';
import 'contents_manager.dart';
import 'frame_manager.dart';
import 'page_manager.dart';

class LinkManager extends BaseLinkManager {
  // final String bookMid;
  // final PageModel pageModel;
  // final FrameModel frameModel;
  // final bool isPublishedMode;

  LinkManager(
    super.contentsMid,
    super.bookMid,
    super.pageModel,
    super.frameModel, {
    super.tableName,
    super.isPublishedMode = false,
  }) {
    //saveManagerHolder?.registerManager('link', this, postfix: contentsMid);
  }

  LinkManager.dummy() : super('', '', PageModel('', BookModel('')), FrameModel('', '')) {
    //saveManagerHolder?.registerManager('link', this, postfix: contentsMid);
  }

  static List<LinkModel> newLinkList = []; // linkCopy 시에 필요하다.

  static final Map<String, LinkManager> _linkManagerMap = {}; // classMid, LinkManager
  static final Map<String, ContentsManager> _contentsManagerMap =
      {}; // linkMid, 그 링크가 지칭하고 있는 콘텐츠의 매니저를 물고 있다. ContentsManager
  static Map<String, LinkManager> get linkManagerMap => _linkManagerMap;
  static void setLinkManager(String contentsId, LinkManager linkManager) {
    //print('setLinkManager($contentsId) ===================================');
    _linkManagerMap[contentsId] = linkManager;
  }

  static LinkManager? findLinkManager(String contentsMid) {
    return _linkManagerMap[contentsMid];
  }

  static ContentsManager? findContentsManager(String linkMid) {
    return _contentsManagerMap[linkMid];
  }

  static bool isCurrentModel(String linkMid, String contentsMid) {
    ContentsManager? contentsManager = findContentsManager(linkMid);
    if (contentsManager != null) {
      return contentsManager.isCurrentModel(contentsMid);
    }
    return false;
  }

  static ContentsModel? getCurrentModel(String linkMid) {
    ContentsManager? contentsManager = findContentsManager(linkMid);
    if (contentsManager != null) {
      return contentsManager.getCurrentModel();
    }
    return null;
  }

  static void clearLink(String contentsMid) {
    for (var linkManager in _linkManagerMap.values) {
      linkManager.removeLink(contentsMid);
    }
  }

  LinkModel? findLink(String connectedMid) {
    for (var ele in modelList) {
      LinkModel model = ele as LinkModel;
      if (model.connectedMid == connectedMid) {
        return model;
      }
    }
    return null;
  }

  // @override
  // CretaModel cloneModel(CretaModel src) {
  //   LinkModel retval = newModel(src.mid) as LinkModel;
  //   src.copyTo(retval);
  //   return retval;
  // }

  @override
  Future<int> copyBook(String newBookMid, String? newParentMid) async {
    lock();
    int counter = 0;
    for (var ele in modelList) {
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

    // if (oldOne.connectedClass == 'page') {
    //   newOne.connectedMid = PageManager.oldNewMap[oldOne.connectedMid] ?? '';
    //   //print('page link connectedMid = ${oldOne.connectedMid} --> ${newOne.connectedMid}');
    // } else if (oldOne.connectedClass == 'frame') {
    //   FrameModel? frame = FrameManager.findNew(oldOne.connectedMid);
    //   if (frame != null) {
    //     newOne.connectedMid = frame.mid;
    //   } else {
    //     newOne.connectedMid = '';
    //   }
    // } else if (oldOne.connectedClass == 'contents') {
    //   ContentsModel? contents = ContentsManager.findNew(oldOne.connectedMid);
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
        newOne.connectedMid = PageManager.oldNewMap[oldConnectedMid] ?? '';
        //print('page link connectedMid = ${oldOne.connectedMid} --> ${newOne.connectedMid}');
      } else if (newOne.connectedClass == 'frame') {
        FrameModel? frame = FrameManager.findNew(oldConnectedMid);
        if (frame != null) {
          newOne.connectedMid = frame.mid;
        } else {
          newOne.connectedMid = '';
        }
      } else if (newOne.connectedClass == 'contents') {
        ContentsModel? contents = ContentsManager.findNew(oldConnectedMid);
        if (contents != null) {
          newOne.connectedParentMid = contents.parentMid.value;
          newOne.connectedMid = contents.mid;
        } else {
          newOne.connectedParentMid = '';
          newOne.connectedMid = '';
        }
      }
      LinkManager dummyLinkManager = LinkManager.dummy();
      await dummyLinkManager.createToDB(newOne);
    }
    PageManager.oldNewMap.clear();
    FrameManager.oldNewMap.clear();
    ContentsManager.oldNewMap.clear();
    newLinkList.clear();
  }

  // @override
  // AbsExModel newModel(String mid) => LinkModel(mid, bookMid);

  Future<int> getAllLinks({required String contentsId}) async {
    //print('getAllLinks($contentsId) ===================================');
    startTransaction();
    try {
      Map<String, QueryValue> query = {};
      query['parentMid'] = QueryValue(value: contentsId);
      query['isRemoved'] = QueryValue(value: false);
      await queryFromDB(query);
      reOrdering();
    } catch (error) {
      logger.fine('something wrong in LinkManager >> $error');
      return 0;
    }
    // if (StudioVariables.isPreview == true && hasLinkCache == true) {
    //   print('insertConnectedContentsManager($contentsId) ===================================');
    //   await insertConnectedContentsManager();
    // }
    endTransaction();
    return modelList.length;
  }

  Future<LinkModel> createNextLink({
    required ContentsModel contentsModel,
    required double posX,
    required double posY,
    String? name,
    required String? connectedParentMid,
    String? connectedMid,
    String? connectedClass,
    bool doNotify = true,
    required void Function(bool, ContentsModel, Offset) onComplete,
  }) async {
    logger.fine('createNext()');
    LinkModel link = LinkModel('', contentsModel.realTimeKey);
    link.parentMid.set(contentsModel.mid, save: false, noUndo: true);
    link.posX.set(posX, save: false, noUndo: true);
    link.posY.set(posY, save: false, noUndo: true);
    link.name.set(name ?? '', save: false, noUndo: true);
    link.connectedParentMid = connectedParentMid ?? '';
    link.connectedMid = connectedMid ?? '';
    link.connectedClass = connectedClass ?? '';
    link.order.set(getMaxOrder() + 1, save: false, noUndo: true);

    await createToDB(link);
    insert(link, postion: getLength(), doNotify: doNotify);
    //selectedMid = link.mid;
    //if (doNotify) notify();
    reOrdering();
    setSelectedMid(link.mid, doNotify: doNotify);
    BookMainPage.containeeNotifier!.set(ContaineeEnum.Link, doNoti: true);
    LeftMenuPage.initTreeNodes();
    LeftMenuPage.treeInvalidate();

    onComplete.call(false, contentsModel, Offset(posX, posY));

    MyChange<LinkModel> c = MyChange<LinkModel>(
      link,
      execute: () {},
      redo: () async {
        link.isRemoved.set(false, noUndo: true);
        insert(link, postion: getLength(), doNotify: doNotify);
        selectedMid = link.mid;
        onComplete.call(false, contentsModel, Offset(posX, posY));
      },
      undo: (LinkModel old) async {
        link.isRemoved.set(true, noUndo: true);
        remove(link);
        selectedMid = '';
        onComplete.call(true, contentsModel, Offset(posX, posY));
      },
    );
    mychangeStack.add(c);

    return link;
  }

  Future<LinkModel> update({
    required LinkModel link,
    bool doNotify = true,
  }) async {
    logger.fine('update()');
    await setToDB(link);
    updateModel(link);
    selectedMid = link.mid;
    if (doNotify) notify();

    return link;
  }

  Future<LinkModel> delete({
    required LinkModel link,
    bool doNotify = true,
  }) async {
    logger.fine('delete()');
    link.isRemoved.set(
      true,
      save: true,
      doComplete: (val) {
        updateModel(link);
        if (selectedMid == link.mid) {
          selectedMid = "";
        }
        if (doNotify) notify();
      },
      undoComplete: (val) {
        updateModel(link);
        if (selectedMid == "") {
          selectedMid = link.mid;
        }
        if (doNotify) notify();
      },
    );
    //await setToDB(link);

    updateModel(link);
    if (selectedMid == link.mid) {
      selectedMid = "";
    }
    if (doNotify) notify();

    return link;
  }

  void removeLink(String frameOrPageMid) {
    for (var ele in modelList) {
      LinkModel model = ele as LinkModel;
      logger.fine('${model.connectedMid} ?? $frameOrPageMid');

      if (model.connectedMid == frameOrPageMid) {
        logger.fine('${model.mid} deleted--------------------$frameOrPageMid');
        model.isRemoved.set(true);
      }
    }
  }

  Future<void> copyLinks(String contentsMid, String bookMid) async {
    double order = 1;
    for (var ele in modelList) {
      LinkModel org = ele as LinkModel;
      if (org.isRemoved.value == true) continue;
      LinkModel newModel = LinkModel('', bookMid);
      newModel.copyFrom(org, newMid: newModel.mid, pMid: contentsMid);
      newModel.order.set(order++, save: false, noUndo: true);
      logger.fine('create new Link ${newModel.mid}');
      await createToDB(newModel);
    }
  }

  String toJson() {
    if (getAvailLength() == 0) {
      return ',\n\t\t\t\t"links" : []\n';
    }
    int linkCount = 0;
    String jsonStr = '';
    jsonStr += ',\n\t\t\t\t"links" : [\n';
    orderMapIterator((val) {
      LinkModel link = val as LinkModel;
      String linkStr = link.toJson(tab: '\t\t\t\t');
      if (linkCount > 0) {
        jsonStr += ',\n';
      }
      jsonStr += '\t\t\t\t{\n$linkStr\n\t\t\t\t}';
      linkCount++;
      return null;
    });
    jsonStr += '\n\t\t\t\t]\n';
    return jsonStr;
  }

  Future<bool> makeClone(
    BookModel newBook, {
    bool cloneToPublishedBook = false,
  }) async {
    for (var link in modelList) {
      String parentContentsMid = BookManager.cloneContentsIdMap[link.parentMid.value] ?? '';
      logger.severe('find: (${link.parentMid.value}) => ($parentContentsMid)');
      AbsExModel newModel = await makeCopy(newBook.mid, link, parentContentsMid);
      logger.severe('clone is created ($collectionId.${newModel.mid}) from (source:${link.mid})');
      BookManager.cloneLinkIdMap[link.mid] = newModel.mid;
    }
    return true;
  }

  List<tree.Node> toNodes() {
    //print('invoke contentsManager.toNodes()');
    List<tree.Node> conNodes = [];
    for (var ele in orderValues()) {
      LinkModel model = ele as LinkModel;
      if (model.isRemoved.value == true) {
        continue;
      }
      //print('model.name=${model.name}');

      final String name = model.name.value;
      conNodes.add(tree.Node<CretaModel>(
          key: '${pageModel.mid}/${frameModel.mid}/${model.parentMid.value}/${model.mid}',
          keyType: ContaineeEnum.Link,
          label: 'link To $name',
          expanded: model.expanded || isSelected(model.mid),
          data: model,
          root: pageModel.mid));
    }
    return conNodes;
  }

  Future<List<AbsExModel>?> getLinkModels(String className, String classMid) async {
    logger.fine('getLinkObject($className,$classMid)');
    //int count = 0;
    Map<String, QueryValue> query = {};
    query['connectedClass'] = QueryValue(value: className);
    query['connectedMid'] = QueryValue(value: classMid);
    query['isRemoved'] = QueryValue(value: false);

    List<AbsExModel> list = await queryFromDB(query);
    if (list.isEmpty) {
      return null;
    }
    return list;
  }

  static Future<bool> deleteLinkReferenceMe(String className, String classMid) async {
    logger.fine('deleteLinkReferenceMe($className,$classMid)');

    BookModel book = BookMainPage.bookManagerHolder!.onlyOne() as BookModel;
    PageModel pageModel = PageModel('', book);
    FrameModel? frameModel = FrameModel('', book.mid);

    // 링크 모델을 구성한다.
    LinkManager? dummyLinkManager = LinkManager('', book.mid, pageModel, frameModel);
    List<AbsExModel>? linkModelList = await dummyLinkManager.getLinkModels(className, classMid);
    if (linkModelList == null) {
      logger.severe('Failed to find linkModel $classMid');
      return false;
    }

    //// 이로서 db 에서는 일단 지웠다. 그러나 메모리에는 남아있기 때문에,  이 이하의 문장은 메모리에서 이를 제거하기 위한 작업이다.
    //dummyLinkManager.delete(link: linkModel);

    // // 이 링크 모델을 관리하는 진짜 링크매니저를 찾아서 delete 를 호출해야 한다.

    // //1. 먼저 이 링크를 포함한, contentsModel 을 찾는다.  (반드시 dummyManager 를 통해 찾아야 한다.)
    // ContentsManager? dummyContentsManager = ContentsManager.dummy(book);
    // ContentsModel? parentContent =
    //     await dummyContentsManager.getFromDB(linkModel.parentMid.value) as ContentsModel?;
    // if (parentContent == null) {
    //   logger.severe('Failed to find contentsModel $classMid');
    //   return false;
    // }

    // //2. 이를 통해 이를 관리하는 frameManager 를 찾는다.  (반드시 dummyManager 를 통해 찾아야 한다.)
    // FrameManager? dummyFrameManager = FrameManager(pageModel: pageModel, bookModel: book);
    // //3. 이를 통해  frameModel 을 찾는다.
    // frameModel = await dummyFrameManager.getFromDB(parentContent.parentMid.value) as FrameModel?;
    // if (frameModel == null) {
    //   logger.severe('Failed to find contentsModel $classMid');
    //   return false;
    // }
    // //4. 이를 통해 이를 관리하는 contentsManager 를 찾는다.  이때는 진짜 frameManager 를 통해 찾아야 한다.
    // FrameManager? frameManager =
    //     BookMainPage.pageManagerHolder!.findFrameManager(frameModel.parentMid.value);
    // if (frameManager == null) {
    //   logger.severe('Failed to find frameManager ${frameModel.parentMid.value}');
    //   return false;
    // }
    // ContentsManager? contentsManager = frameManager.findContentsManager(frameModel);
    // if (contentsManager == null) {
    //   logger.severe('Failed to find contentsManager ${frameModel.mid}');
    //   return false;
    // }
    //5. 이를 통해 이를 관리하는 linkManager 를 찾는다.

    for (var ele in linkModelList) {
      LinkModel linkModel = ele as LinkModel;
      LinkManager? linkManager = LinkManager.findLinkManager(linkModel.parentMid.value);
      if (linkManager == null) {
        logger.severe('Failed to find linkManager $classMid');
        return false;
      }
      linkManager.delete(link: linkModel);
      logger.fine('${linkManager.frameModel.mid}------------------------------');
      logger.fine('${linkModel.mid}, ${linkManager.frameModel.mid} is Removed');
    }
    return true;
  }

  void createLinkContentsManagerMap() {
    {
      for (var ele in modelList) {
        LinkModel linkModel = ele as LinkModel;
        if (linkModel.isRemoved.value == true) {
          continue;
        }
        if (linkModel.connectedClass != 'contents') {
          //콘텐츠 연결의 경우만 링크 관리를 한다.
          continue;
        }
        if (_contentsManagerMap[linkModel.mid] != null) {
          continue;
        }
        ContentsManager? contentsManager =
            _findConnectedContentsManager(linkModel.connectedParentMid, linkModel.connectedMid);
        if (contentsManager != null) {
          // print(
          //     'createLinkContentsManagerMap ${linkModel.mid} = ${contentsManager.frameModel.mid} ---------------');
          _contentsManagerMap[linkModel.mid] = contentsManager;
        }
      }
    }
  }

  ContentsManager? _findConnectedContentsManager(String frameId, String connectedMid) {
    // BookModel book = BookMainPage.bookManagerHolder!.onlyOne() as BookModel;
    // PageModel pageModel = PageModel('', book);
    // FrameModel? frameModel = FrameModel('', book.mid);

    // //1. 이 contentsMid 를 관리하는  ContentsManager 를 찾아야 한다.
    // ContentsManager? dummyContentsManager = ContentsManager.dummy(book);
    // ContentsModel? connectedContents =
    //     await dummyContentsManager.getFromDB(connectedMid) as ContentsModel?;
    // if (connectedContents == null) {
    //   logger.severe('Failed to find contentsModel $connectedMid');
    //   return null;
    // }
    // //2. 이를 통해 이를 관리하는 frameManager 를 찾는다.  (반드시 dummyManager 를 통해 찾아야 한다.)
    // FrameManager? dummyFrameManager = FrameManager(pageModel: pageModel, bookModel: book);
    // //3. 이를 통해  frameModel 을 찾는다.
    // frameModel =
    //     await dummyFrameManager.getFromDB(connectedContents.parentMid.value) as FrameModel?;
    // if (frameModel == null) {
    //   logger.severe('Failed to find contentsModel $connectedMid');
    //   return null;
    // }
    // //4. 이를 통해 이를 관리하는 contentsManager 를 찾는다.  이때는 진짜 frameManager 를 통해 찾아야 한다.
    // FrameManager? frameManager =
    //     BookMainPage.pageManagerHolder!.findFrameManager(frameModel.parentMid.value);
    // if (frameManager == null) {
    //   logger.severe('Failed to find frameManager ${frameModel.parentMid.value}');
    //   return null;
    // }
    FrameManager? frameManager = BookMainPage.pageManagerHolder!.findSelectedFrameManager();
    if (frameManager == null) {
      logger.severe('Failed to find frameManager ${frameModel.parentMid.value}');
      return null;
    }
    ContentsManager? contentsManager = frameManager.findContentsManagerByMid(frameId);
    if (contentsManager == null) {
      logger.severe('Failed to find contentsManager $frameId');
      return null;
    }

    return contentsManager;
  }

  LinkModel? getNoIconLink() {
    for (var ele in modelList) {
      LinkModel linkModel = ele as LinkModel;
      if (linkModel.isRemoved.value == true) {
        continue;
      }
      if (linkModel.noIcon.value == true) {
        return linkModel;
      }
    }
    return null;
  }

  static void openLink(LinkModel model, FrameManager frameManager,
      {double posX = 0, double posY = 0, Offset orgPosition = Offset.zero}) {
    //print('link button pressed ${model.connectedMid},${model.connectedClass}');
    // print('link button pressed ${widget.frameModel.mid},${widget.frameModel.isShow.value}');
    BookMainPage.containeeNotifier?.setFrameClick(true);

    //if (widget.contentsModel.isLinkEditMode == true) return;
    if (LinkParams.isLinkNewMode == true) return;

    // const double stickerOffset = LayoutConst.stikerOffset / 2;
    // double posX = (model.posX.value - stickerOffset) * widget.applyScale;
    // double posY = (model.posY.value - stickerOffset) * widget.applyScale;

    if (model.connectedClass == 'page') {
      //print('connectedClass is page ----------------------');
      _openPage(model, frameManager, posX, posY, orgPosition);
      return;
    }

    if (model.connectedClass == 'frame') {
      //print('connectedClass is frame ----------------------');
      _openFrame(model, frameManager, posX, posY, orgPosition);
      return;
    }
    if (model.connectedClass == 'contents') {
      //print('connectedClass is contents ----------------------');
      _openContents(model, frameManager, posX, posY,
          orgPosition); // 먼저 openFrame 을 하고, Contents가 있는 곳까지 넘어가야 한다.
    }
    return;
  }

  static void _openPage(
      LinkModel model, FrameManager frameManager, double posX, double posY, Offset orgPosition) {
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
      orgPosition, // widget.frameOffset,
      model.connectedParentMid,
      model.connectedMid,
      'page',
      model.name.value,
      frameManager.pageModel.mid,
    );
    //_lineDrawSendEvent?.sendEvent(isShow);
    //_linkManager?.notify();

    BookPreviewMenu.previewMenuPressed = true;
    BookMainPage.pageManagerHolder?.setSelectedMid(model.connectedMid);
  }

  static void _openFrame(
      LinkModel model, FrameManager frameManager, double posX, double posY, Offset orgPosition) {
    FrameModel? childModel = frameManager.getModel(model.connectedMid) as FrameModel?;
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
      double order = frameManager.getMaxOrder();
      if (childModel.order.value < order) {
        frameManager.changeOrderByIsShow(childModel);
        frameManager.reOrdering();
      }
      // 여기서 연결선을 연결한다....
      LinkParams.linkSet(
        Offset(posX, posY),
        orgPosition, // widget.frameOffset,
        model.connectedParentMid,
        model.connectedMid,
        'frame',
        model.name.value,
        frameManager.pageModel.mid,
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
      frameManager.changeOrderByIsShow(childModel);
      frameManager.reOrdering();
    }
    model.showLinkLine = childModel.isShow.value;
    childModel.save();
    //_lineDrawSendEvent?.sendEvent(isShow);
    //print('link button pressed ${widget.frameModel.mid},${widget.frameModel.isShow.value}');
    frameManager.notify();
    if (StudioVariables.isPreview == true) {
      //if (childModel.isShow.value == false) {
      //  // 보이는 상태라면 사라지게 한다.
      StickerViewState.clearOffStage(frameManager.pageModel.mid);
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

  static void _openContents(
      LinkModel model, FrameManager frameManager, double posX, double posY, Offset orgPosition) {
    ContentsModel? contentsModel = frameManager.findContentsModel(model.connectedMid);
    if (contentsModel == null) {
      logger.severe('connected = ${model.connectedMid} not founded');
      return;
    }
    FrameModel? childModel = frameManager.getModel(contentsModel.parentMid.value) as FrameModel?;
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
      double order = frameManager.getMaxOrder();
      if (childModel.order.value < order) {
        frameManager.changeOrderByIsShow(childModel);
        frameManager.reOrdering();
      }
      // 여기서 연결선을 연결한다....
      LinkParams.linkSet(
        Offset(posX, posY),
        orgPosition, // widget.frameOffset,
        model.connectedParentMid,
        model.connectedMid,
        'contents',
        model.name.value,
        frameManager.pageModel.mid,
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
    frameManager.notify();
    if (StudioVariables.isPreview == true) {
      //if (childModel.isShow.value == false) {
      //  // 보이는 상태라면 사라지게 한다.
      StickerViewState.clearOffStage(frameManager.pageModel.mid);
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

    ContentsManager? contentsManager = frameManager.getContentsManager(childModel.mid);

    if (contentsManager == null) {
      logger.severe('Failed to find contentsManager ${childModel.mid}');
      return;
    }

    contentsManager.playManager?.releasePause();
    //print('----------------------------------------');
    contentsManager.goto(contentsModel.order.value).then((v) {
      contentsManager.setSelectedMid(contentsModel.mid, doNotify: true); // 현재 선택된 것이 무엇인지 확실시,
    });
    //print('*******************************************${contentsModel.name}');
    return;
  }
}
