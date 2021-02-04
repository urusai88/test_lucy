import 'dart:io';
import 'dart:math' as math;

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
  final controllerStream = BehaviorSubject<VideoPlayerController>();
  final loadingStream = BehaviorSubject<bool>.seeded(false);

  VideoItem({@required this.src});

  void dispose() {
    controllerStream.close();
    loadingStream.close();
  }
}

class MainScreenModel {
  final http.Client _client = http.Client();
  final Repository repository;
  final VideoFeed videoFeed;

  final loadSink = BehaviorSubject<bool>.seeded(false);
  final goodsSink = BehaviorSubject<List<GoodsEntity>>();

  final videoItemList = <int, VideoItem>{};

  MainScreenModel({@required this.repository}) : videoFeed = VideoFeed();

  Future<void> play({int index}) async {}

  Future<void> load() async {
    final goods = await repository.loadGoods();

    goodsSink.add(goods);
    loadSink.add(true);
  }

  VideoItem getVideoItem(int id) {
    if (!videoItemList.containsKey(id)) {
      final item = goodsSink.value.firstWhere((e) => e.id == id);
      final videoItem = VideoItem(src: item.regularVideo);

      videoItemList[id] = videoItem;
    }

    return videoItemList[id];
  }

  Future<void> changeVideo(int id) async {
    final idx = goodsSink.value.indexWhere((e) => e.id == id);

    final max = math.min(idx + 2, goodsSink.value.length);
    final min = math.max(idx - 2, 0);

    for (var i = min; i <= max; ++i) {
      final videoItem = getVideoItem(goodsSink.value[i].id);

      if (videoItem.controllerStream.value != null) continue;
      if (videoItem.loadingStream.value == true) continue;

      _loadVideo(videoItem);
    }
  }

  Future<void> _loadVideo(VideoItem videoItem) async {
    videoItem.loadingStream.add(true);

    final directory = await pathProvider.getTemporaryDirectory();
    final filename = path.basename(videoItem.src);
    final filepath = path.join(directory.path, filename);
    final file = File(filepath);
    final sw = Stopwatch()..start();

    if (!await file.exists()) {
      print('$filepath download');
      final resp = await _client.readBytes(videoItem.src);
      await file.writeAsBytes(resp.toList());
      print('$filepath download completed ${sw.elapsedMilliseconds}');
    } else {
      print('$filepath exists');
    }

    final controller = VideoPlayerStreamController.file(file);

    try {
      await controller.initialize();
      videoItem.controllerStream.add(controller);
      print('$filepath controller initialized in ${sw.elapsedMilliseconds}');
    } catch (e) {
      print('controller $filepath initialize error:\n$e');
    } finally {
      videoItem.loadingStream.add(false);
    }
  }

  void disposeController(int id) {
    if (videoItemList.containsKey(id)) {
      print('dispose $id');
      final videoItem = videoItemList[id];

      videoItem.controllerStream.value?.dispose();
      videoItem.controllerStream.add(null);
    }
  }

  void dispose() {
    goodsSink.close();
    loadSink.close();
  }
}
