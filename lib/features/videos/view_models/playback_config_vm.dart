// data + UI
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok/features/videos/models/playback_config_model.dart';
import 'package:tiktok/features/videos/repos/playback_config_repo.dart';

class PlaybackConfigViewModel extends Notifier<PlaybackConfigModel> {
  // access to the data (read&wrie 담당과 소통 필요)
  final PlaybackConfigRepository _repository;

  // Constructor (초기화)
  PlaybackConfigViewModel(this._repository);

  /* View 에 data 공개 */
  void setMuted(bool value) {
    _repository.setMuted(value); // 1. repo 에서 value 를 disk 에 persist 하게 저장하게 함

    // state.muted = value; // mutate state (X)
    // create(replace) compeletly new state
    state = PlaybackConfigModel(
      muted: value, // new value
      autoplay: state.autoplay, // old value
    );
  }

  void setAutoplay(bool value) {
    _repository.setAutoplay(value);
    state = PlaybackConfigModel(
      muted: state.muted,
      autoplay: value,
    );
  }

  /* build() : 데이터(state)의 초기 상태 반환. Notifier가 노출할 데이터를 제공하는 방법. 
      Notifier 내부라면 어디든지 state(data)에 접근,수정 가능 */
  @override
  PlaybackConfigModel build() {
    return PlaybackConfigModel(
      muted: _repository.isMuted(),
      autoplay: _repository.isAutoplay(),
    );
  }
}

/* NotifierProvider
  <
    type: expose 하고 싶은 provider
    type: provider가 expose 할 데이터(model)
  >
*/
final playbackConfigProvider =
    NotifierProvider<PlaybackConfigViewModel, PlaybackConfigModel>(
  () =>
      throw UnimplementedError(), // create view model -> (now) need access shared preferences
);
