import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/data/legal_sources/legal_source_registry.dart';
import 'package:lawapp/theme/app_colors.dart';

enum _DocumentTemplate {
  depositDemand,
  laborOvertime,
  carAccidentMemo,
}

extension _DocumentTemplateText on _DocumentTemplate {
  String get label {
    switch (this) {
      case _DocumentTemplate.depositDemand:
        return '押金返還通知';
      case _DocumentTemplate.laborOvertime:
        return '加班費協商';
      case _DocumentTemplate.carAccidentMemo:
        return '車禍紀錄備忘';
    }
  }

  String get hint {
    switch (this) {
      case _DocumentTemplate.depositDemand:
        return '適合房東不退押金、扣款明細不清楚的情境。';
      case _DocumentTemplate.laborOvertime:
        return '適合先向公司整理工時與加班費爭議。';
      case _DocumentTemplate.carAccidentMemo:
        return '適合事故後整理事實、照片、初判表與聯絡紀錄。';
    }
  }
}

class LegalToolsPage extends StatefulWidget {
  const LegalToolsPage({super.key});

  @override
  State<LegalToolsPage> createState() => _LegalToolsPageState();
}

class _LegalToolsPageState extends State<LegalToolsPage> {
  final TextEditingController _nameController =
      TextEditingController(text: '王小明');
  final TextEditingController _targetController =
      TextEditingController(text: '陳房東');
  final TextEditingController _factsController = TextEditingController(
    text: '我在 2026/04/01 退租並完成點交，房東表示要全額扣押金，但尚未提供修繕明細。',
  );

  _DocumentTemplate _selectedTemplate = _DocumentTemplate.depositDemand;
  String _draft = '';

  @override
  void initState() {
    super.initState();
    _draft = _buildDraft(isPremiumTone: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _factsController.dispose();
    super.dispose();
  }

  void _selectTemplate(_DocumentTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _draft = _buildDraft(isPremiumTone: false);
    });
  }

  void _generateDraft() {
    final appState = LawAppScope.of(context);
    if (appState.isGuest) {
      _showMessage('登入後可以產生並保存文件草稿。');
      return;
    }

    setState(() {
      _draft = _buildDraft(isPremiumTone: appState.canUsePremiumDocuments);
    });
    _showMessage(
        appState.canUsePremiumDocuments ? '已產生 Pro 版草稿。' : '已產生會員版草稿。');
  }

  Future<void> _copyDraft() async {
    final appState = LawAppScope.of(context);
    if (!appState.canUsePremiumDocuments) {
      _showMessage('複製與匯出正式草稿屬於訂閱功能。');
      return;
    }

    await Clipboard.setData(ClipboardData(text: _draft));
    if (!mounted) return;
    _showMessage('已複製草稿。');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _buildDraft({required bool isPremiumTone}) {
    final name = _nameController.text.trim().isEmpty
        ? '本人'
        : _nameController.text.trim();
    final target = _targetController.text.trim().isEmpty
        ? '相對人'
        : _targetController.text.trim();
    final facts = _factsController.text.trim().isEmpty
        ? '請在此補充事件發生時間、地點、雙方約定與目前爭議。'
        : _factsController.text.trim();

    final title = _selectedTemplate.label;
    final opening = isPremiumTone
        ? '敬啟者：\n$name 就下列事項，為避免雙方爭議擴大，謹以本通知請 $target 於合理期間內回覆。'
        : '$target 您好：\n我是 $name，想先把目前爭議整理清楚，請您協助回覆。';
    final legalTone = isPremiumTone
        ? '本文件僅為事實整理與溝通草稿，正式寄發前仍建議由律師依完整證據審閱。'
        : '這份草稿是協商用文字，不等於律師正式法律意見。';

    return [
      '【$title】',
      '',
      opening,
      '',
      '一、事實摘要',
      facts,
      '',
      '二、希望對方回覆的事項',
      _requestParagraph,
      '',
      '三、可先準備的附件',
      _attachmentParagraph,
      '',
      '四、提醒',
      legalTone,
    ].join('\n');
  }

  String get _requestParagraph {
    switch (_selectedTemplate) {
      case _DocumentTemplate.depositDemand:
        return '請提供扣款項目、金額、照片或收據等明細；若無具體依據，請安排返還押金。';
      case _DocumentTemplate.laborOvertime:
        return '請協助確認實際工時、加班申請紀錄、補休或加班費計算方式，並提供公司目前認定依據。';
      case _DocumentTemplate.carAccidentMemo:
        return '請確認事故時間、地點、車號、聯絡方式、保險資料，以及後續是否要申請調解。';
    }
  }

  String get _attachmentParagraph {
    switch (_selectedTemplate) {
      case _DocumentTemplate.depositDemand:
        return '租約、匯款紀錄、點交照片、對話紀錄、修繕報價或收據。';
      case _DocumentTemplate.laborOvertime:
        return '班表、打卡紀錄、薪資單、通訊軟體指派工作紀錄、補休紀錄。';
      case _DocumentTemplate.carAccidentMemo:
        return '現場照片、行車紀錄器、初判表、報案三聯單、醫療單據、保險聯絡紀錄。';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = LawAppScope.of(context);
    final topPadding = MediaQuery.paddingOf(context).top;
    final palette = _ToolPalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 32.h),
        children: [
          _ToolTopBar(onBack: () => Navigator.of(context).pop()),
          SizedBox(height: 18.h),
          Text(
            '法律工具箱',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              color: palette.primaryText,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '把問題從「不知道怎麼說」變成可以整理、保存、追蹤與諮詢的材料。',
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.45,
              color: palette.mutedText,
            ),
          ),
          SizedBox(height: 16.h),
          _AccessSummaryCard(appState: appState, palette: palette),
          SizedBox(height: 18.h),
          _TemplateSelector(
            selectedTemplate: _selectedTemplate,
            onSelected: _selectTemplate,
            palette: palette,
          ),
          SizedBox(height: 14.h),
          _DocumentInputCard(
            nameController: _nameController,
            targetController: _targetController,
            factsController: _factsController,
            onGenerate: _generateDraft,
            palette: palette,
          ),
          SizedBox(height: 14.h),
          _DraftPreviewCard(
            draft: _draft,
            onCopy: _copyDraft,
            isCopyLocked: !appState.canUsePremiumDocuments,
            palette: palette,
          ),
          SizedBox(height: 18.h),
          _ChecklistCard(palette: palette),
          SizedBox(height: 18.h),
          _DataSourceCard(palette: palette),
        ],
      ),
    );
  }
}

