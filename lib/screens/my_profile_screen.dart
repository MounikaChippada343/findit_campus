import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../services/item_service.dart';
import 'edit_profile_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final ItemService _itemService = ItemService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  late TabController _tabController;
  UserProfile? _userProfile;
  Map<String, int> _stats = {'totalLost': 0, 'totalFound': 0, 'resolved': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (currentUser == null) return;
    setState(() => _isLoading = true);

    try {
      final profile = await _userService.getUserProfile(currentUser!.uid);
      final stats = await _userService.getUserStatistics(currentUser!.uid);

      // If profile doesn't exist yet, create a default one from Auth
      if (profile == null) {
        final newProfile = UserProfile(
          uid: currentUser!.uid,
          fullName: currentUser!.displayName ?? 'Campus User',
          email: currentUser!.email ?? '',
          collegeName: 'Campus University',
          department: '',
          yearOfStudy: '',
          bio: '',
          profileImageUrl: currentUser!.photoURL ?? '',
          createdAt: DateTime.now(),
        );
        await _userService.saveUserProfile(newProfile);
        setState(() {
          _userProfile = newProfile;
          _stats = stats;
          _isLoading = false;
        });
      } else {
        setState(() {
          _userProfile = profile;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: Text('Failed to load user profile.')),
      );
    }

    final formattedDate = _userProfile!.createdAt != null
        ? DateFormat('MMMM yyyy').format(_userProfile!.createdAt!)
        : 'Recently';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(profile: _userProfile!),
                ),
              );
              _loadProfileData(); // Refresh after edit
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Avatar & Name
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: _userProfile!.profileImageUrl.isNotEmpty
                        ? NetworkImage(_userProfile!.profileImageUrl)
                        : null,
                    child: _userProfile!.profileImageUrl.isEmpty
                        ? Text(
                            _userProfile!.fullName.isNotEmpty
                                ? _userProfile!.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userProfile!.fullName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userProfile!.email,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  if (_userProfile!.collegeName.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.school, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          _userProfile!.collegeName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  if (_userProfile!.department.isNotEmpty || _userProfile!.yearOfStudy.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${_userProfile!.department} ${_userProfile!.yearOfStudy.isNotEmpty ? '• Year ${_userProfile!.yearOfStudy}' : ''}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ),
                  if (_userProfile!.bio.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _userProfile!.bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Member since $formattedDate',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 20),

                  // Statistics Cards Row
                  Row(
                    children: [
                      _buildStatCard('Lost Reported', '${_stats['totalLost']}', Colors.red.shade100, Colors.red.shade900),
                      const SizedBox(width: 8),
                      _buildStatCard('Found Reported', '${_stats['totalFound']}', Colors.green.shade100, Colors.green.shade900),
                      const SizedBox(width: 8),
                      _buildStatCard('Resolved', '${_stats['resolved']}', Colors.blue.shade100, Colors.blue.shade900),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tab Bar for Active vs Resolved Listings
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    tabs: const [
                      Tab(text: 'My Listings'),
                      Tab(text: 'Resolved Items'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildUserListingsStream(isResolved: false),
            _buildUserListingsStream(isResolved: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListingsStream({required bool isResolved}) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _itemService.getItemsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allItems = snapshot.data ?? [];
        // Filter by current user ID and resolution status
        final userItems = allItems.where((item) {
          final isOwner = item['ownerId'] == currentUser?.uid;
          final status = (item['status'] ?? 'active').toString().toLowerCase();
          final isItemResolved = status == 'resolved' || status == 'returned' || status == 'closed';
          
          return isOwner && (isResolved ? isItemResolved : !isItemResolved);
        }).toList();

        if (userItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                isResolved ? 'No resolved listings yet.' : 'No active listings right now.',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: userItems.length,
          itemBuilder: (context, index) {
            final item = userItems[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(item['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${item['location']} •${item['category']}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (item['type'] ?? '').toString().toLowerCase() == 'lost'
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (item['type'] ?? 'LOST').toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: (item['type'] ?? '').toString().toLowerCase() == 'lost'
                          ? Colors.red.shade800
                          : Colors.green.shade800,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}