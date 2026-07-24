import 'package:alazkar/src/core/di/dependency_injection.dart';
import 'package:alazkar/src/core/helpers/bookmarks_helper.dart';
import 'package:alazkar/src/features/home/presentation/components/favorite_times_dialog.dart';
import 'package:alazkar/src/features/home/presentation/controller/home/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteTimeButton extends StatelessWidget {
  final int titleId;
  const FavoriteTimeButton({super.key, required this.titleId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) {
        if (current is! HomeLoadedState || previous is! HomeLoadedState) return true;
        return previous.favouriteTitlesIds.contains(titleId) != current.favouriteTitlesIds.contains(titleId);
      },
      builder: (context, state) {
        if (state is! HomeLoadedState) return const SizedBox();
        
        final isBookmarked = state.favouriteTitlesIds.contains(titleId);
        if (!isBookmarked) return const SizedBox();

        return IconButton(
          icon: const Icon(Icons.access_time_filled, size: 20),
          tooltip: "تحديد أوقات التنبيهات",
          onPressed: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null && context.mounted) {
              final timeStr = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
              final currentTimes = await sl<BookmarksDBHelper>().getNotificationTimes(titleId);
              if (!currentTimes.contains(timeStr)) {
                final newTimes = [...currentTimes, timeStr]..sort();
                if (context.mounted) {
                  context.read<HomeBloc>().add(
                    HomeUpdateFavoriteTimesEvent(
                      titleId: titleId,
                      times: newTimes,
                    ),
                  );
                }
              }
            }
          },
        );
      },
    );
  }
}
