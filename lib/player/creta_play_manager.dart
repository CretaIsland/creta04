// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:creta04/player/pdf/creta_pdf_player.dart';
import 'package:creta04/player/pdf/creta_pdf_widget.dart';
import 'package:flutter/material.dart';
//import 'package:get/get.dart';
import 'package:hycop/common/util/logger.dart';
import 'package:hycop/hycop/enum/model_enums.dart';
import 'package:synchronized/synchronized.dart';
import 'package:get/get.dart';

import '../data_io/contents_manager.dart';
import '../data_io/frame_manager.dart';
import '../data_io/link_manager.dart';
import 'package:creta_common/model/app_enums.dart';
import 'package:creta_studio_model/model/contents_model.dart';
import 'package:creta_studio_model/model/frame_model.dart';
import 'package:creta_studio_model/model/link_model.dart';
import '../pages/studio/book_main_page.dart';
import '../pages/studio/containees/containee_nofifier.dart';
import 'package:creta_user_io/data_io/creta_manager.dart';
import '../pages/studio/left_menu/left_menu_page.dart';
import '../pages/studio/studio_getx_controller.dart';
import '../pages/studio/studio_variables.dart';
import 'creta_abs_player.dart';
import 'creta_abs_media_widget.dart';
import 'doc/creta_doc_player.dart';
import 'doc/creta_doc_widget.dart';
import 'image/creta_image_player.dart';
import 'image/creta_image_widget.dart';
import 'music/creta_music_player.dart';
import 'music/creta_music_widget.dart';
import 'text/creta_text_player.dart';
import 'text/creta_text_widget.dart';
import 'video/creta_video_player.dart';
import 'video/creta_video_widget.dart';

class CretaPlayManager extends ChangeNotifier {
  final ContentsManager contentsManager;
  final FrameManager frameManager;
  ContentsEventController? _sendEvent;

  CretaPlayManager(this.contentsManager, this.frameManager) {
    clear();

    final ContentsEventController sendEvent = Get.find(tag: 'play-to-link');
    _sendEvent = sendEvent;
  }

  static void clearPlayerAll() {
    _playManagerMap.forEach((key, value) {
      value.clear();
    });
    _playManagerMap.clear();
  }

  static final Map<String, CretaPlayManager> _playManagerMap = <String, CretaPlayManager>{};
  static CretaPlayManager? getManager(
      String key, ContentsManager contentsManager, FrameManager frameManager) {
    CretaPlayManager? retval = _playManagerMap[key];
    if (retval == null) {
      logger.warning('CretaPlayManger is newly created');
      retval = CretaPlayManager(contentsManager, frameManager);
      _playManagerMap[key] = retval;
    } else {
      logger.warning('CretaPlayManger is reused');
    }
    //retval.start();
    return retval;
  }

  static CretaPlayManager? findManager(String key) {
    return _playManagerMap[key];
  }

  final Lock _lock = Lock();

  double _currentOrder = -1;
  //double _currentPlaySec = 0.0;

  ContentsModel? _currentModel;
  ContentsModel? get currentModel => _currentModel;
  void setCurrentModel(ContentsModel s) {
    _currentModel = s;
  }

  ContentsModel? _prevModel;

  bool _isPauseTimer = false;
  bool _isPrevPauseTimer = false;
  bool get isPauseTimer => _isPauseTimer;

  bool _isNextButtonBusy = false;
  bool _isPrevButtonBusy = false;
  bool get isNextButtonBusy => _isNextButtonBusy;
  bool get isPrevButtonBusy => _isPrevButtonBusy;
  void setIsNextButtonBusy(bool val) => _isNextButtonBusy = val;
  void setIsPrevButtonBusy(bool val) => _isPrevButtonBusy = val;

  bool _forceToChange = false;

  // from Handler
  CretaAbsPlayer? _currentPlayer;

  //BoolEventController? _lineDrawSendEvent;
  void clear() {
    _currentOrder = -1;
    //_currentPlaySec = 0.0;
    _currentModel = null;
    _prevModel = null;
    _isPauseTimer = false;
    _isPrevPauseTimer = false;
    _isNextButtonBusy = false;
    _isPrevButtonBusy = false;
    _forceToChange = false;
    _currentPlayer = null;
  }

  Future<void> togglePause() async {
    _isPrevPauseTimer = _isPauseTimer;
    _isPauseTimer = !_isPauseTimer;

    if (_currentModel != null) {
      if (_currentModel!.isVideo()) {
        _currentModel!.setIsPauseTimer(_isPauseTimer);
        if (_isPauseTimer) {
          await pause();
        } else {
          await play();
        }
      }
      if (_currentModel!.isImage() || _currentModel!.isText()) {
        contentsManager.notify();
      }
    }
  }

