import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'personnalisation_screen.dart';
import 'choix_acces_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const Color _rose = Color(0xFFD4537E);
  static const Color _roseClair = Color(0xFFFBEAF0);
  static const Color _fond = Color(0xFFFFFDFB);
  static const Color _texte = Color(0xFF2D2A26);
  static const Color _gris = Color(0xFF77716F);

  bool _chargement = false;

  Future<void> _commencer() async {
    setState(() {
      _chargement = true;
    });

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PersonnalisationScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black87,
          content: Text(
            'Impossible d\'accéder à SantéAdo pour le moment.',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _chargement = false;
        });
      }
    }
  }

void _accesPersonnel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChoixAccesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _fond,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final largeur = constraints.maxWidth;
            final hauteur = constraints.maxHeight;

            final bool petitEcran = hauteur < 700;
            final bool tablette = largeur >= 600;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1100,
                ),

                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: tablette ? 55 : 24,
                    vertical: petitEcran ? 15 : 25,
                  ),

                  child: tablette
                      ? _versionTablette(
                          context,
                          largeur,
                          hauteur,
                        )
                      : _versionMobile(
                          context,
                          largeur,
                          hauteur,
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // VERSION MOBILE
  // ============================================================

  Widget _versionMobile(
    BuildContext context,
    double largeur,
    double hauteur,
  ) {
    return Column(
      children: [

        // --------------------------------------------------------
        // LOGO / NOM
        // --------------------------------------------------------

        Align(
          alignment: Alignment.centerLeft,
          child: _logo(),
        ),

        SizedBox(
          height: hauteur < 700 ? 15 : 25,
        ),

        // --------------------------------------------------------
        // IMAGE
        // --------------------------------------------------------

        Expanded(
          child: _imageJeune(
            largeur,
            hauteur,
          ),
        ),

        SizedBox(
          height: hauteur < 700 ? 12 : 20,
        ),

        // --------------------------------------------------------
        // TEXTE
        // --------------------------------------------------------

        _texteBienvenue(
          centre: true,
          petit: hauteur < 700,
        ),

        SizedBox(
          height: hauteur < 700 ? 15 : 25,
        ),

        // --------------------------------------------------------
        // BOUTON
        // --------------------------------------------------------

        _boutonCommencer(context),

        SizedBox(
          height: hauteur < 700 ? 10 : 15,
        ),

        // --------------------------------------------------------
        // ACCÈS PERSONNEL
        // --------------------------------------------------------

        _accesPersonnelLien(),
      ],
    );
  }

  // ============================================================
  // VERSION TABLETTE / GRAND ECRAN
  // ============================================================

  Widget _versionTablette(
    BuildContext context,
    double largeur,
    double hauteur,
  ) {
    return Row(
      children: [

        // --------------------------------------------------------
        // PARTIE GAUCHE : TEXTE
        // --------------------------------------------------------

        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 40,
            ),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                _logo(),

                const SizedBox(height: 55),

                _texteBienvenue(
                  centre: false,
                  petit: false,
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: 330,
                  child: _boutonCommencer(
                    context,
                  ),
                ),

                const SizedBox(height: 18),

                Align(
                  alignment: Alignment.centerLeft,
                  child: _accesPersonnelLien(),
                ),
              ],
            ),
          ),
        ),

        // --------------------------------------------------------
        // PARTIE DROITE : IMAGE
        // --------------------------------------------------------

        Expanded(
          flex: 5,
          child: _imageJeune(
            largeur * 0.45,
            hauteur,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _logo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: _roseClair,
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
    );
  }

  // ============================================================
  // IMAGE DE LA JEUNE
  // ============================================================

  Widget _imageJeune(
    double largeur,
    double hauteur,
  ) {
    final taille = largeur > 600
        ? 420.0
        : (largeur * 0.78).clamp(
            245.0,
            340.0,
          );

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [

          // ------------------------------------------------------
          // CERCLE DECORATIF
          // ------------------------------------------------------

          Container(
            width: taille,
            height: taille,

            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFBEAF0),
            ),
          ),

          // ------------------------------------------------------
          // IMAGE
          // ------------------------------------------------------

          ClipOval(
            child: SizedBox(
              width: taille * 0.88,
              height: taille * 0.88,

              child: Image.asset(
                'assets/images/welcome_girl.png',

                fit: BoxFit.cover,

                errorBuilder:
                    (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFFBEAF0),

                    child: const Icon(
                      Icons.person_outline,
                      color: _rose,
                      size: 90,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXTE DE BIENVENUE
  // ============================================================

  Widget _texteBienvenue({
    required bool centre,
    required bool petit,
  }) {
    return Column(
      crossAxisAlignment: centre
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,

      children: [

        Text(
          'Bienvenue dans',
          textAlign: centre
              ? TextAlign.center
              : TextAlign.left,

          style: GoogleFonts.quicksand(
            color: _gris,
            fontSize: petit ? 16 : 18,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'SantéAdo',
          textAlign: centre
              ? TextAlign.center
              : TextAlign.left,

          style: GoogleFonts.quicksand(
            color: _rose,
            fontSize: petit ? 30 : 38,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'Comprends ton corps,\n'
          'prends soin de toi.',
          textAlign: centre
              ? TextAlign.center
              : TextAlign.left,

          style: GoogleFonts.quicksand(
            color: _texte,
            fontSize: petit ? 22 : 28,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: centre ? 360 : 430,

          child: Text(
            'Découvre des informations fiables et '
            'adaptées à ton âge, avance à ton rythme '
            'et apprends à mieux connaître ton corps.',

            textAlign: centre
                ? TextAlign.center
                : TextAlign.left,

            style: GoogleFonts.quicksand(
              color: _gris,
              fontSize: petit ? 13 : 15,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOUTON COMMENCER
  // ============================================================

  Widget _boutonCommencer(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 54,

      child: ElevatedButton(
        onPressed: _chargement ? null : _commencer,

        style: ElevatedButton.styleFrom(
          backgroundColor: _rose,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _rose.withOpacity(0.5),

          elevation: 3,

          shadowColor:
              _rose.withOpacity(0.25),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(28),
          ),
        ),

        child: _chargement
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Text(
                    'Commencer',
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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
    );
  }

  // ============================================================
  // LIEN ACCÈS PERSONNEL
  // ============================================================

  Widget _accesPersonnelLien() {
    return TextButton(
      onPressed: _chargement ? null : _accesPersonnel,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Accès réservé au personnel',
        style: GoogleFonts.quicksand(
          color: _gris,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}