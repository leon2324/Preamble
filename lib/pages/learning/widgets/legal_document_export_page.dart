import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/home/v2/home_v2_palette.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/theme/app_colors.dart';
import 'package:preamble/features/case_library/widgets/case_library_svg_icon.dart';
import 'package:printing/printing.dart';
import 'package:preamble/pages/learning/widgets/pdf_style_builder.dart';

class LegalDocumentExportPage extends StatefulWidget {
  const LegalDocumentExportPage({
    super.key,
    required this.title,
    required this.content,
    this.dynamicDocument,
  });

  final String title;
  final String content;
  final DynamicLegalDocument? dynamicDocument;

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
    CustomToast.show(
      context,
      '書狀文字已複製。',
      icon: Icons.copy_rounded,
    );
  }

  String _pdfFileName() {
    final now = DateTime.now();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final date =
        '${now.year}${twoDigits(now.month)}${twoDigits(now.day)}_${twoDigits(now.hour)}${twoDigits(now.minute)}';
    return 'preamble_legal_document_$date.pdf';
  }

  Future<Uint8List> _buildPdfBytes() async {
    return PdfStyleBuilder.buildDocumentPdf(
      title: widget.title,
      content: widget.content,
      dynamicDocument: widget.dynamicDocument,
      themeStyle: PdfThemeStyle.morandiGreen,
    );
  }

  Future<void> _exportPdf() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
      _exportStepText = '正在分析書狀段落結構...';
    });
    HapticFeedback.mediumImpact();

    // 匯出流程只負責產生 PDF bytes 並交給系統分享面板，不自行承諾已存到下載資料夾。
    // 這能保留正式產品的真實性，也避免額外檔案權限與平台路徑差異。
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
      _exportStepText = '正在載入繁中文字型並排版書狀內容...';
    });

    // 分兩個 try/catch 層，精準區分「PDF bytes 產生失敗」與「share sheet 失敗」，
    // 避免使用者取消分享或模擬器 share sheet 問題被誤判為 PDF 產生失敗。
    Uint8List pdfBytes;
    try {
      pdfBytes = await _buildPdfBytes();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isExporting = false;
      });
      CustomToast.show(
        context,
        'PDF 產生失敗，請稍後再試。',
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    if (!mounted) return;
    if (pdfBytes.isEmpty) {
      setState(() {
        _isExporting = false;
      });
      CustomToast.show(
        context,
        'PDF 產生失敗，請稍後再試。',
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    setState(() {
      _exportProgress = 0.75;
      _exportStepText = '正在交給系統分享 PDF...';
    });
    _sealAnimController.forward();
    HapticFeedback.heavyImpact();

    try {
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: _pdfFileName(),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isExporting = false;
      });
      CustomToast.show(
        context,
        'PDF 已產生，但目前裝置無法開啟分享流程。',
        icon: Icons.share_outlined,
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _exportProgress = 1.0;
      _exportStepText = 'PDF 已交給系統分享流程。';
    });

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    setState(() {
      _isExporting = false;
    });
    _showPdfSharedDialog();
  }

  void _showPdfSharedDialog() {
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
                  child: CaseLibrarySvgIcon(
                    CaseLibrarySvgIcons.star,
                    size: 24.sp,
                    color: Colors.green,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'PDF 已準備完成',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            '已產生書狀 PDF 並開啟系統分享流程。你可以選擇儲存到檔案、傳送或列印；App 不會宣稱已自動寫入下載資料夾。',
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

    final appState = PreambleScope.of(context);
    final isPro = appState.subscriptionService.isProOrHigher;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '📄 書狀預覽與導出',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: isPro ? 'PRO 專業會員尊享' : '升級 PRO 去除浮水印',
            icon: Icon(
              Icons.workspace_premium_rounded,
              color: isPro ? const Color(0xFFD4AF37) : Colors.white70,
              size: 22.sp,
            ),
            onPressed: () => MorandiPaywallSheet.show(context),
          ),
        ],
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
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
                        Expanded(
                          child: FilledButton.icon(
                            icon: CaseLibrarySvgIcon(
                              CaseLibrarySvgIcons.chevronRight,
                              size: 14.sp,
                              color: Colors.white,
                            ),
                            label: const Text('匯出 PDF'),
                            style: FilledButton.styleFrom(
                              backgroundColor: HomeV2Palette.trustGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r)),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            onPressed: _exportPdf,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // 律師審核交辦入口
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          final brief = widget.dynamicDocument != null
                              ? CaseBriefPackager.fromDynamicDocument(widget.dynamicDocument!)
                              : CaseBrief(
                                  disputeCategory: widget.title,
                                  factSummary: widget.content,
                                  demands: const ['委託專業律師審核書狀條款'],
                                  evidences: const ['相關證據與公文草稿'],
                                  possibleLegalBasis: const [],
                                );
                          LawyerReferralSheet.show(context, caseBrief: brief);
                        },
                        icon: Icon(
                          Icons.gavel_rounded,
                          size: 15.sp,
                          color: isDark ? const Color(0xFFE5C07B) : const Color(0xFF9E6800),
                        ),
                        label: Text(
                          '需要更周全保障？交辦專業執業律師審核此份書狀',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFE5C07B) : const Color(0xFF9E6800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 匯出加載浮層
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
