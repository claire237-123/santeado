import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import 'dossiers_accompagnement_screen.dart';

class ProfessionnelScreen extends StatefulWidget {
  const ProfessionnelScreen({super.key});

  @override
  State<ProfessionnelScreen> createState() => _ProfessionnelScreenState();
}

class _ProfessionnelScreenState extends State<ProfessionnelScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Identité visuelle SantéAdo
  static const Color _vert = Color(0xFF176B5B);
  static const Color _vertClair = Color(0xFFEAF5F2);
  static const Color _rose = Color(0xFFD4537E);
  static const Color _roseClair = Color(0xFFFBEAF0);
  static const Color _orange = Color(0xFFD9822B);
  static const Color _fond = Color(0xFFF7F9F8);
  static const Color _texte = Color(0xFF25332F);
  static const Color _gris = Color(0xFF6D7773);
  static const Color _bordure = Color(0xFFE4EAE7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fond,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool large = constraints.maxWidth >= 850;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: large ? 32 : 18,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildStatistics(large),
                    const SizedBox(height: 32),
                    _buildDemandesSection(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APP BAR
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleSpacing: 18,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo_santeado.png',
            height: 42,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 14),
          Container(
            height: 28,
            width: 1,
            color: _bordure,
          ),
          const SizedBox(width: 14),
          Text(
            'Espace professionnel',
            style: GoogleFonts.quicksand(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _texte,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Déconnexion',
          onPressed: _deconnexion,
          icon: const Icon(
            Icons.logout_rounded,
            color: _texte,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _bordure),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _vertClair,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: _vert,
              size: 29,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suivi des accompagnements',
                  style: GoogleFonts.quicksand(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _texte,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Gérez les demandes et les dossiers qui vous sont attribués.',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _gris,
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
  // STATISTIQUES
  // ---------------------------------------------------------------------------

  Widget _buildStatistics(bool large) {
    final cards = [
      _buildStatCard(
        stream: _db
            .collection('demandes_accompagnement')
            .where('statut', isEqualTo: 'en_attente')
            .snapshots(),
        title: 'Demandes en attente',
        icon: Icons.mark_email_unread_outlined,
        color: _orange,
        background: const Color(0xFFFFF5E9),
        onTap: _ouvrirDemandesEnAttente,
      ),

      _buildStatCard(
        stream: _db
            .collection('dossiers_accompagnement')
            .where('statut', isEqualTo: 'en_cours')
            .snapshots(),
        title: 'Dossiers en cours',
        icon: Icons.folder_open_outlined,
        color: _vert,
        background: _vertClair,
        onTap: _ouvrirDossiersEnCours,
      ),
      _buildStatCard(
        stream: _db
            .collection('rencontres')
            .where('statut', isEqualTo: 'planifiee')
            .snapshots(),
        title: 'Rencontres à venir',
        icon: Icons.event_outlined,
        color: _rose,
        background: _roseClair,
        onTap: _ouvrirRencontres,
      ),
    ];

    if (large) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 16),
          Expanded(child: cards[1]),
          const SizedBox(width: 16),
          Expanded(child: cards[2]),
        ],
      );
    }

    return Column(
      children: [
        cards[0],
        const SizedBox(height: 14),
        cards[1],
        const SizedBox(height: 14),
        cards[2],
      ],
    );
  }

  void _ouvrirDemandesEnAttente() {
  // À compléter
}

void _ouvrirDossiersEnCours() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DossiersAccompagnementScreen(),
    ),
  );
}

