import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/theme/app_colors.dart';

/// 本元件為個人資料編輯底頁 (ProfileEditorSheet)。
/// 使用 StatefulWidget 暫存使用者在介面上的臨時選擇（如新暱稱、新頭像 ID），
/// 當使用者點擊「儲存」時，才一次性呼叫 `PreambleState.updateUserProfile` 進行狀態寫入與 SharedPreferences 持久化。
class PresetAvatar {
  const PresetAvatar({
    required this.id,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String id;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
}

final List<PresetAvatar> presetAvatars = [
  const PresetAvatar(
    id: 'scale',
    icon: Icons.scale_rounded,
    color: Color(0xFF243B63),
    backgroundColor: Color(0xFFEAF0F8),
  ),
  const PresetAvatar(
    id: 'gavel',
    icon: Icons.gavel_rounded,
    color: Color(0xFFD6A85F),
    backgroundColor: Color(0xFFFAF2E6),
  ),
  const PresetAvatar(
    id: 'briefcase',
    icon: Icons.business_center_rounded,
    color: Color(0xFFC96B3B),
    backgroundColor: Color(0xFFFBF0EA),
  ),
  const PresetAvatar(
    id: 'book',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF2E7D32),
    backgroundColor: Color(0xFFE8F5E9),
  ),
  const PresetAvatar(
    id: 'shield',
    icon: Icons.shield_rounded,
    color: Color(0xFF3F51B5),
    backgroundColor: Color(0xFFE8EAF6),
  ),
  const PresetAvatar(
    id: 'person',
    icon: Icons.person_rounded,
    color: Color(0xFF009688),
    backgroundColor: Color(0xFFE0F2F1),
  ),
];

PresetAvatar getAvatarById(String? id) {
  return presetAvatars.firstWhere(
    (avatar) => avatar.id == id,
    orElse: () => presetAvatars.first,
  );
}

class ProfileEditorSheet extends StatefulWidget {
  const ProfileEditorSheet({super.key, required this.appState});

  final PreambleState appState;

  @override
  State<ProfileEditorSheet> createState() => _ProfileEditorSheetState();
}

class _ProfileEditorSheetState extends State<ProfileEditorSheet> {
  late final TextEditingController _nameController;
  late String _selectedAvatarId;
  late String _selectedProfession;
  late String _selectedAiStyle;

  @override
  void initState() {
    super.initState();
    final user = widget.appState.currentUser;
    _nameController = TextEditingController(text: user.displayName);
    _selectedAvatarId = user.avatarUrl ?? 'scale';
    _selectedProfession = user.profession;
    _selectedAiStyle = user.aiStyle;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildStyleCard(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedAiStyle == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAiStyle = value;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF243B63) : const Color(0xFFEAF0F8))
                : (isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2)),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.accent
                  : (isDark ? const Color(0xFF2B3441) : AppColors.border),
              width: isSelected ? 1.5.w : 1.w,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.accent
                    : (isDark ? Colors.white70 : AppColors.textSecondary),
                size: 20.sp,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.accent
                      : (isDark ? Colors.white70 : AppColors.textPrimary),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderStyle =
        BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);
    final titleTextStyle = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w900,
      color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
    );

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(
          20.w, 12.h, 20.w, MediaQuery.viewInsetsOf(context).bottom + 24.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 頂部拖曳指示條 (Drag handle)
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2B3441) : AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text('編輯個人檔案', style: titleTextStyle, textAlign: TextAlign.center),
            SizedBox(height: 20.h),

            // 暱稱輸入欄位 (Nickname field)
            Text('我的暱稱',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFA3ABB6)
                        : AppColors.textSecondary)),
            SizedBox(height: 6.h),
            TextField(
              controller: _nameController,
              maxLength: 15,
              decoration: InputDecoration(
                counterText: '',
                hintText: '請輸入暱稱',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: borderStyle,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                ),
              ),
              style: TextStyle(
                  fontSize: 14.sp,
                  color:
                      isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary),
            ),
            SizedBox(height: 20.h),

            // 頭像選擇網格 (Avatar selection)
            Text('選擇頭像圖示',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFA3ABB6)
                        : AppColors.textSecondary)),
            SizedBox(height: 10.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
              ),
              itemCount: presetAvatars.length,
              itemBuilder: (context, index) {
                final avatar = presetAvatars[index];
                final isSelected = avatar.id == _selectedAvatarId;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatarId = avatar.id;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: avatar.backgroundColor,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.accent, width: 3.w)
                          : Border.all(color: Colors.transparent),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1)
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        avatar.icon,
                        color: avatar.color,
                        size: 20.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),

            // 身分設定下拉選單
            Text(
              '專業身分',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedProfession,
              dropdownColor: surfaceColor,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: borderStyle,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'citizen', child: Text('一般民眾')),
                DropdownMenuItem(value: 'lawyer', child: Text('執業律師')),
                DropdownMenuItem(value: 'legal_staff', child: Text('法務人員')),
                DropdownMenuItem(value: 'law_student', child: Text('法學生')),
              ],
              style: TextStyle(
                  fontSize: 14.sp,
                  color:
                      isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedProfession = val;
                  });
                }
              },
            ),
            SizedBox(height: 20.h),

            // AI 對答風格自訂卡片
            Text(
              '小法助對話風格',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildStyleCard(
                  context,
                  value: 'simple',
                  label: '白話文釋法',
                  icon: Icons.chat_bubble_outline_rounded,
                ),
                SizedBox(width: 8.w),
                _buildStyleCard(
                  context,
                  value: 'pro_analysis',
                  label: '專業訴訟分析',
                  icon: Icons.insights_rounded,
                ),
                SizedBox(width: 8.w),
                _buildStyleCard(
                  context,
                  value: 'strict_cite',
                  label: '精準法條對照',
                  icon: Icons.menu_book_rounded,
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // 底部操作按鈕（取消與儲存） (Action buttons)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: borderStyle,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text('取消',
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark
                                ? const Color(0xFFA3ABB6)
                                : AppColors.textSecondary)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      if (name.isNotEmpty) {
                        widget.appState.updateUserProfile(
                          displayName: name,
                          avatarUrl: _selectedAvatarId,
                          profession: _selectedProfession,
                          aiStyle: _selectedAiStyle,
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text('儲存',
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
