import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/components/shared/liquid_glass_widgets.dart';
import 'package:preamble/platform/ios_today_case_widget_bridge.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 系統整合與實驗室（iOS 小工具、即時動態、Siri 捷徑與手寫辨識展示頁）。
///
/// 全面採用 `context.tokens` 靜奢設計系統與 `PhosphorIcons`，
/// 支援淺深色雙模式、零 3D Emoji、零私用區 `U+F8FF` 字元。
class AppleEcosystemDemoPage extends StatefulWidget {
  const AppleEcosystemDemoPage({super.key});

  @override
  State<AppleEcosystemDemoPage> createState() => _AppleEcosystemDemoPageState();
}

class _AppleEcosystemDemoPageState extends State<AppleEcosystemDemoPage> {
  bool _isIslandExpanded = false;
  final String _islandText = '一審宣判 倒數 3 天';

  final List<Map<String, dynamic>> _widgetTodos = [
    {'title': '遞交訴訟委任狀', 'checked': true},
    {'title': '繳納第一審裁判費', 'checked': false},
    {'title': '聲請傳喚關鍵證人', 'checked': false},
  ];

  bool _isSiriSpeaking = false;
  String _siriResponse = '';
  double _siriWaveHeight = 0.0;
  Timer? _siriTimer;

  final List<Offset?> _points = [];
  bool _isOcrConverted = false;
  final String _ocrText =
      '起訴書\n原告：蒔光未來股份有限公司\n訴訟代理人：張三律師\n被告：相對人股份有限公司\n為前開當事人間請求給付加班費事件，依法提起起訴。';

  bool _isOcrScanning = false;
  bool _ocrScanDone = false;

  @override
  void initState() {
    super.initState();
    final activeTasks = _widgetTodos
        .where((t) => t['checked'] == false)
        .map((t) => t['title'] as String)
        .toList();
    IosTodayCaseWidgetBridge.syncTodoList(activeTasks);
  }

  @override
  void dispose() {
    _siriTimer?.cancel();
    super.dispose();
  }

