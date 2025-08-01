import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import 'event_card.dart';

class UpcomingEventsList extends StatefulWidget {
  final Function(EventModel) onEventTap;

  const UpcomingEventsList({
    super.key,
    required this.onEventTap,
  });

  @override
  State<UpcomingEventsList> createState() => _UpcomingEventsListState();
}

class _UpcomingEventsListState extends State<UpcomingEventsList> {
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.fetchUpcomingEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        if (eventProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (eventProvider.upcomingEvents.isEmpty) {
          return const Center(
            child: Text('Aucun événement à venir'),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadEvents,
          child: ListView.builder(
            itemCount: eventProvider.upcomingEvents.length,
            itemBuilder: (context, index) {
              final event = eventProvider.upcomingEvents[index];
              return EventCard(
                event: event,
                onTap: () => widget.onEventTap(event),
              );
            },
          ),
        );
      },
    );
  }
}