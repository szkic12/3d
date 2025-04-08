import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok/features/videos/view_models/timeline_vm.dart';
import 'package:tiktok/features/videos/views/widgets/video_post.dart';

/* Listen videos from View Model */
class VideoTimelineScreen extends ConsumerStatefulWidget {
  const VideoTimelineScreen({super.key});

  @override
  VideoTimelineScreenState createState() => VideoTimelineScreenState();
}

class VideoTimelineScreenState extends ConsumerState<VideoTimelineScreen> {
  int _itemCount = 4;

  final PageController _pageController = PageController();

  final Duration _scrollDuration = const Duration(milliseconds: 250);
  final Curve _scrollCurve = Curves.linear;

  void _onPageChanged(int page) {
    _pageController.animateToPage(
      page,
      duration: _scrollDuration,
      curve: _scrollCurve,
    );
    if (page == _itemCount - 1) {
      _itemCount = _itemCount + 4;
      setState(() {});
    }
  }

  void _onVideoFinished() {
    return;
    // _pageController.nextPage(
    //   duration: _scrollDuration,
    //   curve: _scrollCurve,
    // );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    return Future.delayed(
      Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    // when() : provider의 각기 다른 state를 위한 callback 제공
    return ref.watch(timelineProvider).when(
          loading: () => Center(
            child: CircularProgressIndicator.adaptive(),
          ), // API 기다리는 중
          error: (error, stackTrace) => Center(
            child: Text("Could not load videos: $error"),
          ),
          data: (video) => RefreshIndicator(
            onRefresh: _onRefresh, // Future or async
            edgeOffset: 30, // refresh indicator 가 어디서부터 시작할지 설정
            displacement: 50, // 화면을 당긴 후 indicator의 위치 설정
            color: Theme.of(context).primaryColor,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: _onPageChanged,
              itemCount: video.length,
              itemBuilder: (context, index) =>
                  VideoPost(onVideoFinished: _onVideoFinished, index: index),
            ),
          ),
        );
  }
}
