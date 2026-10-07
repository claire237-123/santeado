import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import 'welcome_screen.dart';
import 'professionnel_screen.dart';
import 'administrateur_screen.dart';
// Remplace par le nom réel de l'écran d'accueil de l'adolescente
// une fois la session anonyme active (page de profil / navigation principale).
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _router();
  }

  Future<void> _router() async {
    // Petit délai pour laisser le temps au logo de s'afficher.
    await Future.delayed(const Duration(milliseconds: 600));

    final utilisateur = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (utilisateur == null) {
      _aller(const WelcomeScreen());
      return;
    }

    if (utilisateur.isAnonymous) {
      _aller(const MainNavigationScreen());
      return;
    }

    // Compte personnel (email/mot de passe) : on relit le rôle.
    try {
      final role = await _authService.recupererRole(utilisateur.uid);

      if (!mounted) return;

      if (role == 'professionnel') {
        _aller(const ProfessionnelScreen());
      } else if (role == 'administrateur') {
        _aller(const AdministrateurScreen());
      } else {
        await _authService.deconnexion();
        _aller(const WelcomeScreen());
      }
    } catch (_) {
      await _authService.deconnexion();
      if (!mounted) return;
      _aller(const WelcomeScreen());
    }
  }

  void _aller(Widget ecran) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ecran),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFFDFB),
      body: Center(
        child: Icon(
          Icons.favorite_border,
          color: Color(0xFFD4537E),
          size: 54,
        ),
      ),
    );
  }
}