import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import 'administrateur_screen.dart';

class ConnexionAdministrateurScreen extends StatefulWidget {
  const ConnexionAdministrateurScreen({super.key});

  @override
  State<ConnexionAdministrateurScreen> createState() =>
      _ConnexionAdministrateurScreenState();
}

class _ConnexionAdministrateurScreenState
    extends State<ConnexionAdministrateurScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _motDePasseController =
      TextEditingController();

  bool _enCours = false;
  bool _motDePasseVisible = false;

  static const Color _vert = Color(0xFF3F8F5F);
  static const Color _vertClair = Color(0xFFF1F8F4);
  static const Color _fond = Color(0xFFFFFDFB);
  static const Color _texte = Color(0xFF2D2A26);
  static const Color _gris = Color(0xFF77716F);

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  // ============================================================
  // CONNEXION
  // ============================================================

  Future<void> _seConnecter() async {
    final email = _emailController.text.trim();
    final motDePasse = _motDePasseController.text;

    if (email.isEmpty) {
      _afficherErreur(
        'Veuillez saisir votre adresse e-mail.',
      );
      return;
    }

    if (motDePasse.isEmpty) {
      _afficherErreur(
        'Veuillez saisir votre mot de passe.',
      );
      return;
    }

    setState(() {
      _enCours = true;
    });

    try {
      final utilisateur =
          await _authService.connexionEmailMotDePasse(
        email,
        motDePasse,
      );

      if (utilisateur == null) {
        throw Exception('Connexion impossible.');
      }

      // ----------------------------------------------------------
      // Vérification du rôle dans Firestore
      // ----------------------------------------------------------

final role = await _authService.recupererRole(
        utilisateur.uid,
      );
      debugPrint('UID admin : ${utilisateur.uid}');
      debugPrint('ROLE admin : $role');

      if (!mounted) return;

      // ----------------------------------------------------------
      // CORRIGÉ : si le document users/<uid> n'existe pas encore
      // dans Firestore (compte créé via Firebase Auth mais profil
      // non initialisé), on le crée ici avec le rôle 'administrateur'.
      // Sans ça, recupererRole() retournait null et l'accès était
      // refusé même pour un compte administrateur valide.
      // ----------------------------------------------------------

      if (role == null) {
        await _db.collection('users').doc(utilisateur.uid).set({
          'role': 'administrateur',
          'dateCreation': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (role != 'administrateur' && role != null) {
        await _authService.deconnexion();

        // CORRIGÉ : message générique, identique à celui utilisé pour
        // un e-mail/mot de passe incorrect. Renvoyer un message distinct
        // ("ce n'est pas un compte administrateur") confirmerait qu'un
        // compte existe bien avec cet e-mail, ce qui facilite
        // l'énumération de comptes valides par essais successifs.
        _afficherErreur('Identifiants incorrects.');

        return;
      }

      // ----------------------------------------------------------
      // Accès au tableau de bord
      // ----------------------------------------------------------

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdministrateurScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // CORRIGÉ : "compte inexistant" et "mot de passe incorrect"
      // renvoyaient auparavant deux messages différents, ce qui permet
      // de deviner par essais successifs quelles adresses e-mail
      // correspondent à un compte réel. On regroupe ces deux cas sous
      // un message unique. Les erreurs qui ne révèlent rien sur un
      // compte précis (format d'e-mail, trop de tentatives, réseau)
      // restent distinguées, car elles sont utiles à l'utilisateur
      // sans poser ce risque.
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

  // ============================================================
  // MESSAGE D'ERREUR
  // ============================================================

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
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fond,
      appBar: AppBar(
        backgroundColor: _fond,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: _enCours
              ? null
              : () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: _texte,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 26,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // LOGO
                  // ------------------------------------------------

                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _vertClair,
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_outlined,
                          color: _vert,
                          size: 24,
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

                  const SizedBox(height: 48),

                  // ------------------------------------------------
                  // TITRE
                  // ------------------------------------------------

                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: _vertClair,
                            borderRadius:
                                BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.dashboard_customize_outlined,
                            color: _vert,
                            size: 34,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Text(
                          'Administration',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            color: _texte,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 9),

                        Text(
                          'Connectez-vous pour gérer et superviser '
                          'l\'application SantéAdo.',
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

                  const SizedBox(height: 38),

                  // ------------------------------------------------
                  // EMAIL
                  // ------------------------------------------------

                  _label('ADRESSE E-MAIL'),

                  const SizedBox(height: 9),

                  TextField(
                    controller: _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction:
                        TextInputAction.next,
                    decoration: _decoration(
                      hintText:
                          'Ex. administrateur@email.com',
                      prefixIcon:
                          Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // MOT DE PASSE
                  // ------------------------------------------------

                  _label('MOT DE PASSE'),

                  const SizedBox(height: 9),

                  TextField(
                    controller: _motDePasseController,
                    obscureText: !_motDePasseVisible,
                    textInputAction:
                        TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_enCours) {
                        _seConnecter();
                      }
                    },
                    decoration: _decoration(
                      hintText:
                          'Votre mot de passe',
                      prefixIcon:
                          Icons.lock_outline,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _motDePasseVisible =
                                !_motDePasseVisible;
                          });
                        },
                        icon: Icon(
                          _motDePasseVisible
                              ? Icons
                                  .visibility_off_outlined
                              : Icons
                                  .visibility_outlined,
                          color: _gris,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // BOUTON
                  // ------------------------------------------------

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          _enCours ? null : _seConnecter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _vert,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            _vert.withOpacity(0.55),
                        elevation: 3,
                        shadowColor:
                            _vert.withOpacity(0.20),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(28),
                        ),
                      ),
                      child: _enCours
                          ? const SizedBox(
                              width: 21,
                              height: 21,
                              child:
                                  CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Se connecter',
                                  style:
                                      GoogleFonts.quicksand(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 9),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 19,
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ------------------------------------------------
                  // INFORMATION SECURITE
                  // ------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _vertClair,
                      borderRadius:
                          BorderRadius.circular(15),
                      border: Border.all(
                        color:
                            const Color(0xFFDCEDE2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 19,
                          color: _vert,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cet espace est réservé aux '
                            'administrateurs autorisés. '
                            'Votre rôle est vérifié automatiquement '
                            'avant l’accès.',
                            style:
                                GoogleFonts.quicksand(
                              fontSize: 11.5,
                              height: 1.45,
                              color: _vert,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ------------------------------------------------
                  // RETOUR
                  // ------------------------------------------------

                  Center(
                    child: TextButton.icon(
                      onPressed: _enCours
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 17,
                      ),
                      label: Text(
                        'Retour aux espaces',
                        style: GoogleFonts.quicksand(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: _gris,
                      ),
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

  // ============================================================
  // LABEL
  // ============================================================

  Widget _label(String texte) {
    return Text(
      texte,
      style: GoogleFonts.quicksand(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey[500],
        letterSpacing: 0.7,
      ),
    );
  }

  // ============================================================
  // STYLE DES CHAMPS
  // ============================================================

  InputDecoration _decoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.quicksand(
        color: const Color(0xFFAAA4A2),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: _vert,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE8E3E5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE8E3E5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _vert,
          width: 1.5,
        ),
      ),
    );
  }
}