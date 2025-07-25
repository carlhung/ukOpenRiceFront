import 'package:flutter/material.dart';

class OpeningHoursSelector extends StatefulWidget {
  final Function(String)? onHoursChanged;

  const OpeningHoursSelector({Key? key, this.onHoursChanged}) : super(key: key);

  @override
  _OpeningHoursSelectorState createState() => _OpeningHoursSelectorState();
}

class _OpeningHoursSelectorState extends State<OpeningHoursSelector> {
  Map<String, List<TimeSlot>> schedule = {
    'Today': [
      TimeSlot(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 13, minute: 0)),
    ],
    'Mon': [],
    'Tue': [
      TimeSlot(TimeOfDay(hour: 18, minute: 0), TimeOfDay(hour: 22, minute: 0)),
    ],
    'Wed': [
      TimeSlot(TimeOfDay(hour: 18, minute: 0), TimeOfDay(hour: 22, minute: 0)),
    ],
    'Thu': [
      TimeSlot(TimeOfDay(hour: 11, minute: 30), TimeOfDay(hour: 22, minute: 0)),
    ],
    'Fri': [
      TimeSlot(TimeOfDay(hour: 11, minute: 30), TimeOfDay(hour: 22, minute: 0)),
    ],
    'Sat': [
      TimeSlot(TimeOfDay(hour: 11, minute: 30), TimeOfDay(hour: 22, minute: 0)),
    ],
    'Sun': [
      TimeSlot(TimeOfDay(hour: 11, minute: 30), TimeOfDay(hour: 22, minute: 0)),
    ],
  };

  @override
  void initState() {
    super.initState();
    // Add second time slot for "Today"
    schedule['Today']!.add(
      TimeSlot(TimeOfDay(hour: 17, minute: 0), TimeOfDay(hour: 23, minute: 0)),
    );
    _notifyChanges();
  }

  void _notifyChanges() {
    if (widget.onHoursChanged != null) {
      widget.onHoursChanged!(generateFormattedSchedule());
    }
  }

  String generateFormattedSchedule() {
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

        if (day == 'Today') {
          lines.add('$day, $timeString');
        } else {
          // Group consecutive days with same hours
          lines.add('$day, $timeString');
        }
      }
    }

    return _groupConsecutiveDays(lines);
  }

  String _groupConsecutiveDays(List<String> lines) {
    List<String> result = [];
    Map<String, List<String>> timeGroups = {};

    // Group days by their time slots (excluding Today)
    for (String line in lines) {
      if (line.startsWith('Today')) {
        result.add(line);
        continue;
      }

      List<String> parts = line.split(', ');
      String day = parts[0];
      String time = parts.length > 1 ? parts[1] : 'Closed';

      if (!timeGroups.containsKey(time)) {
        timeGroups[time] = [];
      }
      timeGroups[time]!.add(day);
    }

    // Format grouped days
    for (String time in timeGroups.keys) {
      List<String> days = timeGroups[time]!;
      if (days.length == 1) {
        result.add('${days[0]}, $time');
      } else {
        String dayRange = _formatDayRange(days);
        result.add('$dayRange, $time');
      }
    }

    return result.join('\n');
  }

  String _formatDayRange(List<String> days) {
    List<String> weekOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    days.sort((a, b) => weekOrder.indexOf(a).compareTo(weekOrder.indexOf(b)));

    if (days.length <= 2) {
      return days.join(' - ');
    }

    // Check for consecutive days
    List<List<String>> groups = [];
    List<String> currentGroup = [days[0]];

    for (int i = 1; i < days.length; i++) {
      int currentIndex = weekOrder.indexOf(days[i]);
      int previousIndex = weekOrder.indexOf(days[i - 1]);

      if (currentIndex == previousIndex + 1) {
        currentGroup.add(days[i]);
      } else {
        groups.add(List.from(currentGroup));
        currentGroup = [days[i]];
      }
    }
    groups.add(currentGroup);

    return groups
        .map((group) {
          if (group.length == 1) return group[0];
          if (group.length == 2) return '${group[0]} - ${group[1]}';
          return '${group.first} - ${group.last}';
        })
        .join(', ');
  }

  String _formatTime(TimeOfDay time) {
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
                    generateFormattedSchedule(),
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

class TimeSlot {
  TimeOfDay start;
  TimeOfDay end;

  TimeSlot(this.start, this.end);
}

// Example usage widget
class OpeningHoursDemo extends StatefulWidget {
  @override
  _OpeningHoursDemoState createState() => _OpeningHoursDemoState();
}

class _OpeningHoursDemoState extends State<OpeningHoursDemo> {
  String currentSchedule = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opening Hours Selector'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            OpeningHoursSelector(
              onHoursChanged: (schedule) {
                setState(() {
                  currentSchedule = schedule;
                });
              },
            ),
            if (currentSchedule.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Final Output:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            currentSchedule,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
