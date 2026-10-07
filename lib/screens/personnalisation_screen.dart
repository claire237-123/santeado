import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'main_navigation_screen.dart';

class PersonnalisationScreen extends StatefulWidget {
  const PersonnalisationScreen({super.key});

  @override
  State<PersonnalisationScreen> createState() =>
      _PersonnalisationScreenState();
}

class _PersonnalisationScreenState
    extends State<PersonnalisationScreen> {

  final TextEditingController _surnomController =
      TextEditingController();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

 String _teintSelectionne = 'moyen';
  static const Color _rose = Color(0xFFD4537E);
  static const Color _fond = Color(0xFFFFFDFB);
  static const Color _texte = Color(0xFF2D2A26);
  static const Color _gris = Color(0xFF77716F);

  bool _enCours = false;

  @override
  void dispose() {
    _surnomController.dispose();
    super.dispose();
  }

  Future<void> _continuer() async {
    final surnom = _surnomController.text.trim();

    if (surnom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Choisis un surnom pour continuer.',
          ),
        ),
      );
      return;
    }

    if (surnom.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ton surnom doit contenir au moins 2 caractères.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _enCours = true;
    });

    try {
      final utilisateur = await _authService.connexionAnonyme();

if (utilisateur == null) {
  throw Exception('Impossible de créer une session anonyme.');
}

final uid = utilisateur.uid;

await _firestoreService.creerProfil(
  uid,
  surnom: _surnomController.text,
  langue: 'fr',
  avatar: {
    'teint': _teintSelectionne,
  },
);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _enCours = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de créer ton profil : $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fond,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 28,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

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
                          Icons.favorite_border,
                          color: _rose,
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

                  const Spacer(),

                  // ==================================================
                  // TITRE
                  // ==================================================

                  Center(
                    child: Column(
                      children: [

                        Text(
                          'Comment souhaites-tu',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            color: _texte,
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'être appelée ?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            color: _rose,
                            fontSize: 29,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          'Choisis un surnom pour ton expérience '
                          'SantéAdo.',
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

                  // ==================================================
                  // SURNOM
                  // ==================================================

                  Text(
                    'TON SURNOM',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[500],
                      letterSpacing: 0.7,
                    ),
                  ),

                  const SizedBox(height: 9),

                  TextField(
                    controller: _surnomController,

                    maxLength: 20,

                    textCapitalization:
                        TextCapitalization.words,

                    decoration: InputDecoration(
                      hintText: 'Ex. Aline',

                      counterText: '',

                      prefixIcon: const Icon(
                        Icons.person_outline,
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

                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),

                        borderSide: const BorderSide(
                          color: Color(0xFFE8E3E5),
                        ),
                      ),

                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),

                        borderSide: const BorderSide(
                          color: _rose,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // CONFIDENTIALITÉ
                  // ==================================================

                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.symmetric(
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

                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.lock_outline,
                            size: 17,
                            color: Color(0xFF3F8F5F),
                          ),
                        ),

                        const SizedBox(width: 9),

                        Expanded(
                          child: Text(
                            'Ton profil reste anonyme. '
                            'Aucune information personnelle '
                            'n’est demandée.',
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

                  const Spacer(),

                  // ==================================================
                  // BOUTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 54,

                    child: ElevatedButton(
                      onPressed:
                          _enCours ? null : _continuer,

                      style:
                          ElevatedButton.styleFrom(
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
                          : Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [

                                Text(
                                  'Continuer',
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

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}