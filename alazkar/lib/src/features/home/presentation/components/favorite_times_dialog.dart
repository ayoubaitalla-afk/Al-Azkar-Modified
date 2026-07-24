import 'package:alazkar/src/features/home/presentation/controller/home/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteTimesDialog extends StatefulWidget {
  final int titleId;
  final List<String> initialTimes;

  const FavoriteTimesDialog({
    super.key,
    required this.titleId,
    required this.initialTimes,
  });

  @override
  State<FavoriteTimesDialog> createState() => _FavoriteTimesDialogState();
}

class _FavoriteTimesDialogState extends State<FavoriteTimesDialog> {
  late List<String> times;

  @override
  void initState() {
    super.initState();
    times = List.from(widget.initialTimes);
  }

  Future<void> _addTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final timeStr = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      if (!times.contains(timeStr)) {
        setState(() {
          times.add(timeStr);
          times.sort();
        });
      }
    }
  }

  void _removeTime(int index) {
    setState(() {
      times.removeAt(index);
    });
  }

  void _saveChanges() {
    context.read<HomeBloc>().add(
      HomeUpdateFavoriteTimesEvent(
        titleId: widget.titleId,
        times: times,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("تحديد أوقات التنبيهات"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (times.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("لم تحدد أي أوقات بعد"),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: times.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(times[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeTime(index),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addTime,
              icon: const Icon(Icons.add),
              label: const Text("إضافة وقت"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إلغاء"),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text("حفظ"),
        ),
      ],
    );
  }
}
