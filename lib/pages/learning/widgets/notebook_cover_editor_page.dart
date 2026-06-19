import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/data/learning/learning_game_state.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/theme/app_colors.dart';

class NotebookCoverEditorPage extends StatefulWidget {
  const NotebookCoverEditorPage({super.key});

  @override
  State<NotebookCoverEditorPage> createState() => _NotebookCoverEditorPageState();
}

class _NotebookCoverEditorPageState extends State<NotebookCoverEditorPage> {
  late final LearningGameState _gameState;
  
  // 莫蘭迪封面底色選項
  final List<Map<String, dynamic>> _coverColors = [
    {'name': '燕麥奶油', 'hex': '#EFECE6', 'color': const Color(0xFFEFECE6)},
    {'name': '鼠尾草綠', 'hex': '#E0ECE0', 'color': const Color(0xFFE0ECE0)},
    {'name': '霧霾灰藍', 'hex': '#DFE9F2', 'color': const Color(0xFFDFE9F2)},
    {'name': '薰衣草紫', 'hex': '#E8DFE9', 'color': const Color(0xFFE8DFE9)},
    {'name': '嫣粉珊瑚', 'hex': '#F2DFE3', 'color': const Color(0xFFF2DFE3)},
    {'name': '摩卡雅灰', 'hex': '#E1DDD5', 'color': const Color(0xFFE1DDD5)},
  ];

  // 貼紙/印章庫定義
  final Map<String, Map<String, dynamic>> _stickersDb = {
    'sprout': {'emoji': '🌱', 'name': '法學新芽', 'desc': 'Level 1 解鎖'},
    'gavel': {'emoji': '🔨', 'name': '思辨法槌', 'desc': '使用 3 次翻譯機解鎖'},
    'shield': {'emoji': '🛡️', 'name': '自救盾牌', 'desc': '儲存任意證據清單解鎖'},
    'trophy': {'emoji': '🏆', 'name': '擂台金盃', 'desc': '隨堂考或小擂台完美解鎖'},
    'star': {'emoji': '⭐', 'name': '連擊之星', 'desc': '學習連擊達到 7 天解鎖'},
    'heart': {'emoji': '❤️', 'name': '平分秋色', 'desc': '進行財產或加班計算解鎖'},
    'scale': {'emoji': '⚖️', 'name': '公平天平', 'desc': '通關 3 個專題單元解鎖'},
    'car': {'emoji': '🚗', 'name': '交通安全', 'desc': '使用車禍折舊計算器解鎖'},
  };

  late String _selectedColorHex;
  List<Map<String, dynamic>> _tempPlacedStickers = [];
  int? _activeStickerIndex;

  @override
  void initState() {
    super.initState();
    _gameState = LearningGameState.instance;
    _selectedColorHex = _gameState.coverColorHex;
    // 複製一份，避免未按保存就直接影響全局狀態
    _tempPlacedStickers = List<Map<String, dynamic>>.from(
      _gameState.placedStickers.map((item) => Map<String, dynamic>.from(item)),
    );
  }

  // 取得轉換後的顏色物件
  Color _getCoverColor(String hex) {
    final match = _coverColors.firstWhere((c) => c['hex'] == hex, orElse: () => _coverColors.first);
    return match['color'] as Color;
  }

