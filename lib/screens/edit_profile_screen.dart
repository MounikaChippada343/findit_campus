import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel userModel; // Matches ProfileScreen parameter name
  const EditProfileScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  late TextEditingController _nameController;
  late TextEditingController _collegeController;
  late TextEditingController _departmentController;
  late TextEditingController _yearController;
  late TextEditingController _bioController;
  late TextEditingController _imageController;

  late bool _showCollege;
  late bool _showDepartment;
  late bool _showYearOfStudy;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userModel.fullName);
    _collegeController = TextEditingController(text: widget.userModel.collegeName);
    _departmentController = TextEditingController(text: widget.userModel.department);
    _yearController = TextEditingController(text: widget.userModel.yearOfStudy);
    _bioController = TextEditingController(text: widget.userModel.bio);
    _imageController = TextEditingController(text: widget.userModel.profileImageUrl);

    _showCollege = widget.userModel.showCollege;
    _showDepartment = widget.userModel.showDepartment;
    _showYearOfStudy = widget.userModel.showYearOfStudy;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final updatedUser = UserModel(
        uid: widget.userModel.uid,
        email: widget.userModel.email,
        fullName: _nameController.text.trim(),
        collegeName: _collegeController.text.trim(),
        department: _departmentController.text.trim(),
        yearOfStudy: _yearController.text.trim(),
        bio: _bioController.text.trim(),
        profileImageUrl: _imageController.text.trim(),
        showCollege: _showCollege,
        showDepartment: _showDepartment,
        showYearOfStudy: _showYearOfStudy,
        createdAt: widget.userModel.createdAt,
        updatedAt: DateTime.now(),
      );

      await _userService.updateUserProfile(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _collegeController,
                      decoration: const InputDecoration(labelText: 'College Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _departmentController,
                      decoration: const InputDecoration(labelText: 'Department / Branch', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(labelText: 'Year of Study (e.g. 4th Year)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageController,
                      decoration: const InputDecoration(labelText: 'Profile Image URL', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Short Bio', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    const Text('Privacy Settings (Public Visibility)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: const Text('Show College on Public Profile'),
                      value: _showCollege,
                      onChanged: (val) => setState(() => _showCollege = val),
                    ),
                    SwitchListTile(
                      title: const Text('Show Department on Public Profile'),
                      value: _showDepartment,
                      onChanged: (val) => setState(() => _showDepartment = val),
                    ),
                    SwitchListTile(
                      title: const Text('Show Year of Study on Public Profile'),
                      value: _showYearOfStudy,
                      onChanged: (val) => setState(() => _showYearOfStudy = val),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _saveProfile,
                      child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}