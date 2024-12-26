import 'package:flutter/material.dart';

class EventCard extends StatefulWidget {
  final String time;
  final IconData icon;
  final String title;
  final Color color;
  final String label;
  final VoidCallback addToCalendar;

  const EventCard({
    required this.time,
    required this.icon,
    required this.title,
    required this.color,
    required this.label,
    required this.addToCalendar,
    Key? key,
  }) : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Zachowanie stanu
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildIconSection(theme),
          const SizedBox(width: 16.0),
          _buildDetailsSection(theme),
          _buildCalendarButton(theme),
        ],
      ),
    );
  }

  Widget _buildIconSection(ThemeData theme) {
    return Container(
      width: 80,
      height: 70,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            color: theme.colorScheme.onPrimary,
            size: 24.0,
          ),
          const SizedBox(height: 4.0),
          Text(
            widget.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(ThemeData theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4.0),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16.0,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4.0),
              Text(
                widget.time,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarButton(ThemeData theme) {
    return IconButton(
      icon: Icon(
        Icons.calendar_today,
        color: theme.colorScheme.primary,
        size: 24.0,
      ),
      onPressed: widget.addToCalendar,
      tooltip: 'Add to Calendar',
    );
  }
}

