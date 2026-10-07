import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import 'professionnel_screen.dart';

class ConnexionProfessionnelScreen extends StatefulWidget {
  const ConnexionProfessionnelScreen({super.key});

  @override
  State<ConnexionProfessionnelScreen> createState() =>
      _ConnexionProfessionnelScreenState();
}

class _ConnexionProfessionnelScreenState
    extends State<ConnexionProfessionnelScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _motDePasseController =
      TextEditingController();

  bool _enCours = false;
  bool _motDePasseVisible = false;

  static const Color _rose = Color(0xFFD4537E);
  static const Color _fond = Color(0xFFFFFDFB);
  static const Color _texte = Color(0xFF2D2A26);
  static const Color _gris = Color(0xFF77716F);

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    final email = _emailController.text.trim();
    final motDePasse = _motDePasseController.text;

    // ==========================================================
    // VERIFICATION DES CHAMPS
    // ==========================================================

    if (email.isEmpty) {
      _afficherErreur('Veuillez saisir votre adresse e-mail.');
      return;
    }

    if (motDePasse.isEmpty) {
      _afficherErreur('Veuillez saisir votre mot de passe.');
      return;
    }

    setState(() {
      _enCours = true;
    });

    try {
      // ========================================================
      // CONNEXION FIREBASE
      // ========================================================

      final utilisateur = await _authService.connexionEmailMotDePasse(
        email,
        motDePasse,
      );
      debugPrint('UID PROFESSIONNEL CONNECTÉ : ${utilisateur?.uid}');

      if (utilisateur == null) {
        throw Exception('Connexion impossible.');
      }

      // ========================================================
      // RECUPERATION DU ROLE
      // ========================================================

      final role = await _authService.recupererRole(
        utilisateur.uid,
      );

      if (!mounted) return;

      // ========================================================
      // VERIFICATION DU ROLE
      // ========================================================

      if (role != 'professionnel') {
        await _authService.deconnexion();

        // CORRIGÉ : même message que pour un identifiant/mot de passe
        // incorrect -- voir la note dans connexion_administrateur_screen.dart.
        // Confirmer explicitement "ce compte existe mais n'est pas
        // professionnel" permettrait de deviner quelles adresses e-mail
        // correspondent à un compte réel.
        _afficherErreur('Identifiants incorrects.');

        return;
      }

      // ========================================================
      // ACCES A L'ESPACE PROFESSIONNEL
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfessionnelScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // CORRIGÉ : "compte inexistant" et "mot de passe incorrect"
      // fusionnés sous un message unique pour éviter l'énumération de
      // comptes valides. Les erreurs qui ne révèlent rien sur un compte
      // précis restent distinguées.
      String message = 'Identifiants incorrects.';

      final erreur = e.toString();

      if (erreur.contains('invalid-email')) {
        message = 'L’adresse e-mail saisie est invalide.';
      } else if (erreur.contains('too-many-requests')) {
        message = 'Trop de tentatives. Réessayez plus tard.';
      } else if (erreur.contains('network-request-failed')) {
        message =
            'Problème de connexion Internet. Vérifiez votre connexion.';
      }
      // user-not-found, wrong-password, invalid-credential -> message
      // générique par défaut ci-dessus, volontairement non distingués.

      _afficherErreur(message);
    } finally {
      if (mounted) {
        setState(() {
          _enCours = false;
        });
      }
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fond,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 26,
              vertical: 30,
            ),

            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ==================================================
                  // EN-TÊTE
                  // ==================================================

                  Row(
                    children: [

                      Container(
                        width: 42,
                        height: 42,

                        decoration: BoxDecoration(
                          color: const Color(0xFFFBEAF0),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),

                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: _rose,
                          size: 23,
                        ),
                      ),

                      const SizedBox(width: 11),

                      Text(
                        'SantéAdo',
                        style: GoogleFonts.quicksand(
                          color: _texte,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 55),

                  // ==================================================
                  // TITRE
                  // ==================================================

                  Center(
                    child: Column(
                      children: [

                        Text(
                          'Espace professionnel',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            color: _texte,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Connectez-vous pour accéder à votre espace '
                          'd’accompagnement.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            color: _gris,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 42),

                  // ==================================================
                  // EMAIL
                  // ==================================================

                  Text(
                    'ADRESSE E-MAIL',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[500],
                      letterSpacing: 0.7,
                    ),
                  ),

                  const SizedBox(height: 9),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,

                    decoration: InputDecoration(
                      hintText: 'Ex. professionnel@email.com',

                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: _rose,
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFE8E3E5),
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFE8E3E5),
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: _rose,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // MOT DE PASSE
                  // ==================================================

                  Text(
                    'MOT DE PASSE',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[500],
                      letterSpacing: 0.7,
                    ),
                  ),

                  const SizedBox(height: 9),

                  TextField(
                    controller: _motDePasseController,
                    obscureText: !_motDePasseVisible,

                    decoration: InputDecoration(
                      hintText: 'Votre mot de passe',

                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: _rose,
                      ),

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _motDePasseVisible =
                                !_motDePasseVisible;
                          });
                        },

                        icon: Icon(
                          _motDePasseVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _gris,
                        ),
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFE8E3E5),
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFE8E3E5),
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: _rose,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // BOUTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 54,

                    child: ElevatedButton(
                      onPressed:
                          _enCours ? null : _seConnecter,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rose,
                        foregroundColor: Colors.white,
                        elevation: 3,

                        shadowColor:
                            _rose.withOpacity(0.25),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(28),
                        ),
                      ),

                      child: _enCours
                          ? const SizedBox(
                              width: 20,
                              height: 20,

                              child:
                                  CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Se connecter',
                              style:
                                  GoogleFonts.quicksand(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // INFORMATION
                  // ==================================================

                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8F4),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Icon(
                          Icons.verified_user_outlined,
                          size: 18,
                          color: Color(0xFF3F8F5F),
                        ),

                        const SizedBox(width: 9),

                        Expanded(
                          child: Text(
                            'Cet espace est réservé aux professionnels '
                            'autorisés de la plateforme.',
                            style: GoogleFonts.quicksand(
                              fontSize: 11.5,
                              height: 1.45,
                              color:
                                  const Color(0xFF3F8F5F),
                            ),
                          ),
                        ),
                      ],
                    ),
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