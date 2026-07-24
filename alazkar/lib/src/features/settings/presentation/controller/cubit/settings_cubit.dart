import 'package:alazkar/src/core/di/dependency_injection.dart';
import 'package:alazkar/src/core/helpers/notification_helper.dart';
import 'package:alazkar/src/features/settings/data/repository/settings_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' as material;

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsStorage settingsStorage;
  SettingsCubit(this.settingsStorage)
      : super(
          SettingsState(
            showTextInBrackets: settingsStorage.showTextInBrackets(),
            praiseWithVolumeKeys: settingsStorage.praiseWithVolumeKeys,
            dailyNotificationsEnabled: settingsStorage.dailyNotificationsEnabled,
            dailyNotificationsHour: settingsStorage.dailyNotificationsHour,
            dailyNotificationsMinute: settingsStorage.dailyNotificationsMinute,
          ),
        );

  Future toggleShowTextInBrackets() async {
    final bool showTextInBrackets = !state.showTextInBrackets;
    await settingsStorage.setShowTextInBrackets(showTextInBrackets);
    emit(state.copyWith(showTextInBrackets: showTextInBrackets));
  }

  ///MARK: praiseWithVolumeKeys
  Future togglePraiseWithVolumeKeys({required bool use}) async {
    await settingsStorage.changePraiseWithVolumeKeysStatus(value: use);
    emit(state.copyWith(praiseWithVolumeKeys: use));
  }

  ///MARK: dailyNotifications
  Future toggleDailyNotifications(bool value) async {
    await settingsStorage.setDailyNotificationsEnabled(value);
    emit(state.copyWith(dailyNotificationsEnabled: value));
    await _updateNotificationSchedule();
  }

  Future setDailyNotificationsTime(int hour, int minute) async {
    await settingsStorage.setDailyNotificationsTime(hour, minute);
    emit(state.copyWith(
      dailyNotificationsHour: hour,
      dailyNotificationsMinute: minute,
    ));
    await _updateNotificationSchedule();
  }

  Future<void> _updateNotificationSchedule() async {
    final notificationHelper = sl<NotificationHelper>();
    await notificationHelper.rescheduleDailyFavoriteAzkar();
  }
}
