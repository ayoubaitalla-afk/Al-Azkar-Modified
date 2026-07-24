import 'package:alazkar/src/core/di/dependency_injection.dart';
import 'package:alazkar/src/core/helpers/notification_helper.dart';
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
              onChanged: (value) async {
                if (value) {
                  await sl<NotificationHelper>().requestPermissions();
                }
                if (context.mounted) {
                  context.read<SettingsCubit>().toggleDailyNotifications(value);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
