import 'package:flutter/material.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/viewmodels/users_view_model.dart';

class ProfileAppBar extends StatelessWidget {
  final Users user;
  final bool isOwnProfile;
  final VoidCallback onEditPressed;
  final VoidCallback onLogoutPressed;
  const ProfileAppBar({
    super.key,
    required this.user,
    required this.isOwnProfile,
    required this.onEditPressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF2E5C9A),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (isOwnProfile) ...[
          TextButton(
            onPressed: onEditPressed,
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),
          // Logout Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFF2E5C9A)),
              onPressed: onLogoutPressed,
              tooltip: 'Logout',
            ),
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2E5C9A), Color(0xFF1E4C7A)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: user.profilePic.isNotEmpty
                      ? NetworkImage(user.profilePic)
                      : null,
                  child: user.profilePic.isEmpty
                      ? Text(
                          UsersViewModel.getInitials(user.name),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E5C9A),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  UsersViewModel.getUsername(user.email),
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      user.reputationScore.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ' (${user.totalSales} sales)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