void _ouvrirRencontres() {
  // À compléter
}

 Widget _buildStatCard({
  required Stream<QuerySnapshot<Map<String, dynamic>>> stream,
  required String title,
  required IconData icon,
  required Color color,
  required Color background,
  required VoidCallback onTap,
}) {
  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: stream,
    builder: (context, snapshot) {
      final int count = snapshot.data?.docs.length ?? 0;

      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _bordure),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _gris,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$count',
                        style: GoogleFonts.quicksand(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: _texte,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  // ---------------------------------------------------------------------------
  // DEMANDES
  // ---------------------------------------------------------------------------

  Widget _buildDemandesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Demandes d’accompagnement',
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _texte,
              ),
            ),
            const SizedBox(width: 10),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db
                  .collection('demandes_accompagnement')
                  .where('statut', isEqualTo: 'en_attente')
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _roseClair,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _rose,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Les demandes sont présentées sous forme pseudonymisée.',
          style: GoogleFonts.quicksand(
            fontSize: 13,
            color: _gris,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        _buildDemandesList(),
      ],
    );
  }

  Widget _buildDemandesList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db
          .collection('demandes_accompagnement')
          .where('statut', isEqualTo: 'en_attente')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.hasError) {
          return _buildEmptyCard(
            icon: Icons.error_outline,
            title: 'Impossible de charger les demandes',
          );
        }

        final documents = snapshot.data?.docs ?? [];

        if (documents.isEmpty) {
          return _buildEmptyCard(
            icon: Icons.inbox_outlined,
            title: 'Aucune demande en attente',
          );
        }

        return Column(
          children: documents.map((document) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDemandeTile(
                documentId: document.id,
                data: document.data(),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // CARTE DEMANDE
  // ---------------------------------------------------------------------------

  Widget _buildDemandeTile({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    final String code = _texteValeur(
      data['codeAnonyme'],
      'Dossier sans code',
    );

    final String surnom = _texteValeur(
      data['surnom'],
      'Adolescente',
    );

    final String trancheAge = _texteValeur(
      data['trancheAge'],
      '',
    );

    final String motif = _texteValeur(
      data['motif'],
      'Demande d’accompagnement',
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _afficherDemande(
          documentId: documentId,
          data: data,
        ),
        child: Container(
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _bordure),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _vertClair,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: _vert,
                  size: 25,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _vert,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        surnom,
                        if (trancheAge.isNotEmpty) trancheAge,
                      ].join(' · '),
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _texte,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      motif,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _gris,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _fond,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: _vert,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DETAIL D'UNE DEMANDE
  // ---------------------------------------------------------------------------

  void _afficherDemande({
  required String documentId,
  required Map<String, dynamic> data,
}) {
  final String motif = _texteValeur(
    data['motif'],
    'Non précisé',
  );

  final String message = _texteValeur(
    data['message'],
    'Aucun message.',
  );

  final String statut = _texteValeur(
    data['statut'],
    'en_attente',
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _bordure,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _vertClair,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.folder_shared_outlined,
                        color: _vert,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demande d’accompagnement',
                            style: GoogleFonts.quicksand(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: _texte,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Statut : $statut',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _gris,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildInfoRow(
                  icon: Icons.subject_outlined,
                  label: 'Motif',
                  value: motif,
                ),

                const SizedBox(height: 15),

                Text(
                  'Message de l’adolescente',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _texte,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: _fond,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _bordure),
                  ),
                  child: Text(
                    message,
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: _gris,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: _vertClair,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: _vert,
                        size: 19,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Les informations d’identité civile ne sont pas affichées dans cet espace.',
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                            color: _vert,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                if (statut == 'en_attente') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _rejeterDemande(documentId);
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 20,
                          ),
                          label: Text(
                            'Rejeter',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _rose,
                            side: const BorderSide(
                              color: _rose,
                            ),
                            minimumSize:
                                const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _accepterDemande(documentId);
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 21,
                          ),
                          label: Text(
                            'Accepter',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _vert,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize:
                                const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _accepterDemande(String documentId) async {
  try {
    final professionnelId = _authService.uid;

    if (professionnelId == null) {
      _afficherMessage('Session professionnelle invalide.');
      return;
    }

    // Récupérer la demande
    final demande = await _db
        .collection('demandes_accompagnement')
        .doc(documentId)
        .get();

    if (!demande.exists) {
      _afficherMessage('Demande introuvable.');
      return;
    }

    final data = demande.data()!;

    // 1. Mettre à jour la demande
    await demande.reference.update({
      'statut': 'acceptee',
      'professionnelId': professionnelId,
      'dateModification': FieldValue.serverTimestamp(),
      'dateAcceptation': FieldValue.serverTimestamp(),
    });

    // 2. Créer le dossier d'accompagnement
    await _db.collection('dossiers_accompagnement').add({
      'demandeId': documentId,
      'uidAdolescente': data['uidAdolescente'],
      'professionnelId': professionnelId,
      'motif': data['motif'],
      'messageInitial': data['message'],
      'statut': 'en_cours',
      'dateCreation': FieldValue.serverTimestamp(),
      'dateModification': FieldValue.serverTimestamp(),
    });

    _afficherMessage('Demande acceptée. Dossier créé.');
  } catch (e) {
    _afficherMessage(
      'Erreur : $e',
    );
  }
}

Future<void> _rejeterDemande(String documentId) async {
  try {
    final professionnelId = _authService.uid;

    if (professionnelId == null) {
      _afficherMessage('Session professionnelle invalide.');
      return;
    }

    await _db
        .collection('demandes_accompagnement')
        .doc(documentId)
        .update({
      'statut': 'rejetee',
      'professionnelId': professionnelId,
      'dateModification': FieldValue.serverTimestamp(),
      'dateRejet': FieldValue.serverTimestamp(),
    });

    _afficherMessage('Demande rejetée.');
  } catch (e) {
    _afficherMessage(
      'Impossible de rejeter la demande.',
    );
  }
}

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: _gris,
          ),
          const SizedBox(width: 11),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _gris,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _texte,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PRISE EN CHARGE
  // ---------------------------------------------------------------------------

  Future<void> _prendreEnCharge(String documentId) async {
    try {
      final String? professionnelId = _authService.uid;

      if (professionnelId == null) {
        _afficherMessage('Session professionnelle invalide.');
        return;
      }

      await _db
          .collection('demandes_accompagnement')
          .doc(documentId)
          .update({
        'statut': 'prise_en_charge',
        'professionnelId': professionnelId,
        'datePriseEnCharge': FieldValue.serverTimestamp(),
      });

      _afficherMessage('Demande prise en charge.');
    } catch (e) {
      _afficherMessage('Impossible de traiter la demande.');
    }
  }

  // ---------------------------------------------------------------------------
  // UTILITAIRES
  // ---------------------------------------------------------------------------

  String _texteValeur(dynamic valeur, String valeurParDefaut) {
    if (valeur == null) {
      return valeurParDefaut;
    }

    final texte = valeur.toString().trim();

    if (texte.isEmpty) {
      return valeurParDefaut;
    }

    return texte;
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _bordure),
      ),
      child: const Center(
        child: SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: _vert,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _bordure),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
            color: _gris,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _gris,
            ),
          ),
        ],
      ),
    );
  }

  void _afficherMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _deconnexion() async {
    await _authService.deconnexion();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }
}