  void _triggerSiri() {
    if (_isSiriSpeaking) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _isSiriSpeaking = true;
      _siriResponse = '正在傾聽語音指令...';
      _siriWaveHeight = 28.0;
    });

    int ticks = 0;
    _siriTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      ticks++;
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (ticks == 10) {
        setState(() {
          _siriResponse = 'Siri：「您最近的開庭期日為 7 月 2 日 14:00，臺北地院第 12 法庭。」';
          _siriWaveHeight = 6.0;
        });
        HapticFeedback.mediumImpact();
      } else if (ticks == 30) {
        timer.cancel();
        setState(() {
          _isSiriSpeaking = false;
          _siriWaveHeight = 0.0;
        });
      } else {
        setState(() {
          _siriWaveHeight = 10.0 + (ticks % 3 == 0 ? 22.0 : 6.0);
        });
      }
    });
  }

  void _startCameraOcr() {
    HapticFeedback.selectionClick();
    setState(() {
      _isOcrScanning = true;
      _ocrScanDone = false;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isOcrScanning = false;
          _ocrScanDone = true;
        });
        HapticFeedback.vibrate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 62.h, 16.w, 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(t),
                    SizedBox(height: 18.h),
                    _buildSectionTitle(
                      t,
                      icon: PhosphorIconsRegular.squaresFour,
                      title: 'iOS 互動式桌面小工具 (Widgets)',
                    ),
                    _buildWidgetDemo(t),
                    SizedBox(height: 22.h),
                    _buildSectionTitle(
                      t,
                      icon: PhosphorIconsRegular.pencilLine,
                      title: 'PencilKit 批註與隨手寫筆記 (Scribble)',
                    ),
                    _buildPencilKitDemo(t),
                    SizedBox(height: 22.h),
                    _buildSectionTitle(
                      t,
                      icon: PhosphorIconsRegular.microphoneStage,
                      title: 'Apple Siri 捷徑語音與快問整合',
                    ),
                    _buildSiriDemo(t),
                    SizedBox(height: 22.h),
                    _buildSectionTitle(
                      t,
                      icon: PhosphorIconsRegular.scan,
                      title: 'Live Text 原況文字（起訴書光學辨識）',
                    ),
                    _buildCameraOcrDemo(t),
                    SizedBox(height: 22.h),
                    _buildSectionTitle(
                      t,
                      icon: PhosphorIconsRegular.watch,
                      title: 'Apple Watch 與 CarPlay 跨裝置預覽',
                    ),
                    _buildDeviceSimulators(t),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: _buildDynamicIsland(t),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PreambleTokens t) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            PhosphorIconsRegular.caretLeft,
            color: t.textPrimary,
            size: 22.sp,
          ),
          tooltip: '返回',
          onPressed: () => Navigator.maybePop(context),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '系統整合與實驗室',
                style: t.serifTitle(size: 20.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                'Apple iOS 與 iPadOS 小工具、捷徑及原況文字展示',
                style: t.sansBody(size: 12.sp, color: t.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    PreambleTokens t, {
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, left: 4.w),
      child: Row(
        children: [
          Icon(icon, size: 17.sp, color: t.brandPrimary),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              title,
              style: t.sansTitle(size: 14.sp, color: t.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicIsland(PreambleTokens t) {
    const liveActivityChannel = MethodChannel('preamble/live_activity');
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        setState(() {
          _isIslandExpanded = !_isIslandExpanded;
        });
        try {
          if (_isIslandExpanded) {
            await liveActivityChannel.invokeMethod('startLiveActivity', {
              'caseTitle': '租屋退租返還押金與自然折舊扣抵爭議案',
              'status': '一審宣判',
              'countdownDays': 3,
              'nextEvent': '前往簡易庭聽取判決宣判',
            });
          } else {
            await liveActivityChannel.invokeMethod('stopLiveActivity');
          }
        } catch (e) {
          debugPrint('Live Activity Channel error: $e');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        constraints: BoxConstraints(
          maxWidth: _isIslandExpanded ? 328.w : 124.w,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: _isIslandExpanded ? 11.h : 6.h,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF101413),
          borderRadius: BorderRadius.circular(_isIslandExpanded ? 24.r : 16.r),
          border: Border.all(
            color: t.accentBrass.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: t.shadowAmbient,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isIslandExpanded
            ? Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: t.brandPrimaryStrong,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIconsRegular.scales,
                      color: t.accentBrass,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '緒言 Preamble • 即時動態',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.sansBody(
                            size: 10.sp,
                            weight: FontWeight.w600,
                            color: const Color(0xFFA7B3AE),
                          ),
                        ),
                        Text(
                          _islandText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.sansTitle(
                            size: 13.sp,
                            color: const Color(0xFFFAF8F4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '期日提醒',
                    style: t.sansBody(
                      size: 10.5.sp,
                      weight: FontWeight.w700,
                      color: t.accentBrass,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsRegular.scales,
                    color: t.accentBrass,
                    size: 13.sp,
                  ),
                  SizedBox(width: 5.w),
                  Flexible(
                    child: Text(
                      'Preamble',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.sansBody(
                        size: 10.5.sp,
                        weight: FontWeight.w700,
                        color: const Color(0xFFFAF8F4),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildWidgetDemo(PreambleTokens t) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: t.cardDecoration(radius: 20.r, elevated: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '可於 iOS 桌面新增小工具並直接勾選訴訟待辦清單：',
            style: t.sansBody(size: 12.sp, color: t.textSecondary),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: t.surfaceSubtle,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsRegular.scales,
                            color: t.brandPrimary,
                            size: 15.sp,
                          ),
                          SizedBox(width: 5.w),
                          Flexible(
                            child: Text(
                              '訴訟準備進度',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.sansTitle(
                                size: 12.sp,
                                color: t.brandPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '一審準備程序',
                      style: t.sansBody(size: 10.5.sp, color: t.textMuted),
                    ),
                  ],
                ),
                Divider(color: t.border, height: 18.h),
                Column(
                  children: List.generate(_widgetTodos.length, (idx) {
                    final item = _widgetTodos[idx];
                    final isChecked = item['checked'] as bool;
                    return InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _widgetTodos[idx]['checked'] = !isChecked;
                        });
                        final activeTasks = _widgetTodos
                            .where((task) => task['checked'] == false)
                            .map((task) => task['title'] as String)
                            .toList();
                        IosTodayCaseWidgetBridge.syncTodoList(activeTasks);
                      },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: Row(
                          children: [
                            Icon(
                              isChecked
                                  ? PhosphorIconsFill.checkCircle
                                  : PhosphorIconsRegular.circle,
                              size: 18.sp,
                              color: isChecked ? t.brandPrimary : t.textMuted,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                item['title'] as String,
                                style: t.sansBody(
                                  size: 12.5.sp,
                                  color: isChecked
                                      ? t.textMuted
                                      : t.textPrimary,
                                ).copyWith(
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPencilKitDemo(PreambleTokens t) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: t.cardDecoration(radius: 20.r, elevated: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '支援 iPadOS 手寫批註與隨手寫（Scribble）文字轉換：',
            style: t.sansBody(size: 12.sp, color: t.textSecondary),
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: t.surfaceSubtle,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: t.border),
              ),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _points.add(details.localPosition);
                  });
                },
                onPanEnd: (_) => _points.add(null),
                child: CustomPaint(
                  painter: PencilKitPainter(
                    points: _points,
                    strokeColor: t.brandPrimary,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _points.clear();
                    _isOcrConverted = false;
                  });
                },
                icon: Icon(PhosphorIconsRegular.eraser, size: 15.sp),
                label: const Text('清除畫布'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: t.semanticUrgent,
                  side: BorderSide(
                    color: t.semanticUrgent.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _isOcrConverted = true;
                  });
                },
                icon: Icon(PhosphorIconsRegular.textT, size: 15.sp),
                label: const Text('隨手寫 (Scribble) 辨識'),
                style: FilledButton.styleFrom(
                  backgroundColor: t.brandContainer,
                  foregroundColor: t.brandPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
          if (_isOcrConverted) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: t.subtleBoxDecoration(radius: 14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.pencilSimpleLine,
                        size: 15.sp,
                        color: t.brandPrimary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Apple Scribble 轉文字成果：',
                          style: t.sansTitle(
                            size: 12.sp,
                            color: t.brandPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    _ocrText,
                    style: t.sansBody(
                      size: 12.sp,
                      height: 1.5,
                      color: t.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSiriDemo(PreambleTokens t) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: t.cardDecoration(radius: 20.r, elevated: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '對接 iOS 捷徑（Shortcuts）語音喚醒與快速問診指令：',
            style: t.sansBody(size: 12.sp, color: t.textSecondary),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Column(
              children: [
                Wrap(
                  spacing: 10.w,
                  runSpacing: 8.h,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: _triggerSiri,
                      icon: Icon(PhosphorIconsRegular.microphone, size: 16.sp),
                      label: const Text('喚醒 Siri 查詢期日'),
                      style: FilledButton.styleFrom(
                        backgroundColor: t.surfaceElevated,
                        foregroundColor: t.textPrimary,
                        side: BorderSide(color: t.borderStrong),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ServicesBinding.instance.channelBuffers.push(
                          'preamble/quick_ask_intent',
                          const StandardMethodCodec().encodeMethodCall(
                            const MethodCall(
                              'openQuickAsk',
                              {'prompt': '租屋押金被扣怎麼辦？'},
                            ),
                          ),
                          (ByteData? data) {},
                        );
                        Navigator.of(context).maybePop();
                      },
                      icon: Icon(PhosphorIconsRegular.lightning, size: 16.sp),
                      label: const Text('捷徑指令快問'),
                      style: FilledButton.styleFrom(
                        backgroundColor: t.brandPrimaryStrong,
                        foregroundColor: const Color(0xFFFAF8F4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isSiriSpeaking) ...[
                  SizedBox(height: 14.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: _siriWaveHeight.h,
                    width: 140.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (_) {
                        return Container(
                          width: 4.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.r),
                            gradient: LinearGradient(
                              colors: [
                                t.brandPrimary,
                                t.accentBrass,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    _siriResponse,
                    textAlign: TextAlign.center,
                    style: t.sansTitle(size: 12.sp, color: t.brandPrimary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraOcrDemo(PreambleTokens t) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: t.cardDecoration(radius: 20.r, elevated: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '整合原況文字（Live Text），對準紙本法規與裁判書擷取關鍵段落：',
            style: t.sansBody(size: 12.sp, color: t.textSecondary),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Column(
              children: [
                FilledButton.icon(
                  onPressed: _startCameraOcr,
                  icon: Icon(PhosphorIconsRegular.camera, size: 16.sp),
                  label: const Text('模擬掃描裁判書並擷取文字'),
                  style: FilledButton.styleFrom(
                    backgroundColor: t.brandPrimaryStrong,
                    foregroundColor: const Color(0xFFFAF8F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                if (_isOcrScanning) ...[
                  SizedBox(height: 14.h),
                  LiquidGlassShimmer(
                    width: double.infinity,
                    height: 48.h,
                    radius: 12.r,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '正在進行原況文字光學辨識...',
                    style: t.sansBody(size: 11.5.sp, color: t.textMuted),
                  ),
                ],
                if (_ocrScanDone) ...[
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: t.semanticSuccessContainer,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: t.semanticSuccess.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              PhosphorIconsFill.checkCircle,
                              color: t.semanticSuccess,
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                '辨識完成，已擷取判決主文摘要',
                                style: t.sansTitle(
                                  size: 12.sp,
                                  color: t.semanticSuccess,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '「臺灣臺北地方法院民事判決 — 115 年度勞訴字第 99 號請求給付加班費事件，主文：被告應給付原告新臺幣參拾萬零捌仟元。」',
                          style: t.sansBody(
                            size: 11.5.sp,
                            color: t.textPrimary,
                            height: 1.48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSimulators(PreambleTokens t) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: t.cardDecoration(radius: 20.r, elevated: false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 290;
          final watchCard = _buildWatchPreviewCard(t);
          final carPlayCard = _buildCarPlayPreviewCard(t);

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                watchCard,
                SizedBox(height: 12.h),
                carPlayCard,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: watchCard),
              SizedBox(width: 10.w),
              Expanded(flex: 6, child: carPlayCard),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWatchPreviewCard(PreambleTokens t) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.watch,
              size: 14.sp,
              color: t.textSecondary,
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                'Apple Watch',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.sansTitle(size: 11.5.sp, color: t.textSecondary),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFF101413),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFF2D3532), width: 3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    PhosphorIconsRegular.scales,
                    color: t.accentBrass,
                    size: 12.sp,
                  ),
                  Text(
                    '10:09',
                    style: t.tabularMetric(
                      size: 9.5.sp,
                      color: const Color(0xFFFAF8F4),
                    ),
                  ),
                ],
              ),
              Divider(color: const Color(0xFF2D3532), height: 10.h),
              Text(
                '開庭期日提醒',
                style: t.sansBody(
                  size: 10.sp,
                  weight: FontWeight.w700,
                  color: t.accentBrass,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '下週二 14:00',
                style: t.sansTitle(
                  size: 11.sp,
                  color: const Color(0xFFFAF8F4),
                ),
              ),
              Text(
                '二審準備程序',
                style: t.sansBody(
                  size: 9.5.sp,
                  color: const Color(0xFFA7B3AE),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 4.h),
                decoration: BoxDecoration(
                  color: t.brandPrimaryStrong,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Center(
                  child: Text(
                    '確認收悉',
                    style: t.sansBody(
                      size: 9.5.sp,
                      weight: FontWeight.w700,
                      color: const Color(0xFFFAF8F4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarPlayPreviewCard(PreambleTokens t) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.carProfile,
              size: 14.sp,
              color: t.textSecondary,
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                'Apple CarPlay',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.sansTitle(size: 11.5.sp, color: t.textSecondary),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFF101413),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFF2D3532), width: 3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.speakerHigh,
                    color: t.accentBrass,
                    size: 12.sp,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      '語音導讀模式',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.sansBody(
                        size: 10.sp,
                        weight: FontWeight.w700,
                        color: const Color(0xFFFAF8F4),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF19211F),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '正在播報避坑筆記：',
                      style: t.sansBody(
                        size: 9.5.sp,
                        weight: FontWeight.w700,
                        color: t.accentBrass,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '「房屋租賃糾紛：定期租約原則上適用買賣不破租賃保障...」',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.sansBody(
                        size: 9.5.sp,
                        color: const Color(0xFFD6E2DC),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    PhosphorIconsFill.skipBack,
                    color: const Color(0xFFFAF8F4),
                    size: 13.sp,
                  ),
                  Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: t.brandPrimaryStrong,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIconsFill.play,
                      color: const Color(0xFFFAF8F4),
                      size: 12.sp,
                    ),
                  ),
                  Icon(
                    PhosphorIconsFill.skipForward,
                    color: const Color(0xFFFAF8F4),
                    size: 13.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PencilKitPainter extends CustomPainter {
  PencilKitPainter({
    required this.points,
    required this.strokeColor,
  });

  final List<Offset?> points;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PencilKitPainter oldDelegate) => true;
}
