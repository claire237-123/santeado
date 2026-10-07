import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';
import '../models/module.dart';
import '../models/user_profile.dart';
import 'thematiques_screen.dart';
import 'urgences_screen.dart';
import 'assistant_ia_screen.dart';
import 'demande_accompagnement_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _rose = Color(0xFFD4537E);
  static const Color _fond = Color(0xFFFFF9FB);

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Session utilisateur introuvable.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _fond,

      body: SafeArea(
        child: StreamBuilder<UserProfile?>(
          stream: firestoreService.getUserProfile(user.uid),

          builder: (context, profilSnapshot) {
            if (profilSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _rose,
                ),
              );
            }

            if (profilSnapshot.hasError) {
              return Center(
                child: Text(
                  'Erreur : ${profilSnapshot.error}',
                ),
              );
            }

            final profil = profilSnapshot.data;

            if (profil == null) {
              return const Center(
                child: Text(
                  'Profil introuvable.',
                ),
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 430,
                ),

                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    100,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      _buildHeader(profil),

                      const SizedBox(height: 20),

                      // CORRIGÉ : progression réelle (voir
                      // _buildProgressCard) au lieu de 0.80 figé.
                      _buildProgressCard(profil, user.uid, firestoreService),

                      const SizedBox(height: 24),

                      _buildSectionTitle(),

                      const SizedBox(height: 12),

                      _buildModules(context, firestoreService),

                      const SizedBox(height: 16),

                      _buildRewardsCard(profil),

                      const SizedBox(height: 16),

                      _buildUrgencesButton(context),

                      const SizedBox(height: 16),
                      _buildAccompagnementButton(context),

                      const SizedBox(height: 20),
                      
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // CORRIGÉ : le bouton IA n'avait aucun onTap -- un point d'entrée
      // mort vers une fonctionnalité clé du cahier des charges. Il n'y
      // a pour l'instant aucun écran de chat Flutter à ouvrir (seul le
      // backend FastAPI existe), donc on affiche un message clair
      // plutôt que de laisser croire que la fonctionnalité marche.
      // À remplacer par une vraie navigation dès que l'écran de chat
      // existe.
      floatingActionButton: _buildAiButton(context),
    );
  }

  Widget _buildUrgencesButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const UrgencesScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9DDE1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFBE8EF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.emergency_outlined,
                color: _rose,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Urgences & aide',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF292525),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Accéder rapidement aux contacts utiles',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF9A9295),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccompagnementButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () {
         Navigator.push(
          context,
        MaterialPageRoute(
          builder: (_) => const DemandeAccompagnementScreen(),
    ),
  );

        // Écran de demande d'accompagnement à créer
      },
      icon: const Icon(Icons.support_agent_outlined),
      label: const Text(
        'Demander un accompagnement',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: _rose,
        side: const BorderSide(color: _rose),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}

  Widget _buildHeader(UserProfile profil) {
    final surnom = profil.surnom.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                surnom.isEmpty ? 'Bonjour 👋' : 'Bonjour, $surnom 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF292525),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Prête à continuer ton parcours ?',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEDE6E8)),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_none,
                  color: Color(0xFF3E393B),
                  size: 25,
                ),
              ),
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: _rose,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _buildAvatar(profil.teintAvatar, size: 52),
      ],
    );
  }

  Widget _buildAvatar(String teint, {double size = 52}) {
    final teints = {
      'clair': const Color(0xFFF4C9A8),
      'moyen': const Color(0xFFC68863),
      'fonce': const Color(0xFF7A4B32),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: teints[teint] ?? teints['moyen'],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.face_retouching_natural,
        size: size * 0.48,
        color: Colors.white,
      ),
    );
  }

  // ================================================================
  // CARTE PROGRESSION (CORRIGÉE)
  // ================================================================
  //
  // Avant : 'const double progression = 0.80;' -- valeur figée pour
  // toutes les utilisatrices. Désormais calculée à partir de deux
  // sources réelles : le nombre total de thématiques dans les modules
  // publiés ('publie'), et le nombre de thématiques que
  // l'utilisatrice a effectivement terminées (collection 'progress').
  // Le doublon "Niveau X" affiché deux fois dans la carte d'origine a
  // aussi été retiré -- la seconde ligne indique maintenant le nombre
  // de thématiques terminées, plus utile que répéter le niveau.

  Widget _buildProgressCard(
    UserProfile profil,
    String uid,
    FirestoreService firestoreService,
  ) {
    final db = FirebaseFirestore.instance;

    return StreamBuilder<List<Module>>(
      stream: firestoreService.getModules(),
      builder: (context, modulesSnapshot) {
        final modules = modulesSnapshot.data ?? [];
        debugPrint(
  'MODULES : ${modules.length}',
);

for (final module in modules) {
  debugPrint(
    'MODULE : ${module.titre} | '
    'statut=${module.statut} | '
    'nombreThematiques=${module.nombreThematiques}',
  );
}

        final totalThematiques = modules
            .where((m) => m.statut == 'publie')
            .fold<int>(0, (total, m) => total + m.nombreThematiques);
            debugPrint(
  'TOTAL THEMATIQUES : $totalThematiques',
);

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: db
              .collection('progress')
              .where('uid', isEqualTo: uid)
              .where('statut', isEqualTo: 'termine')
              .snapshots(),
          builder: (context, progressSnapshot) {
            if (progressSnapshot.hasError) {
  return Text(
    'Erreur progression : ${progressSnapshot.error}',
    style: const TextStyle(color: Colors.red),
  );
}
            final terminees = progressSnapshot.data?.docs.length ?? 0;

            final progression = totalThematiques > 0
                ? (terminees / totalThematiques).clamp(0.0, 1.0)
                : 0.0;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDF2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFCCD9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ta progression',
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF332C2F),
                        ),
                      ),
                      Text(
                        'Niveau ${profil.niveau}',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF993556),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalThematiques > 0
                            ? '$terminees/$totalThematiques thématiques'
                            : 'Aucun contenu disponible pour le moment',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${(progression * 100).round()} %',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF332C2F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progression,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFB83D80),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Mes modules',
          style: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF292525),
          ),
        ),
        Text(
          'Voir tout',
          style: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _rose,
          ),
        ),
      ],
    );
  }

  Widget _buildModules(
    BuildContext context,
    FirestoreService service,
  ) {
    return StreamBuilder<List<Module>>(
      stream: service.getModules(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Erreur : ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: _rose),
          );
        }

        final modules = snapshot.data!;

        if (modules.isEmpty) {
          return _buildEmptyModules();
        }

        return Column(
          children: modules.map((module) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildModuleCard(context, module),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildModuleCard(BuildContext context, Module module) {
    final couleur = _getModuleColor(module);
    final publie = module.statut == 'publie';
    final numero = module.ordre;
    final icon = _getModuleIcon(module);

    return GestureDetector(
      onTap: publie
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ThematiquesScreen(module: module),
                ),
              );
            }
          : null,
      child: Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: couleur.withOpacity(publie? 0.14 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: couleur.withOpacity(0.45)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: couleur.withOpacity(0.38),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '$numero',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF302C2D),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.sousTitre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.quicksand(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E292B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    module.titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.quicksand(
                      fontSize: 10.5,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                publie ? icon : Icons.lock_outline,
                size: 24,
                color: publie ? couleur : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getModuleColor(Module module) {
    try {
      return Color(
        int.parse(module.couleur.replaceFirst('#', '0xFF')),
      );
    } catch (_) {
      switch (module.ordre) {
        case 1:
          return const Color(0xFF8AD5BA);
        case 2:
          return const Color(0xFFF4A69A);
        case 3:
          return const Color(0xFFF4C17E);
        default:
          return _rose;
      }
    }
  }

  IconData _getModuleIcon(Module module) {
    final texte = '${module.titre} ${module.sousTitre}'.toLowerCase();

    if (texte.contains('corps') || texte.contains('pubert')) {
      return Icons.accessibility_new;
    }

    if (texte.contains('cycle') || texte.contains('saignement')) {
      return Icons.water_drop_outlined;
    }

    if (texte.contains('sexual') || texte.contains('prévention')) {
      return Icons.lock_outline;
    }

    return Icons.menu_book_outlined;
  }

  Widget _buildEmptyModules() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE6E8)),
      ),
      child: Text(
        'Les modules arrivent bientôt.',
        textAlign: TextAlign.center,
        style: GoogleFonts.quicksand(
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildRewardsCard(UserProfile profil) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1D8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5D7A3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Color(0xFFE4A51C),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mes récompenses',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${profil.points} pts',
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB26A00),
                  ),
                ),
                Text(
                  'Niveau ${profil.niveau}',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Text('🎁', style: TextStyle(fontSize: 29)),
        ],
      ),
    );
  }

  Widget _buildAiButton(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AssistantIAScreen(),
        ),
      );
    },
    child: Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF302E2F),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.smart_toy_outlined,
        color: Colors.white,
        size: 28,
      ),
    ),
  );
}
}