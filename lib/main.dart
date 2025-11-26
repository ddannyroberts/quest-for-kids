import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/login_screen.dart';
import 'screens/parent/parent_home_screen.dart';
import 'screens/child/child_home_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notifications
  await NotificationService.initialize();
  
  runApp(QuestForKidsApp());
}

class QuestForKidsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuestForKids',
      theme: ThemeData(
        // Primary Color - Adventure Purple
        primaryColor: Color(0xFF8B5CF6), // Vibrant Purple
        primarySwatch: _createMaterialColor(Color(0xFF8B5CF6)),
        
        // Color Scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF8B5CF6),
          brightness: Brightness.light,
        ),
        
        // App Bar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        
        // Card Theme
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        
        // Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            elevation: 3,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        // Input Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF8B5CF6), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        
        // Bottom Navigation Bar Theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF8B5CF6),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Kanit',
      ),
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
  
  MaterialColor _createMaterialColor(Color color) {
    List<double> strengths = [0.05];
    Map<int, Color> swatch = {};
    // ใช้ channel ปกติของ Color (red, green, blue) แทน r/g/b ที่ไม่มีใน Flutter
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    // ใช้ค่า color.value ตรง ๆ (ARGB) ในการสร้าง MaterialColor
    return MaterialColor(color.value, swatch);
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData) {
          // User is logged in, check user type
          return UserTypeWrapper();
        } else {
          // User is not logged in
          return LoginScreen();
        }
      },
    );
  }
}

class UserTypeWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService.getUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        String? userType = snapshot.data;
        
        if (userType == 'parent') {
          return ParentHomeScreen();
        } else if (userType == 'child') {
          return ChildHomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}