class _ToolPalette {
  const _ToolPalette({
    required this.background,
    required this.surface,
    required this.subtleSurface,
    required this.border,
    required this.primaryText,
    required this.mutedText,
    required this.accent,
  });

  final Color background;
  final Color surface;
  final Color subtleSurface;
  final Color border;
  final Color primaryText;
  final Color mutedText;
  final Color accent;

  static _ToolPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const _ToolPalette(
        background: Color(0xFF0F1216),
        surface: Color(0xFF171C22),
        subtleSurface: Color(0xFF202731),
        border: Color(0xFF2B3441),
        primaryText: Color(0xFFF2F4F7),
        mutedText: Color(0xFFA3ABB6),
        accent: Color(0xFFE5CD93),
      );
    }

    return const _ToolPalette(
      background: AppColors.background,
      surface: Colors.white,
      subtleSurface: Color(0xFFF6E8D7),
      border: AppColors.border,
      primaryText: AppColors.textPrimary,
      mutedText: AppColors.textSecondary,
      accent: AppColors.accent,
    );
  }
}

class _ToolTopBar extends StatelessWidget {
  const _ToolTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToolIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
        SizedBox(width: 10.w),
        Text(
          '文件與行動',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: _ToolPalette.of(context).primaryText,
          ),
        ),
      ],
    );
  }
}

class _AccessSummaryCard extends StatelessWidget {
  const _AccessSummaryCard({
    required this.appState,
    required this.palette,
  });