  Future<void> releasePause() async {
    _isPauseTimer = false;
    _isPrevPauseTimer = false;
    if (_currentModel != null && _currentModel!.contentsType == ContentsType.video) {
      _currentModel!.setIsPauseTimer(_isPauseTimer);
      // if (_isPauseTimer) {
      //   await pause();
      // } else {
      //   await play();
      // }
    }
  }

  // Future<void> toggleIsPause() async {
  //   await togglePause();
  // }

  bool isPause() {
    return isPauseTimer;
  }

  Future<void> pause() async {
    await _currentPlayer?.pause();
  }

  // Future<void> close() async {
  //   await _currentPlayer?.close();
  // }

  Future<void> play() async {
    await _currentPlayer?.play();
  }

  Future<void> rewind() async {
    reset();
    await _currentPlayer?.rewind();
  }

  Future<void> globalPause() async {
    await _currentPlayer?.globalPause();
  }

  Future<void> globalResume() async {
    await _currentPlayer?.globalResume();
  }

  bool isInit() {
    if (_currentPlayer == null) {
      return false;
    }
    return _currentPlayer!.isInit();
  }

  int getAvailLength() {
    return contentsManager.getAvailLength();
  }

  void notify() {
    notifyListeners();
  }

  Future<void> reset() async {
    await _lock.synchronized(() {
      //_currentPlaySec = 0.0;
    });
  }

  void setLooping(bool val) {
    _currentPlayer?.setLooping(val);
  }

  Future<void> reOrdering({bool isRewind = false}) async {
    await _lock.synchronized(() {
      contentsManager.reOrdering();
      if (isRewind) {
        //_currentPlaySec = 0.0;
        _currentOrder = contentsManager.lastOrder();
      }
    });
  }

  bool isCurrentModel(String mid) {
    if (_currentModel == null) {
      return false;
    }
    return _currentModel!.mid == mid;
  }

  ContentsModel? initCurrentModel() {
    if (_currentOrder < 0) {
      _currentOrder = contentsManager.lastOrder(); //가장 마지막이 가장 먼저 돌아야 하므로.
      if (_currentOrder < 0) {
        return null; // 돌릴게 없다.
      }
    }
    _currentModel = contentsManager.getNthOrder(_currentOrder) as ContentsModel?;
    sendEventToLink();
    return _currentModel;
  }

  ContentsModel? getCurrentModel() {
    if (_currentModel == null) {
      initCurrentModel();
    }
    return _currentModel;
  }

  void clearCurrentModel() {
    _currentOrder = -1;
    _currentModel = null;
  }

  Future<void> setCurrentOrder(double order) async {
    await _lock.synchronized(() async {
      _currentOrder = order;
      _updateCurrentModel(debug: true);
    });
  }

  Future<void> resetCurrentOrder() async {
    // _currentModel의 mid를 이용하여, 현재 _currentOrder를 역으로 찾아서 설정한다.
    // 이는 전체 order 체계가 모두 바뀌어, _currentOrder가 현재의 _currentModel 과 일치하지 않을때  사용된다.
    if (_currentModel == null) return;
    await _lock.synchronized(() async {
      _currentOrder = _currentModel!.order.value;
    });
  }

