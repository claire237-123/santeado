import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/module.dart';
import '../models/thematique.dart';
import '../models/progress.dart';
import '../services/firestore_service.dart';
import 'etape_screen.dart';

class ThematiquesScreen extends StatefulWidget {
  final Module module;

  const ThematiquesScreen({
    super.key,
    required this.module,
  });

  @override
  State<ThematiquesScreen> createState() => _ThematiquesScreenState();
}

class _ThematiquesScreenState extends State<ThematiquesScreen> {
  // ---------------------------------------------------------------------------
  // SERVICES
  // ---------------------------------------------------------------------------

  final FirestoreService _firestoreService = FirestoreService();
  final FlutterTts _flutterTts = FlutterTts();

  // ---------------------------------------------------------------------------
  // ÉTAT
  // ---------------------------------------------------------------------------

  late Future<Map<String, Progress>> _progressFuture;

  bool _chargement = true;

  // ---------------------------------------------------------------------------
  // COULEURS
  // ---------------------------------------------------------------------------

  static const Color _fond = Color(0xFFFFFDFB);
  static const Color _texte = Color(0xFF2D2D32);
  static const Color _texteSecondaire = Color(0xFF74747D);

  static const Color _rose = Color(0xFFD4537E);
  static const Color _roseClair = Color(0xFFFBE8EF);

  static const Color _vert = Color(0xFF176B5B);
  static const Color _vertClair = Color(0xFFE6F3EF);

  static const Color _bordure = Color(0xFFE9E5E7);

