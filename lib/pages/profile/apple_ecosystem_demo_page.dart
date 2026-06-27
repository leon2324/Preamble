import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/shared/liquid_glass_widgets.dart';
import 'package:preamble/platform/ios_today_case_widget_bridge.dart';

/// 台灣繁體中文教學註解：
/// 這是 Apple 生態展示中心 (AppleEcosystemDemoPage)。
/// 用於在 Maic 大賽中向評審演示 Live Activities, SwiftUI Widgets, PencilKit, 
/// Siri Shortcuts 等需要 Apple 付費證書才能在實機完整打包的 Apple 優勢特色，
/// 同時在專案中建立最穩健的展示邏輯。
class AppleEcosystemDemoPage extends StatefulWidget {
  const AppleEcosystemDemoPage({super.key});

  @override
  State<AppleEcosystemDemoPage> createState() => _AppleEcosystemDemoPageState();
}

class _AppleEcosystemDemoPageState extends State<AppleEcosystemDemoPage> {
  // 動態島狀態
  bool _isIslandExpanded = false;
  String _islandText = "1審宣判 倒數 3 天";

  // Widget 互動待辦
  final List<Map<String, dynamic>> _widgetTodos = [
    {"title": "遞交訴訟委任狀", "checked": true},
    {"title": "繳納第一審裁判費", "checked": false},
    {"title": "聲請傳喚關鍵證人", "checked": false},
  ];

  // Siri 語音動畫狀態
  bool _isSiriSpeaking = false;
  String _siriResponse = "";
  double _siriWaveHeight = 0.0;
  Timer? _siriTimer;

  // PencilKit 畫板狀態
  List<Offset?> _points = [];
  bool _isOcrConverted = false;
  String _ocrText = "起訴書\n原告：蒔光未來股份有限公司\n訴訟代理人：張三律師\n被告：被告股份有限公司\n為前開當事人間請求給付加班費事件，依法提起起訴。";

  // Live Text 相機狀態
  bool _isOcrScanning = false;
  bool _ocrScanDone = false;

  @override
  void initState() {
    super.initState();
    // 初始化時同步一次待辦清單
    final activeTasks = _widgetTodos
        .where((t) => t["checked"] == false)
        .map((t) => t["title"] as String)
        .toList();
    IosTodayCaseWidgetBridge.syncTodoList(activeTasks);
  }

  @override
  void dispose() {
    _siriTimer?.cancel();
    super.dispose();
  }

