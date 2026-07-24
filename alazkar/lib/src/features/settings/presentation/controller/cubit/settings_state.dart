// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool showTextInBrackets;
  final bool praiseWithVolumeKeys;
  final bool dailyNotificationsEnabled;
  final int dailyNotificationsHour;
  final int dailyNotificationsMinute;
  const SettingsState({
    required this.showTextInBrackets,
    required this.praiseWithVolumeKeys,
    required this.dailyNotificationsEnabled,
    required this.dailyNotificationsHour,
    required this.dailyNotificationsMinute,
  });

  @override
  List<Object> get props => [
        showTextInBrackets,
        praiseWithVolumeKeys,
        dailyNotificationsEnabled,
        dailyNotificationsHour,
        dailyNotificationsMinute,
      ];

  SettingsState copyWith({
    bool? showTextInBrackets,
    bool? praiseWithVolumeKeys,
    bool? dailyNotificationsEnabled,
    int? dailyNotificationsHour,
    int? dailyNotificationsMinute,
  }) {
    return SettingsState(
      showTextInBrackets: showTextInBrackets ?? this.showTextInBrackets,
      praiseWithVolumeKeys: praiseWithVolumeKeys ?? this.praiseWithVolumeKeys,
      dailyNotificationsEnabled:
          dailyNotificationsEnabled ?? this.dailyNotificationsEnabled,
      dailyNotificationsHour:
          dailyNotificationsHour ?? this.dailyNotificationsHour,
      dailyNotificationsMinute:
          dailyNotificationsMinute ?? this.dailyNotificationsMinute,
    );
  }
}
