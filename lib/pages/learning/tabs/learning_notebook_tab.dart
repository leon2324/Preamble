part of '../know_law_page.dart';

/// 手帳筆記 Tab 外層容器。
///
/// 台灣繁體中文教學註解：
/// 這個 widget 只包住原本在 KnowLawPageState 組出的 Tab 子項目，
/// 真正資料來源、互動狀態與視覺 helper 仍留在原本 state，避免 Step 4A 改到功能邏輯。
class LearningNotebookTab extends StatelessWidget {
  const LearningNotebookTab({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

extension LearningNotebookTabBuilder on KnowLawPageState {
  // ==========================================
  // 📝 手帳筆記分頁建構與互動邏輯
  // ==========================================

  Widget buildLearningNotebookTab(bool isDark, LearningGameState gameState) {
    return LearningNotebookTab(children: [
      // 1. 筆記本美學與字體設定
      _buildAestheticsConfigCard(isDark, gameState),
      SizedBox(height: 12.h),

      // 2. 我的手帳貼紙簿
      _buildStickersAlbumCard(isDark, gameState),
      SizedBox(height: 12.h),

      // 3. 我的法律摘錄本
      _buildHighlightsSection(isDark, gameState),
      SizedBox(height: 12.h),

      // 3.5 隨手記與法條標籤對照 (新加入功能)
      _buildQuickNotesAndStatutesSection(isDark, gameState),
      SizedBox(height: 12.h),

      // 4. 三段論邏輯思維筆記
      _buildCornellSection(isDark, gameState),
    ]);
  }

  Widget _buildQuickNotesAndStatutesSection(bool isDark, LearningGameState gameState) {
    // 定義法條標籤及其對照條文
    final Map<String, String> statuteMapping = {
      '租賃契約': '民法第 421 條：\n稱租賃者，謂當事人約定，一方以物租與他方使用收益，他方支付租金之契約。',
      '侵權行為': '民法第 184 條：\n因故意或過失，不法侵害他人之權利者，負損害賠償責任。故意以背於善良風俗之方法加損害於他人者亦同。',
      '消費者保護': '消保法第 19 條：\n通訊交易或訪問交易之消費者，得於收受商品或接受服務後七日內，退回商品或以書面通知方式解除契約，無須說明理由及負擔任何費用或對價。',
      '勞基法': '勞基法第 24 條：\n雇主延長勞工工作時間者，其延長工作時間之工資，應依規定標準加給（加班費計算基準）。',
    };

    return NotebookCard(
      hasBookmark: true,
      bookmarkColor: const Color(0xFF8CAF96),
      backgroundColor: isDark ? const Color(0xFF1B241E) : const Color(0xFFF2F8F4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 20.sp,
                color: const Color(0xFF4E7D5B),
              ),
              SizedBox(width: 8.w),
              Text(
                '法治隨手記',
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 隨手記輸入框與按鈕
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quickNoteController,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '寫下您的日常法律筆記...',
                    hintStyle: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF232B25) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF2D3B30) : const Color(0xFFD4E8DA),
                        width: 1.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF4E7D5B),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: () {
                  final text = _quickNoteController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _quickNotes.insert(0, text);
                      _quickNoteController.clear();
                    });
                    HapticFeedback.lightImpact();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E7D5B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                ),
                child: Text(
                  '儲存',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 已儲存筆記清單
          if (_quickNotes.isNotEmpty) ...[
            Container(
              constraints: BoxConstraints(maxHeight: 120.h),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: _quickNotes.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 6.h),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131A15) : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: isDark ? const Color(0xFF232D26) : const Color(0xFFE2EFE5),
                        width: 0.8.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.push_pin_rounded,
                          size: 12,
                          color: Color(0xFF8CAF96),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            _quickNotes[index],
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _quickNotes.removeAt(index);
                            });
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
          ],

          Divider(
            color: isDark ? const Color(0xFF232D26) : const Color(0xFFD4E8DA),
            height: 1,
          ),
          SizedBox(height: 12.h),

          // 標題 2
          Row(
            children: [
              Icon(
                Icons.bookmark_added_rounded,
                size: 20.sp,
                color: const Color(0xFF4E7D5B),
              ),
              SizedBox(width: 8.w),
              Text(
                '常用法條標籤對照',
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // 標籤排
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: statuteMapping.keys.map((tag) {
              final isSelected = _selectedStatuteTag == tag;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatuteTag = tag;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4E7D5B)
                        : (isDark ? const Color(0xFF232B25) : const Color(0xFFE2EFE5)),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4E7D5B)
                          : (isDark ? const Color(0xFF2D3B30) : const Color(0xFFC7DEC9)),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFF8CAF96) : const Color(0xFF386343)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),

          // 對照顯示卡片
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131A15) : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isDark ? const Color(0xFF232D26) : const Color(0xFFE2EFE5),
              ),
            ),
            child: Text(
              statuteMapping[_selectedStatuteTag] ?? '點選上方標籤顯示條文對照。',
              style: TextStyle(
                fontSize: 11.5.sp,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
