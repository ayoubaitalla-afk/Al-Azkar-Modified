import 'package:alazkar/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoricalNotificationsSwitch extends StatelessWidget {
  const HistoricalNotificationsSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            SwitchListTile(
              title: const Text("تنبيهات أسبوعية"),
              subtitle: const Text("تذكيرات أسبوعية بالأذكار"),
              value: state.weeklyNotificationsEnabled,
              onChanged: (value) {
                context.read<SettingsCubit>().toggleWeeklyNotifications(value);
              },
            ),
            SwitchListTile(
              title: const Text("تنبيهات شهرية"),
              subtitle: const Text("تذكيرات شهرية بالأذكار"),
              value: state.monthlyNotificationsEnabled,
              onChanged: (value) {
                context.read<SettingsCubit>().toggleMonthlyNotifications(value);
              },
            ),
            SwitchListTile(
              title: const Text("تنبيهات سنوية"),
              subtitle: const Text("تذكيرات سنوية بالأذكار"),
              value: state.yearlyNotificationsEnabled,
              onChanged: (value) {
                context.read<SettingsCubit>().toggleYearlyNotifications(value);
              },
            ),
          ],
        );
      },
    );
  }
}
