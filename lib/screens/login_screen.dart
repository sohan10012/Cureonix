import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui'; // For ColorFilter, ImageFilter

import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController(); 
  final _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState!.validate()) {
      Provider.of<AppState>(context, listen: false).setUserName(_nameController.text);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Ambient BackgroundGlows (Light)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.05),
                ),
              ),
            ),
             Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary.withOpacity(0.05),
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Animated Logo Container
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C4B4), Color(0xFF0056D2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: -5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(FontAwesomeIcons.dna, size: 40, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Welcome Text
                      Text(
                        'CUREONIX',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Future of Pharma Intelligence',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 50),
                
                      // Glass Login Card (White Frosted)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ACCESS PORTAL',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Name Input
                                  TextFormField(
                                    controller: _nameController,
                                    style: const TextStyle(color: AppTheme.textPrimary),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.person_rounded),
                                      hintText: 'Agent ID',
                                    ),
                                    validator: (value) => value!.isEmpty ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Password Input
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    style: const TextStyle(color: AppTheme.textPrimary),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.lock_rounded),
                                      hintText: 'Passkey',
                                      suffixIcon: Icon(Icons.visibility_off_rounded),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _login,
                                      child: const Text('INITIALIZE SESSION'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      Text(
                        'SECURE CONNECTION // ENCRYPTED',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textSecondary.withOpacity(0.5),
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
