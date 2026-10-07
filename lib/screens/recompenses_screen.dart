import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import '../services/firestore_service.dart';

class RecompensesScreen extends StatefulWidget {
  const RecompensesScreen({super.key});

  @override
  State<RecompensesScreen> createState() => _RecompensesScreenState();
}

class _RecompensesScreenState extends State<RecompensesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ============================================================
  // NIVEAU CALCULÉ À PARTIR DES POINTS
  // ============================================================
  //
  // NOTE IMPORTANTE : firestore_service.dart (marquerThematiqueTerminee)
  // incrémente déjà 'points' sur users/{uid}, mais ne met JAMAIS à jour
  // 'niveau' ni 'titreNiveau'. Ces deux champs restent donc figés à leur
  // valeur de création (1 / 'Débutante') si on les lit tels quels.
  // Pour ne rien casser côté Firestore, on calcule ici le niveau à la
  // volée à partir des points réels, plutôt que de faire confiance aux
  // champs stockés. À terme, il serait plus propre de faire calculer et
  // stocker 'niveau'/'titreNiveau' côté service à chaque incrément.

  static const List<_Palier> _paliers = [
    _Palier(seuil: 0, titre: 'Débutante'),
    _Palier(seuil: 100, titre: 'Curieuse'),
    _Palier(seuil: 250, titre: 'Confiante'),
    _Palier(seuil: 500, titre: 'Experte'),
  ];

  _NiveauCalcule _calculerNiveau(int points) {
    _Palier palierActuel = _paliers.first;
    _Palier? palierSuivant;

    for (int i = 0; i < _paliers.length; i++) {
      if (points >= _paliers[i].seuil) {
        palierActuel = _paliers[i];
        palierSuivant = (i + 1 < _paliers.length) ? _paliers[i + 1] : null;
      }
    }

    final seuilBas = palierActuel.seuil;
    final seuilHaut = palierSuivant?.seuil;

    final fraction = seuilHaut == null
        ? 1.0
        : ((points - seuilBas) / (seuilHaut - seuilBas)).clamp(0.0, 1.0);

    return _NiveauCalcule(
      titre: palierActuel.titre,
      fraction: fraction,
      pointsRestants: seuilHaut == null ? 0 : seuilHaut - points,
      seuilSuivant: seuilHaut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Mes récompenses',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: uid == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'Session introuvable. Reconnecte-toi pour voir tes récompenses.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF888888)),
                ),
              ),
            )
          : StreamBuilder<UserProfile?>(
              stream: _firestoreService.getUserProfile(uid),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    !profileSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD4537E),
                    ),
                  );
                }

                final profile = profileSnapshot.data;
                final points = profile?.points ?? 0;
                final niveau = _calculerNiveau(points);

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  // Toutes les thématiques terminées, tous modules
                  // confondus, pour calculer les badges de progression.
                  stream: _db
                      .collection('progress')
                      .where('uid', isEqualTo: uid)
                      .where('statut', isEqualTo: 'termine')
                      .snapshots(),
                  builder: (context, progressSnapshot) {
                    final nombreTerminees =
                        progressSnapshot.data?.docs.length ?? 0;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Continue ton parcours pour gagner des points '
                            'et débloquer de nouvelles récompenses.',
                            style: TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 25),
                          _cartePoints(points),
                          const SizedBox(height: 20),
                          _carteNiveau(niveau),
                          const SizedBox(height: 30),
                          const Text(
                            'Mes badges',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Accomplis des activités pour débloquer des badges.',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _badgeCard(
                            icon: Icons.flag_outlined,
                            title: 'Premiers pas',
                            description: 'Terminer ta première thématique',
                            unlocked: nombreTerminees >= 1,
                          ),
                          const SizedBox(height: 12),
                          _badgeCard(
                            icon: Icons.menu_book_outlined,
                            title: 'Curieuse',
                            description: 'Terminer 3 thématiques',
                            unlocked: nombreTerminees >= 3,
                          ),
                          const SizedBox(height: 12),
                          // NOTE : ces deux badges étaient à l'origine
                          // liés à des thématiques précises (hygiène,
                          // cycle menstruel). Comme les documents
                          // 'progress' ne stockent pas le sujet de la
                          // thématique, on les débloque ici sur un
                          // palier de progression générale (5 et 7
                          // thématiques terminées) en attendant un
                          // système de tags par thématique côté admin.
                          _badgeCard(
                            icon: Icons.favorite_border,
                            title: 'Je prends soin de moi',
                            description: 'Continuer régulièrement son parcours',
                            unlocked: nombreTerminees >= 5,
                          ),
                          const SizedBox(height: 12),
                          _badgeCard(
                            icon: Icons.water_drop_outlined,
                            title: 'Je comprends mon cycle',
                            description: 'Avoir terminé 7 thématiques',
                            unlocked: nombreTerminees >= 7,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _cartePoints(int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFEFD7E0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.star_outline,
              color: Color(0xFFD4537E),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mes points',
                  style: TextStyle(color: Color(0xFF555555), fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '$points points',
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteNiveau(_NiveauCalcule niveau) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEDFE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mon niveau',
                style: TextStyle(color: Color(0xFF555555), fontSize: 15),
              ),
              Text(
                niveau.titre,
                style: const TextStyle(
                  color: Color(0xFFD4537E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: niveau.fraction,
              minHeight: 9,
              backgroundColor: const Color(0xFFF0E5E9),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFD4537E),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            niveau.seuilSuivant == null
                ? 'Niveau maximum atteint pour le moment.'
                : 'Encore ${niveau.pointsRestants} points pour atteindre le niveau suivant',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
          ),
        ],
      ),
    );
  }

  static Widget _badgeCard({
    required IconData icon,
    required String title,
    required String description,
    required bool unlocked,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : const Color(0xFFF5F2F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDFE5)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: unlocked
                  ? const Color(0xFFF8E6ED)
                  : const Color(0xFFE9E5E6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              unlocked ? icon : Icons.lock_outline,
              color: unlocked ? const Color(0xFFD4537E) : const Color(0xFF999999),
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: unlocked
                        ? const Color(0xFF333333)
                        : const Color(0xFF888888),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Palier {
  final int seuil;
  final String titre;

  const _Palier({required this.seuil, required this.titre});
}

class _NiveauCalcule {
  final String titre;
  final double fraction;
  final int pointsRestants;
  final int? seuilSuivant;

  const _NiveauCalcule({
    required this.titre,
    required this.fraction,
    required this.pointsRestants,
    required this.seuilSuivant,
  });
}