  // ---------------------------------------------------------------------------
  // INITIALISATION
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _initialiserTts();
    _chargerProgression();
  }

  Future<void> _initialiserTts() async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
  }

  // ---------------------------------------------------------------------------
  // PROGRESSION
  // ---------------------------------------------------------------------------

  void _chargerProgression() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      if (!mounted) return;

      setState(() {
        _chargement = false;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _chargement = true;

        _progressFuture = _firestoreService.getProgressModule(
          uid,
          widget.module.id,
        );
      });
    } else {
      _progressFuture = _firestoreService.getProgressModule(
        uid,
        widget.module.id,
      );
    }

    _progressFuture.whenComplete(() {
      if (!mounted) return;

      setState(() {
        _chargement = false;
      });
    });
  }

  // ---------------------------------------------------------------------------
  // RECHARGER LES THÉMATIQUES
  // ---------------------------------------------------------------------------

  void _rechargerThematiques() {
    if (!mounted) return;

    // On reconstruit le StreamBuilder afin de relancer
    // la récupération des données Firestore.
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // LECTURE VOCALE
  // ---------------------------------------------------------------------------

  Future<void> _lireTitre(String texte) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(texte);
    } catch (_) {
      // On ne bloque pas l'application si la synthèse vocale échoue.
    }
  }

  // ---------------------------------------------------------------------------
  // ICÔNES DES THÉMATIQUES
  // ---------------------------------------------------------------------------

  IconData _iconeThematique(String titre) {
    final t = titre.toLowerCase();

    if (t.contains('pubert') ||
        t.contains('corps') ||
        t.contains('comprendre')) {
      return Icons.accessibility_new_rounded;
    }

    if (t.contains('cycle') ||
        t.contains('menstru') ||
        t.contains('règle') ||
        t.contains('regle') ||
        t.contains('saign')) {
      return Icons.calendar_month_rounded;
    }

    if (t.contains('sexual') ||
        t.contains('prévention') ||
        t.contains('prevention') ||
        t.contains('contraception') ||
        t.contains('ist')) {
      return Icons.health_and_safety_rounded;
    }

    if (t.contains('grossesse')) {
      return Icons.favorite_border_rounded;
    }

    if (t.contains('maman') || t.contains('matern')) {
      return Icons.family_restroom_rounded;
    }

    if (t.contains('hygiène') || t.contains('hygiene')) {
      return Icons.spa_rounded;
    }

    if (t.contains('intimit')) {
      return Icons.lock_outline_rounded;
    }

    if (t.contains('internet')) {
      return Icons.language_rounded;
    }

    if (t.contains('aide')) {
      return Icons.support_agent_rounded;
    }

    return Icons.menu_book_rounded;
  }

  // ---------------------------------------------------------------------------
  // COULEUR DE L'ICÔNE
  // ---------------------------------------------------------------------------

  Color _couleurIcone({
    required bool accessible,
    required bool terminee,
  }) {
    if (terminee) {
      return _vert;
    }

    if (accessible) {
      return _rose;
    }

    return _texteSecondaire;
  }

  // ---------------------------------------------------------------------------
  // VÉRIFICATION DE L'ACCÈS
  // ---------------------------------------------------------------------------

  bool _estAccessible({
    required int index,
    required List<Thematique> thematiques,
    required Map<String, Progress> progressions,
  }) {
    // La première thématique est toujours accessible.
    if (index == 0) {
      return true;
    }

    // Pour les suivantes :
    // la thématique précédente doit être terminée.
    final precedente = thematiques[index - 1];

    final progressionPrecedente = progressions[precedente.id];

    return progressionPrecedente?.statut == 'termine';
  }

  // ---------------------------------------------------------------------------
  // OUVRIR UNE THÉMATIQUE
  // ---------------------------------------------------------------------------

  Future<void> _ouvrirThematique(Thematique thematique) async {
    await _lireTitre(thematique.titre);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EtapeScreen(
          module: widget.module,
          thematique: thematique,
        ),
      ),
    );

    if (!mounted) return;

    _chargerProgression();
  }

  // ---------------------------------------------------------------------------
  // CARTE THÉMATIQUE
  // ---------------------------------------------------------------------------

  Widget _carteThematique({
    required Thematique thematique,
    required int index,
    required bool accessible,
    required bool terminee,
  }) {
    final couleurIcone = _couleurIcone(
      accessible: accessible,
      terminee: terminee,
    );

    final icone = _iconeThematique(thematique.titre);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: accessible ? 1.0 : 0.68,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: accessible
            ? () => _ouvrirThematique(thematique)
            : () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Termine d’abord la thématique précédente pour continuer.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: terminee
                  ? _vert.withOpacity(0.25)
                  : _bordure,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: terminee
                            ? _vertClair
                            : accessible
                                ? _roseClair
                                : const Color(0xFFF1F1F2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        terminee
                            ? Icons.check_rounded
                            : accessible
                                ? icone
                                : Icons.lock_outline_rounded,
                        color: couleurIcone,
                        size: 25,
                      ),
                    ),
                    if (terminee)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _vertClair,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 14,
                              color: _vert,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Terminée',
                              style: TextStyle(
                                color: _vert,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (!accessible)
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: _texteSecondaire,
                          size: 17,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  'THÉMATIQUE ${index + 1}',
                  style: const TextStyle(
                    color: _texteSecondaire,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  thematique.titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _texte,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                if (thematique.description.trim().isNotEmpty)
                  Text(
                    thematique.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _texteSecondaire,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  )
                else
                  const Text(
                    'Explore cette thématique pour avancer dans ton parcours.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _texteSecondaire,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),

                const Spacer(),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        terminee
                            ? 'Revoir la thématique'
                            : accessible
                                ? 'Commencer'
                                : 'Thématique verrouillée',
                        style: TextStyle(
                          color: accessible
                              ? (terminee ? _vert : _rose)
                              : _texteSecondaire,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      terminee
                          ? Icons.replay_rounded
                          : accessible
                              ? Icons.arrow_forward_rounded
                              : Icons.lock_outline_rounded,
                      color: accessible
                          ? (terminee ? _vert : _rose)
                          : _texteSecondaire,
                      size: 19,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EN-TÊTE
  // ---------------------------------------------------------------------------

  Widget _construireEntete() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF7F3F5),
                ),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: _texte,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _roseClair,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: _rose,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Parcours',
                      style: TextStyle(
                        color: _rose,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            widget.module.titre,
            style: const TextStyle(
              color: _texte,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 8),

          if (widget.module.sousTitre.trim().isNotEmpty)
            Text(
              widget.module.sousTitre,
              style: const TextStyle(
                color: _texteSecondaire,
                fontSize: 14,
                height: 1.45,
              ),
            ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: _rose,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Avance étape par étape dans ton parcours.',
                    style: TextStyle(
                      color: _texteSecondaire,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONSTRUCTION
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fond,
      body: SafeArea(
        child: FutureBuilder<Map<String, Progress>>(
          future: _progressFuture,
          builder: (context, progressSnapshot) {
            if (progressSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _rose,
                ),
              );
            }

            if (progressSnapshot.hasError) {
              return _construireErreur(
                'Impossible de charger ta progression.',
                erreur: progressSnapshot.error,
                onRetry: _chargerProgression,
              );
            }

            final progressions =
                progressSnapshot.data ?? <String, Progress>{};

            return StreamBuilder<List<Thematique>>(
              stream: _firestoreService.getThematiques(
                widget.module.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _rose,
                    ),
                  );
                }

                // ----------------------------------------------------------------
                // ERREUR FIRESTORE DES THÉMATIQUES
                // ----------------------------------------------------------------

                if (snapshot.hasError) {
                  return _construireErreur(
                    'Impossible de charger les thématiques.',
                    erreur: snapshot.error,
                    onRetry: _rechargerThematiques,
                  );
                }

                final thematiques = snapshot.data ?? [];

                // ----------------------------------------------------------------
                // AUCUNE THÉMATIQUE
                // ----------------------------------------------------------------

                if (thematiques.isEmpty) {
                  return Column(
                    children: [
                      _construireEntete(),

                      const Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Text(
                              'Aucune thématique n’est encore disponible dans ce module.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _texteSecondaire,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // ----------------------------------------------------------------
                // AFFICHAGE DES THÉMATIQUES
                // ----------------------------------------------------------------

                return RefreshIndicator(
                  color: _rose,
                  onRefresh: () async {
                    _chargerProgression();

                    await _progressFuture;
                  },
                  child: CustomScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _construireEntete(),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          22,
                          18,
                          30,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ton parcours',
                                      style: TextStyle(
                                        color: _texte,
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Progresse à ton rythme.',
                                      style: TextStyle(
                                        color:
                                            _texteSecondaire,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                '${progressions.values.where((p) => p.statut == 'termine').length}/${thematiques.length}',
                                style: const TextStyle(
                                  color: _rose,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        sliver: SliverGrid(
                          delegate:
                              SliverChildBuilderDelegate(
                            (context, index) {
                              final thematique =
                                  thematiques[index];

                              final progression =
                                  progressions[
                                      thematique.id];

                              final terminee =
                                  progression?.statut ==
                                      'termine';

                              final accessible =
                                  _estAccessible(
                                index: index,
                                thematiques: thematiques,
                                progressions:
                                    progressions,
                              );

                              return _carteThematique(
                                thematique: thematique,
                                index: index,
                                accessible: accessible,
                                terminee: terminee,
                              );
                            },
                            childCount:
                                thematiques.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 13,
                            mainAxisSpacing: 13,
                            childAspectRatio: 0.68,
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 25),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ÉCRAN D'ERREUR
  // ---------------------------------------------------------------------------

  Widget _construireErreur(
    String message, {
    Object? erreur,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _roseClair,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: _rose,
                size: 30,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _texte,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            // ---------------------------------------------------------------
            // ERREUR TECHNIQUE RÉELLE
            // ---------------------------------------------------------------

            if (erreur != null) ...[
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _rose.withOpacity(0.25),
                  ),
                ),
                child: SelectableText(
                  erreur.toString(),
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xFF8A304B),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _rose,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NETTOYAGE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}