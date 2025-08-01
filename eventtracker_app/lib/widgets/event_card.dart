import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/date_utils.dart' as event_date_utils;

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = event.date.isBefore(DateTime.now());
    final isToday = event_date_utils.DateUtils.isToday(event.date);
    final isTomorrow = event_date_utils.DateUtils.isTomorrow(event.date);
    
    Color cardColor;
    
    if (isToday) {
      cardColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
    } else if (isTomorrow) {
      cardColor = Theme.of(context).colorScheme.secondary.withOpacity(0.1);
    } else if (isPast) {
      cardColor = Colors.grey.withOpacity(0.1);
    } else {
      cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPast ? Colors.grey : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildDateChip(context),
                ],
              ),
              if (event.location.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: TextStyle(
                          color: isPast ? Colors.grey : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    event.formattedTime,
                    style: TextStyle(
                      color: isPast ? Colors.grey : null,
                    ),
                  ),
                ],
              ),
              if (event.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: TextStyle(
                    color: isPast ? Colors.grey : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(BuildContext context) {
    final isPast = event.date.isBefore(DateTime.now());
    final isToday = event_date_utils.DateUtils.isToday(event.date);
    final isTomorrow = event_date_utils.DateUtils.isTomorrow(event.date);
    
    String dateText;
    Color chipColor;
    
    if (isToday) {
      dateText = 'Aujourd\'hui';
      chipColor = Theme.of(context).colorScheme.primary;
    } else if (isTomorrow) {
      dateText = 'Demain';
      chipColor = Theme.of(context).colorScheme.secondary;
    } else if (isPast) {
      dateText = event.formattedDate;
      chipColor = Colors.grey;
    } else {
      dateText = event.formattedDate;
      chipColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withOpacity(0.5)),
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