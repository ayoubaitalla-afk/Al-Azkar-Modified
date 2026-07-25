enum DayPeriod { morning, afternoon, evening, night, all }

DayPeriod getCurrentDayPeriod() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return DayPeriod.morning;
  if (hour >= 12 && hour < 17) return DayPeriod.afternoon;
  if (hour >= 17 && hour < 21) return DayPeriod.evening;
  return DayPeriod.night;
}

String dayPeriodToString(DayPeriod p) => p.toString().split('.').last;
