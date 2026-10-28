import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;

  const PublicProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final UserService _userService = UserService();
  UserModel? _userModel;
  Map<String, int> _stats = {'lost': 0, 'found': 0, 'resolved': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _userService.getUserProfile(widget.userId);
      if (user != null) {
        final stats = await _userService.getUserStats(widget.userId);
        setState(() {
          _userModel = user;
          _stats = stats;
        });
      }
    } catch (e) {
      // Handle error gracefully
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userModel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: const Center(child: Text('User profile not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_userModel!.fullName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: _userModel!.profileImageUrl.isNotEmpty
                  ? NetworkImage(_userModel!.profileImageUrl)
                  : null,
              child: _userModel!.profileImageUrl.isEmpty
                  ? Text(
                      _userModel!.fullName.isNotEmpty ? _userModel!.fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              _userModel!.fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (_userModel!.showCollege && _userModel!.collegeName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _userModel!.collegeName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.blueGrey),
              ),
            ],
            if ((_userModel!.showDepartment && _userModel!.department.isNotEmpty) ||
                (_userModel!.showYearOfStudy && _userModel!.yearOfStudy.isNotEmpty)) ...[
              const SizedBox(height: 4),
              Text(
                '${_userModel!.showDepartment ? _userModel!.department : ''} ${_userModel!.showYearOfStudy && _userModel!.yearOfStudy.isNotEmpty ? '• Year ${_userModel!.yearOfStudy}' : ''}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
            if (_userModel!.bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _userModel!.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Lost', '${_stats['lost']}', Colors.red.shade100, Colors.red.shade900),
                _buildStatCard('Found', '${_stats['found']}', Colors.green.shade100, Colors.green.shade900),
                _buildStatCard('Resolved', '${_stats['resolved']}', Colors.blue.shade100, Colors.blue.shade900),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color bgColor, Color textColor) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
        ],
      ),
    );
  }
}