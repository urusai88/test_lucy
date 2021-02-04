import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../export.dart';

export 'main_screen_model.dart';

class _NavigationItem extends StatelessWidget {
  final String iconAsset;
  final String text;

  _NavigationItem({@required this.iconAsset, this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ImageIcon(
          AssetImage(iconAsset),
          color: Colors.white,
          size: text == null ? 38 : 22,
        ),
        if (text != null) ...[
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ]
      ],
    );
  }
}

class _GoodsLayout extends StatefulWidget {
  final MainScreenModel bloc;
  final GoodsEntity goods;
  final double bottomOffset;

  _GoodsLayout({
    @required this.bloc,
    @required this.goods,
    @required this.bottomOffset,
  });

  @override
  State<StatefulWidget> createState() => _GoodsLayoutState();
}

class _GoodsLayoutState extends State<_GoodsLayout> {
  @override
  void dispose() {
    super.dispose();

    widget.bloc.disposeController(widget.goods.id);
  }

  Widget _goodsInfo() {
    const textStyleName = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Color(0xFF111010),
    );
    const textStyleDefault = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
    final textStylePrice = textStyleDefault.copyWith(
        color: Color(0xFF4B4B4B), decoration: TextDecoration.lineThrough);
    final textStyleSpecial =
        textStyleDefault.copyWith(color: Color(0xFF0C0B0B));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.goods.name, style: textStyleName),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formatPrice(widget.goods.price), style: textStylePrice),
            const SizedBox(width: 7),
            Text(formatPrice(widget.goods.special), style: textStyleSpecial),
          ],
        ),
      ],
    );
  }

  Widget _actions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ImageIcon(
          AssetImage(iconLayoutLike),
          size: 32,
          color: Color(0xFFF97369),
        ),
        const SizedBox(height: 24),
        ImageIcon(AssetImage(iconNavigationCart), size: 32),
      ],
    );
  }

  Widget _layout() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: widget.bottomOffset + 21,
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: _actions(),
            ),
          ),
          Container(
            alignment: Alignment.bottomLeft,
            child: _goodsInfo(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoItem = widget.bloc.getVideoItem(widget.goods.id);

    Widget player = StreamBuilder<VideoPlayerController>(
      stream: videoItem.controllerStream,
      builder: (_, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final controller = snapshot.data;

        Widget player = VideoPlayer(controller);

        player = FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: player,
          ),
        );

        player = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            if (!controller.value.initialized) return;

            controller.value.isPlaying ? controller.pause() : controller.play();
          },
          child: player,
        );

        return player;
      },
    );

    return Stack(
      fit: StackFit.passthrough,
      children: [
        player,
        _layout(),
      ],
    );
  }
}

class _ScrollPhysics extends PageScrollPhysics {
  final SpringDescription _spring;

  _ScrollPhysics({ScrollPhysics parent, SpringDescription spring})
      : _spring = spring,
        super(parent: parent);

  @override
  _ScrollPhysics applyTo(ScrollPhysics ancestor) =>
      _ScrollPhysics(parent: buildParent(ancestor), spring: _spring);

  @override
  SpringDescription get spring => _spring;
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const navigationHeight = 50.0;

  MainScreenModel bloc;
  ScrollController scrollController;

  int _page = 0;

  void _scrollControllerListener() {
    final r =
        (scrollController.offset % scrollController.position.viewportDimension);

    if (r == 0.0) {
      final j = (scrollController.offset /
          scrollController.position.viewportDimension);
      final p = j.floor();

      if (_page != p) {
        bloc.changeVideo(bloc.goodsSink.value[_page = p].id);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    scrollController.addListener(_scrollControllerListener);

    bloc = MainScreenModel(
      repository: Provider.of<Repository>(context, listen: false),
    );

    Future(_asyncInitState);
  }

  Future<void> _asyncInitState() async {
    await bloc.load();
    await bloc.changeVideo(bloc.goodsSink.value[_page].id);
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  Widget _videoList() {
    return LayoutBuilder(
      builder: (_, constraints) {
        return StreamBuilder<List<GoodsEntity>>(
          stream: bloc.goodsSink,
          initialData: [],
          builder: (_, snapshot) {
            return ListView.builder(
              controller: scrollController,
              physics: _ScrollPhysics(
                spring: SpringDescription(
                  mass: 80,
                  stiffness: 10,
                  damping: 1,
                ),
              ),
              cacheExtent: constraints.maxHeight * 2,
              itemExtent: constraints.maxHeight,
              itemCount: snapshot.data.length,
              padding: EdgeInsets.zero,
              itemBuilder: (_, i) {
                final item = snapshot.data[i];

                return Container(
                  child: _GoodsLayout(
                    bloc: bloc,
                    goods: item,
                    bottomOffset: navigationHeight,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _navigation() {
    return Container(
      height: navigationHeight,
      alignment: Alignment.center,
      color: Color.fromRGBO(0, 0, 0, 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _NavigationItem(iconAsset: iconNavigationHome, text: 'Home'),
          _NavigationItem(iconAsset: iconNavigationDiscover, text: 'Discover'),
          _NavigationItem(iconAsset: iconNavigationCart),
          _NavigationItem(iconAsset: iconNavigationInbox, text: 'Inbox'),
          _NavigationItem(iconAsset: iconNavigationMe, text: 'Me'),
        ],
      ),
    );
  }

  Widget _loadBody() {
    return Stack(
      children: [
        _videoList(),
        Container(
          alignment: Alignment.bottomCenter,
          child: _navigation(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body = StreamBuilder<bool>(
      stream: bloc.loadSink,
      initialData: false,
      builder: (_, snapshot) {
        if (!snapshot.data) {
          return Center(child: CircularProgressIndicator());
        }

        return _loadBody();
      },
    );

    return Scaffold(
      body: body,
    );
  }
}
