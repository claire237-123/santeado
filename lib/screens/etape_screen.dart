import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/module.dart';
import '../models/thematique.dart';
import '../models/etape.dart';
import '../services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EtapeScreen extends StatefulWidget {
  final Module module;
  final Thematique thematique;

  const EtapeScreen({
    super.key,
    required this.module,
    required this.thematique,
  });

  @override
  State<EtapeScreen> createState() => _EtapeScreenState();
}

class _EtapeScreenState extends State<EtapeScreen> {
  final FlutterTts _tts = FlutterTts();

  List<Etape> _etapes = [];

  bool _chargement = true;
  bool _enregistrement = false;
  bool _enTrainDeLire = false;

  int _index = 0;

  String? _choixSelectionne;

  Color get _couleur {
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

    _initialiserTts();
    _chargerEtapes();
  }

  // ============================================================
  // INITIALISATION TTS
  // ============================================================

  Future<void> _initialiserTts() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _enTrainDeLire = false;
        });
      }
    });
  }

Future<void> _ouvrirLien(String url) async {
  final uri = Uri.tryParse(url.trim());

  if (uri == null) {
    _afficherErreur('Lien vidéo invalide.');
    return;
  }

  final ouvert = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );

  if (!ouvert && mounted) {
    _afficherErreur('Impossible d’ouvrir cette vidéo.');
  }
}

  // ============================================================
  // CHARGEMENT DES ÉTAPES
  // ============================================================
