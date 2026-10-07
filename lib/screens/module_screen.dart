import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/module.dart';
import '../models/progress.dart';
import '../services/firestore_service.dart';
import 'thematiques_screen.dart';

class ModuleScreen extends StatefulWidget {
  final Module module;

  const ModuleScreen({super.key, required this.module});

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  late Future<Map<String, Progress>> _progressFuture;

  // CORRIGÉ : parsing protégé, comme dans EtapeScreen. Sans try/catch,
  // un module dont le champ 'couleur' est vide ou mal formé (saisi à la
  // main par l'admin) faisait planter tout l'écran avec un FormatException.
  Color get _couleurModule {
    try {
      return Color(
        int.parse(
          widget.module.couleur.replaceFirst('#', '0xFF'),
        ),
      );
    } catch (_) {
      switch (widget.module.ordre) {
        case 1:
          return const Color(0xFF8AD5BA);
        case 2:
          return const Color(0xFFF4A69A);
        case 3:
          return const Color(0xFFF4C17E);
        default:
          return const Color(0xFFD4537E);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _chargerProgression();
  }

  void _chargerProgression() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      _progressFuture = Future.value(<String, Progress>{});
      return;
    }

    _progressFuture = _firestoreService.getProgressModule(
      uid,
      widget.module.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final couleurModule = _couleurModule;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFB),
      body: Column(
        children: [
          // En-tête coloré
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  couleurModule.withOpacity(0.9),
                  couleurModule.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.module.sousTitre,
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.module.description,
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 18),

                // CORRIGÉ : progression réelle calculée à partir de la
                // collection 'progress' de l'utilisatrice, au lieu de la
                // valeur figée à 0.4 pour tout le monde.
                FutureBuilder<Map<String, Progress>>(
                  future: _progressFuture,
                  builder: (context, snapshot) {
                    final progressions = snapshot.data ?? {};

                    final total = widget.module.nombreThematiques;

                    final terminees = progressions.values
                        .where((p) => p.statut == 'termine')
                        .length;

                    final fraction =
                        total > 0 ? (terminees / total).clamp(0.0, 1.0) : 0.0;

                    return Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: fraction,
                              minHeight: 6,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$terminees/$total',
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Corps de l'écran
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.module.nombreThematiques} thématiques',
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ThematiquesScreen(module: widget.module),
                          ),
                        ).then((_) {
                          // Au retour du parcours, la progression a pu
                          // changer : on la recharge.
                          setState(_chargerProgression);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: couleurModule,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Continuer',
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}