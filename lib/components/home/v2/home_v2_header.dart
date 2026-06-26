import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/components/home/v2/home_v2_primitives.dart';
import 'package:lawapp/data/mock_data/home/home_v2_mock_data.dart';
import 'package:lawapp/theme/app_colors.dart';

class HomeV2HeroHeader extends StatefulWidget {
  const HomeV2HeroHeader({
    super.key,
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.onTickerTap,
  });

  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onTickerTap;

  @override
  State<HomeV2HeroHeader> createState() => _HomeV2HeroHeaderState();
}

class _HomeV2HeroHeaderState extends State<HomeV2HeroHeader> {
  late final PageController _tickerController;
  Timer? _tickerTimer;
  var _tickerIndex = 0;

  @override
  void initState() {
    super.initState();
    _tickerController = PageController();
    // 頂部法規快訊每 4 秒往上換一則，先使用 mock data；
    // 未來接 API 時只要替換 homeV2TickerItems 的資料來源即可。
    _tickerTimer = Timer.periodic(const Duration(seconds: 4), (__) {
      if (!_tickerController.hasClients || homeV2TickerItems.isEmpty) return;
      final nextIndex = (_tickerIndex + 1) % homeV2TickerItems.length;
      _tickerController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preamble 緒言',
                    style: TextStyle(
                      color: HomeV2Palette.ink,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '讓法律更懂你',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderIcon(
              icon: Icons.notifications_none_rounded,
              onTap: widget.onNotificationTap,
            ),
            SizedBox(width: 10.w),
            _HeaderAvatar(onTap: widget.onProfileTap),
          ],
        ),
        SizedBox(height: 16.h),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          child: InkWell(
            onTap: widget.onTickerTap,
            borderRadius: BorderRadius.circular(20.r),
            child: Ink(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
              decoration: BoxDecoration(
                color: HomeV2Palette.trustGreen,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: SizedBox(
                height: 24.h,
                child: PageView.builder(
                  controller: _tickerController,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: homeV2TickerItems.length,
                  onPageChanged: (index) =>
                      setState(() => _tickerIndex = index),
                  itemBuilder: (context, index) {
                    final tickerItem = homeV2TickerItems[index];
                    return Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                          child: Text(
                            tickerItem.badge,
                            maxLines: 1,
                            style: TextStyle(
                              color: const Color(0xFFFFD36D),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            tickerItem.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20.sp,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeV2GreetingCard extends StatelessWidget {
  const HomeV2GreetingCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shouldStack = MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.08;

    return HomeV2SurfaceCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 14.w, 16.h),
            child: shouldStack
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GreetingTextBlock(),
                      SizedBox(height: 10.h),
                      const HomeV2SmallPill(
                        label: '查看全部',
                        icon: Icons.chevron_right_rounded,
                        background: Colors.white,
                        borderColor: AppColors.border,
                        textColor: HomeV2Palette.ink,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _GreetingTextBlock()),
                      const HomeV2SmallPill(
                        label: '查看全部',
                        icon: Icons.chevron_right_rounded,
                        background: Colors.white,
                        borderColor: AppColors.border,
                        textColor: HomeV2Palette.ink,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _GreetingTextBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = PreambleScope.of(context);
    final user = appState.currentUser;
    final nameText = user.isGuest ? '訪客' : user.displayName;
    final updateCount = user.isGuest
        ? 3
        : (appState.followingSummary.followedTopicIds.length + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '早安，$nameText',
          style: TextStyle(
            color: HomeV2Palette.ink,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '今天有 $updateCount 則與你相關的法律更新',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: HomeV2Palette.trustGreen, size: 21.sp),
        ),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 通知右邊這顆頭像就是首頁的「我的」快捷入口，因此要做成真正可點擊按鈕，
    // 不要只保留視覺外觀。未來若要接會員照片或未讀徽章，也建議從這個元件擴充。
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 40.w,
          height: 40.w,
          decoration: const BoxDecoration(
            color: HomeV2Palette.trustGreen,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_rounded, color: Colors.white, size: 25.sp),
        ),
      ),
    );
  }
}