  bool _updateCurrentModel({bool debug = false}) {
    if (_currentOrder < 0) {
      _currentOrder = contentsManager.lastOrder(); //가장 마지막이 가장 먼저 돌아야 하므로.
      if (_currentOrder < 0) {
        return false; // 돌릴게 없다.
      }
    }
    _currentModel = contentsManager.getNthOrder(_currentOrder) as ContentsModel?;

    contentsManager.printLog();

    while (_currentModel == null) {
      _next();
      if (debug) {
        logger.info(
            '_updateCurrentModel ++++++++++++++++ ($_currentOrder) +++++++++++++++++++++++++++++++++++');
      }
      if (_currentOrder < 0) {
        return false; // 돌릴게 없다.
      }
      _currentModel = contentsManager.getNthOrder(_currentOrder) as ContentsModel?;
    }
    _prevModel ??= ContentsModel('', '');

    if (debug) logger.info('_updateCurrentModel($_currentOrder, ${_currentModel!.name})');

    if (_currentModel != null &&
        (_currentModel!.mid != _prevModel!.mid || _forceToChange == true)) {
      if (debug) logger.info('CurrentModel changed from ${_prevModel!.name}');
      if (_forceToChange == true || //skpark 2023.11.24 1개 밖에 없을때, 반복이 안되서리...
          contentsManager.getAvailLength() > 1 ||
          _currentModel!.mid != _prevModel!.mid) {
        if (debug) logger.info('notify()');
        contentsManager.setSelectedMid(_currentModel!.mid,
            doNotify:
                false); //skpark 2024.11.04  ContentsManager 에서는 현재 seletedMid를 가지고 있지 않는 경우가 있다.
        notify();
        sendEventToLink();
      }
      _forceToChange = false;
      if (_currentModel!.mid != _prevModel!.mid) {
        if (debug) logger.info('notifyToProperty');
        notifyToProperty();

        // prev 모델의 frame를 inVisible 하게 만들어야 한다.
        LinkManager? linkManager = contentsManager.findLinkManager(_prevModel!.mid);
        if (linkManager != null) {
          linkManager.listIterator((value) {
            LinkModel link = value as LinkModel;
            FrameModel? frame = frameManager.getModel(link.connectedMid) as FrameModel?;
            if (frame != null) {
              frame.isShow.set(false);
              frameManager.notify();
            }
            return false;
          });
        }
      }
      _currentModel!.copyTo(_prevModel!);
      if (debug) logger.info('CurrentModel changed to ${_currentModel!.name}');
    }

    return true;
  }

  void sendEventToLink() {
    if (StudioVariables.isPreview && _currentModel != null) {
      //print('sendEventToLink ${_currentModel!.name}');
      _sendEvent?.sendEvent(_currentModel!);
    }
  }

  Future<void> prev() async {
    setIsPrevButtonBusy(true);
    logger.fine('prev button pressed');
    await _lock.synchronized(() async {
      if (isInit()) {
        //if (contentsManager.getAvailLength() > 1) {
        await pause();
        await rewind();
        //}
        double oldOrder = _currentOrder;
        _currentOrder = contentsManager.prevOrder(oldOrder);
        _updateCurrentModel(debug: true);
        if (oldOrder == _currentOrder) {
          _forceToChange = true;
        }
      }
    });
  }

  Future<void> next() async {
    setIsNextButtonBusy(true);
    await _lock.synchronized(() async {
      if (isInit()) {
        await pause();
        await rewind();
        _next();
        _updateCurrentModel(debug: true);
      }
    });
  }

  bool _next() {
    //_currentPlaySec = 0.0;
    double oldOrder = _currentOrder;
    _currentOrder = contentsManager.nextOrder(oldOrder, alwaysOneExist: true);
    logger.info('oldOrder=$oldOrder, _currentOrder=$_currentOrder');
    if (oldOrder == _currentOrder) {
      _forceToChange = true;
    }
    if (oldOrder <= _currentOrder) {
      // 이경우 한바퀴 돌았다는 뜻이다.
      frameManager.nextPageListener(contentsManager.frameModel);
      return true;
    }
    return false;
  }

  void notifyToProperty() {
    if (BookMainPage.containeeNotifier == null) return;

    if (BookMainPage.containeeNotifier!.selectedClass == ContaineeEnum.Contents) {
      ContentsModel? content = contentsManager.getCurrentModel();
      if (content != null &&
          CretaManager.frameSelectNotifier != null &&
          CretaManager.frameSelectNotifier!.selectedAssetId != null) {
        if (content.parentMid.value == CretaManager.frameSelectNotifier!.selectedAssetId) {
          logger.finest('notifyToProperty');
          contentsManager.setSelectedMid(content.mid, doNotify: false);
          BookMainPage.containeeNotifier!.set(ContaineeEnum.Contents, doNoti: true);
          LeftMenuPage.treeInvalidate();
        }
      }
    }
    //logger.info('6666666666666666666666666');
    //_lineDrawSendEvent?.sendEvent(false);
  }

  CretaAbsPlayer createPlayer(ContentsModel model) {
    final String key = contentsManager.keyMangler(model);
    logger.info('createPlayer(${model.name}, $key)');
    CretaAbsPlayer? player = contentsManager.getPlayer(model.mid);
    if (player != null) {
      player.model!.updateFrom(model); // 모델이 달라졌을수 있다.
      _currentPlayer = player;
      logger.info('player is already created : ${model.name}');
      return player;
    }
    player = _createPlayer(key, model);
    _currentPlayer = player;
    contentsManager.setPlayer(model.mid, player);
    //player.init();
    logger.fine('player is newly created');
    return player;
  }

