import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'connexion_professionnel_screen.dart';
import 'connexion_administrateur_screen.dart';

class ChoixAccesScreen extends StatelessWidget {
  const ChoixAccesScreen({super.key});

  static const Color _rose = Color(0xFFD4537E);
  static const Color _roseClair = Color(0xFFFBEAF0);
  static const Color _fond = Color(0xFFFFFDFB);
  static const Color _texte = Color(0xFF2D2A26);
  static const Color _gris = Color(0xFF77716F);
  static const Color _vert = Color(0xFF3F8F5F);
  static const Color _vertClair = Color(0xFFF1F8F4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fond,
      appBar: AppBar(
        backgroundColor: _fond,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: _texte,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tablette = constraints.maxWidth >= 650;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: tablette ? 70 : 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 850,
                  ),
                  child: Column(
                    children: [
                      _entete(),

                      const SizedBox(height: 38),

                      if (tablette)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _carteProfessionnel(context),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _carteAdministrateur(context),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _carteProfessionnel(context),
                            const SizedBox(height: 18),
                            _carteAdministrateur(context),
                          ],
                        ),

                      const SizedBox(height: 25),

                      _informationSecurite(),
                    ],
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
  // EN-TÊTE
  // ============================================================

  Widget _entete() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _roseClair,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.business_center_outlined,
            color: _rose,
            size: 30,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Accès professionnel',
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
            color: _texte,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'Sélectionnez l’espace correspondant à votre rôle '
          'sur la plateforme.',
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
            color: _gris,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARTE PROFESSIONNEL
  // ============================================================

  Widget _carteProfessionnel(BuildContext context) {
    return _carteAcces(
      icon: Icons.medical_services_outlined,
      iconColor: _rose,
      iconBackground: _roseClair,
      titre: 'Professionnel d’accompagnement',
      description:
          'Accédez à votre espace pour consulter les demandes '
          'd’accompagnement et analyser les situations qui vous '
          'sont confiées.',
      bouton: 'Accéder à l’espace',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ConnexionProfessionnelScreen(),
          ),
        );
      },
    );
  }

  // ============================================================
  // CARTE ADMINISTRATEUR
  // ============================================================

  Widget _carteAdministrateur(BuildContext context) {
  return _carteAcces(
    icon: Icons.admin_panel_settings_outlined,
    iconColor: _vert,
    iconBackground: _vertClair,
    titre: 'Administrateur',
    description:
        'Gérez les utilisateurs, les contenus éducatifs, '
        'les activités et les statistiques de la plateforme.',
    bouton: 'Accéder à l’administration',
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ConnexionAdministrateurScreen(),
        ),
      );
    },
  );
}

  // ============================================================
  // CARTE GENERIQUE
  // ============================================================

  Widget _carteAcces({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String titre,
    required String description,
    required String bouton,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEAE5E7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Accès sécurisé',
                  style: GoogleFonts.quicksand(
                    color: _gris,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            titre,
            style: GoogleFonts.quicksand(
              color: _texte,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            description,
            style: GoogleFonts.quicksand(
              color: _gris,
              fontSize: 13,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: iconColor.withOpacity(0.20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bouton,
                    style: GoogleFonts.quicksand(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 17,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION SECURITE
  // ============================================================

  Widget _informationSecurite() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline,
            color: _gris,
            size: 19,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Les espaces professionnels sont accessibles '
              'uniquement aux comptes autorisés.',
              style: GoogleFonts.quicksand(
                color: _gris,
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}