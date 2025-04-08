import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tiktok/features/authentication/repos/authentication_repo.dart';
import 'package:tiktok/features/users/view_models/users_vm.dart';
import 'package:tiktok/features/videos/models/video_model.dart';
import 'package:tiktok/features/videos/repos/videos_repo.dart';

class UploadVideoViewModel extends AsyncNotifier<void> {
  late final VideosRepository _repository;

  @override
  FutureOr build() {
    _repository = ref.read(videoRepo);
  }

  Future<void> uploadVideo(File video, BuildContext context) async {
    final user = ref.read(authRepo).user;
    // final userProfile = "jimnny"; // temp
    final userProfile = ref.read(usersProvider).value;

    if (userProfile != null) {
      state = AsyncValue.loading();
      state = await AsyncValue.guard(
        () async {
          // upload
          final task = await _repository.uploadVideoFile(
            video,
            user!.uid,
          );
          // save
          if (task.metadata != null) {
            await _repository.saveVideo(
              VideoModel(
                title: "video title",
                description: "video description",
                fileUrl: await task.ref.getDownloadURL(),
                thumbnailUrl: "",
                creatorUid: user.uid,
                creator: userProfile.name,
                likes: 0,
                comments: 0,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
            if (context.mounted) {
              context.pushReplacement("/home");
            }
          }
        },
      );
    }
  }
}

// expose
final uploadVideoProvider = AsyncNotifierProvider<UploadVideoViewModel, void>(
  () => UploadVideoViewModel(),
);
