import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? result = await AuthService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result != null) {
        // Navigation will be handled by AuthWrapper
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เข้าสู่ระบบสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and Title
                Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber,
                ),
                SizedBox(height: 24),
                Text(
                  'QuestForKids',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'แอปพลิเคชันภารกิจสร้างปฏิสัมพันธ์กับเด็ก',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 48),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  labelText: 'อีเมล',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }
                    if (!value.contains('@')) {
                      return 'รูปแบบอีเมลไม่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'รหัสผ่าน',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }
                    if (value.length < 6) {
                      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Login Button
                CustomButton(
                  text: 'เข้าสู่ระบบ',
                  onPressed: _isLoading ? null : _signIn,
                  isLoading: _isLoading,
                ),
                SizedBox(height: 16),

                // Register Link
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'ยังไม่มีบัญชี? สมัครสมาชิก',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedUserType = 'parent';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? result = await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        userType: _selectedUserType,
      );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('สมัครสมาชิกสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('สมัครสมาชิกไม่สำเร็จ กรุณาลองใหม่'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สมัครสมาชิก'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Type Selection
                  Text(
                    'ประเภทผู้ใช้',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('ผู้ปกครอง'),
                          value: 'parent',
                          groupValue: _selectedUserType,
                          onChanged: (value) {
                            setState(() {
                              _selectedUserType = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('เด็ก'),
                          value: 'child',
                          groupValue: _selectedUserType,
                          onChanged: (value) {
                            setState(() {
                              _selectedUserType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Name Field
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'ชื่อ-นามสกุล',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อ-นามสกุล';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'อีเมล',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอีเมล';
                      }
                      if (!value.contains('@')) {
                        return 'รูปแบบอีเมลไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'รหัสผ่าน',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกรหัสผ่าน';
                      }
                      if (value.length < 6) {
                        return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Confirm Password Field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: 'ยืนยันรหัสผ่าน',
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณายืนยันรหัสผ่าน';
                      }
                      if (value != _passwordController.text) {
                        return 'รหัสผ่านไม่ตรงกัน';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Register Button
                  CustomButton(
                    text: 'สมัครสมาชิก',
                    onPressed: _isLoading ? null : _signUp,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