  // 模擬 Siri 觸發
  void _triggerSiri() {
    if (_isSiriSpeaking) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _isSiriSpeaking = true;
      _siriResponse = "正在傾聽...";
      _siriWaveHeight = 30.0;
    });

    int ticks = 0;
    _siriTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      ticks++;
      if (ticks == 10) {
        setState(() {
          _siriResponse = "Siri：「您最近的開庭期日為 7 月 2 日 14:00，台北地院第 12 法庭。」";
          _siriWaveHeight = 5.0;
          HapticFeedback.mediumImpact();
        });
      } else if (ticks == 30) {
        timer.cancel();
        setState(() {
          _isSiriSpeaking = false;
          _siriWaveHeight = 0.0;
        });
      } else {
        // 隨機波形高度
        if (mounted) {
          setState(() {
            _siriWaveHeight = 10.0 + (ticks % 3 == 0 ? 25.0 : 5.0);
          });
        }
      }
    });
  }

  // 模擬相機 Live Text 掃描
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
          HapticFeedback.vibrate();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // 主滾動區
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 64.h, 16.w, 40.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 16.h),
                      _buildSectionTitle("📱 iOS 17 互動式桌面小工具 (Widgets)"),
                      _buildWidgetDemo(),
                      SizedBox(height: 24.h),
                      _buildSectionTitle("✏️ PencilKit 批註畫板 & 隨手寫 (Scribble)"),
                      _buildPencilKitDemo(),
                      SizedBox(height: 24.h),
                      _buildSectionTitle(" Siri 捷徑語音與多彩流體波形"),
                      _buildSiriDemo(),
                      SizedBox(height: 24.h),
                      _buildSectionTitle("📷 Live Text 活字相機（起訴書辨識）"),
                      _buildCameraOcrDemo(),
                      SizedBox(height: 24.h),
                      _buildSectionTitle("⌚ Apple Watch & CarPlay 車載模擬"),
                      _buildDeviceSimulators(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),

              // 螢幕最上方的「仿真動態島 (Dynamic Island)」
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: _buildDynamicIsland(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B5E4F)),
          onPressed: () => Navigator.pop(context),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Apple 技術整合展示",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1B5E4F),
              ),
            ),
            Text(
              "Maic 賽道評審演示專屬工作區",
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2E7D32),
        ),
      ),
    );
  }

  // 1. 動態島模擬
  Widget _buildDynamicIsland() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isIslandExpanded = !_isIslandExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.elasticOut,
        width: _isIslandExpanded ? 330.w : 110.w,
        height: _isIslandExpanded ? 76.h : 28.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(_isIslandExpanded ? 24.r : 14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: _isIslandExpanded
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.scale, color: Colors.white, size: 16),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "緒言 Preamble • 即時時程",
                            style: TextStyle(color: Colors.grey, fontSize: 9.sp, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _islandText,
                            style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Text(
                    "3D 開庭中",
                    style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                  )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.scale, color: Color(0xFFFFB74D), size: 12),
                  SizedBox(width: 4.w),
                  Text(
                    "Preamble",
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
      ),
    );
  }

  // 2. iOS 桌面小工具模擬
  Widget _buildWidgetDemo() {
    return LiquidGlassCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "評審點選以下 Widget 圖板，可直接測試 iOS 17 的「桌面互動式勾選功能」：",
            style: TextStyle(fontSize: 10.5.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Container(
              width: 310.w,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.scale, color: Color(0xFF2E7D32), size: 14),
                          SizedBox(width: 4.w),
                          Text(
                            "訴訟準備進度",
                            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E4F)),
                          ),
                        ],
                      ),
                      Text("一審準備程序", style: TextStyle(fontSize: 8.sp, color: Colors.grey)),
                    ],
                  ),
                  const Divider(color: Color(0xFFC8E6C9), height: 16),
                  Column(
                    children: List.generate(_widgetTodos.length, (idx) {
                      final item = _widgetTodos[idx];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                setState(() {
                                  _widgetTodos[idx]["checked"] = !_widgetTodos[idx]["checked"];
                                });
                                final activeTasks = _widgetTodos
                                    .where((t) => t["checked"] == false)
                                    .map((t) => t["title"] as String)
                                    .toList();
                                IosTodayCaseWidgetBridge.syncTodoList(activeTasks);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: item["checked"] ? const Color(0xFF2E7D32) : Colors.transparent,
                                  border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: item["checked"]
                                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                                      : SizedBox(width: 10.w, height: 10.w),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              item["title"],
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: item["checked"] ? Colors.grey : const Color(0xFF0F1216),
                                decoration: item["checked"] ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // 3. PencilKit 批註畫板
  Widget _buildPencilKitDemo() {
    return LiquidGlassCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "請在下方手寫畫布進行簽名或寫字批註，模擬 iPad 上的 Apple Pencil 手寫筆跡：",
            style: TextStyle(fontSize: 10.5.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 10.h),
          // 畫板區域
          Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: GestureDetector(
              onPanUpdate: (details) {
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final localPosition = renderBox.globalToLocal(details.globalPosition);
                // 限制畫筆僅在畫布內
                setState(() {
                  _points.add(details.localPosition);
                });
              },
              onPanEnd: (details) => _points.add(null),
              child: CustomPaint(
                painter: PencilKitPainter(points: _points),
                size: Size.infinite,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LiquidGlassButton(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                buttonColor: const Color(0xFFC62828).withValues(alpha: 0.1),
                onTap: () {
                  setState(() {
                    _points.clear();
                    _isOcrConverted = false;
                  });
                },
                child: Text("清除畫布", style: TextStyle(color: const Color(0xFFC62828), fontSize: 10.sp, fontWeight: FontWeight.bold)),
              ),
              LiquidGlassButton(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                buttonColor: const Color(0xFF1B5E4F).withValues(alpha: 0.1),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _isOcrConverted = true;
                  });
                },
                child: Text("隨手寫 (Scribble) 辨識", style: TextStyle(color: const Color(0xFF1B5E4F), fontSize: 10.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (_isOcrConverted) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7F2),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE0DCCF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("✍️ Apple Scribble 轉文字成果：", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E4F))),
                  SizedBox(height: 4.h),
                  Text(_ocrText, style: TextStyle(fontSize: 10.sp, height: 1.4, color: Colors.grey[800])),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  // 4. Siri 語音捷徑
  Widget _buildSiriDemo() {
    return LiquidGlassCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "點擊下方按鈕觸發 Siri 捷徑模擬。程式會繪製 Siri 彩虹流體光學波形：",
            style: TextStyle(fontSize: 10.5.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Column(
              children: [
                LiquidGlassButton(
                  buttonColor: const Color(0xFF0F1216),
                  onTap: _triggerSiri,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mic, color: Colors.white, size: 16),
                      SizedBox(width: 6.w),
                      Text("喚醒 Siri：『打開緒言最近開庭』", style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                if (_isSiriSpeaking) ...[
                  SizedBox(height: 14.h),
                  // Siri 波形動畫
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: _siriWaveHeight.h,
                    width: 140.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (idx) {
                        return Container(
                          width: 4.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.r),
                            gradient: const LinearGradient(
                              colors: [Colors.purple, Colors.blue, Colors.cyan, Colors.pink],
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
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E4F)),
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  // 5. Live Text 相機模擬
  Widget _buildCameraOcrDemo() {
    return LiquidGlassCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "模擬調用 iOS Live Text (相機活字辨識)。對準紙本法學文書直接抓取文字：",
            style: TextStyle(fontSize: 10.5.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Column(
              children: [
                LiquidGlassButton(
                  buttonColor: const Color(0xFF1B5E4F),
                  onTap: _startCameraOcr,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      SizedBox(width: 6.w),
                      Text("對準判決書掃描並提取文字", style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                if (_isOcrScanning) ...[
                  SizedBox(height: 14.h),
                  Column(
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF1B5E4F)),
                      SizedBox(height: 8.h),
                      Text("iOS Live Text 正在光學識別中...", style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                    ],
                  )
                ],
                if (_ocrScanDone) ...[
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 14),
                            SizedBox(width: 4.w),
                            Text("辨識成功！文字已匯入手帳草稿", style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E4F))),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "「臺灣臺北地方法院民事判決 - 115年度勞訴字第99號... 請求給付加班費事件，判決主文：被告應給付原告新臺幣參拾萬零捌仟元。」",
                          style: TextStyle(fontSize: 9.5.sp, color: Colors.grey[800], height: 1.4),
                        ),
                      ],
                    ),
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  // 6. 設備模擬器
  Widget _buildDeviceSimulators() {
    return LiquidGlassCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Watch 模擬器
              Column(
                children: [
                  Text("⌚ Apple Watch", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  SizedBox(height: 8.h),
                  Container(
                    width: 100.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: Colors.grey[800]!, width: 4),
                    ),
                    padding: EdgeInsets.all(8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.scale, color: Color(0xFFFFB74D), size: 10),
                            Text("10:09", style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(color: Colors.grey, height: 8),
                        Text("開庭警告", style: TextStyle(color: Colors.red, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                        Text("下週二 14:00", style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold)),
                        Text("二審準備程序", style: TextStyle(color: Colors.grey, fontSize: 8.sp)),
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Center(
                            child: Text("確認收悉", style: TextStyle(color: Colors.white, fontSize: 7.sp, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              // CarPlay 模擬器
              Column(
                children: [
                  Text("🚗 Apple CarPlay", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  SizedBox(height: 8.h),
                  Container(
                    width: 160.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1216),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey[800]!, width: 3),
                    ),
                    padding: EdgeInsets.all(8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_car, color: Colors.blue, size: 10),
                            SizedBox(width: 4.w),
                            Text("CarPlay HUD", style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("🔊 正在播報避坑筆記：", style: TextStyle(color: Colors.green, fontSize: 7.5.sp, fontWeight: FontWeight.bold)),
                              Text("「房屋租賃糾紛：承租人有買賣不破租賃之適用...」", style: TextStyle(color: Colors.white, fontSize: 7.sp), maxLines: 2),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Icon(Icons.skip_previous, color: Colors.white, size: 12),
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
                              child: const Icon(Icons.play_arrow, color: Colors.white, size: 12),
                            ),
                            const Icon(Icons.skip_next, color: Colors.white, size: 12),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

// PencilKit 自定義畫筆繪製
class PencilKitPainter extends CustomPainter {
  final List<Offset?> points;

  PencilKitPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
