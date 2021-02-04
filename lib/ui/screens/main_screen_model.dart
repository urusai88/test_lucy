import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test_lucy/core/video_feed.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

import '../../export.dart';

class VideoItem {
  final String src;
  final controller = BehaviorSubject<VideoPlayerController>();

  VideoItem({@required this.src});

  void dispose() {
    controller.close();
  }
}

class MainScreenModel {
  final Repository repository;
  final VideoFeed videoFeed;

  final loadSink = BehaviorSubject<bool>.seeded(false);
  final goodsSink = BehaviorSubject<List<GoodsEntity>>();

  final videoItemList = <int, VideoItem>{};

  final controllerList = <int, VideoPlayerController>{};

  VideoPlayerController _activeController;

  MainScreenModel({@required this.repository}) : videoFeed = VideoFeed();

  Future<void> play({int index}) async {}

  Future<void> load() async {
    final goods = await repository.loadGoods();
    // final sourceList = goods.map((e) => e.regularVideo).toList();

    goodsSink.add(goods);
    loadSink.add(true);
    // videoFeed.sourceList.addAll(sourceList);
  }

  VideoItem getVideoItem(int id) {
    if (!videoItemList.containsKey(id)) {
      final item = goodsSink.value.firstWhere((e) => e.id == id);
      final videoItem = VideoItem(src: item.regularVideo);

      _loadVideo(videoItem);

      videoItemList[id] = videoItem;
    }

    return videoItemList[id];
  }

  Future<void> changeVideo(int index) async {}

  Future<void> _loadVideo(VideoItem videoItem) async {
    final directory = await pathProvider.getTemporaryDirectory();
    final filename = path.basename(videoItem.src);
    final filepath = path.join(directory.path, filename);
    final file = File(filepath);

    if (!await file.exists()) {
      print('$filepath download');
      final resp = await http.readBytes(videoItem.src);
      await file.writeAsBytes(resp.toList());
      print('$filepath download complete');
    } else {
      print('$filepath exists');
    }

    final controller = VideoPlayerStreamController.file(file);

    try {
      await controller.initialize();
      videoItem.controller.add(controller);
      print('$filepath controller initialized');
    } catch (e) {
      print('controller $filepath initialize error:\n$e');
    }
  }

  void disposeController(int id) {
    if (videoItemList.containsKey(id)) {
      print('dispose $id');
      final videoItem = videoItemList[id];

      videoItem.controller.value?.dispose();
      videoItem.controller.add(null);
    }
  }

/*
  VideoItem getVideoItem(int id) {

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
  */

  void dispose() {
    goodsSink.close();
    loadSink.close();
  }
}
