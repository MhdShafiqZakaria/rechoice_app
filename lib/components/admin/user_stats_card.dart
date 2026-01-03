import 'package:flutter/material.dart';

class UserStatsCards extends StatelessWidget {
  final Map<String, int> statusCounts;
  final Map<String, int> roleCounts;

  const UserStatsCards({
    super.key,
    required this.statusCounts,
    required this.roleCounts,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use wrap for responsive layout on smaller screens
        if (constraints.maxWidth < 800) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                title: 'Total Users',
                value: '${statusCounts.values.fold(0, (a, b) => a + b)}',
                icon: Icons.people,
                color: Colors.blue,
                width: (constraints.maxWidth - 16) / 2,
              ),
              _StatCard(
                title: 'Active',
                value: '${statusCounts['active'] ?? 0}',
                icon: Icons.check_circle,
                color: Colors.green,
                width: (constraints.maxWidth - 16) / 2,
              ),
              _StatCard(
                title: 'Suspended',
                value: '${statusCounts['suspended'] ?? 0}',
                icon: Icons.block,
                color: Colors.orange,
                width: (constraints.maxWidth - 16) / 2,
              ),
              _StatCard(
                title: 'Sellers',
                value: '${roleCounts['seller'] ?? 0}',
                icon: Icons.store,
                color: Colors.purple,
                width: (constraints.maxWidth - 16) / 2,
              ),
            ],
          );
        }

        // Use Row for wider screens
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Users',
                value: '${statusCounts.values.fold(0, (a, b) => a + b)}',
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Active',
                value: '${statusCounts['active'] ?? 0}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Suspended',
                value: '${statusCounts['suspended'] ?? 0}',
                icon: Icons.block,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Sellers',
                value: '${roleCounts['seller'] ?? 0}',
                icon: Icons.store,
                color: Colors.purple,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? width;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
