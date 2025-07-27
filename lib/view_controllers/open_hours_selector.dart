import 'package:flutter/material.dart';

final class DayOperationsTime {
  final String time;
  List<String> days = [];

  DayOperationsTime({required this.time});
}

class OpenHoursSelectorViewController extends StatelessWidget {
  const OpenHoursSelectorViewController({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Open Hours Selector")),
      body: Center(child: SingleChildScrollView(child: OpeningHoursSelector())),
    );
  }
}

class OpeningHoursSelector extends StatefulWidget {
  final Function(Map<String, List<TimeSlot>>)? onHoursChanged;

  const OpeningHoursSelector({super.key, this.onHoursChanged});

  @override
  OpeningHoursSelectorState createState() => OpeningHoursSelectorState();
}

class OpeningHoursSelectorState extends State<OpeningHoursSelector> {
  static final Map<String, List<TimeSlot>> defaultSchedule = {
    'Mon': [],
    'Tue': [],
    'Wed': [],
    'Thu': [],
    'Fri': [],
    'Sat': [],
    'Sun': [],
  };

  Map<String, List<TimeSlot>> schedule = defaultSchedule;

  @override
  void initState() {
    super.initState();
  }

  void _notifyChanges() {
    if (widget.onHoursChanged != null) {
      widget.onHoursChanged!(schedule);
    }
  }

  static String generateFormattedSchedule(
    Map<String, List<TimeSlot>> schedule,
  ) {
    final lines = toLines(schedule);
    // final today = lines.removeAt(0);
    final groupedLines = _groupConsecutiveDays(lines);
    final result = groupedLines.join('\n');
    return result; //'$today\n$result';
  }

  static List<String> toLines(Map<String, List<TimeSlot>> schedule) {
    List<String> lines = [];

    for (String day in schedule.keys) {
      List<TimeSlot> slots = schedule[day]!;

      if (slots.isEmpty) {
        lines.add('$day, Closed');
      } else {
        String timeString = slots
            .map(
              (slot) => '${_formatTime(slot.start)} - ${_formatTime(slot.end)}',
            )
            .join(', ');

        lines.add('$day, $timeString');
      }
    }
    return lines;
  }

  // The `lines` has to be mon - sun.
  static List<String> _groupConsecutiveDays(List<String> lines) {
    final dayAndOperationTimes = lines.map((line) {
      final components = line.split(", ");
      final dayStr = components.removeAt(0);
      final operationTimes = components.join(", ");
      return [dayStr, operationTimes];
    });

    List<DayOperationsTime> result = [];
    for (final each in dayAndOperationTimes) {
      final day = each[0];
      final operationTime = each[1];
      final DayOperationsTime last;
      if (result.isNotEmpty) {
        last = result.last;
      } else {
        last = DayOperationsTime(time: operationTime);
        result.add(last);
      }

      if (last.time == operationTime) {
        last.days.add(day);
      } else {
        final dayOperationsTime = DayOperationsTime(time: operationTime);
        dayOperationsTime.days.add(day);
        result.add(dayOperationsTime);
      }
    }

    return addDaysToOneStr(result);
  }

  static List<String> addDaysToOneStr(
    List<DayOperationsTime> listOpertionDayAndTime,
  ) {
    return listOpertionDayAndTime.map((elm) {
      final days = elm.days;
      var daysStr = days[0];
      final len = days.length;
      if (len > 1) {
        final lastDay = days[len - 1];
        daysStr = "$daysStr - $lastDay";
      }
      return "$daysStr | ${elm.time}";
    }).toList();
  }

  static String _formatTime(TimeOfDay time) {
    String hour = time.hour.toString();
    String minute = time.minute == 0
        ? '00'
        : time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opening Hours',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...schedule.keys.map((day) => _buildDayRow(day)),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    generateFormattedSchedule(schedule),
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(String day) {
    List<TimeSlot> slots = schedule[day]!;
    bool isClosed = slots.isEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(day, style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              Switch(
                value: !isClosed,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      schedule[day] = [
                        TimeSlot(
                          TimeOfDay(hour: 9, minute: 0),
                          TimeOfDay(hour: 17, minute: 0),
                        ),
                      ];
                    } else {
                      schedule[day] = [];
                    }
                    _notifyChanges();
                  });
                },
              ),
              SizedBox(width: 16),
              if (isClosed)
                Text('Closed', style: TextStyle(color: Colors.grey[600]))
              else
                Expanded(
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _addTimeSlot(day),
                        icon: Icon(Icons.add, size: 16),
                        label: Text('Add Hours'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (!isClosed)
            ...slots.asMap().entries.map((entry) {
              int index = entry.key;
              TimeSlot slot = entry.value;
              return Padding(
                padding: EdgeInsets.only(left: 96, top: 8),
                child: _buildTimeSlotRow(day, index, slot),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTimeSlotRow(String day, int index, TimeSlot slot) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _selectTime(day, index, true),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(_formatTime(slot.start)),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(' - '),
        ),
        GestureDetector(
          onTap: () => _selectTime(day, index, false),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(_formatTime(slot.end)),
          ),
        ),
        SizedBox(width: 8),
        if (schedule[day]!.length > 1)
          IconButton(
            onPressed: () => _removeTimeSlot(day, index),
            icon: Icon(Icons.delete, size: 20, color: Colors.red[400]),
            padding: EdgeInsets.all(4),
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );
  }

  void _addTimeSlot(String day) {
    setState(() {
      schedule[day]!.add(
        TimeSlot(
          TimeOfDay(hour: 18, minute: 0),
          TimeOfDay(hour: 22, minute: 0),
        ),
      );
      _notifyChanges();
    });
  }

  void _removeTimeSlot(String day, int index) {
    setState(() {
      schedule[day]!.removeAt(index);
      _notifyChanges();
    });
  }

  void _selectTime(String day, int slotIndex, bool isStart) async {
    TimeSlot slot = schedule[day]![slotIndex];
    TimeOfDay initialTime = isStart ? slot.start : slot.end;

    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (newTime != null) {
      setState(() {
        if (isStart) {
          schedule[day]![slotIndex] = TimeSlot(newTime, slot.end);
        } else {
          schedule[day]![slotIndex] = TimeSlot(slot.start, newTime);
        }
        _notifyChanges();
      });
    }
  }
}

extension CompareTimeSlots on List<TimeSlot> {
  // Helper function to compare two TimeOfDay objects
  int compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    return a.timeOfDayToMinutes().compareTo(b.timeOfDayToMinutes());
  }

  bool areTimeSlotsInOrder() {
    if (isEmpty || length == 1) {
      return true;
    }

    for (int i = 0; i < length; i++) {
      TimeSlot current = this[i];

      // Check if start time is before end time within the same slot
      if (compareTimeOfDay(current.start, current.end) >= 0) {
        return false;
      }

      // Check if current slot comes before next slot with no overlap
      if (i < length - 1) {
        TimeSlot next = this[i + 1];

        // Current slot's end should be strictly before next slot's start
        if (compareTimeOfDay(current.end, next.start) >= 0) {
          return false; // slots overlap or touch
        }
      }
    }

    return true;
  }
}

class TimeSlot {
  TimeOfDay start;
  TimeOfDay end;

  TimeSlot(this.start, this.end);
}

extension ConverToMins on TimeOfDay {
  int timeOfDayToMinutes() {
    return hour * 60 + minute;
  }
}
