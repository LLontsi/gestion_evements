import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/date_utils.dart' as task_date_utils;

class TaskListItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final ValueChanged<bool?>? onStatusChanged;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onTap,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    final isPast = task.dueDate.isBefore(DateTime.now()) && !isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: onStatusChanged,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey : null,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildPriorityChip(),
                const SizedBox(width: 8),
                _buildDueDateChip(context, isPast),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: onTap,
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    Color chipColor;
    String priorityText = task.priorityString;
    
    switch (task.priority) {
      case TaskPriority.high:
        chipColor = Colors.red;
        break;
      case TaskPriority.medium:
        chipColor = Colors.orange;
        break;
      default:
        chipColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priorityText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDueDateChip(BuildContext context, bool isPast) {
    String dateText;
    Color chipColor;
    
    final isToday = task_date_utils.DateUtils.isToday(task.dueDate);
    final isTomorrow = task_date_utils.DateUtils.isTomorrow(task.dueDate);
    
    if (isToday) {
      dateText = 'Aujourd\'hui';
      chipColor = Colors.green;
    } else if (isTomorrow) {
      dateText = 'Demain';
      chipColor = Colors.blue;
    } else if (isPast) {
      dateText = 'En retard';
      chipColor = Colors.red;
    } else {
      dateText = task_date_utils.DateUtils.formatDate(task.dueDate);
      chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        dateText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}