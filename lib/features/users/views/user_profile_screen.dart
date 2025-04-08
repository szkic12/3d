import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiktok/constants/gaps.dart';
import 'package:tiktok/constants/sizes.dart';
import 'package:tiktok/features/settings/settings_screen.dart';
import 'package:tiktok/features/users/view_models/users_vm.dart';
import 'package:tiktok/features/users/views/widgets/avatar.dart';
import 'package:tiktok/features/users/views/widgets/persistent_tab_bar.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String username;
  final String tab;

  const UserProfileScreen({
    super.key,
    required this.username,
    required this.tab,
  });

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  void _onGearPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(usersProvider).when(
          error: (error, stackTrace) => Center(
            child: Text(
              error.toString(),
            ),
          ),
          loading: () => Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          data: (data) => Scaffold(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            body: SafeArea(
              child: DefaultTabController(
                initialIndex: widget.tab == "likes" ? 1 : 0,
                length: 2,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        title: Text(data.name),
                        actions: [
                          IconButton(
                            onPressed: _onGearPressed,
                            icon: FaIcon(
                              FontAwesomeIcons.gear,
                              size: Sizes.size20,
                            ),
                          )
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Gaps.v20,
                            Avatar(
                              uid: data.uid,
                              name: data.name,
                              hasAvatar: data.hasAvatar,
                              avatarURL: data.avatarURL,
                            ),
                            Gaps.v20,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "@${data.name}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Sizes.size18,
                                  ),
                                ),
                                Gaps.h5,
                                FaIcon(
                                  FontAwesomeIcons.solidCircleCheck,
                                  size: 13,
                                  color: Colors.blue.shade500,
                                ),
                              ],
                            ),
                            Gaps.v24,
                            SizedBox(
                              height: Sizes.size52,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SocialStats(
                                    count: 97,
                                    label: "Follwing",
                                  ),
                                  VerticalDivider(
                                    width: Sizes.size32, // 간격
                                    thickness: 0.5,
                                    color: Colors.grey.shade400,
                                    indent: Sizes.size12,
                                    endIndent: Sizes.size12,
                                  ),
                                  SocialStats(
                                    count: 12110,
                                    label: "Follwers",
                                  ),
                                  VerticalDivider(
                                    width: Sizes.size32, // 간격
                                    thickness: 0.5,
                                    color: Colors.grey.shade400,
                                    indent: Sizes.size12,
                                    endIndent: Sizes.size12,
                                  ),
                                  SocialStats(
                                    count: 819430000,
                                    label: "Likes",
                                  ),
                                ],
                              ),
                            ),
                            Gaps.v14,
                            FractionallySizedBox(
                              widthFactor: 0.33,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: Sizes.size12,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      Sizes.size4,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Follow",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Gaps.v14,
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Sizes.size32,
                              ),
                              child: Text(
                                "My pooku dog is fluffy like a big big cloud, and its cuteness is absolutely irresistible. Just one cuddle feels like hugging a warm bundle of joy!",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Gaps.v14,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.link,
                                  size: Sizes.size12,
                                ),
                                Gaps.h4,
                                Text(
                                  "https://github.com/wozlsla",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Gaps.v20,
                          ],
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: PersistentTabBar(),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      GridView.builder(
                        // physics: NeverScrollableScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: 20,
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: Sizes.size2,
                          mainAxisSpacing: Sizes.size2,
                          childAspectRatio: 9 / 14,
                        ),
                        itemBuilder: (context, index) => Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 9 / 14,
                              child: FadeInImage.assetNetwork(
                                fit: BoxFit.cover,
                                placeholder: "assets/images/pooku_sleep.jpg",
                                image:
                                    "https://picsum.photos/seed/${index + 1}/200/${350 + (5 * index)}",
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Text("Page 2"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }
}

class SocialStats extends StatelessWidget {
  final int count;
  final String label;

  const SocialStats({
    super.key,
    required this.count,
    required this.label,
  });

  String formatNumber(int number) {
    if (number >= 1000 && number < 1000000) {
      // 천 이상 백만 미만 (K)
      double value = number / 1000;
      return (value == value.toInt())
          ? "${value.toInt()}K"
          : "${value.toStringAsFixed(1)}K";
    } else if (number >= 1000000 && number < 1000000000) {
      // 백만 이상 십억 미만 (M)
      double value = number / 1000000;
      return (value == value.toInt())
          ? "${value.toInt()}M"
          : "${value.toStringAsFixed(1)}M";
    } else if (number >= 1000000000) {
      // 십억 이상 (B)
      double value = number / 1000000000;
      return (value == value.toInt())
          ? "${value.toInt()}B"
          : "${value.toStringAsFixed(1)}B";
    }
    return number.toString(); // 1000 미만은 그대로 출력
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          formatNumber(count),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Sizes.size18,
          ),
        ),
        Gaps.v3,
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
