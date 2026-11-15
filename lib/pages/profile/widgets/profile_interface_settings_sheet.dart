import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 介面自訂設定底頁：
/// - 即時預覽盒同步反映 `_tempAccentIndex`、`_tempShowLabels` 與 `_tempOrder`
/// - 分頁名稱與 `main.dart` 完全對齊（Tab 3 為「問診」）
class _JiggleWidget extends StatefulWidget {
  const _JiggleWidget({
    required this.child,
    required this.index,
    this.enabled = true,
  });

  final Widget child;
  final int index;
  final bool enabled;

  @override
  State<_JiggleWidget> createState() => _JiggleWidgetState();
}

class _JiggleWidgetState extends State<_JiggleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnim;
  late final Animation<double> _translationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _rotationAnim = Tween<double>(begin: -0.018, end: 0.018).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _translationAnim = Tween<double>(begin: -0.5, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.enabled) {
      _controller.value = (widget.index * 0.23) % 1.0;
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _JiggleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translationAnim.value),
          child: Transform.rotate(
            angle: _rotationAnim.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class InterfaceSettingsSheet extends StatefulWidget {
  const InterfaceSettingsSheet({super.key, required this.appState});

  final PreambleState appState;

  @override
  State<InterfaceSettingsSheet> createState() => _InterfaceSettingsSheetState();
}

class _InterfaceSettingsSheetState extends State<InterfaceSettingsSheet> {
  late List<int> _tempOrder;
  late bool _tempShowLabels;
  late int _tempAccentIndex;

  /// 與 `main.dart` `_originalNavItems` 100% 一致的五大核心分頁標籤
  static const Map<int, String> _tabLabelsShort = {
    0: '首頁',
    1: '學習',
    2: '問診',
    3: '紀事',
    4: '我的',
  };

  /// 與 `AppColors` 靜奢強調色選擇器 1:1 對齊的 4 組高質感色票
  static const List<({Color color, String label})> _accentSwatches = [
    (color: Color(0xFFB5894A), label: '典藏古銅金'),
    (color: Color(0xFFA64B3B), label: '朱砂印記紅'),
    (color: Color(0xFF35546C), label: '岩青律政藍'),
    (color: Color(0xFF235D46), label: '蒼松墨玉綠'),
  ];

  Color get _previewAccent =>
      _accentSwatches[_tempAccentIndex.clamp(0, _accentSwatches.length - 1)]
          .color;

  @override
  void initState() {
    super.initState();
    _tempOrder = List<int>.from(widget.appState.navbarOrder);
    _tempShowLabels = widget.appState.showNavbarLabels;
    _tempAccentIndex = widget.appState.accentColorIndex;
  }

  Widget _buildTabIcon(int index, {required bool isPreviewActive}) {
    final t = context.tokens;
    final IconData iconData = switch (index) {
      0 => isPreviewActive ? PhosphorIconsFill.house : PhosphorIconsRegular.house,
      1 => isPreviewActive
          ? PhosphorIconsFill.graduationCap
          : PhosphorIconsRegular.graduationCap,
      2 => isPreviewActive
          ? PhosphorIconsFill.scales
          : PhosphorIconsRegular.scales,
      3 => isPreviewActive ? PhosphorIconsFill.books : PhosphorIconsRegular.books,
      _ => isPreviewActive
          ? PhosphorIconsFill.userCircle
          : PhosphorIconsRegular.userCircle,
    };

    return Icon(
      iconData,
      color: isPreviewActive ? _previewAccent : t.textSecondary,
      size: 22.sp,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final previewAccent = _previewAccent;

    return Container(
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: t.border),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: t.borderStrong,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '自訂導覽與介面',
                style: t.serifTitle(size: 17.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18.h),

              Text(
                '即時導覽列預覽（長按圖示並左右拖曳可調整順序）',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 10.h),

              // 懸浮島嶼即時預覽盒：即時反映 _tempAccentIndex、_tempShowLabels 與 _tempOrder
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _tempShowLabels ? 82.h : 66.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(26.r),
                  border: Border.all(
                    color: previewAccent.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: t.shadowAmbient,
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / _tempOrder.length;
                    return ReorderableListView(
                      scrollDirection: Axis.horizontal,
                      buildDefaultDragHandles: false,
                      proxyDecorator: (child, _, __) => Material(
                        color: Colors.transparent,
                        child: child,
                      ),
                      children: [
                        for (int i = 0; i < _tempOrder.length; i++)
                          ReorderableDelayedDragStartListener(
                            index: i,
                            key: ValueKey(_tempOrder[i]),
                            child: _JiggleWidget(
                              index: i,
                              enabled: true,
                              child: SizedBox(
                                width: itemWidth,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: i == 0
                                            ? previewAccent.withValues(
                                                alpha: 0.14,
                                              )
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(99.r),
                                      ),
                                      child: _buildTabIcon(
                                        _tempOrder[i],
                                        isPreviewActive: i == 0,
                                      ),
                                    ),
                                    if (_tempShowLabels) ...[
                                      SizedBox(height: 3.h),
                                      Text(
                                        _tabLabelsShort[_tempOrder[i]] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.sansBody(
                                          size: 10.5.sp,
                                          weight: i == 0
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: i == 0
                                              ? previewAccent
                                              : t.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                      onReorder: (oldIndex, newIndex) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = _tempOrder.removeAt(oldIndex);
                          _tempOrder.insert(newIndex, item);
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),

              // 顯示文字標籤切換
              Container(
                decoration: t.subtleBoxDecoration(radius: 14.r),
                child: SwitchListTile.adaptive(
                  title: Text(
                    '顯示分頁文字標籤',
                    style: t.sansTitle(size: 14.sp),
                  ),
                  subtitle: Text(
                    '關閉後導覽列僅呈現極簡圖示，視覺更緊湊',
                    style: t.sansBody(size: 11.5.sp, color: t.textSecondary),
                  ),
                  value: _tempShowLabels,
                  activeThumbColor: previewAccent,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _tempShowLabels = val);
                  },
                ),
              ),
              SizedBox(height: 20.h),

              // 靜奢點綴色票選擇
              Text(
                '靜奢重點色票（即時預覽）',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 12.w,
                runSpacing: 12.h,
                children: List.generate(_accentSwatches.length, (i) {
                  return _buildColorSwatch(
                    context,
                    index: i,
                    color: _accentSwatches[i].color,
                    name: _accentSwatches[i].label,
                  );
                }),
              ),
              SizedBox(height: 26.h),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: t.borderStrong),
                        foregroundColor: t.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        widget.appState.updateInterfaceSettings(
                          navbarOrder: _tempOrder,
                          showNavbarLabels: _tempShowLabels,
                          accentColorIndex: _tempAccentIndex,
                        );
                        Navigator.pop(context);
                        CustomToast.show(
                          context,
                          '介面導覽與配色偏好已儲存',
                          icon: PhosphorIconsFill.checkCircle,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: t.brandPrimaryStrong,
                        foregroundColor: const Color(0xFFFAF8F4),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: const Text('儲存變更'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSwatch(
    BuildContext context, {
    required int index,
    required Color color,
    required String name,
  }) {
    final t = context.tokens;
    final isSelected = _tempAccentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _tempAccentIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? t.textPrimary : Colors.transparent,
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isSelected ? 0.42 : 0.16),
                  blurRadius: isSelected ? 10 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? Icon(
                    PhosphorIconsBold.check,
                    color: Colors.white,
                    size: 16.sp,
                  )
                : null,
          ),
          SizedBox(height: 6.h),
          Text(
            name,
            style: t.sansBody(
              size: 11.sp,
              weight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? color : t.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