  CretaAbsPlayer _createPlayer(String key, ContentsModel model) {
    logger.info('_createPlayer(${model.name})');
    switch (model.contentsType) {
      case ContentsType.video:
        return CretaVideoPlayer(
          keyString: key,
          model: model,
          acc: contentsManager,
          onAfterEvent: (postion, duration) async {
            await _onAfterEventVideo();
          },
        );
      case ContentsType.image:
        return CretaImagePlayer(
          keyString: key,
          model: model,
          acc: contentsManager,
          onAfterEvent: (position, duration) async {},
        );
      case ContentsType.text:
        return CretaTextPlayer(
          keyString: key,
          model: model,
          acc: contentsManager,
          onAfterEvent: (position, duration) async {},
        );
      case ContentsType.document:
        return CretaDocPlayer(
          keyString: key,
          model: model,
          acc: contentsManager,
          onAfterEvent: (position, duration) async {},
        );
      case ContentsType.music:
        return CretaMusicPlayer(
          keyString: key,
          model: model,
          acc: contentsManager,
          onAfterEvent: (position, duration) async {},
        );
      case ContentsType.pdf:
        return CretaPdfPlayer(
          keyString: key,
          model: model,
          acc: contentsManager,
          onAfterEvent: (position, duration) async {},
        );
      default:
        return CretaEmptyPlayer(
          keyString: key,
          acc: contentsManager,
          onAfterEvent: (postion, duration) async {},
        );
    }
  }

  CretaAbsMediaWidget createWidget(ContentsModel model) {
    CretaAbsPlayer player = createPlayer(model);

    switch (model.contentsType) {
      case ContentsType.video:
        logger.info('createWidget video, ${model.name} ,${player.keyString}');
        return CretaVideoWidget(
          // Video 는 timer 를 사용하지 않는다.  따라서 Frame 단위로 initalize 된다.
          key: contentsManager.registerPlayerWidgetKey(player.keyString, model.contentsType),
          player: player,
        );
      case ContentsType.image:
        logger.info('createWidget image, ${model.name} ,${player.keyString}');
        return CretaImageWidget(
          // image는 timer 를 사용한다. 따라서, Contents 단위로 initalize 된다.
          key: contentsManager.registerPlayerWidgetKey(player.keyString, model.contentsType),
          player: player,
          timeExpired: _timerExpired,
        );
      case ContentsType.text:
        // text 는 timer 를 사용한다. 따라서, Contents 단위로 initalize 된다.
        return CretaTextWidget(
          key: contentsManager.registerPlayerWidgetKey(player.keyString, model.contentsType),
          player: player,
          timeExpired: _timerExpired,
        );
      case ContentsType.document:
        // return CretaEmptyPlayerWidget(
        //   key: GlobalObjectKey(player.frameKeyString),
        //   player: player,
        // );
        //logger.info('-------------createWidget${model.name}, ${model.contentsType})------------');
        return CretaDocWidget(
          key: contentsManager.registerPlayerWidgetKey(player.keyString, model.contentsType),
          player: player,
          frameManager: frameManager,
        );
      case ContentsType.music:
        // logger.info('-------------createMusicWidget${model.name}, ${model.contentsType})------------');
        return CretaMusicWidget(
          key: contentsManager.registerPlayerWidgetKey(player.keyString, model.contentsType),
          player: player,
        );
      case ContentsType.pdf:
        return CretaPdfWidget(
          key: contentsManager.registerPlayerWidgetKey(player.keyString, model.contentsType),
          player: player,
        );
      default:
        return CretaEmptyPlayerWidget(
          key: contentsManager.registerPlayerWidgetKey(player.keyString, model.contentsType),
          player: player,
        );
    }
  }

