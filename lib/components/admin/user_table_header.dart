import 'package:flutter/material.dart';

class UserTableHeader extends StatelessWidget {
  const UserTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _HeaderText('USER'),
          ),
          Expanded(
            flex: 2,
            child: _HeaderText('ROLE'),
          ),
          Expanded(
            flex: 2,
            child: _HeaderText('STATUS'),
          ),
          Expanded(
            flex: 2,
            child: _HeaderText('JOIN DATE'),
          ),
          Expanded(
            flex: 2,
            child: _HeaderText('ACTIONS'),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;

  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }
}