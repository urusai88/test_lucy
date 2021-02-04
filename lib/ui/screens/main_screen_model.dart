import 'package:flutter/foundation.dart';
import 'package:flutter_test_lucy/core/video_feed.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

import '../../export.dart';

class MainScreenModel {
  final Repository repository;
  final VideoFeed videoFeed;

  final loadSink = BehaviorSubject<bool>.seeded(false);
  final goodsSink = BehaviorSubject<List<GoodsEntity>>();

  final controllerList = <int, VideoPlayerController>{};

  VideoPlayerController _activeController;

  MainScreenModel({@required this.repository}) : videoFeed = VideoFeed();

  Future<void> load() async {
    final goods = await repository.loadGoods();
    final sourceList = goods.map((e) => e.regularVideo).toList();

    goodsSink.add(goods);
    loadSink.add(true);
    videoFeed.sourceList.addAll(sourceList);
  }

  VideoPlayerController ensureController(int id) {
    if (!controllerList.containsKey(id)) {
      print('ensure $id');
      final goods = goodsSink.value.firstWhere((e) => e.id == id);
      final controller = VideoPlayerController.network(goods.regularVideo);

      controller.initialize().then((_) => controller.setLooping(true));

      controllerList[id] = controller;

      if (_activeController == null) {
        _activeController = controller;
        _activeController.play();
      }
    }

    return controllerList[id];
  }

  void disposeController(int id) {
    if (controllerList.containsKey(id)) {
      print('dispose $id');
      controllerList[id].dispose();
      controllerList.remove(id);
    }
  }

  Future<void> onPageChanged(int p) async {
    videoFeed.s(p);
    final goods = goodsSink.value[p];
    final controller = ensureController(goods.id);

    if (_activeController != null) {
      await _activeController.pause();
      if (_activeController.value.duration != null) {
        await _activeController.seekTo(Duration.zero);
      }
    }

    await controller.play();

    _activeController = controller;
  }

  void dispose() {
    goodsSink.close();
    loadSink.close();
  }
}
