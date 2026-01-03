import 'package:flutter/material.dart';

class UserFiltersBar extends StatelessWidget {
  final String selectedStatus;
  final String selectedRole;
  final Function(String) onStatusChanged;
  final Function(String) onRoleChanged;
  final VoidCallback onExport;

  const UserFiltersBar({
    super.key,
    required this.selectedStatus,
    required this.selectedRole,
    required this.onStatusChanged,
    required this.onRoleChanged,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56, // Add fixed height
      child: Row(
        children: [
          Expanded(
            child: _FilterDropdown(
              value: selectedStatus,
              items: const ['All Status', 'Active', 'Suspended', 'Inactive'],
              onChanged: onStatusChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FilterDropdown(
              value: selectedRole,
              items: const ['All Roles', 'Buyer', 'Seller', 'Admin'],
              onChanged: onRoleChanged,
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.download, color: Colors.white, size: 18),
            label: const Text(
              'Export',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String) onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: (val) => onChanged(val!),
        ),
      ),
    );
  }
}