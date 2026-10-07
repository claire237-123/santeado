import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/module.dart';
import '../services/firestore_service.dart';
import 'module_screen.dart';

class ParcoursScreen extends StatelessWidget {
  const ParcoursScreen({super.key});

  static const Color _rose = Color(0xFFD4537E);
  static const Color _fond = Color(0xFFFFF9FB);

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: _fond,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),

            child: StreamBuilder<List<Module>>(
              stream: firestoreService.getModules(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _rose,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Erreur : ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }

                final modules = snapshot.data ?? [];

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    100,
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

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  'Mon parcours',
                                  style:
                                      GoogleFonts.quicksand(
                                    fontSize: 24,
                                    fontWeight:
                                        FontWeight.w700,
                                    color:
                                        const Color(0xFF292525),
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  'Avance à ton rythme, étape par étape.',
                                  style:
                                      GoogleFonts.quicksand(
                                    fontSize: 13,
                                    color:
                                        Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Petit indicateur de parcours

                          Container(
                            width: 48,
                            height: 48,

                            decoration:
                                const BoxDecoration(
                              color: Color(0xFFFBEAF0),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.route_outlined,
                              color: _rose,
                              size: 24,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // MESSAGE INTRODUCTIF
                      // ==================================================

                      _buildIntroCard(),

                      const SizedBox(height: 28),

                      // ==================================================
                      // TITRE
                      // ==================================================

                      Text(
                        'Les étapes de ton parcours',
                        style:
                            GoogleFonts.quicksand(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              const Color(0xFF292525),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ==================================================
                      // MODULES
                      // ==================================================

                      if (modules.isEmpty)
                        _buildEmptyState()
                      else
                        _buildModules(
                          context,
                          modules,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // CARTE INTRODUCTIVE
  // ================================================================

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFFFFEDF2),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFFFCCD9),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            width: 46,
            height: 46,

            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.explore_outlined,
              color: _rose,
              size: 25,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  'Ton parcours santé',
                  style:
                      GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        const Color(0xFF4B1528),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Découvre les différentes étapes pour mieux comprendre ton corps et prendre soin de toi.',
                  style:
                      GoogleFonts.quicksand(
                    fontSize: 11.5,
                    height: 1.45,
                    color:
                        const Color(0xFF8A4A5C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // LISTE DES MODULES
  // ================================================================

  Widget _buildModules(
    BuildContext context,
    List<Module> modules,
  ) {
    return Column(
      children:
          modules.asMap().entries.map((entry) {
        final index = entry.key;
        final module = entry.value;

        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 16,
          ),

          child: _buildPathModule(
            context,
            module,
            index,
          ),
        );
      }).toList(),
    );
  }

  // ================================================================
  // CARTE D'UNE ÉTAPE
  // ================================================================

  Widget _buildPathModule(
    BuildContext context,
    Module module,
    int index,
  ) {
    final couleur =
        _getModuleColor(module);

    final disponible =
        module.statut == 'disponible';

    final icon =
        _getModuleIcon(module);

    return GestureDetector(
      onTap: disponible
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ModuleScreen(
                    module: module,
                  ),
                ),
              );
            }
          : null,

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // ==========================================================
          // COLONNE DU PARCOURS
          // ==========================================================

          SizedBox(
            width: 54,

            child: Column(
              children: [

                Container(
                  width: 48,
                  height: 48,

                  decoration:
                      BoxDecoration(
                    color: disponible
                        ? couleur
                            .withOpacity(0.18)
                        : const Color(
                            0xFFF0EEEB,
                          ),

                    shape: BoxShape.circle,

                    border: Border.all(
                      color: disponible
                          ? couleur
                          : const Color(
                              0xFFE0DDD9,
                            ),
                      width: 1.5,
                    ),
                  ),

                  child: Icon(
                    disponible
                        ? icon
                        : Icons.lock_outline,

                    color: disponible
                        ? couleur
                        : Colors.grey[500],

                    size: 22,
                  ),
                ),

                if (index <
                    2) ...[
                  const SizedBox(height: 4),

                  Container(
                    width: 2,
                    height: 68,

                    color: const Color(
                      0xFFE5E0E1,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ==========================================================
          // CARTE
          // ==========================================================

          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.all(15),

              decoration:
                  BoxDecoration(
                color: disponible
                    ? Colors.white
                    : const Color(
                        0xFFF7F5F3,
                      ),

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),

                border: Border.all(
                  color: disponible
                      ? couleur
                          .withOpacity(0.30)
                      : const Color(
                          0xFFE8E4E1,
                        ),
                ),

                boxShadow: disponible
                    ? [
                        BoxShadow(
                          color: couleur
                              .withOpacity(
                            0.07,
                          ),
                          blurRadius: 8,
                          offset:
                              const Offset(
                            0,
                            3,
                          ),
                        ),
                      ]
                    : null,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // --------------------------------------------------
                  // PETIT BADGE
                  // --------------------------------------------------

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),

                        decoration:
                            BoxDecoration(
                          color: disponible
                              ? couleur
                                  .withOpacity(
                                  0.12,
                                )
                              : const Color(
                                  0xFFEDEAE7,
                                ),

                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: Text(
                          'ÉTAPE ${module.ordre}',

                          style:
                              GoogleFonts.quicksand(
                            fontSize: 9,
                            fontWeight:
                                FontWeight.w700,
                            letterSpacing:
                                0.4,
                            color: disponible
                                ? couleur
                                : Colors.grey[
                                    500],
                          ),
                        ),
                      ),

                      Icon(
                        disponible
                            ? Icons
                                .arrow_forward_ios_rounded
                            : Icons
                                .lock_outline,

                        size: 15,

                        color: disponible
                            ? couleur
                            : Colors.grey[
                                400],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // --------------------------------------------------
                  // TITRE
                  // --------------------------------------------------

                  Text(
                    module.sousTitre,

                    maxLines: 2,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w700,
                      color: disponible
                          ? const Color(
                              0xFF292525,
                            )
                          : Colors.grey[500],
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    module.titre,

                    style:
                        GoogleFonts.quicksand(
                      fontSize: 11.5,
                      color: disponible
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --------------------------------------------------
                  // DESCRIPTION
                  // --------------------------------------------------

                  Text(
                    module.description,

                    maxLines: 2,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        GoogleFonts.quicksand(
                      fontSize: 10.5,
                      height: 1.4,
                      color: disponible
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // --------------------------------------------------
                  // BAS DE CARTE
                  // --------------------------------------------------

                  Row(
                    children: [

                      Icon(
                        disponible
                            ? Icons.play_circle_outline
                            : Icons.lock_outline,

                        size: 15,

                        color: disponible
                            ? couleur
                            : Colors.grey[400],
                      ),

                      const SizedBox(width: 5),

                      Text(
                        disponible
                            ? 'Commencer'
                            : 'Bientôt disponible',

                        style:
                            GoogleFonts.quicksand(
                          fontSize: 10.5,
                          fontWeight:
                              FontWeight.w600,
                          color: disponible
                              ? couleur
                              : Colors.grey[
                                  400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ÉTAT VIDE
  // ================================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color:
              const Color(0xFFEDE6E8),
        ),
      ),

      child: Column(
        children: [

          const Icon(
            Icons.route_outlined,
            size: 38,
            color: _rose,
          ),

          const SizedBox(height: 10),

          Text(
            'Ton parcours arrive bientôt.',
            textAlign:
                TextAlign.center,

            style:
                GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
              color:
                  const Color(0xFF4B1528),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Les différentes étapes seront bientôt disponibles.',
            textAlign:
                TextAlign.center,

            style:
                GoogleFonts.quicksand(
              fontSize: 11,
              color:
                  Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // COULEUR DU MODULE
  // ================================================================

  Color _getModuleColor(
    Module module,
  ) {
    try {
      return Color(
        int.parse(
          module.couleur
              .replaceFirst(
            '#',
            '0xFF',
          ),
        ),
      );
    } catch (_) {
      switch (module.ordre) {
        case 1:
          return const Color(
            0xFF8AD5BA,
          );

        case 2:
          return const Color(
            0xFFF4A69A,
          );

        case 3:
          return const Color(
            0xFFF4C17E,
          );

        default:
          return _rose;
      }
    }
  }

  // ================================================================
  // ICÔNE DU MODULE
  // ================================================================

  IconData _getModuleIcon(
    Module module,
  ) {
    final texte =
        '${module.titre} ${module.sousTitre}'
            .toLowerCase();

    if (texte.contains('corps') ||
        texte.contains('pubert')) {
      return Icons.accessibility_new;
    }

    if (texte.contains('cycle') ||
        texte.contains('saignement')) {
      return Icons.water_drop_outlined;
    }

    if (texte.contains('sexual') ||
        texte.contains('prévention')) {
      return Icons.lock_outline;
    }

    return Icons.menu_book_outlined;
  }
}