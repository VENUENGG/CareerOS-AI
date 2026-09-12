import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../core/widgets/avatar.dart';

class AvatarStorage {
  static const String _avatarKey = 'selected_avatar_style';
  static const String _avatarPickerShownKey = 'avatar_picker_shown';

  static Future<AvatarStyle> getSelectedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_avatarKey) ?? 0;
    return AvatarStyle.values[index.clamp(0, AvatarStyle.values.length - 1)];
  }

  static Future<void> setSelectedAvatar(AvatarStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_avatarKey, style.index);
  }

  static Future<String?> getInitials(UserProfile profile) async {
    final firstName = profile.firstName?.isNotEmpty == true ? profile.firstName![0] : '';
    final lastName = profile.lastName?.isNotEmpty == true ? profile.lastName![0] : '';
    final initials = '$firstName$lastName'.toUpperCase();
    return initials.isNotEmpty ? initials : null;
  }

  static Future<bool> hasAvatarPickerBeenShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_avatarPickerShownKey) ?? false;
  }

  static Future<void> setAvatarPickerShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_avatarPickerShownKey, true);
  }
}