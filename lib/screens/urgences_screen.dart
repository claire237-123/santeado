import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class UrgencesScreen extends StatelessWidget {
  const UrgencesScreen({super.key});

  static const Color _rose = Color(0xFFD4537E);
  static const Color _fond = Color(0xFFFFF9FB);
  static const Color _texte = Color(0xFF292525);
  static const Color _secondaire = Color(0xFF6F696C);

  Future<void> _appeler(String numero) async {
    final uri = Uri(scheme: 'tel', path: numero);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fond,
      appBar: AppBar(
        backgroundColor: _fond,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Urgences & aide',
          style: GoogleFonts.quicksand(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: _texte,
          ),
        ),
        iconTheme: const IconThemeData(
          color: _texte,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroduction(),

              const SizedBox(height: 22),

              Text(
                'Contacts d’urgence',
                style: GoogleFonts.quicksand(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _texte,
                ),
              ),

              const SizedBox(height: 12),

              _buildContactCard(
                icon: Icons.local_police_outlined,
                title: 'Police secours',
                description:
                    'En cas de danger, agression ou problème de sécurité.',
                numero: '117',
                numeroSecondaire: '17',
              ),

              _buildContactCard(
                icon: Icons.shield_outlined,
                title: 'Gendarmerie',
                description:
                    'Pour les situations nécessitant l’intervention de la gendarmerie.',
                numero: '113',
                numeroSecondaire: '13',
              ),

              _buildContactCard(
                icon: Icons.local_fire_department_outlined,
                title: 'Sapeurs-pompiers',
                description:
                    'Incendie, accident ou personne en situation de danger.',
                numero: '118',
                numeroSecondaire: '18',
              ),

              _buildContactCard(
                icon: Icons.medical_services_outlined,
                title: 'SAMU',
                description:
                    'Pour une situation nécessitant une assistance médicale urgente.',
                numero: '119',
                numeroSecondaire: '19',
              ),

              const SizedBox(height: 18),

              _buildConseil(),

              const SizedBox(height: 18),

              Text(
                'Source',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _secondaire,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Numéros utiles publiés par le Ministère de '
                'l’Administration Territoriale du Cameroun (MINAT).',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  height: 1.5,
                  color: _secondaire,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE8EF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF2CCD8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency_outlined,
              color: _rose,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Besoin d’aide rapidement ?',
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _texte,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Retrouve ici quelques contacts utiles en cas '
                  'd’urgence ou de danger.',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    height: 1.45,
                    color: _secondaire,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String description,
    required String numero,
    required String numeroSecondaire,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFEDE6E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFBE8EF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: _rose,
              size: 25,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _texte,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    height: 1.35,
                    color: _secondaire,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mobile : $numero  •  Fixe : $numeroSecondaire',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _rose,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Material(
            color: _rose,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () => _appeler(numero),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.phone_in_talk_outlined,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConseil() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDDE7E3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFF176B5B),
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'En cas de danger immédiat, mets-toi si possible '
              'dans un endroit sûr et contacte le service approprié.',
              style: GoogleFonts.quicksand(
                fontSize: 11,
                height: 1.45,
                color: const Color(0xFF4F5D58),
              ),
            ),
          ),
        ],
      ),
    );
  }
}