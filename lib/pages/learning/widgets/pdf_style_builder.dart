import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:preamble/components/shared/mvp_state_widgets.dart';
import 'package:preamble/data/documents/document_models.dart';

enum PdfThemeStyle {
  morandiGreen,
  charcoalDark,
}

/// 莫蘭迪 / Charcoal 設計系統自適應法律文件 PDF 主題繪製引擎。
///
/// 支援純文字排版，以及支援 100% 動態 AI 生成之 `DynamicLegalDocument`
/// 結構化多章節、請求事項、附件清單、法規依據與雙方當事人用印簽章落款。
class PdfStyleBuilder {
  const PdfStyleBuilder();

  static Future<Uint8List> buildDocumentPdf({
    required String title,
    required String content,
    DynamicLegalDocument? dynamicDocument,
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

    final amberHighlight = PdfColor.fromHex('#FDF7E7');
    final amberBorder = PdfColor.fromHex('#E0C58A');
    final amberText = PdfColor.fromHex('#8A5A00');

    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 42, 40, 46),
        theme: pw.ThemeData.withFont(
          base: serifFont,
          bold: sansFont,
        ),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '緒言 PREAMBLE 法律公文系統',
                style: pw.TextStyle(
                  font: sansFont,
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: sansFont,
                  fontSize: 13,
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
            pw.SizedBox(height: 3),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    '法律提醒：$lawAppLegalDisclaimer',
                    style: pw.TextStyle(
                      font: sansFont,
                      fontSize: 7.5,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
                pw.Text(
                  '${context.pageNumber} / ${context.pagesCount}',
                  style: pw.TextStyle(
                    font: sansFont,
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 12),

          // 標題大字卡與發文字號/日期
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                if (dynamicDocument?.subtitle.isNotEmpty == true) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    dynamicDocument!.subtitle,
                    style: pw.TextStyle(
                      font: sansFont,
                      fontSize: 9.5,
                      color: primaryColor,
                    ),
                  ),
                ],
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '文件編號：PRM-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                      style: pw.TextStyle(
                        font: sansFont,
                        fontSize: 8.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      '產出日期：${DateTime.now().toString().split('.').first}',
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
          ),
          pw.SizedBox(height: 12),

          // 若為 100% 動態 AI 生成結構，自適應渲染各專業章節
          if (dynamicDocument != null && dynamicDocument.sections.isNotEmpty) ...[
            // 當事人資訊卡片
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                color: PdfColor.fromHex('#FCFDFD'),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      '發函人 / 申請人：${dynamicDocument.senderName}',
                      style: pw.TextStyle(
                        font: sansFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#17231F'),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      '相對人 / 受函人：${dynamicDocument.receiverName}',
                      style: pw.TextStyle(
                        font: sansFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#17231F'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // 動態章節內容
            for (var i = 0; i < dynamicDocument.sections.length; i++) ...[
              pw.Container(
                width: double.infinity,
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: accentBorderColor, width: 0.6),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${_chineseNumber(i + 1)}、${dynamicDocument.sections[i].heading}',
                      style: pw.TextStyle(
                        font: sansFont,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    if (dynamicDocument.sections[i].body.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        dynamicDocument.sections[i].body,
                        style: pw.TextStyle(
                          font: serifFont,
                          fontSize: 10.5,
                          lineSpacing: 4.5,
                          color: PdfColor.fromHex('#222B28'),
                        ),
                      ),
                    ],
                    for (final pt in dynamicDocument.sections[i].subPoints) ...[
                      pw.SizedBox(height: 3),
                      pw.Text(
                        '  （一）$pt',
                        style: pw.TextStyle(
                          font: serifFont,
                          fontSize: 10,
                          lineSpacing: 3.5,
                          color: PdfColor.fromHex('#3B4743'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // 請求及履行事項高亮卡片
            if (dynamicDocument.demands.isNotEmpty) ...[
              pw.Container(
                width: double.infinity,
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: bgCardColor,
                  border: pw.Border.all(color: primaryColor, width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '請求及履行事項（限期 ${dynamicDocument.deadlineDays} 日內）：',
                      style: pw.TextStyle(
                        font: sansFont,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    for (var d = 0; d < dynamicDocument.demands.length; d++)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 3),
                        child: pw.Text(
                          '${d + 1}. ${dynamicDocument.demands[d]}',
                          style: pw.TextStyle(
                            font: sansFont,
                            fontSize: 10,
                            color: PdfColor.fromHex('#17231F'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // 法律依據與權益警告卡片
            if (dynamicDocument.warningClause.isNotEmpty) ...[
              pw.Container(
                width: double.infinity,
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: amberHighlight,
                  border: pw.Border.all(color: amberBorder, width: 0.8),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '【法律權益保留聲明】',
                      style: pw.TextStyle(
                        font: sansFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: amberText,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      dynamicDocument.warningClause,
                      style: pw.TextStyle(
                        font: serifFont,
                        fontSize: 9.5,
                        lineSpacing: 3.5,
                        color: PdfColor.fromHex('#473415'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            // 標準純文字卡片
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: accentBorderColor, width: 0.8),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                content,
                style: pw.TextStyle(
                  font: serifFont,
                  fontSize: 11,
                  lineSpacing: 5,
                  color: PdfColor.fromHex('#17231F'),
                ),
              ),
            ),
            pw.SizedBox(height: 12),
          ],

          // 雙方用印與簽章落款卡片 (Dual-Party Seal Block)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
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
                        '立書人 / 發函人親筆簽章：',
                        style: pw.TextStyle(
                          font: sansFont,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#17231F'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        width: 120,
                        height: 36,
                        child: pw.Image(
                          pw.MemoryImage(signaturePngBytes),
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                    ] else ...[
                      pw.Text(
                        '立書人 / 發函人簽章：__________________',
                        style: pw.TextStyle(
                          font: sansFont,
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#17231F'),
                        ),
                      ),
                    ],
                    pw.SizedBox(height: 6),
                    pw.Text(
                      '中華民國 ______ 年 ______ 月 ______ 日',
                      style: pw.TextStyle(
                        font: sansFont,
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  width: 48,
                  height: 48,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('#9E4A4A'), width: 1.2),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '官方用印\n存證專用',
                      style: pw.TextStyle(
                        font: sansFont,
                        fontSize: 7.5,
                        color: PdfColor.fromHex('#9E4A4A'),
                        lineSpacing: 1.5,
                      ),
                      textAlign: pw.TextAlign.center,
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

  static String _chineseNumber(int num) {
    const list = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    if (num >= 1 && num <= 10) return list[num - 1];
    return num.toString();
  }
}