  // 新增貼紙到封面中心 (相對百分比座標 0.5, 0.4)
  void _addStickerToCover(String id) {
    if (!_gameState.unlockedStickers.contains(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔒 此貼紙尚未解鎖！條件：${_stickersDb[id]?['desc']}'),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _tempPlacedStickers.add({
        'id': id,
        'dx': 0.5, // 相對 X (0.0 到 1.0)
        'dy': 0.4, // 相對 Y (0.0 到 1.0)
        'scale': 1.0,
      });
      _activeStickerIndex = _tempPlacedStickers.length - 1;
    });
    HapticFeedback.lightImpact();
  }

  void _saveDesign() {
    _gameState.saveNotebookCover(_selectedColorHex, _tempPlacedStickers);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💾 筆記本封面設計保存成功！'),
        backgroundColor: HomeV2Palette.trustGreen,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coverBgColor = _getCoverColor(_selectedColorHex);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🎨 筆記本封面編輯器',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveDesign,
            child: Text(
              '保存',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: HomeV2Palette.trustGreen,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // 頂部操作小提示
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              '提示：選取貼紙後，可在封面上拖曳調整位置，或使用下方滑桿縮放。',
              style: TextStyle(fontSize: 10.5.sp, color: AppColors.textSecondary),
            ),
          ),

          // 筆記本封面渲染工作區
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activeStickerIndex = null; // 點選空白處取消選取
                  });
                },
                child: AspectRatio(
                  aspectRatio: 3.2 / 4.4, // 仿筆記本比例
                  child: Container(
                    margin: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: coverBgColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16.r),
                        bottomRight: Radius.circular(16.r),
                        topLeft: Radius.circular(4.r),
                        bottomLeft: Radius.circular(4.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(4, 6),
                        )
                      ],
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
                        width: 1.w,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final coverWidth = constraints.maxWidth;
                        final coverHeight = constraints.maxHeight;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 筆記本脊椎陰影 (強調書脊立體感)
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: 12.w,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.15),
                                      Colors.black.withValues(alpha: 0.03),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.4, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            // 書脊側邊壓紋雙線
                            Positioned(
                              left: 14.w,
                              top: 0,
                              bottom: 0,
                              width: 1.5.w,
                              child: Container(color: Colors.black.withValues(alpha: 0.08)),
                            ),

                            // 書名標籤貼紙 (手寫本特色)
                            Positioned(
                              top: 45.h,
                              left: 32.w,
                              right: 32.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(color: Colors.brown.shade200, width: 1.w),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'LAW NOTEBOOK',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown.shade800,
                                        letterSpacing: 2,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '我的法學成長手寫本',
                                      style: TextStyle(
                                        fontSize: 9.5.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown.shade600,
                                        fontFamily: 'SourceHanSerifTW',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 渲染已貼上的貼紙列表
                            ...List.generate(_tempPlacedStickers.length, (index) {
                              final item = _tempPlacedStickers[index];
                              final String stickerId = item['id'];
                              final double rx = item['dx']; // 相對 X
                              final double ry = item['dy']; // 相對 Y
                              final double scale = item['scale'];
                              final emoji = _stickersDb[stickerId]?['emoji'] ?? '🌿';

                              // 計算絕對像素位置
                              final stickerSize = 48.w * scale;
                              final posX = (rx * coverWidth) - (stickerSize / 2);
                              final posY = (ry * coverHeight) - (stickerSize / 2);

                              final isActive = _activeStickerIndex == index;

                              return Positioned(
                                left: posX,
                                top: posY,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _activeStickerIndex = index;
                                    });
                                  },
                                  onPanUpdate: (details) {
                                    setState(() {
                                      _activeStickerIndex = index;
                                      // 增量更新相對座標
                                      double newDx = rx + (details.delta.dx / coverWidth);
                                      double newDy = ry + (details.delta.dy / coverHeight);
                                      // 限制在封面範圍內 (留些邊緣)
                                      item['dx'] = newDx.clamp(0.08, 0.92);
                                      item['dy'] = newDy.clamp(0.08, 0.92);
                                    });
                                  },
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // 貼紙本體 (Emoji)
                                      Container(
                                        width: stickerSize,
                                        height: stickerSize,
                                        decoration: isActive
                                            ? BoxDecoration(
                                                border: Border.all(
                                                  color: HomeV2Palette.trustGreen,
                                                  width: 1.5.w,
                                                  style: BorderStyle.solid,
                                                ),
                                                borderRadius: BorderRadius.circular(6.r),
                                              )
                                            : null,
                                        alignment: Alignment.center,
                                        child: Text(
                                          emoji,
                                          style: TextStyle(fontSize: 32.sp * scale),
                                        ),
                                      ),

                                      // 刪除按鈕 (僅在選取狀態顯示)
                                      if (isActive)
                                        Positioned(
                                          right: -8.w,
                                          top: -8.w,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _tempPlacedStickers.removeAt(index);
                                                _activeStickerIndex = null;
                                              });
                                              HapticFeedback.lightImpact();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(2.w),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 下方編輯工具列 (底色選取 + 貼紙縮放 + 貼紙庫)
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161C23) : const Color(0xFFF7F5F0),
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF2D3845) : const Color(0xFFE5DCCF),
                  width: 1.2.w,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. 若有選中貼紙，顯示「縮放控制滑桿」
                if (_activeStickerIndex != null) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Icon(Icons.zoom_in_rounded, size: 16.sp, color: AppColors.textSecondary),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Slider(
                            value: _tempPlacedStickers[_activeStickerIndex!]['scale'] as double,
                            min: 0.6,
                            max: 2.0,
                            activeColor: HomeV2Palette.trustGreen,
                            onChanged: (val) {
                              setState(() {
                                _tempPlacedStickers[_activeStickerIndex!]['scale'] = val;
                              });
                            },
                          ),
                        ),
                        Text(
                          '${((_tempPlacedStickers[_activeStickerIndex!]['scale'] as double) * 100).toInt()}%',
                          style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],

                // 2. 封面色系切換列
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        '封面底色：',
                        style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    SizedBox(
                      height: 32.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        itemCount: _coverColors.length,
                        itemBuilder: (context, index) {
                          final c = _coverColors[index];
                          final hex = c['hex'] as String;
                          final isSelected = hex == _selectedColorHex;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColorHex = hex;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: 32.w,
                              height: 32.h,
                              decoration: BoxDecoration(
                                color: c['color'] as Color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? HomeV2Palette.trustGreen : Colors.transparent,
                                  width: 2.5.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // 3. 貼紙庫抽屜
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Text(
                            '已解鎖的貼紙庫：',
                            style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          Text(
                            '已解鎖 ${_gameState.unlockedStickers.length} / ${_stickersDb.length}',
                            style: TextStyle(fontSize: 10.sp, color: HomeV2Palette.trustGreen, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    SizedBox(
                      height: 56.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        children: _stickersDb.keys.map((id) {
                          final sticker = _stickersDb[id]!;
                          final isUnlocked = _gameState.unlockedStickers.contains(id);

                          return GestureDetector(
                            onTap: () => _addStickerToCover(id),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 6.w),
                              width: 50.w,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF232C35) : Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF2D3845) : const Color(0xFFECE5D9),
                                  width: 1.w,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Sticker Emoji
                                  Text(
                                    sticker['emoji'],
                                    style: TextStyle(fontSize: 26.sp),
                                  ),
                                  // Lock Mask
                                  if (!isUnlocked)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.45),
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.lock_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
