import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok/features/inbox/models/message_model.dart';
import 'package:tiktok/features/inbox/repos/messages_repo.dart';

class MessagesViewModel extends AsyncNotifier<void> {
  late final MessagesRepository _repo;

  @override
  FutureOr<void> build() {
    _repo = ref.read(messagesRepo);
  }

  Future<void> sendMessage(String text) async {
    final user = ref.read(authRepo).user;

    state = AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        final message = MessageModel(
          text: text,
          uid: user!.uid,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );

        _repo.saveMessage(message);
      },
    );
  }
}

final messagesProvider = AsyncNotifierProvider<MessagesViewModel, void>(
  () => MessagesViewModel(),
);

// Stream을 return해야 함 (realtime conn)
final chatProvider = StreamProvider.autoDispose<List<MessageModel>>((ref) {
  final db = FirebaseFirestore.instance;

  return db
      .collection("chat_rooms")
      .doc("3QaAmV1MO1Ojo58OOMZX")
      .collection("texts")
      .orderBy("createdAt")
      .snapshots()
      .map(
        (event) => event.docs
            .map(
              (doc) => MessageModel.fromJson(doc.data()),
            )
            .toList()
            .reversed
            .toList(),
      );
  /* 
      snapshot : collection의 상태
      event: (realtime) collection에서 일어난 이벤트
      즉, 변경된 모든 docs의 list //map1
      에서 doc 을 처리하여 반환 //map2
  */
});