  final LawAppState appState;
  final _ToolPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.subtleSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined,
              color: palette.accent, size: 24.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '目前權限：${appState.accessTier.label}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.primaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  appState.accessTier.helperText,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.4,
                    color: palette.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateSelector extends StatelessWidget {
  const _TemplateSelector({
    required this.selectedTemplate,
    required this.onSelected,
    required this.palette,
  });

  final _DocumentTemplate selectedTemplate;
  final ValueChanged<_DocumentTemplate> onSelected;
  final _ToolPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ToolSectionTitle(title: '文件模板', palette: palette),
        SizedBox(height: 10.h),
        ..._DocumentTemplate.values.map(
          (template) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: InkWell(
              onTap: () => onSelected(template),
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: selectedTemplate == template
                      ? palette.subtleSurface
                      : palette.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: selectedTemplate == template
                        ? palette.accent
                        : palette.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedTemplate == template
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: selectedTemplate == template
                          ? palette.accent
                          : palette.mutedText,
                      size: 20.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.label,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w900,
                              color: palette.primaryText,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            template.hint,
                            style: TextStyle(
                              fontSize: 11.sp,
                              height: 1.35,
                              color: palette.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentInputCard extends StatelessWidget {
  const _DocumentInputCard({
    required this.nameController,
    required this.targetController,
    required this.factsController,
    required this.onGenerate,
    required this.palette,
  });

  final TextEditingController nameController;
  final TextEditingController targetController;
  final TextEditingController factsController;
  final VoidCallback onGenerate;
  final _ToolPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToolSectionTitle(title: '基本資料', palette: palette),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _ToolTextField(
                  controller: nameController,
                  label: '你的稱呼',
                  palette: palette,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ToolTextField(
                  controller: targetController,
                  label: '對方稱呼',
                  palette: palette,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _ToolTextField(
            controller: factsController,
            label: '事實摘要',
            minLines: 4,
            maxLines: 6,
            palette: palette,
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_fix_high_rounded),
              label: const Text('產生文件草稿'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftPreviewCard extends StatelessWidget {
  const _DraftPreviewCard({
    required this.draft,
    required this.onCopy,
    required this.isCopyLocked,
    required this.palette,
  });

  final String draft;
  final VoidCallback onCopy;
  final bool isCopyLocked;
  final _ToolPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _ToolSectionTitle(title: '草稿預覽', palette: palette)),
              TextButton.icon(
                onPressed: onCopy,
                icon: Icon(
                  isCopyLocked
                      ? Icons.lock_outline_rounded
                      : Icons.copy_rounded,
                  size: 17.sp,
                ),
                label: Text(isCopyLocked ? 'Pro 匯出' : '複製'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: palette.subtleSurface.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              draft,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.6,
                color: palette.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.palette});

  final _ToolPalette palette;

  static const _items = [
    '先保存合約、對話、照片、收據與匯款紀錄。',
    '把時間線整理成「日期、事件、證據」三欄。',
    '正式寄發文件前，避免加入辱罵、猜測或無法證明的指控。',
    '涉及重大權益或訴訟期限時，請儘快諮詢律師或法律扶助。',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToolSectionTitle(title: '行動檢查表', palette: palette),
          SizedBox(height: 10.h),
          ..._items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18.sp,
                    color: palette.accent,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.45,
                        color: palette.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataSourceCard extends StatelessWidget {
  const _DataSourceCard({required this.palette});

  final _ToolPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToolSectionTitle(title: '資料串接狀態', palette: palette),
          SizedBox(height: 10.h),
          ...legalSourceEntries.take(3).map(
                (source) => Padding(
                  padding: EdgeInsets.only(bottom: 9.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(source.icon, size: 19.sp, color: palette.accent),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${source.title} · ${source.statusLabel}',
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w900,
                                color: palette.primaryText,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              source.endpointLabel,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: palette.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _ToolTextField extends StatelessWidget {
  const _ToolTextField({
    required this.controller,
    required this.label,
    required this.palette,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final _ToolPalette palette;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: TextStyle(color: palette.primaryText, fontSize: 13.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: palette.mutedText, fontSize: 12.sp),
        filled: true,
        fillColor: palette.subtleSurface.withValues(alpha: 0.38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: palette.border),
        ),
      ),
    );
  }
}

class _ToolSectionTitle extends StatelessWidget {
  const _ToolSectionTitle({
    required this.title,
    required this.palette,
  });

  final String title;
  final _ToolPalette palette;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w900,
        color: palette.primaryText,
      ),
    );
  }
}

class _ToolIconButton extends StatelessWidget {
  const _ToolIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _ToolPalette.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: palette.border),
        ),
        child: Icon(icon, color: palette.primaryText, size: 22.sp),
      ),
    );
  }
}
