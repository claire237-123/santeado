import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class DossiersAccompagnementScreen extends StatelessWidget {
  DossiersAccompagnementScreen({super.key});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const Color _vert = Color(0xFF176B5B);
  static const Color _vertClair = Color(0xFFEAF5F2);
  static const Color _fond = Color(0xFFF7F9F8);
  static const Color _texte = Color(0xFF25332F);
  static const Color _gris = Color(0xFF6D7773);
  static const Color _bordure = Color(0xFFE4EAE7);

  String _texteValeur(dynamic valeur, String valeurParDefaut) {
    if (valeur == null) return valeurParDefaut;
    final texte = valeur.toString().trim();
    return texte.isEmpty ? valeurParDefaut : texte;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fond,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _texte),
        title: Text(
          'Dossiers en cours',
          style: GoogleFonts.quicksand(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: _texte,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db
            .collection('dossiers_accompagnement')
            .where('statut', isEqualTo: 'en_cours')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Impossible de charger les dossiers.',
                style: GoogleFonts.quicksand(
                  color: _gris,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final dossiers = snapshot.data?.docs ?? [];

          if (dossiers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _vertClair,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.folder_open_outlined,
                        color: _vert,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Aucun dossier en cours',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _texte,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Les demandes acceptées apparaîtront ici.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        color: _gris,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: dossiers.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = dossiers[index];
              final data = doc.data();

              final motif = _texteValeur(
                data['motif'],
                'Accompagnement',
              );

              final statut = _texteValeur(
                data['statut'],
                'en_cours',
              );

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    // Détail du dossier à ajouter ensuite.
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _bordure,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _vertClair,
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.folder_open_outlined,
                            color: _vert,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                motif,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: GoogleFonts.quicksand(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _texte,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Statut : $statut',
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _vert,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: _vert,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}