import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:preamble/components/shared/mvp_state_widgets.dart';

enum PdfThemeStyle {
  morandiGreen,
  charcoalDark,
}

/// 莫蘭迪 / Charcoal 設計系統 PDF 主題繪製引擎。
class PdfStyleBuilder {
  const PdfStyleBuilder();

  static Future<Uint8List> buildDocumentPdf({
    required String title,
    required String content,
    PdfThemeStyle themeStyle = PdfThemeStyle.morandiGreen,
    Uint8List? signaturePngBytes,
  }) async {
    final serifData = await rootBundle.load(
      'assets/fonts/open_source/SourceHanSerifTW-VF.ttf',
    );
    final sansData = await rootBundle.load(
      'assets/fonts/open_source/SourceHanSansTW-VF.ttf',
    );

    final serifFont = pw.Font.ttf(serifData);
    final sansFont = pw.Font.ttf(sansData);

    final primaryColor = themeStyle == PdfThemeStyle.morandiGreen
        ? PdfColor.fromHex('#2C5E43') // 莫蘭迪墨綠
        : PdfColor.fromHex('#17231F'); // 炭灰

    final accentBorderColor = themeStyle == PdfThemeStyle.morandiGreen
        ? PdfColor.fromHex('#B8DAC8')
        : PdfColor.fromHex('#D0D5DD');

    final bgCardColor = themeStyle == PdfThemeStyle.morandiGreen
        ? PdfColor.fromHex('#F5F8F6')
        : PdfColor.fromHex('#F8F9FA');

    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(42, 44, 42, 48),
        theme: pw.ThemeData.withFont(
          base: serifFont,
          bold: sansFont,
        ),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '緒言 PREAMBLE 法律文件草稿',
                style: pw.TextStyle(
                  font: sansFont,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: sansFont,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    '法律提醒：$lawAppLegalDisclaimer',
                    style: pw.TextStyle(
                      font: sansFont,
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
                pw.Text(
                  '${context.pageNumber} / ${context.pagesCount}',
                  style: pw.TextStyle(
                    font: sansFont,
                    fontSize: 8.5,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 16),

          // 標題大字卡
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: pw.BoxDecoration(
              color: bgCardColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: accentBorderColor),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    font: sansFont,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '產出日期：${DateTime.now().toString().split('.').first}',
                  style: pw.TextStyle(
                    font: sansFont,
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // 內文卡片
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: accentBorderColor, width: 0.8),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              content,
              style: pw.TextStyle(
                font: serifFont,
                fontSize: 11.5,
                lineSpacing: 5.5,
                color: PdfColor.fromHex('#17231F'),
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // 申請人蓋印與簽名落款卡片 (Signature / Seal Block)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#FAFAFA'),
              border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (signaturePngBytes != null && signaturePngBytes.isNotEmpty) ...[
                      pw.Text(
                        '立書人 / 發起人親筆簽章：',
                        style: pw.TextStyle(
                          font: sansFont,
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#17231F'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        width: 120,
                        height: 40,
                        child: pw.Image(
                          pw.MemoryImage(signaturePngBytes),
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                    ] else ...[
                      pw.Text(
                        '立書人 / 發起人簽章：__________________',
                        style: pw.TextStyle(
                          font: sansFont,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#17231F'),
                        ),
                      ),
                    ],
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '日期：______ 年 ______ 月 ______ 日',
                      style: pw.TextStyle(
                        font: sansFont,
                        fontSize: 9.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  width: 50,
                  height: 50,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('#9E4A4A'), width: 1.2),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '簽章蓋印',
                      style: pw.TextStyle(
                        font: sansFont,
                        fontSize: 8.5,
                        color: PdfColor.fromHex('#9E4A4A'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return document.save();
  }
}
