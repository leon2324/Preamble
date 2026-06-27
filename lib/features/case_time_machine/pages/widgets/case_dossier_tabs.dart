
part of '../case_dossier_detail_page.dart';

// 這個 part 檔集中收納案件詳情頁的展示型 Tab UI。
// repository 載入、route/navigation、controller 與資料 mapping 仍保留在主檔。

extension _CaseDossierTabs on _CaseDossierDetailPageState {
  Widget _buildBackgroundTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (book.background.isNotEmpty) ...[
          Text(
            '事件背景與始末',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          _buildRichTextWithGlossary(
            context,
            book.background,
            LightTextStyles.body(context).copyWith(
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),
        ],
        if (book.fullStory.isNotEmpty) ...[
          Text(
            '事件詳細經過',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          _buildRichTextWithGlossary(
            context,
            book.fullStory,
            LightTextStyles.body(context).copyWith(
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),
        ],
        // Sources & Disclaimer
        Text(
          '資料來源與更新時間',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8.h),
        _buildContentCard(
          accentColor: CaseTimeMachineColors.textMuted,
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final source in book.sources) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      CtmSvgIcon(
                        CtmSvgIcons.link,
                        size: 16.sp,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          source.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: CaseTimeMachineColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        source.updatedAt,
                        style: LightTextStyles.caption(context)
                            .copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
                const Divider(color: CaseTimeMachineColors.borderLight),
              ],
              SizedBox(height: 10.h),
              Text(
                '免責聲明：\n本卷宗內容均基於客觀司法裁判與官方公開資訊進行整理，旨在提供公正中立之歷史與法律學習參考，不構成任何正式法律意見。實際個案請諮詢專業律師。',
                style: LightTextStyles.caption(context)
                    .copyWith(height: 1.5, fontSize: 9.5.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialImpactTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '輿論反應與社會影響',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 12.h),
        _buildContentCard(
          accentColor: const Color(0xFF8E24AA),
          child: Text(
            book.socialImpact,
            style: LightTextStyles.body(context).copyWith(
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiteratureTab(BuildContext context) {
    return _buildLiteratureSection(context);
  }

  Widget _buildMediaTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '延伸影音資訊',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10.h),
        for (final ref in book.mediaReferences) ...[
          Container(
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(
              color: CaseTimeMachineColors.bgWhite,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: CaseTimeMachineColors.borderLight),
            ),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              leading: CircleAvatar(
                backgroundColor: (ref.mediaType == 'podcast'
                        ? const Color(0xFF8E24AA)
                        : ref.mediaType == 'youtube'
                            ? const Color(0xFFD32F2F)
                            : ref.mediaType == 'news'
                                ? const Color(0xFF1976D2)
                                : const Color(0xFF388E3C))
                    .withValues(alpha: 0.1),
                child: CtmSvgIcon(
                  ref.mediaType == 'podcast'
                      ? CtmSvgIcons.podcast
                      : ref.mediaType == 'youtube'
                          ? CtmSvgIcons.playCircle
                          : ref.mediaType == 'news'
                              ? CtmSvgIcons.newspaper
                              : CtmSvgIcons.school,
                  color: ref.mediaType == 'podcast'
                      ? const Color(0xFF8E24AA)
                      : ref.mediaType == 'youtube'
                          ? const Color(0xFFD32F2F)
                          : ref.mediaType == 'news'
                              ? const Color(0xFF1976D2)
                              : const Color(0xFF388E3C),
                  size: 20.sp,
                ),
              ),
              title: Text(
                ref.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.bold,
                  color: CaseTimeMachineColors.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: CaseTimeMachineColors.bgCream,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        ref.platform,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: CaseTimeMachineColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: CtmSvgIcon(
                CtmSvgIcons.externalLink,
                size: 16.sp,
                color: CaseTimeMachineColors.accentGold,
              ),
              onTap: () {
                CustomToast.show(context, '前往媒體：${ref.title}');

              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDisputesTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '主要法律爭點',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 12.h),
        for (final issue in book.legalIssues) ...[
          _buildContentCard(
            accentColor: const Color(0xFF1F4E5B),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.title,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w900,
                    color: CaseTimeMachineColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '法律說明：',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildRichTextWithGlossary(
                  context,
                  issue.plainExplanation,
                  LightTextStyles.body(context).copyWith(fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  '與本案關聯：',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildRichTextWithGlossary(
                  context,
                  issue.relationToCase,
                  LightTextStyles.bodySmall(context).copyWith(
                    fontSize: 11.5.sp,
                    color: CaseTimeMachineColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildLawsTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '相關法條資訊',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 12.h),
        for (final law in book.relatedLaws) ...[
          GestureDetector(
            onTap: () => _showLawBottomSheet(context, law),
            child: _buildContentCard(
              accentColor: CaseTimeMachineColors.accentGold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${law.lawName} ${law.articleNumber}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: CaseTimeMachineColors.accentGold,
                          ),
                        ),
                      ),
                      CtmSvgIcon(
                        CtmSvgIcons.chevronRight,
                        size: 16.sp,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    law.plainSummary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        LightTextStyles.body(context).copyWith(fontSize: 12.sp),
                  ),
                  if (law.relationToCase.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      '法規關聯：${law.relationToCase}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LightTextStyles.bodySmall(context).copyWith(
                        fontSize: 11.sp,
                        color: CaseTimeMachineColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildExtensionsTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 延伸影音資訊
        if (book.mediaReferences.isNotEmpty) ...[
          Text(
            '延伸影音資訊',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: book.mediaReferences.length,
            itemBuilder: (context, index) {
              final ref = book.mediaReferences[index];
              String iconSvg = CtmSvgIcons.link;
              Color iconColor = CaseTimeMachineColors.accentGold;

              switch (ref.mediaType) {
                case 'podcast':
                  iconSvg = CtmSvgIcons.podcast;
                  iconColor = const Color(0xFF8E24AA);
                  break;
                case 'youtube':
                  iconSvg = CtmSvgIcons.playCircle;
                  iconColor = const Color(0xFFD32F2F);
                  break;
                case 'news':
                  iconSvg = CtmSvgIcons.newspaper;
                  iconColor = const Color(0xFF1976D2);
                  break;
                case 'academic':
                  iconSvg = CtmSvgIcons.school;
                  iconColor = const Color(0xFF388E3C);
                  break;
              }

              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: CaseTimeMachineColors.bgWhite,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: CaseTimeMachineColors.borderLight),
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withValues(alpha: 0.1),
                    child: CtmSvgIcon(iconSvg, size: 20.sp, color: iconColor),
                  ),
                  title: Text(
                    ref.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.bold,
                      color: CaseTimeMachineColors.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: CaseTimeMachineColors.bgCream,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            ref.platform,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: CaseTimeMachineColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: CtmSvgIcon(
                    CtmSvgIcons.externalLink,
                    size: 16.sp,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                  onTap: () {
                    CustomToast.show(context, '前往媒體：${ref.title}');

                  },
                ),
              );
            },
          ),
          SizedBox(height: 18.h),
        ],

        // 相關案件
        if (book.relatedCases.isNotEmpty) ...[
          Text(
            '相關案件推薦',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          for (final rel in book.relatedCases) ...[
            GestureDetector(
              onTap: () => _openRelatedCase(context, rel.caseId),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: CaseTimeMachineColors.bgWhite,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: CaseTimeMachineColors.borderLight),
                ),
                child: Row(
                  children: [
                    Text(
                      rel.yearLabel,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w900,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rel.title,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: CaseTimeMachineColors.textPrimary,
                            ),
                          ),
                          if (rel.reason.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              rel.reason,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: CaseTimeMachineColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    CtmSvgIcon(
                      CtmSvgIcons.chevronRight,
                      size: 12.sp,
                      color: CaseTimeMachineColors.primaryGreen
                          .withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],

        _buildLiteratureSection(context),

        // Sources section
        SizedBox(height: 20.h),
        Text(
          '資料來源與更新時間',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8.h),
        _buildContentCard(
          accentColor: CaseTimeMachineColors.textMuted,
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final source in book.sources) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      CtmSvgIcon(
                        CtmSvgIcons.link,
                        size: 16.sp,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          source.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: CaseTimeMachineColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        source.updatedAt,
                        style: LightTextStyles.caption(context)
                            .copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
                const Divider(color: CaseTimeMachineColors.borderLight),
              ],
              SizedBox(height: 10.h),
              Text(
                '免責聲明：\n本卷宗內容均基於客觀司法裁判與官方公開資訊進行整理，旨在提供公正中立之歷史與法律學習參考，不構成任何正式法律意見。實際個案請諮詢專業律師。',
                style: LightTextStyles.caption(context)
                    .copyWith(height: 1.5, fontSize: 9.5.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiteratureSection(BuildContext context) {
    final items = _getLiteratures(book.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text(
          '法學評析與學術文獻',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10.h),
        for (final item in items) ...[
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: CaseTimeMachineColors.bgWhite,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: CaseTimeMachineColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: item.sourceType == '學術期刊'
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    item.sourceType,
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.bold,
                      color: item.sourceType == '學術期刊'
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF1565C0),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                          color: CaseTimeMachineColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${item.author} · ${item.journal}',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color: CaseTimeMachineColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: CtmSvgIcon(
                    CtmSvgIcons.externalLink,
                    size: 16.sp,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                  onPressed: () {
                    CustomToast.show(context, '已複製文獻引用資訊：${item.title}');

                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPeopleTab(BuildContext context) {
    final book = _detailedBook ?? widget.book;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '關係人與角色分工',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10.h),
        for (final person in book.people) ...[
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: CaseTimeMachineColors.bgWhite,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: CaseTimeMachineColors.borderLight),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: CaseTimeMachineColors.primaryGreen
                        .withValues(alpha: 0.1),
                    child: Text(
                      person.role.isNotEmpty
                          ? person.role.substring(0, 1)
                          : '人',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseTimeMachineColors.primaryGreen,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.role,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: CaseTimeMachineColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          person.description,
                          style: LightTextStyles.bodySmall(context).copyWith(
                            fontSize: 12.sp,
                            height: 1.5,
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
      ],
    );
  }

  Widget _buildCourtReasoningTab(BuildContext context) {
    final book = _detailedBook ?? widget.book;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (book.investigationAndTrial.isNotEmpty) ...[
          Text(
            '審判程序簡述',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          _buildRichTextWithGlossary(
            context,
            book.investigationAndTrial,
            LightTextStyles.body(context).copyWith(
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),
        ],
        if (book.courtReasoning.isNotEmpty) ...[
          Text(
            '法院心證與裁判理由',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          _buildRichTextWithGlossary(
            context,
            book.courtReasoning,
            LightTextStyles.body(context).copyWith(
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),
        ],
        if (book.courtArguments.isNotEmpty) ...[
          Text(
            '兩造辯論與攻防重點',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          for (final arg in book.courtArguments) ...[
            Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: CaseTimeMachineColors.bgWhite,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: CaseTimeMachineColors.borderLight),
              ),
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: (arg.partyName.contains('被告') ||
                                    arg.partyName.contains('辯護'))
                                ? const Color(0xFFC62828).withValues(alpha: 0.1)
                                : CaseTimeMachineColors.primaryGreen
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            arg.partyName,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.bold,
                              color: (arg.partyName.contains('被告') ||
                                      arg.partyName.contains('辯護'))
                                  ? const Color(0xFFC62828)
                                  : CaseTimeMachineColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _buildRichTextWithGlossary(
                      context,
                      arg.mainPoint,
                      LightTextStyles.body(context).copyWith(
                        fontSize: 12.5.sp,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
