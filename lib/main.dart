import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_service.dart';
import 'screens/citizen_dashboard.dart';
import 'screens/farmer_dashboard.dart';
import 'screens/factory_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const NafasGabesApp());
}

class NafasGabesApp extends StatelessWidget {
  const NafasGabesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nafas Gabès',
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}

class AppTheme {
  static const Color deepTeal = Color(0xFF0A3D62);
  static const Color teal = Color(0xFF1A6B8A);
  static const Color skyBlue = Color(0xFF2E9EC7);
  static const Color mint = Color(0xFF27AE60);
  static const Color leafGreen = Color(0xFF1E8449);
  static const Color paleGreen = Color(0xFFD5F5E3);
  static const Color paleTeal = Color(0xFFD6EAF8);
  static const Color surface = Color(0xFFF0F7F4);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0D2137);
  static const Color textMid = Color(0xFF4A6572);
  static const Color textLight = Color(0xFF8EAAB8);
  static const Color warning = Color(0xFFE67E22);
  static const Color danger = Color(0xFFE74C3C);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: teal,
          onPrimary: Colors.white,
          secondary: mint,
          onSecondary: Colors.white,
          error: danger,
          onError: Colors.white,
          surface: cardWhite,
          onSurface: textDark,
        ),
        scaffoldBackgroundColor: surface,
        fontFamily: 'Georgia',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: teal,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD0E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD0E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: teal, width: 2),
          ),
          labelStyle: const TextStyle(color: textMid),
        ),
      );
}

class GradientScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool extendBodyBehindAppBar;

  const GradientScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.deepTeal, AppTheme.teal, AppTheme.skyBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(title),
        actions: actions,
      ),
      body: body,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    setState(() => isLoading = true);

    final result = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result != null && result["user"] != null) {
      final role = result["user"]["role"];

      if (role == "citizen") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CitizenDashboard()),
        );
      } else if (role == "farmer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FarmerDashboard()),
        );
      } else if (role == "factory") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FactoryDashboardScreen()),
        );
      } else {
        _showSnack("Rôle non supporté : $role");
      }
    } else {
      _showSnack("Email ou mot de passe incorrect");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.deepTeal, AppTheme.teal, AppTheme.skyBlue],
                begin: Alignment.topCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: _Circle(
              size: 200,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          Positioned(
            top: 80,
            left: -40,
            child: _Circle(
              size: 130,
              color: AppTheme.mint.withOpacity(0.15),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepTeal.withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'lib/assets/logo.jpg',
                        fit: BoxFit.cover,
                        width: 110,
                        height: 110,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.teal.withOpacity(0.1),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Connexion',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Connectez-vous pour continuer',
                          style: TextStyle(
                            color: AppTheme.textMid,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppTheme.teal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppTheme.teal,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.textLight,
                              ),
                              onPressed: () {
                                setState(() => _obscure = !_obscure);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.teal,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.teal, AppTheme.skyBlue],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.teal.withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;

  const _Circle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}