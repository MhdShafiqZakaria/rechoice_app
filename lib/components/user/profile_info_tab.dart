import 'package:flutter/material.dart';
import 'package:rechoice_app/components/user/info_row.dart';
import 'package:rechoice_app/components/user/section_card.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/viewmodels/users_view_model.dart';

class ProfileInfoTab extends StatelessWidget {
  final Users user;
  final bool isOwnProfile;
  const ProfileInfoTab({
    super.key,
    required this.user,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            title: 'Personal Information',
            children: [
              InfoRow(
                label: 'Bio',
                value: user.bio.isEmpty ? 'No bio yet' : user.bio,
                icon: null,
              ),
              const Divider(),
              InfoRow(
                label: 'Member Since',
                value: UsersViewModel.getMemberSince(user.joinDate),
                icon: null,
              ),
              const Divider(),
              InfoRow(
                label: 'Account Status',
                value: user.status.toString().split('.').last.toUpperCase(),
                icon: null,
              ),
              const Divider(),
              InfoRow(
                label: 'Role',
                value: UsersViewModel.getRoleText(user.role),
                icon: null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Activity Stats',
            children: [
              InfoRow(
                label: 'Total Listings',
                value: user.totalListings.toString(),
                icon: null,
              ),
              const Divider(),
              InfoRow(
                label: 'Total Purchases',
                value: user.totalPurchases.toString(),
                icon: null,
              ),
              const Divider(),
              InfoRow(
                label: 'Total Sales',
                value: user.totalSales.toString(),
                icon: null,
              ),
              const Divider(),
              InfoRow(
                label: 'Reputation Score',
                value: user.reputationScore.toStringAsFixed(1),
                icon: null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isOwnProfile && user.hasContactInfo)
            SectionCard(
              title: 'Contact Information',
              children: [
                InfoRow(
                  label: 'Email Address',
                  value: user.email,
                  icon: Icons.email,
                ),
                const Divider(),
                if (user.phoneNumber != null)
                  InfoRow(
                    label: 'Phone Number',
                    value: user.phoneNumber!,
                    icon: Icons.phone,
                  ),
                if (user.phoneNumber != null) const Divider(),
                if (user.address != null)
                  InfoRow(
                    label: 'Address',
                    value: user.address!,
                    icon: Icons.location_on,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
