import 'package:alazkar/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DailyNotificationsSwitch extends StatelessWidget {
  const DailyNotificationsSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active),
              title: const Text("الإشعارات اليومية"),
              subtitle: const Text("تذكير يومي بالأذكار المفضلة"),
              value: state.dailyNotificationsEnabled,
              onChanged: (value) {
                context.read<SettingsCubit>().toggleDailyNotifications(value);
              },
            ),
            if (state.dailyNotificationsEnabled)
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("وقت التنبيه"),
                trailing: Text(
                  "${state.dailyNotificationsHour.toString().padLeft(2, '0')}:${state.dailyNotificationsMinute.toString().padLeft(2, '0')}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: state.dailyNotificationsHour,
                      minute: state.dailyNotificationsMinute,
                    ),
                  );
                  if (picked != null) {
                    if (context.mounted) {
                      context
                          .read<SettingsCubit>()
                          .setDailyNotificationsTime(picked.hour, picked.minute);
                    }
                  }
                },
              ),
          ],
        );
      },
    );
  }
}
