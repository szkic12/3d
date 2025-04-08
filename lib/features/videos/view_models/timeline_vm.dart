import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok/features/videos/models/video_model.dart';

class TimelineViewModel extends AsyncNotifier<List<VideoModel>> {
  List<VideoModel> _list = [VideoModel.empty()];

  Future<void> uploadVideo() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(seconds: 2));
    // final newVideo = VideoModel(title: "${DateTime.now()}");
    // _list = [..._list, newVideo];
    _list = [..._list];
    state = AsyncValue.data(_list);
  }

  @override
  FutureOr<List<VideoModel>> build() async {
    // call API
    await Future.delayed(Duration(seconds: 3)); // for simulation
    // throw Exception("Can't fetch for test");

    // initial data
    return _list;
  }
}

/* provider 생성 : Views로 이 View Model을 전달함
  <
    type: expose 할 notifier
    type: provider가 expose 할 데이터(model) -> to Views(screen UI)
  >
*/
final timelineProvider =
    AsyncNotifierProvider<TimelineViewModel, List<VideoModel>>(
  () => TimelineViewModel(), // View Model 을 초기화 해 줄 func. -> class 초기화 단계
);
