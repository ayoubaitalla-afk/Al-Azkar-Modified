// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool showTextInBrackets;
  final bool praiseWithVolumeKeys;
  final bool dailyNotificationsEnabled;
  final int dailyNotificationsHour;
  final int dailyNotificationsMinute;
  final bool weeklyNotificationsEnabled;
  final bool monthlyNotificationsEnabled;
  final bool yearlyNotificationsEnabled;

  const SettingsState({
    required this.showTextInBrackets,
    required this.praiseWithVolumeKeys,
    required this.dailyNotificationsEnabled,
    required this.dailyNotificationsHour,
    required this.dailyNotificationsMinute,
    required this.weeklyNotificationsEnabled,
    required this.monthlyNotificationsEnabled,
    required this.yearlyNotificationsEnabled,
  });

  @override
  List<Object> get props => [
        showTextInBrackets,
        praiseWithVolumeKeys,
        dailyNotificationsEnabled,
        dailyNotificationsHour,
        dailyNotificationsMinute,
        weeklyNotificationsEnabled,
        monthlyNotificationsEnabled,
        yearlyNotificationsEnabled,
      ];

  SettingsState copyWith({
    bool? showTextInBrackets,
    bool? praiseWithVolumeKeys,
    bool? dailyNotificationsEnabled,
    int? dailyNotificationsHour,
    int? dailyNotificationsMinute,
    bool? weeklyNotificationsEnabled,
    bool? monthlyNotificationsEnabled,
    bool? yearlyNotificationsEnabled,
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
      weeklyNotificationsEnabled:
          weeklyNotificationsEnabled ?? this.weeklyNotificationsEnabled,
      monthlyNotificationsEnabled:
          monthlyNotificationsEnabled ?? this.monthlyNotificationsEnabled,
      yearlyNotificationsEnabled:
          yearlyNotificationsEnabled ?? this.yearlyNotificationsEnabled,
    );
  }
}
