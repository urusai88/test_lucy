import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_stream_notifiers/flutter_stream_notifiers.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:video_player/video_player.dart';

class VideoPlayerStreamController = VideoPlayerController
    with ValueStream<VideoPlayerValue>;

class VideoItem {
  final String src;

  bool status = false;
  VideoPlayerStreamController controller;

  VideoItem({@required this.src});

  VideoItem copyWith({
    bool status,
  }) {
    return VideoItem(src: src)
      ..status = status
      ..controller = controller;
  }
}

class VideoFeed {
  final countPreload = 2;
  final sourceList = <int, String>{};
  final items = <int, VideoItem>{};

  VideoFeed() {
    pathProvider.getTemporaryDirectory().then((directory) {
      directory.delete(recursive: true);
    });
  }

  VideoItem getVideoItem(int id) {
    if (!items.containsKey(id)) {
      items[id] = VideoItem(src: null);
    }

    return items[id];
  }

  void s(int i) {
    final max = math.min(i + countPreload, sourceList.length);
    final min = math.max(i - countPreload, 0);

    for (var i = min; i <= max; ++i) {
      if (!items.containsKey(i)) {
        _preload(i);
      }
    }

    print('min: $min max: $max');
  }

  Future<void> _preload(int i) async {
    /*
    print('preload $i');
    items[i] = ValueNotifier(VideoItem(src: sourceList[i]));
    final directory = await pathProvider.getTemporaryDirectory();
    final filename = path.basename(sourceList[i]);
    final filepath = path.join(directory.path, filename);
    final file = File(filepath);

    if (!await file.exists()) {
      print('$filepath download');
      final sw = Stopwatch()..start();
      final resp = await http.readBytes(sourceList[i]);
      print('$filepath download ${sw.elapsedMilliseconds}');
      sw.reset();
      await file.writeAsBytes(resp.toList());
      print('$filepath write ${sw.elapsedMilliseconds}');
    } else {
      print('$filepath exists');
    }

    items[i].value = items[i].value.copyWith(items: true);*/
  }
}
