import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/theme/preamble_tokens.dart';

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
    icon: PhosphorIconsRegular.scales,
    color: Color(0xFF18362C),
    backgroundColor: Color(0xFFE5EFEA),
  ),
  const PresetAvatar(
    id: 'gavel',
    icon: PhosphorIconsRegular.gavel,
    color: Color(0xFFB5894A),
    backgroundColor: Color(0xFFF7EFE1),
  ),
  const PresetAvatar(
    id: 'briefcase',
    icon: PhosphorIconsRegular.briefcase,
    color: Color(0xFF35546C),
    backgroundColor: Color(0xFFE9EFF4),
  ),
  const PresetAvatar(
    id: 'book',
    icon: PhosphorIconsRegular.bookOpenText,
    color: Color(0xFF235D46),
    backgroundColor: Color(0xFFE4F1EB),
  ),
  const PresetAvatar(
    id: 'shield',
    icon: PhosphorIconsRegular.shieldCheck,
    color: Color(0xFF7A5621),
    backgroundColor: Color(0xFFF7EFE1),
  ),
  const PresetAvatar(
    id: 'person',
    icon: PhosphorIconsRegular.userCircle,
    color: Color(0xFF142E25),
    backgroundColor: Color(0xFFEBE6DC),
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
    final t = context.tokens;
    final isSelected = _selectedAiStyle == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedAiStyle = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
          decoration: BoxDecoration(
            color: isSelected ? t.brandContainer : t.surfaceSubtle,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? t.brandPrimary : t.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? t.brandPrimary : t.textSecondary,
                size: 20.sp,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: t.sansBody(
                  size: 11.5.sp,
                  weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? t.brandOnContainer : t.textPrimary,
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
    final t = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: t.border),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        MediaQuery.viewInsetsOf(context).bottom + 24.h,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: t.borderStrong,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '編輯個人檔案',
                style: t.serifTitle(size: 17.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),

              Text(
                '顯示暱稱',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 6.h),
              TextField(
                controller: _nameController,
                maxLength: 15,
                style: t.sansBody(size: 14.sp, color: t.textPrimary),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '請輸入暱稱',
                  hintStyle: t.sansBody(size: 13.sp, color: t.textMuted),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  filled: true,
                  fillColor: t.surfaceSubtle,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: t.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: t.brandPrimary, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              Text(
                '選擇頭像徽記',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 10.w,
                runSpacing: 10.h,
                children: presetAvatars.map((avatar) {
                  final isSelected = avatar.id == _selectedAvatarId;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedAvatarId = avatar.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        color: t.isDark
                            ? avatar.color.withValues(alpha: 0.22)
                            : avatar.backgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? t.accentBrass : t.border,
                          width: isSelected ? 2.4 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          avatar.icon,
                          color: t.isDark ? t.brandPrimary : avatar.color,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 18.h),

              Text(
                '讀者身分背景',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                initialValue: _selectedProfession,
                dropdownColor: t.surfaceElevated,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  filled: true,
                  fillColor: t.surfaceSubtle,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: t.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: t.brandPrimary, width: 1.5),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'citizen', child: Text('一般民眾')),
                  DropdownMenuItem(value: 'lawyer', child: Text('執業律師')),
                  DropdownMenuItem(value: 'legal_staff', child: Text('法務人員')),
                  DropdownMenuItem(value: 'law_student', child: Text('法學生')),
                ],
                style: t.sansBody(size: 14.sp, color: t.textPrimary),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedProfession = val);
                  }
                },
              ),
              SizedBox(height: 18.h),

              Text(
                '小法助問診語氣偏好',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _buildStyleCard(
                    context,
                    value: 'simple',
                    label: '白話文釋法',
                    icon: PhosphorIconsRegular.chatCircleText,
                  ),
                  SizedBox(width: 8.w),
                  _buildStyleCard(
                    context,
                    value: 'pro_analysis',
                    label: '實務爭點分析',
                    icon: PhosphorIconsRegular.scales,
                  ),
                  SizedBox(width: 8.w),
                  _buildStyleCard(
                    context,
                    value: 'strict_cite',
                    label: '精準法條對照',
                    icon: PhosphorIconsRegular.bookOpenText,
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: t.borderStrong),
                        foregroundColor: t.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: const Text('取消'),
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
                        backgroundColor: t.brandPrimaryStrong,
                        foregroundColor: const Color(0xFFFAF8F4),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: const Text('儲存'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
