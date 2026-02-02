import 'dart:io';
import 'package:concession_tracker_ui/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  File? _profileImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.gradientTop, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),


      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20), // small top padding like iOS
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage(
                                'assets/images/profile_placeholder.png')
                            as ImageProvider,
                  ),
                  Container(
                    height: 34,
                    width: 34,
                    decoration: const BoxDecoration(
                      color: AppColors.gradientTop,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 18),
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),


              _buildTile(
                icon: Icons.person_outline,
                title: "Name : Johnson",
                onTap: () {},
              ),
              const SizedBox(height: 12),

              _buildTile(
                icon: Icons.email,
                title: "Email Address : johnson@gmail.com",
                onTap: () {},
              ),
              const SizedBox(height: 12),

              _buildTile(
                icon: Icons.settings_outlined,
                title: "Phone Number : (830) 663-5968 ",
                onTap: () {},
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.gradientTop),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appleBlack
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}
