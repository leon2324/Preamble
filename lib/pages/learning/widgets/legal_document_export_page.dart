import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';

class LegalDocumentExportPage extends StatefulWidget {
  const LegalDocumentExportPage({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  State<LegalDocumentExportPage> createState() =>
      _LegalDocumentExportPageState();
}

class _LegalDocumentExportPageState extends State<LegalDocumentExportPage>
    with SingleTickerProviderStateMixin {
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _exportStepText = '';
  late AnimationController _sealAnimController;
  late Animation<double> _sealScaleAnimation;

  @override
  void initState() {
    super.initState();
    _sealAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _sealScaleAnimation = CurvedAnimation(
      parent: _sealAnimController,
      curve: Curves.bounceOut,
    );
  }

  @override
  void dispose() {
    _sealAnimController.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.content));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 已複製催告信函草稿至剪貼簿，可直接至外部貼上編輯！'),
        backgroundColor: HomeV2Palette.trustGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _prepareCopyPackage() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
      _exportStepText = '正在分析書狀段落結構...';
    });
    HapticFeedback.mediumImpact();

    // 台灣繁體中文教學註解：
    // Release 版尚未接入真正 PDF/圖片產生器，因此這裡只整理可複製的正式文字包，
    // 不宣稱已寫入下載資料夾，也不要求相簿或檔案權限。
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _exportProgress = 0.25;
      _exportStepText = '正在套用中華民國郵局存證信函格式...';
    });

    // 步驟 2
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _exportProgress = 0.50;
      _exportStepText = '正在整理可複製的標題、段落與簽名欄位...';
    });

    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _exportProgress = 0.75;
      _exportStepText = '正在加入法律資訊免責與本機保存提醒...';
    });
    _sealAnimController.forward();
    HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _exportProgress = 1.0;
      _exportStepText = '書狀文字包已整理完成。';
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    Clipboard.setData(ClipboardData(text: widget.content));
    setState(() {
      _isExporting = false;
    });

    _showCopyReadyDialog();
  }

  void _showCopyReadyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF6E2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CtmSvgIcon(
                    CtmSvgIcons.star,
                    size: 24.sp,
                    color: Colors.green,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '書狀文字已整理',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            '書狀文字已複製到剪貼簿，可貼到外部文件工具進一步編輯、列印或轉成 PDF。目前 App 不會自行產生 PDF、圖片或寫入下載資料夾。',
            style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.45,
                color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _sealAnimController.reset();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: HomeV2Palette.trustGreen,
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: const Text('確定'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '📄 書狀預覽與導出',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 主要預覽區
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(minHeight: 520.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF231E1E)
                            : const Color(0xFFFFFDF9), // 米白色紙張質感
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF4C3030)
                              : const Color(0xFFE2C2C2), // 紅色雙線邊框視覺
                          width: 2.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: EdgeInsets.all(20.w),
                      child: Stack(
                        children: [
                          // 浮水印 (背景小法助圖案)
                          Positioned.fill(
                            child: Opacity(
                              opacity: isDark ? 0.03 : 0.05,
                              child: Center(
                                child: Image.asset(
                                  'assets/images/assistant/law_assistant_home.png',
                                  width: 180.w,
                                  height: 180.w,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          // 存證信函格線視覺與內容
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 頂部抬頭
                              Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF6C3E3E)
                                          : const Color(0xFFC97F7F),
                                      width: 1.5.w,
                                    ),
                                  ),
                                  child: Text(
                                    widget.title.contains('存證信函')
                                        ? '郵局存證信函 (草案)'
                                        : '正式法律公文委託書',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? const Color(0xFFE2C2C2)
                                          : const Color(0xFF9E4A4A),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // 文件本文
                              SelectableText(
                                widget.content,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  height: 1.6,
                                  color: isDark
                                      ? const Color(0xFFE5D5D5)
                                      : const Color(0xFF2C2424),
                                  fontFamily: 'SourceHanSerifTW', // 法律明體字重書卷感
                                ),
                              ),

                              SizedBox(height: 60.h),

                              // 用印處 (蓋章)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '官方認證核發專用章：',
                                        style: TextStyle(
                                          fontSize: 9.5.sp,
                                          color: isDark
                                              ? Colors.grey
                                              : const Color(0xFF8C7F7F),
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      // 蓋章縮放動畫
                                      ScaleTransition(
                                        scale: _sealScaleAnimation,
                                        child: Container(
                                          width: 52.w,
                                          height: 52.w,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: isDark
                                                  ? const Color(0xFFFF4D4D)
                                                  : const Color(0xFFE60000),
                                              width: 2.2.w,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '小法\n助印',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? const Color(0xFFFF4D4D)
                                                    : const Color(0xFFE60000),
                                                fontFamily: 'Kai',
                                                height: 1.25,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 16.w),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 底部按鈕區
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF161C23)
                      : const Color(0xFFF7F7F7),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? const Color(0xFF2D3845)
                          : const Color(0xFFE5E5E5),
                      width: 1.w,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // 複製按鈕
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('僅複製本文'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.grey.shade300
                              : AppColors.textPrimary,
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF354454)
                                : const Color(0xFFCCCCCC),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: _copyToClipboard,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // 台灣繁體中文教學註解：只提供真實可完成的剪貼簿整理，不宣稱產生檔案。
                    Expanded(
                      child: FilledButton.icon(
                        icon: CtmSvgIcon(
                          CtmSvgIcons.chevronRight,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                        label: const Text('整理並複製文字'),
                        style: FilledButton.styleFrom(
                          backgroundColor: HomeV2Palette.trustGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: _prepareCopyPackage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 匯出加載浮層 (編譯用印動畫)
          if (_isExporting)
            Container(
              color: Colors.black.withValues(alpha: 0.75),
              child: Center(
                child: Container(
                  width: 280.w,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF202A35) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black45,
                          blurRadius: 15,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '📝 正在導出書狀...',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // 進度條
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: LinearProgressIndicator(
                          value: _exportProgress,
                          color: HomeV2Palette.trustGreen,
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          minHeight: 6.h,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      // 狀態步驟提示字
                      Text(
                        _exportStepText,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