Future<void> _chargerEtapes() async {
  try {
    final etapes = await FirestoreService().getEtapes(
      widget.module.id,
      widget.thematique.id,
    );

    if (!mounted) return;

    setState(() {
      _etapes = etapes;
      _chargement = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _chargement = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erreur : $e',
        ),
        duration: const Duration(seconds: 10),
      ),
    );

    debugPrint('ERREUR ETAPES : $e');
  }
}

  // ============================================================
  // LECTURE VOCALE
  // ============================================================

  Future<void> _lire(String texte) async {
    if (texte.trim().isEmpty) return;

    try {
      await _tts.stop();

      if (!mounted) return;

      setState(() {
        _enTrainDeLire = true;
      });

      await _tts.speak(texte);
    } catch (_) {
      if (mounted) {
        setState(() {
          _enTrainDeLire = false;
        });
      }
    }
  }

  // ============================================================
  // ARRÊTER LA LECTURE
  // ============================================================

  Future<void> _arreterLecture() async {
    await _tts.stop();

    if (!mounted) return;

    setState(() {
      _enTrainDeLire = false;
    });
  }

  // ============================================================
  // ÉTAPE SUIVANTE
  // ============================================================

  Future<void> _suivant() async {
    if (_enregistrement) return;

    if (_index < _etapes.length - 1) {
      await _arreterLecture();

      if (!mounted) return;

      setState(() {
        _index++;
        _choixSelectionne = null;
      });

      return;
    }

    await _terminerThematique();
  }

  // ============================================================
  // ÉTAPE PRÉCÉDENTE
  // ============================================================

  Future<void> _precedent() async {
    if (_index <= 0) return;

    await _arreterLecture();

    if (!mounted) return;

    setState(() {
      _index--;
      _choixSelectionne = null;
    });
  }

  // ============================================================
  // TERMINER LA THÉMATIQUE
  // ============================================================

  Future<void> _terminerThematique() async {
    final utilisateur = FirebaseAuth.instance.currentUser;

    if (utilisateur == null) {
      _afficherErreur(
        'Session utilisateur introuvable.',
      );
      return;
    }

    if (_enregistrement) return;

    setState(() {
      _enregistrement = true;
    });

    try {
      int points = 0;
      int score = 100;

      final derniereEtape = _etapes.isNotEmpty
          ? _etapes.last
          : null;

      // ----------------------------------------------------------
      // CALCUL DU SCORE POUR L'ACTIVITÉ
      // ----------------------------------------------------------

      if (derniereEtape != null &&
          derniereEtape.type == 'joue' &&
          derniereEtape.jeu != null &&
          derniereEtape.jeu!.choix.isNotEmpty) {
        if (_choixSelectionne != null) {
          final choix = derniereEtape.jeu!.choix.firstWhere(
            (c) => c.id == _choixSelectionne,
          );

          if (choix.correct) {
            points = derniereEtape.jeu!.pointsGagnes;
            score = 100;
          } else {
            score = 0;
          }
        } else {
          score = 0;
        }
      }

      // ----------------------------------------------------------
      // ENREGISTREMENT FIRESTORE
      // ----------------------------------------------------------

      await FirestoreService().marquerThematiqueTerminee(
        uid: utilisateur.uid,
        moduleId: widget.module.id,
        thematiqueId: widget.thematique.id,
        score: score,
        pointsGagnes: points,
      );
      
      if (!mounted) return;

      setState(() {
        _enregistrement = false;
      });

      await _arreterLecture();

      if (!mounted) return;

      // ----------------------------------------------------------
      // ÉCRAN DE FIN
      // ----------------------------------------------------------

      await _afficherFin(
        points: points,
        score: score,
      );
    } catch (e, stackTrace) {
  debugPrint('===== ERREUR ENREGISTREMENT PROGRESSION =====');
  debugPrint('ERREUR : $e');
  debugPrint('STACK : $stackTrace');

  if (!mounted) return;

  setState(() {
    _enregistrement = false;
  });

  _afficherErreur(
    'Erreur : $e',
  );
}
  }

  // ============================================================
  // ÉCRAN DE FIN
  // ============================================================

  Future<void> _afficherFin({
    required int points,
    required int score,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            28,
            24,
            30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: _couleur.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: _couleur,
                  size: 38,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Thématique terminée',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2A26),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Bravo ! Tu as terminé cette partie de ton parcours.',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 13.5,
                  height: 1.5,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _statFin(
                      icone: Icons.star_outline,
                      titre: 'Score',
                      valeur: '$score %',
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _statFin(
                      icone: Icons.add_circle_outline,
                      titre: 'Points',
                      valeur: '+$points',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _couleur,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Retour aux thématiques',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  Widget _statFin({
    required IconData icone,
    required String titre,
    required String valeur,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFEDE8E6),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icone,
            color: _couleur,
            size: 22,
          ),

          const SizedBox(height: 5),

          Text(
            titre,
            style: GoogleFonts.quicksand(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 2),

          Text(
            valeur,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2A26),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE ERREUR
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFB),
      body: SafeArea(
        child: _chargement
            ? _etatChargement()
            : _etapes.isEmpty
                ? _etatVide()
                : Column(
                    children: [
                      _enTete(),

                      Expanded(
                        child: SingleChildScrollView(
                          physics:
                              const BouncingScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(
                            22,
                            10,
                            22,
                            20,
                          ),
                          child: _contenuEtape(),
                        ),
                      ),

                      _boutonBas(),
                    ],
                  ),
      ),
    );
  }

  // ============================================================
  // CHARGEMENT
  // ============================================================

  Widget _etatChargement() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: _couleur,
            strokeWidth: 2.5,
          ),

          const SizedBox(height: 14),

          Text(
            'Chargement de ton parcours...',
            style: GoogleFonts.quicksand(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AUCUNE ÉTAPE
  // ============================================================

  Widget _etatVide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _couleur.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 34,
                color: _couleur,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Contenu en cours de préparation',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2A26),
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Cette thématique sera bientôt disponible.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Retour',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w700,
                  color: _couleur,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EN-TÊTE
  // ============================================================

  Widget _enTete() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        10,
        7,
        18,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              await _arreterLecture();

              if (!context.mounted) return;

              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                Text(
                  widget.thematique.titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2A26),
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: List.generate(
                    _etapes.length,
                    (i) {
                      final actif = i == _index;
                      final fait = i < _index;

                      return AnimatedContainer(
                        duration:
                            const Duration(
                          milliseconds: 200,
                        ),
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 3,
                        ),
                        width: actif ? 22 : 8,
                        height: 7,
                        decoration:
                            BoxDecoration(
                          color: (actif || fait)
                              ? _couleur
                              : Colors.grey[300],
                          borderRadius:
                              BorderRadius.circular(5),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 42),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENU DE L'ÉTAPE
  // ============================================================

  Widget _contenuEtape() {
    final etape = _etapes[_index];

    switch (etape.type) {
      case 'regarde':
        return _blocMedia(
          icone: Icons.play_circle_outline,
          texte: etape.texte,
          label: 'Regarde',
          url: etape.videoUrl,
        );

      case 'observe':
        return _blocMedia(
          icone: Icons.image_outlined,
          texte: etape.texte,
          label: 'Observe',
          url: etape.illustrationUrl,
        );

      case 'joue':
        return _blocJeu(etape);

      case 'retiens':
        return _blocTexte(
          etape.texte,
          titre: 'Je retiens',
        );

      case 'decouvre':
      default:
        return _blocTexte(
          etape.texte,
          titre: 'Découvre',
        );
    }
  }

  // ============================================================
  // BLOC TEXTE
  // ============================================================

  Widget _blocTexte(
    String texte, {
    required String titre,
  }) {
    final contenu = texte.trim().isEmpty
        ? 'Contenu à venir.'
        : texte;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titre,
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2A26),
                ),
              ),
            ),

            if (texte.trim().isNotEmpty)
              _boutonTts(texte),
          ],
        ),

        const SizedBox(height: 17),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _couleur.withOpacity(0.08),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: _couleur.withOpacity(0.14),
            ),
          ),
          child: Text(
            contenu,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              height: 1.65,
              color: const Color(0xFF3C3735),
            ),
          ),
        ),
      ],
    );
  }

 // ============================================================
