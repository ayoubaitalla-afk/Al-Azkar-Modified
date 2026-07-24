import 'package:alazkar/src/core/storage/kv_storage.dart';

class SettingsStorage {
  final KVStorage _box;
  SettingsStorage(this._box);

  static const String _settingsPrefixNameKey = "SettingsStorage";

  ///MARK: showTextInBrackets
  static const String _showTextInBrackets =
      "${_settingsPrefixNameKey}showTextInBrackets";

  bool showTextInBrackets() {
    final bool? data = _box.read(_showTextInBrackets);

    return data ?? true;
  }

  Future setShowTextInBrackets(bool showTextInBrackets) {
    return _box.write(_showTextInBrackets, showTextInBrackets);
  }

  ///MARK: praiseWithVolumeKeys
  static const praiseWithVolumeKeysKey = 'praiseWithVolumeKeys';
  bool get praiseWithVolumeKeys => _box.read(praiseWithVolumeKeysKey) ?? true;
  Future<void> changePraiseWithVolumeKeysStatus({required bool value}) =>
      _box.write(praiseWithVolumeKeysKey, value);

  ///MARK: dailyNotifications
  static const String _dailyNotificationsEnabledKey = "dailyNotificationsEnabled";
  static const String _dailyNotificationsHourKey = "dailyNotificationsHour";
  static const String _dailyNotificationsMinuteKey = "dailyNotificationsMinute";

  bool get dailyNotificationsEnabled => _box.read(_dailyNotificationsEnabledKey) ?? false;
  int get dailyNotificationsHour => _box.read(_dailyNotificationsHourKey) ?? 8;
  int get dailyNotificationsMinute => _box.read(_dailyNotificationsMinuteKey) ?? 0;

  Future setDailyNotificationsEnabled(bool value) => _box.write(_dailyNotificationsEnabledKey, value);
  Future setDailyNotificationsTime(int hour, int minute) async {
    await _box.write(_dailyNotificationsHourKey, hour);
    await _box.write(_dailyNotificationsMinuteKey, minute);
  }

  ///MARK: historicalNotifications
  static const String _weeklyNotificationsEnabledKey = "weeklyNotificationsEnabled";
  static const String _monthlyNotificationsEnabledKey = "monthlyNotificationsEnabled";
  static const String _yearlyNotificationsEnabledKey = "yearlyNotificationsEnabled";

  bool get weeklyNotificationsEnabled => _box.read(_weeklyNotificationsEnabledKey) ?? false;
  bool get monthlyNotificationsEnabled => _box.read(_monthlyNotificationsEnabledKey) ?? false;
  bool get yearlyNotificationsEnabled => _box.read(_yearlyNotificationsEnabledKey) ?? false;

  Future setWeeklyNotificationsEnabled(bool value) => _box.write(_weeklyNotificationsEnabledKey, value);
  Future setMonthlyNotificationsEnabled(bool value) => _box.write(_monthlyNotificationsEnabledKey, value);
  Future setYearlyNotificationsEnabled(bool value) => _box.write(_yearlyNotificationsEnabledKey, value);
}
