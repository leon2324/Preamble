import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/components/shared/mvp_state_widgets.dart';
import 'package:lawapp/data/legal_sources/legal_source_registry.dart';
import 'package:lawapp/pages/following/following_page.dart';
import 'package:lawapp/pages/tools/legal_tools_page.dart';
import 'package:lawapp/theme/adaptive_layout.dart';
import 'package:lawapp/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = LawAppScope.of(context);
    final canPop = Navigator.of(context).canPop();
    final topPadding =
        context.hasLargeTopInset ? context.topSafeInset + 10.h : 22.h;

    return Scaffold(
      backgroundColor: _background(context),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            16.w, topPadding, 16.w, context.pageContentBottomPadding + 32.h),
        children: [
          if (canPop) _BackButton(onBack: () => Navigator.of(context).pop()),
          _Header(appState: appState),
          SizedBox(height: 14.h),
          _SectionTitle('我的資料'),
          SizedBox(height: 10.h),
          _DataGrid(appState: appState),
          SizedBox(height: 16.h),
          _SectionTitle('會員區'),
          SizedBox(height: 10.h),
          _PlanCard(appState: appState),
          SizedBox(height: 10.h),
          LockedFeatureCard(
            title: 'Pro 功能預覽',
            message: '完整案件卷宗、進階文件匯出、高額度小法助與追蹤提醒會在正式訂閱流程完成後開放。',
            actionLabel: '啟用 Pro Demo',
            onAction: appState.activateSubscriberDemo,
          ),
          SizedBox(height: 16.h),
          _SectionTitle('設定'),
          SizedBox(height: 10.h),
          _SettingsCard(appState: appState),
          SizedBox(height: 10.h),
          const LegalDisclaimerBox(),
          SizedBox(height: 10.h),
          _SourcesCard(),
          SizedBox(height: 10.h),
          _DevLoginCard(appState: appState),
          SizedBox(height: 10.h),
          _ComingSoonLoginCard(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.appState});

  final LawAppState appState;

  @override
  Widget build(BuildContext context) {
    final quota = appState.remainingAiQuota;
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: _border(context)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x10000000), blurRadius: 18, offset: Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: AppColors.chipSurface,
              shape: BoxShape.circle,
              border: Border.all(color: _border(context)),
            ),
            child: Icon(
                appState.isSubscriber
                    ? Icons.workspace_premium_rounded
                    : Icons.person_rounded,
                color: AppColors.accent,
                size: 30.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    appState.isGuest
                        ? '訪客資料中心'
                        : appState.currentUser.displayName,
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: _text(context))),
                SizedBox(height: 4.h),
                Text('目前方案：${appState.accessTier.label}｜今日 AI 額度：$quota',
                    style: TextStyle(
                        fontSize: 11.5.sp,
                        height: 1.4,
                        color: _muted(context))),
                SizedBox(height: 8.h),
                Text(appState.accessTier.helperText,
                    style: TextStyle(
                        fontSize: 11.sp, height: 1.4, color: _muted(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataGrid extends StatelessWidget {
  const _DataGrid({required this.appState});

  final LawAppState appState;

  @override
  Widget build(BuildContext context) {
    final items = [
      _DataItem(
          '我的收藏',
          '${appState.savedCaseIds.length} 件',
          Icons.bookmark_rounded,
          () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (__) => const FollowingPage()))),
      _DataItem('我的筆記', '2 則 mock', Icons.note_alt_rounded,
          () => _showMockSheet(context, '我的筆記', '案件筆記與法條筆記會在正式同步後顯示在這裡。')),
      _DataItem(
          '我的提問紀錄',
          appState.isGuest ? '訪客未同步' : '3 段 mock',
          Icons.smart_toy_rounded,
          () => _showMockSheet(context, '我的提問紀錄', '小法助對話會由後端同步；目前顯示 mock 狀態。')),
      _DataItem(
          '我的文件草稿',
          '1 份草稿',
          Icons.description_rounded,
          () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (__) => const LegalToolsPage()))),
      _DataItem(
          '我的追蹤',
          '案件 / 法條 / 主題',
          Icons.notifications_active_rounded,
          () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (__) => const FollowingPage()))),
    ];

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: items.map((item) {
        return SizedBox(
          width: (MediaQuery.sizeOf(context).width - 42.w) / 2,
          child: _DataCard(item: item),
        );
      }).toList(growable: false),
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({required this.item});

  final _DataItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, color: AppColors.accent, size: 23.sp),
            SizedBox(height: 10.h),
            Text(item.title,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: _text(context))),
            SizedBox(height: 4.h),
            Text(item.subtitle,
                style: TextStyle(fontSize: 11.sp, color: _muted(context))),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.appState});

  final LawAppState appState;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('目前方案：${appState.accessTier.label}',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: _text(context))),
          SizedBox(height: 6.h),
          Text('升級 CTA 目前是 mock，不會進入真付款；正式付款 SDK 接上後會從這張卡承接。',
              style: TextStyle(
                  fontSize: 11.5.sp, height: 1.45, color: _muted(context))),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: appState.signInDemo,
                      child: const Text('Demo 會員'))),
              SizedBox(width: 10.w),
              Expanded(
                  child: FilledButton(
                      onPressed: appState.activateSubscriberDemo,
                      child: const Text('Pro Demo'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.appState});

  final LawAppState appState;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: SwitchListTile.adaptive(
        value: appState.isDarkMode,
        onChanged: appState.setDarkMode,
        contentPadding: EdgeInsets.zero,
        title: Text('深色模式',
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
                color: _text(context))),
        subtitle: Text('夜間查資料或讀案例時降低亮度。',
            style: TextStyle(fontSize: 11.5.sp, color: _muted(context))),
      ),
    );
  }
}

class _SourcesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('資料來源',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: _text(context))),
          SizedBox(height: 8.h),
          for (final source in legalSourceEntries.take(3))
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text('${source.title}｜${source.statusLabel}',
                  style: TextStyle(
                      fontSize: 11.5.sp, height: 1.4, color: _muted(context))),
            ),
        ],
      ),
    );
  }
}

class _DevLoginCard extends StatelessWidget {
  const _DevLoginCard({required this.appState});

  final LawAppState appState;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('開發模式 Demo 登入',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: _text(context))),
          SizedBox(height: 6.h),
          Text('這是開發展示模式，用來預覽會員與 Pro UI，不代表正式登入或付款。',
              style: TextStyle(
                  fontSize: 11.5.sp, height: 1.45, color: _muted(context))),
          if (!appState.isGuest) ...[
            SizedBox(height: 8.h),
            TextButton(
                onPressed: appState.signOut, child: const Text('登出並回到訪客')),
          ],
        ],
      ),
    );
  }
}

class _ComingSoonLoginCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('即將支援',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: _text(context))),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: const [
              Chip(label: Text('Google 登入')),
              Chip(label: Text('Apple 登入')),
              Chip(label: Text('訂閱付款')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _border(context)),
      ),
      child: child,
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: _text(context),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: _text(context)));
  }
}

class _DataItem {
  const _DataItem(this.title, this.subtitle, this.icon, this.onTap);
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

void _showMockSheet(BuildContext context, String title, String message) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.all(16.w),
      child: AppEmptyState(
          title: title, message: message, icon: Icons.folder_open_rounded),
    ),
  );
}

Color _background(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0F1216)
        : AppColors.background;
Color _surface(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF171C22)
        : Colors.white;
Color _border(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2B3441)
        : AppColors.border;
Color _text(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFF2F4F7)
        : AppColors.textPrimary;
Color _muted(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFA3ABB6)
        : AppColors.textSecondary;
