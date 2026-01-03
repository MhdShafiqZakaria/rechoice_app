import 'package:flutter/material.dart';
// import 'package:rechoice_app/models/category_model.dart';

class CategoryButton extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade700 : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