  Future<bool> _timerExpired(CretaAbsMediaWidget widget) async {
    return await _lock.synchronized<bool>(
      () async {
        // if (widget.isTimerAvailable == false) {
        //   return false;
        // }

        if (contentsManager.isEmpty()) {
          //logger.info('contentsManager is empty');
          return true;
        }
        if (contentsManager.iamBusy) {
          logger.info('i am busy');
          return true;
        }

        // if (BookMainPage.pageManagerHolder!.isSelected(contentsManager.pageModel.mid) == false) {
        //   // 현재 보여지고 있는 페이지가 아니라면 타이머는 쉰다.
        //   // logger.fine(
        //   //     '${contentsManager.pageModel.mid} is not ${BookMainPage.pageManagerHolder!.getSelectedMid()}');
        //   return;
        // }

        if (_isPauseTimer == true) {
          _currentModel?.setPlayState(PlayState.pause);
          return true;
        }
        if (_isPauseTimer != _isPrevPauseTimer) {
          _isPrevPauseTimer = _isPauseTimer;
          if (_currentModel != null && _currentModel!.isState(PlayState.pause)) {
            _currentModel?.resumeState();
          }
        }

        // if (_currentModel != null && _currentModel!.contentsType == ContentsType.video) {
        //   //  Video 는 timer 를 사용하지 않는다.
        //   return;
        // }
        // //BookMainPage.pageManagerHolder!.printSelectedMid(1);

        // 아무것도 돌고 있지 않다면,
        if (_updateCurrentModel() == false) {
          return true;
        }
        if (_currentModel == null) {
          logger.warning('_curentModel is null');
          return true;
        }

        // // 비디오의 경우, 처음에  _currentModel 이  null 이기 때문에, 처음 한번은 여기에 도달한다.
        // if (_currentModel!.isVideo()) {
        //   // 이때, play 가 되게 하기 위해 한번은  notify 를 해야 한다.
        //   notify();
        //   notifyToProperty();
        //   return;
        // }
        //BookMainPage.pageManagerHolder!.printSelectedMid(3);

        // Studio 에서 선택된 프레임의 경우, 플레이가 정지한다.
        // skpark 2024.08.01  이 기능을 일단 사용하지 않는다.  헷갈리기 때문이다.
        // if (StudioVariables.isPreview == false) {
        //   if (CretaManager.frameSelectNotifier != null && _currentModel != null) {
        //     if (CretaManager.frameSelectNotifier!.selectedAssetId ==
        //             _currentModel!.parentMid.value &&
        //         _currentModel!.isRemoved.value == false) {
        //       if (_currentModel!.isVideo() || _isPauseTimer == false) {}
        //       return;
        //     }
        //   }
        // }

        if (StudioVariables.isPreview && StudioVariables.stopNextContents) {
          // 사용자가 멈춤 버튼을 눌렀다.
          return true;
        }

        double playTime = _currentModel!.playTime.value;
        if (0 > playTime) {
          // 영구히 케이스
          return true;
        }

        if (StudioVariables.isAutoPlay == false) {
          return true;
        }

        if (_currentModel!.playState == PlayState.pause &&
            _currentModel!.manualState != PlayState.start) {
          return true;
        }

        // if (_currentPlaySec < playTime) {
        //   if ((StudioVariables.isAutoPlay && _currentModel!.playState != PlayState.pause) ||
        //       _currentModel!.manualState == PlayState.start) {
        //     _currentPlaySec += StudioConst.playTimerInterval;
        //     // await playHandler.setProgressBar(
        //     //   playTime <= 0 ? 0 : _currentPlaySec / playTime,
        //     //   _currentModel!,
        //     // );
        //   }
        //   return true;
        // }

        logger.info('교체시간이 되었다.');
        _next();
        _updateCurrentModel(debug: true);
        // await playHandler.setProgressBar(
        //   playTime <= 0 ? 0 : _currentPlaySec / playTime,
        //   _currentModel!,
        // );
        // 여기서 타이머를 종료하면...멈춰버리네...쩌비...

        return false;
      },
    );
  }

  Future<void> _onAfterEventVideo() async {
    // 이 함수는 비디오가 끝날때  호출된다.

    logger.fine('_onAfterEventVideo(${_currentModel?.playState})');
    await _lock.synchronized(() async {
      _currentModel?.setPlayState(PlayState.none);
      logger.info('before next, currentOrder=$_currentOrder');
      _next();
      _updateCurrentModel(debug: true);
    });
    if (_currentModel != null && _currentModel!.isVideo() == false) return;

    logger.info('after next, currentOrder=$_currentOrder');

    // // // 다시 play 를 해야 한다. 동일한 놈은 afterBuild 가 호출되지 않기 때문이다.
    // // 근데,,2개 였다가 하나로 줄었다면,,,,이전것과 같다고 해서 꼭 하나인것이 아니다.
    // // 하나였다가 두개가 되는 지점에도...이렇게 되어야 한다.
    // if (StudioVariables.isAutoPlay) {
    //   if (contentsManager.getAvailLength() == 1 ||
    //       (_prevModel != null && _currentModel!.mid == _prevModel!.mid)) {
    //     logger.info('only one video exist case');
    //     await play();
    //   }
    // }

    return;
  }
}
