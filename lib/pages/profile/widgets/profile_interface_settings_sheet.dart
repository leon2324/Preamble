import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/theme/app_colors.dart';

// 介面自訂設定底頁，支援 iOS 風格橫向島嶼導覽列拖曳排序、非同步微幅晃動動效，
// 以及導覽文字標籤開關與 Accent 主題色彩點選。

class _JiggleWidget extends StatefulWidget {
  const _JiggleWidget(
      {required this.child, required this.index, this.enabled = true});

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

    // 微幅的弧度旋轉動效（約 -1.1度 到 1.1度）
    _rotationAnim = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 微幅的上下平移，加強懸浮晃動感
    _translationAnim = Tween<double>(begin: -0.6, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.enabled) {
      // 使用項目 index 來決定相位偏移量，
      // 如此能確保每個分頁的抖動起動點不同，呈現擬真且不呆板的 iOS 非同步抖動效果。
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

  // 簡短文字標籤，適用於島嶼空間
  static const Map<int, String> _tabLabelsShort = {
    0: '首頁',
    1: '學習',
    2: '小法助',
    3: '紀事',
    4: '我的',
  };

  @override
  void initState() {
    super.initState();
    _tempOrder = List<int>.from(widget.appState.navbarOrder);
    _tempShowLabels = widget.appState.showNavbarLabels;
    _tempAccentIndex = widget.appState.accentColorIndex;
  }

  Widget _buildTabIcon(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 使用當前的 Accent 主題色，增加自訂時的色彩回饋感
    final iconColor = AppColors.accent;

    if (index == 2) {
      return Container(
        width: 24.w,
        height: 24.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/assistant/law_assistant_home.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
      );
    }

    final IconData iconData;
    switch (index) {
      case 0:
        iconData = Icons.home_rounded;
        break;
      case 1:
        iconData = Icons.menu_book_rounded;
        break;
      case 3:
        iconData = Icons.inventory_2_rounded;
        break;
      case 4:
      default:
        iconData = Icons.person_rounded;
        break;
    }

    return Icon(iconData, color: iconColor, size: 24.sp);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderSide =
        BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);
    final textMuted =
        isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2B3441) : AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '自訂導覽與介面',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color:
                      isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),

              // 1. 拖曳排序
              Text('自訂分頁順序（長按並左右拖曳進行排序）',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: textMuted)),
              SizedBox(height: 12.h),

              // 水平「懸浮島嶼」拖曳排序列，高度固定為 84.h，大圓角與精緻陰影
              Container(
                height: 84.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A2028)
                      : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ReorderableListView(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false, // 長按拖曳
                  children: [
                    for (int i = 0; i < _tempOrder.length; i++)
                      ReorderableDelayedDragStartListener(
                        index: i,
                        key: ValueKey(_tempOrder[i]),
                        child: _JiggleWidget(
                          index: i,
                          enabled: true,
                          child: Container(
                            width:
                                (MediaQuery.sizeOf(context).width - 64.w) / 5.2,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTabIcon(_tempOrder[i]),
                                SizedBox(height: 5.h),
                                Text(
                                  _tabLabelsShort[_tempOrder[i]]!,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFF2F4F7)
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final int item = _tempOrder.removeAt(oldIndex);
                      _tempOrder.insert(newIndex, item);
                    });
                  },
                ),
              ),
              SizedBox(height: 24.h),

              // 2. 顯示文字標籤
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F1216)
                      : const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: borderSide.color),
                ),
                child: SwitchListTile(
                  title: const Text('顯示分頁文字標籤',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('關閉後將只顯示導覽圖示，高度更加緊湊'),
                  value: _tempShowLabels,
                  activeThumbColor: AppColors.accent,
                  onChanged: (val) {
                    setState(() {
                      _tempShowLabels = val;
                    });
                  },
                ),
              ),
              SizedBox(height: 24.h),

              // 3. 主題 Accent Color 點選
              Text('App 品牌配色',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: textMuted)),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildColorCircle(0, const Color(0xFFD6A85F), '金沙黃'),
                  _buildColorCircle(1, const Color(0xFFC62828), '酒櫻紅'),
                  _buildColorCircle(2, const Color(0xFF1565C0), '律政藍'),
                  _buildColorCircle(3, const Color(0xFF2E7D32), '法規綠'),
                ],
              ),
              SizedBox(height: 28.h),

              // 操作按鈕
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: borderSide,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text('取消',
                          style: TextStyle(fontSize: 14.sp, color: textMuted)),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('介面自訂偏好已儲存！'),
                            backgroundColor: Color(0xFF2E7D32),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text('儲存變更',
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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

  Widget _buildColorCircle(int index, Color color, String name) {
    final isSelected = _tempAccentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempAccentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3.w)
                  : Border.all(color: Colors.transparent),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isSelected ? 0.5 : 0.2),
                  blurRadius: isSelected ? 8 : 4,
                  spreadRadius: isSelected ? 2 : 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
          SizedBox(height: 6.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.accent : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
