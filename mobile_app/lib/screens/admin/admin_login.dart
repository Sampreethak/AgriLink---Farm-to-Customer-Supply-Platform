import 'package:flutter/material.dart';
import '../../core/colors.dart';
import 'admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController(text: "admin@agrilink.com");
  final _passwordController = TextEditingController(text: "admin123");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Admin Portal Login"),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.admin_panel_settings,
                size: 90,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 15),
              const Text(
                "System Admin Portal",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Access central administration panels",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 40),

              // Email input
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Admin Username / Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),

              // Password input
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Admin Security PIN / Password",
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                  ),
                  onPressed: () {
                    if (_emailController.text == "admin@agrilink.com" && _passwordController.text == "admin123") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboard(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Invalid admin credentials! Hint: admin@agrilink.com / admin123"),
                        ),
                      );
                    }
                  },
                  child: const Text("Enter Admin Dashboard", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