// BLOC MÉDIA
// ============================================================

Widget _blocMedia({
  required IconData icone,
  required String texte,
  required String label,
  required String url,
}) {
  final lienDisponible = url.trim().isNotEmpty;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        height: 190,
        decoration: BoxDecoration(
          color: _couleur.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _couleur.withOpacity(0.12),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icone,
              size: 58,
              color: _couleur,
            ),

            // ----------------------------------------------------
            // BOUTON CLIQUABLE POUR LE LIEN
            // ----------------------------------------------------

            if (lienDisponible)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: InkWell(
                  onTap: () => _ouvrirLien(url),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.open_in_new,
                          size: 17,
                          color: _couleur,
                        ),

                        const SizedBox(width: 7),

                        Flexible(
                          child: Text(
                            'Ouvrir le contenu',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _couleur,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
              ),
            ),
          ),

          if (texte.trim().isNotEmpty)
            _boutonTts(texte),
        ],
      ),

      if (texte.trim().isNotEmpty) ...[
        const SizedBox(height: 8),

        Text(
          texte,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            height: 1.55,
            color: Colors.grey[700],
          ),
        ),
      ],
    ],
  );
}

  // ============================================================
  // BOUTON TTS
  // ============================================================

  Widget _boutonTts(String texte) {
    return IconButton(
      onPressed: _enTrainDeLire
          ? _arreterLecture
          : () => _lire(texte),
      tooltip: _enTrainDeLire
          ? 'Arrêter'
          : 'Écouter',
      icon: Icon(
        _enTrainDeLire
            ? Icons.stop_circle_outlined
            : Icons.volume_up_outlined,
        color: _couleur,
      ),
    );
  }

  // ============================================================
  // BLOC JEU
  // ============================================================

  Widget _blocJeu(Etape etape) {
    final jeu = etape.jeu;

    if (jeu == null || jeu.choix.isEmpty) {
      return _blocTexte(
        'Cette activité sera bientôt disponible.',
        titre: 'Activité',
      );
    }

    final bool aRepondu =
        _choixSelectionne != null;

    Choix? choixActuel;

    if (aRepondu) {
      try {
        choixActuel =
            jeu.choix.firstWhere(
          (c) => c.id == _choixSelectionne,
        );
      } catch (_) {
        choixActuel = null;
      }
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // --------------------------------------------------------
        // TITRE
        // --------------------------------------------------------

        Row(
          children: [
            Expanded(
              child: Text(
                'À toi de jouer',
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2A26),
                ),
              ),
            ),

            _boutonTts(jeu.situation),
          ],
        ),

        const SizedBox(height: 16),

        // --------------------------------------------------------
        // SITUATION
        // --------------------------------------------------------

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _couleur.withOpacity(0.08),
            borderRadius:
                BorderRadius.circular(19),
            border: Border.all(
              color: _couleur.withOpacity(0.14),
            ),
          ),
          child: Text(
            jeu.situation,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3C3735),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          aRepondu
              ? 'Ta réponse'
              : 'Choisis la réponse qui te semble correcte',
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),

        const SizedBox(height: 10),

        // --------------------------------------------------------
        // CHOIX
        // --------------------------------------------------------

        ...jeu.choix.map(
          (choix) {
            return _carteChoix(
              choix,
              choixActuel,
            );
          },
        ),

        // --------------------------------------------------------
        // FEEDBACK
        // --------------------------------------------------------

        if (choixActuel != null) ...[
          const SizedBox(height: 14),
          _blocFeedback(
            choixActuel,
            jeu.pointsGagnes,
          ),
        ],
      ],
    );
  }

  // ============================================================
  // CARTE CHOIX
  // ============================================================

  Widget _carteChoix(
    Choix choix,
    Choix? choixActuel,
  ) {
    final selectionne =
        _choixSelectionne == choix.id;

    final aRepondu =
        _choixSelectionne != null;

    Color fond = Colors.white;
    Color bordure =
        const Color(0xFFE3DEDC);
    Color texte =
        const Color(0xFF373230);

    IconData? icone;

    if (aRepondu) {
      if (choix.correct) {
        fond = const Color(0xFFEAF6EE);
        bordure = const Color(0xFF9BCDA9);
        texte = const Color(0xFF28613A);
        icone = Icons.check_circle_outline;
      } else if (selectionne) {
        fond = const Color(0xFFFCECEF);
        bordure = const Color(0xFFE2A4B4);
        texte = const Color(0xFF91394F);
        icone = Icons.cancel_outlined;
      } else {
        fond = const Color(0xFFF9F7F6);
      }
    } else if (selectionne) {
      fond = _couleur.withOpacity(0.08);
      bordure = _couleur;
    }

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: aRepondu
            ? null
            : () {
                setState(() {
                  _choixSelectionne =
                      choix.id;
                });
              },
        borderRadius:
            BorderRadius.circular(15),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: fond,
            borderRadius:
                BorderRadius.circular(15),
            border: Border.all(
              color: bordure,
              width: selectionne ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: selectionne
                      ? _couleur.withOpacity(0.12)
                      : const Color(0xFFF4F1F0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(
                      65 +
                          _indexChoix(
                            choix,
                          ),
                    ),
                    style:
                        GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                      color: selectionne
                          ? _couleur
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  choix.texte,
                  style:
                      GoogleFonts.quicksand(
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight:
                        selectionne
                            ? FontWeight.w600
                            : FontWeight.w500,
                    color: texte,
                  ),
                ),
              ),

              if (icone != null)
                Icon(
                  icone,
                  size: 21,
                  color: choix.correct
                      ? const Color(0xFF4B9A61)
                      : const Color(0xFFC04E68),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // POSITION DU CHOIX
  // ============================================================

  int _indexChoix(Choix choix) {
    final jeu = _etapes[_index].jeu;

    if (jeu == null) return 0;

    final index = jeu.choix.indexWhere(
      (c) => c.id == choix.id,
    );

    return index < 0 ? 0 : index;
  }

  // ============================================================
  // FEEDBACK
  // ============================================================

  Widget _blocFeedback(
    Choix choix,
    int points,
  ) {
    final correcte = choix.correct;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: correcte
            ? const Color(0xFFEAF6EE)
            : const Color(0xFFFCECEF),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: correcte
              ? const Color(0xFFB8DCC2)
              : const Color(0xFFE8B4C1),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correcte
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                size: 20,
                color: correcte
                    ? const Color(0xFF39804D)
                    : const Color(0xFFB44660),
              ),

              const SizedBox(width: 8),

              Text(
                correcte
                    ? 'Bonne réponse'
                    : 'Pas tout à fait',
                style:
                    GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color: correcte
                      ? const Color(0xFF28613A)
                      : const Color(0xFF91394F),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Text(
            choix.feedback.trim().isEmpty
                ? 'Continue ton parcours pour découvrir la suite.'
                : choix.feedback,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF4A4441),
            ),
          ),

          if (correcte) ...[
            const SizedBox(height: 10),

            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 17,
                  color: _couleur,
                ),

                const SizedBox(width: 5),

                Text(
                  '+ $points points',
                  style:
                      GoogleFonts.quicksand(
                    fontSize: 12.5,
                    fontWeight:
                        FontWeight.w700,
                    color: _couleur,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // BOUTON BAS
  // ============================================================

  Widget _boutonBas() {
    final etape = _etapes[_index];

    final estJeu =
        etape.type == 'joue';

    final jeuValide =
        etape.jeu != null &&
        etape.jeu!.choix.isNotEmpty;

    final bloque =
        estJeu &&
        jeuValide &&
        _choixSelectionne == null;

    final derniereEtape =
        _index == _etapes.length - 1;

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        8,
        22,
        18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFB),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_index > 0) ...[
            SizedBox(
              width: 52,
              height: 52,
              child: OutlinedButton(
                onPressed:
                    _enregistrement
                        ? null
                        : _precedent,
                style:
                    OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: BorderSide(
                    color: _couleur
                        .withOpacity(0.35),
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: _couleur,
                ),
              ),
            ),

            const SizedBox(width: 10),
          ],

          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed:
                    bloque ||
                            _enregistrement
                        ? null
                        : _suivant,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: _couleur,
                  disabledBackgroundColor:
                      Colors.grey[300],
                  foregroundColor:
                      Colors.white,
                  disabledForegroundColor:
                      Colors.grey[500],
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
                child:
                    _enregistrement
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Text(
                                derniereEtape
                                    ? 'Terminer'
                                    : 'Continuer',
                                style:
                                    GoogleFonts.quicksand(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Icon(
                                derniereEtape
                                    ? Icons
                                        .check_rounded
                                    : Icons
                                        .arrow_forward,
                                size: 18,
                              ),
                            ],
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}