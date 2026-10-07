import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';
import 'welcome_screen.dart';

class AdministrateurScreen extends StatefulWidget {
  const AdministrateurScreen({super.key});

  @override
  State<AdministrateurScreen> createState() =>_AdministrateurScreenState();
}

class _AdministrateurScreenState extends State<AdministrateurScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _service = FirestoreService();

  int _selection = 0;

  String? _moduleId;
  String? _moduleTitre;

  String? _thematiqueId;
  String? _thematiqueTitre;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _modulesStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _modulesCountStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _demandesStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _demandesOrderedStream;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _thematiquesStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _etapesStream;

  static const Color _vert = Color(0xFF176B5B);
  static const Color _turquoise = Color(0xFF2E9C8C);
  static const Color _rose = Color(0xFFD4537E);
  static const Color _orange = Color(0xFFD9822B);
  static const Color _fond = Color(0xFFF6F8F7);
  static const Color _texte = Color(0xFF26332F);
  static const Color _gris = Color(0xFF6F7975);
  static const Color _bordure = Color(0xFFE2E9E6);

  final List<_MenuItem> _menu = const [
    _MenuItem(Icons.dashboard_outlined, 'Vue d’ensemble'),
    _MenuItem(Icons.people_outline, 'Utilisateurs'),
    _MenuItem(Icons.library_books_outlined, 'Contenus'),
    _MenuItem(Icons.quiz_outlined, 'Activités'),
    _MenuItem(Icons.notifications_none_outlined, 'Alertes'),
    _MenuItem(Icons.bar_chart_outlined, 'Statistiques'),
  ];

  @override
  void initState() {
    super.initState();

    _usersStream = _db.collection('users').snapshots();

    _modulesStream = _db
        .collection('modules')
        .orderBy('ordre')
        .snapshots();

    _modulesCountStream = _db.collection('modules').snapshots();

    _demandesStream =
        _db.collection('demandes_accompagnement').snapshots();

    _demandesOrderedStream = _db
        .collection('demandes_accompagnement')
        .orderBy('dateDemande', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fond,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 900;

          if (desktop) {
            return Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildMainContent()),
              ],
            );
          }

          return _buildMobileLayout();
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: _fond,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo_santeado.png',
          height: 40,
        ),
        actions: [
          IconButton(
            onPressed: _deconnexion,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: _buildSidebarContent(),
        ),
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 255,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: _bordure),
        ),
      ),
      child: SafeArea(
        child: _buildSidebarContent(),
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/logo_santeado.png',
              height: 52,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _fond,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _vert,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administration',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: _texte,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SantéAdo',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: _gris,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _menu.length,
            itemBuilder: (context, index) {
              final item = _menu[index];
              final active = _selection == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Material(
                  color: active
                      ? const Color(0xFFEAF5F2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _selection = index;
                        _moduleId = null;
                        _moduleTitre = null;
                        _thematiqueId = null;
                        _thematiqueTitre = null;
                      });

                      Navigator.of(context).maybePop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 21,
                            color: active ? _vert : _gris,
                          ),
                          const SizedBox(width: 13),
                          Text(
                            item.label,
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: active
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: active ? _vert : _texte,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: OutlinedButton.icon(
            onPressed: _deconnexion,
            icon: const Icon(Icons.logout_outlined, size: 18),
            label: Text(
              'Déconnexion',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _texte,
              side: const BorderSide(color: _bordure),
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 25, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1150),
            child: _buildCurrentSection(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_selection) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildUtilisateurs();
      case 2:
        return _buildContenus();
      case 3:
        return _buildActivites();
      case 4:
        return _buildAlertes();
      case 5:
        return _buildStatistiques();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildPageHeader(
    String titre,
    String sousTitre,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: GoogleFonts.quicksand(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: _texte,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            sousTitre,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _gris,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(
          'Vue d’ensemble',
          'Gérez les ressources et le contenu de la plateforme SantéAdo.',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _buildDashboardCounter(
                stream: _usersStream,
                titre: 'Utilisateurs',
                icon: Icons.people_outline,
                color: _vert,
                messageErreur: 'Impossible de charger les utilisateurs.',
              ),
              _buildDashboardCounter(
                stream: _modulesCountStream,
                titre: 'Modules',
                icon: Icons.library_books_outlined,
                color: _turquoise,
                messageErreur: 'Impossible de charger les modules.',
              ),
              _buildDashboardCounter(
                stream: _demandesStream,
                titre: 'Demandes',
                icon: Icons.support_agent_outlined,
                color: _rose,
                messageErreur: 'Impossible de charger les demandes.',
              ),
            ];

            if (constraints.maxWidth < 700) {
              return Column(
                children: cards
                    .map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: card,
                      ),
                    )
                    .toList(),
              );
            }

            return Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 14),
                Expanded(child: cards[1]),
                const SizedBox(width: 14),
                Expanded(child: cards[2]),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildDashboardCounter({
    required Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    required String titre,
    required IconData icon,
    required Color color,
    required String messageErreur,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _statCard(titre, '—', icon, color);
        }

        if (!snapshot.hasData) {
          return _statCard(titre, '…', icon, color);
        }

        final total = snapshot.data!.docs.length;

        return _statCard(titre, '$total', icon, color);
      },
    );
  }

  Widget _statCard(
    String titre,
    String valeur,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _bordure),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: _gris,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valeur,
                  style: GoogleFonts.quicksand(
                    fontSize: 24,
                    color: _texte,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return _sectionCard(
      title: 'Actions rapides',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _actionButton(
            'Gérer les contenus',
            Icons.library_books_outlined,
            () => setState(() => _selection = 2),
          ),
          _actionButton(
            'Gérer les utilisateurs',
            Icons.people_outline,
            () => setState(() => _selection = 1),
          ),
          _actionButton(
            'Gérer les activités',
            Icons.quiz_outlined,
            () => setState(() => _selection = 3),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: _vert,
        side: const BorderSide(color: _bordure),
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.quicksand(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildContenus() {
    if (_moduleId == null) {
      return _buildModules();
    }

    if (_thematiqueId == null) {
      return _buildThematiques();
    }

    return _buildEtapes();
  }

  Widget _buildModules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(
          'Gestion des contenus',
          'Organisez les modules, thématiques, étapes et activités pédagogiques.',
        ),
        _sectionCard(
          title: 'Modules',
          trailing: _primaryButton(
            'Ajouter un module',
            Icons.add,
            _ajouterModule,
          ),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _modulesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _loading();
              }

              if (snapshot.hasError) {
                return _messageCard(
                  Icons.error_outline,
                  'Impossible de charger les modules.',
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return _messageCard(
                  Icons.library_books_outlined,
                  'Aucun module disponible.',
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data();

                  final titre = _value(data['titre'], 'Module sans titre');
                  final description = _value(data['description'], '');

                  // Statut réel du module : 'brouillon' par défaut si le
                  // champ est absent (anciens documents créés avant la
                  // mise en place du workflow de publication).
                  final statut = _value(data['statut'], 'brouillon');

                  return _contentTile(
                    icon: Icons.menu_book_outlined,
                    title: titre,
                    subtitle: description,
                    statut: statut,
                    onTogglePublish: () =>
                        _togglePublierModule(doc.id, statut),
                    onTap: () {
                      final moduleId = doc.id;

                      setState(() {
                        _moduleId = moduleId;
                        _moduleTitre = titre;
                        _thematiqueId = null;
                        _thematiqueTitre = null;

                        _thematiquesStream = _db
                            .collection('modules')
                            .doc(moduleId)
                            .collection('thematiques')
                            .orderBy('ordre')
                            .snapshots();

                        _etapesStream = null;
                      });
                    },
                    onEdit: () => _modifierModule(doc.id, data),
                    onDelete: () => _supprimerModule(doc.id, titre),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PUBLIER / DEPUBLIER UN MODULE (NOUVEAU)
  // ============================================================

  Future<void> _togglePublierModule(
    String moduleId,
    String statutActuel,
  ) async {
    try {
      if (statutActuel == 'disponible') {
        await _service.depublierModule(moduleId);
        _message('Module dépublié : de nouveau invisible pour les adolescentes.');
      } else {
        await _service.publierModule(moduleId);
        _message('Module publié : visible par les adolescentes.');
      }
    } catch (e) {
      _message('Impossible de modifier la publication du module.');
    }
  }

  Future<void> _ajouterModule() async {
    final titre = TextEditingController();
    final sousTitre = TextEditingController();
    final description = TextEditingController();

    await _showFormDialog(
      title: 'Ajouter un module',
      fields: [
        _field('Titre du module', titre),
        _field('Sous-titre', sousTitre),
        _field('Description', description, maxLines: 4),
      ],
      onSave: () async {
        if (titre.text.trim().isEmpty) {
          _message('Le titre du module est obligatoire.');
          return;
        }

        try {
          final snapshot = await _db.collection('modules').get();

          await _service.ajouterModule(
            titre: titre.text,
            sousTitre: sousTitre.text,
            description: description.text,
            ordre: snapshot.docs.length + 1,
          );

          _message('Module ajouté en brouillon. Pense à le publier une fois prêt.');
        } catch (e) {
          _message('Impossible d’ajouter le module.');
        }
      },
    );
  }

  Future<void> _modifierModule(
    String id,
    Map<String, dynamic> data,
  ) async {
    final titre = TextEditingController(text: _value(data['titre'], ''));
    final sousTitre =
        TextEditingController(text: _value(data['sousTitre'], ''));
    final description =
        TextEditingController(text: _value(data['description'], ''));

    await _showFormDialog(
      title: 'Modifier le module',
      fields: [
        _field('Titre du module', titre),
        _field('Sous-titre', sousTitre),
        _field('Description', description, maxLines: 4),
      ],
      onSave: () async {
        if (titre.text.trim().isEmpty) {
          _message('Le titre du module est obligatoire.');
          return;
        }

        try {
          await _service.modifierModule(
            moduleId: id,
            titre: titre.text,
            sousTitre: sousTitre.text,
            description: description.text,
            ordre: _intValue(data['ordre'], 1),
            couleur: _value(data['couleur'], '#D4537E'),
            // Le statut ne se modifie plus ici : uniquement via le
            // bouton Publier/Dépublier, pour éviter qu'une simple
            // édition de texte republie un module par accident.
          );

          _message('Module modifié.');
        } catch (e) {
          _message('Impossible de modifier le module.');
        }
      },
    );
  }

  Widget _buildThematiques() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBreadcrumb(
          ['Contenus', _moduleTitre ?? 'Module'],
          () {
            setState(() {
              _moduleId = null;
              _moduleTitre = null;
              _thematiqueId = null;
              _thematiqueTitre = null;
              _thematiquesStream = null;
              _etapesStream = null;
            });
          },
        ),
        _buildPageHeader(
          _moduleTitre ?? 'Module',
          'Gérez les thématiques de ce module.',
        ),
        _sectionCard(
          title: 'Thématiques',
          trailing: _primaryButton(
            'Ajouter une thématique',
            Icons.add,
            _ajouterThematique,
          ),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _thematiquesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _loading();
              }

              if (snapshot.hasError) {
                return _messageCard(
                  Icons.error_outline,
                  'Erreur Firestore : ${snapshot.error}',
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return _messageCard(
                  Icons.topic_outlined,
                  'Aucune thématique. Ajoutez la première thématique de ce module.',
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data();
                  final titre =
                      _value(data['titre'], 'Thématique sans titre');
                  final description = _value(data['description'], '');

                  // Pas de champ statut ici : les thématiques héritent
                  // de la visibilité de leur module parent (voir
                  // firestore.rules -> moduleEstDisponible()).
                  return _contentTile(
                    icon: Icons.topic_outlined,
                    title: titre,
                    subtitle: description,
                    onTap: () {
                      if (_moduleId == null) return;

                      final thematiqueId = doc.id;

                      setState(() {
                        _thematiqueId = thematiqueId;
                        _thematiqueTitre = titre;

                        _etapesStream = _db
                            .collection('modules')
                            .doc(_moduleId)
                            .collection('thematiques')
                            .doc(thematiqueId)
                            .collection('etapes')
                            .orderBy('ordre')
                            .snapshots();
                      });

                      _verifierEtCompleterEtapes(
                        _moduleId!,
                        thematiqueId,
                      ).catchError((_) {});
                    },
                    onEdit: () => _modifierThematique(doc.id, data),
                    onDelete: () => _supprimerThematique(doc.id, titre),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _ajouterThematique() async {
    final titre = TextEditingController();
    final description = TextEditingController();

    await _showFormDialog(
      title: 'Ajouter une thématique',
      fields: [
        _field('Titre de la thématique', titre),
        _field('Description', description, maxLines: 4),
      ],
      onSave: () async {
        if (_moduleId == null) return;

        if (titre.text.trim().isEmpty) {
          _message('Le titre de la thématique est obligatoire.');
          return;
        }

        try {
          final snapshot = await _db
              .collection('modules')
              .doc(_moduleId)
              .collection('thematiques')
              .get();

          await _service.ajouterThematique(
            moduleId: _moduleId!,
            titre: titre.text,
            description: description.text,
            ordre: snapshot.docs.length + 1,
          );

          _message('Thématique ajoutée avec ses 5 étapes.');
        } catch (e) {
          _message('Impossible d’ajouter la thématique.');
        }
      },
    );
  }

  Future<void> _modifierThematique(
    String id,
    Map<String, dynamic> data,
  ) async {
    final titre = TextEditingController(text: _value(data['titre'], ''));
    final description =
        TextEditingController(text: _value(data['description'], ''));

    await _showFormDialog(
      title: 'Modifier la thématique',
      fields: [
        _field('Titre', titre),
        _field('Description', description, maxLines: 4),
      ],
      onSave: () async {
        if (_moduleId == null) return;

        try {
          await _service.modifierThematique(
            moduleId: _moduleId!,
            thematiqueId: id,
            titre: titre.text,
            description: description.text,
            ordre: _intValue(data['ordre'], 1),
          );

          _message('Thématique modifiée.');
        } catch (e) {
          _message('Impossible de modifier la thématique.');
        }
      },
    );
  }

  Future<void> _verifierEtCompleterEtapes(
    String moduleId,
    String thematiqueId,
  ) async {
    final thematiqueRef = _db
        .collection('modules')
        .doc(moduleId)
        .collection('thematiques')
        .doc(thematiqueId);

    final etapesRef = thematiqueRef.collection('etapes');
    final snapshot = await etapesRef.get();

    QueryDocumentSnapshot<Map<String, dynamic>>? etape3;
    QueryDocumentSnapshot<Map<String, dynamic>>? etape5;

    for (final doc in snapshot.docs) {
      final ordre = _intValue(doc.data()['ordre'], 0);

      if (ordre == 3) etape3 = doc;
      if (ordre == 5) etape5 = doc;
    }

    if (etape3 != null) {
      await etape3.reference.update({
        'ordre': 3,
        'type': 'observe',
        'titre': 'Approfondir',
        'dateModification': FieldValue.serverTimestamp(),
      });
    } else {
      await etapesRef.add({
        'ordre': 3,
        'type': 'observe',
        'titre': 'Approfondir',
        'statut': 'brouillon',
        'contenu': {'texte': '', 'videoUrl': '', 'illustrationUrl': ''},
        'dateCreation': FieldValue.serverTimestamp(),
        'dateModification': FieldValue.serverTimestamp(),
      });
    }

    if (etape5 == null) {
      await etapesRef.add({
        'ordre': 5,
        'type': 'joue',
        'titre': 'Activité',
         'statut': 'brouillon',
        'contenu': {'texte': '', 'videoUrl': '', 'illustrationUrl': ''},
        'jeu': {
          'typeJeu': 'situation',
          'situation': '',
          'pointsGagnes': 10,
          'choix': [],
        },
        'dateCreation': FieldValue.serverTimestamp(),
        'dateModification': FieldValue.serverTimestamp(),
      });
    }

    await thematiqueRef.update({
      'nombreEtapes': 5,
      'dateModification': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _togglePublierEtape(
  String etapeId,
  String statutActuel,
) async {
  if (_moduleId == null || _thematiqueId == null) return;

  try {
    if (statutActuel == 'publie') {
      await _service.depublierEtape(
        moduleId: _moduleId!,
        thematiqueId: _thematiqueId!,
        etapeId: etapeId,
      );

      _message('Étape dépubliée.');
    } else {
      await _service.publierEtape(
        moduleId: _moduleId!,
        thematiqueId: _thematiqueId!,
        etapeId: etapeId,
      );

      _message('Étape publiée.');
    }
  } catch (e) {
    _message('Erreur : $e');
  }
}

  Widget _buildEtapes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBreadcrumb(
          ['Contenus', _moduleTitre ?? 'Module', _thematiqueTitre ?? 'Thématique'],
          () {
            setState(() {
              _thematiqueId = null;
              _thematiqueTitre = null;
              _etapesStream = null;
            });
          },
        ),
        _buildPageHeader(
          _thematiqueTitre ?? 'Thématique',
          'Gérez les cinq étapes du parcours pédagogique.',
        ),
        _sectionCard(
          title: 'Parcours pédagogique',
          trailing: _primaryButton(
            'Ajouter une étape',
            Icons.add,
            _ajouterEtape,
          ),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _etapesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _loading();
              }

              if (snapshot.hasError) {
                return _messageCard(
                  Icons.error_outline,
                  'Impossible de charger les étapes.',
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return _messageCard(
                  Icons.layers_outlined,
                  'Aucune étape pour le moment.',
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data();
                  final ordre = _intValue(data['ordre'], 0);
                  final titre = _value(data['titre'], 'Étape $ordre');
                  final type = _value(data['type'], 'decouvre');
                  final statut = _value(data['statut'], 'brouillon');

                  return _etapeTile(
                    ordre: ordre,
                    titre: titre,
                    type: type,
                    statut: statut,
                    onEdit: () => _modifierEtape(doc.id, data),
                    onDelete: () => _supprimerEtape(doc.id, titre),
                    onTogglePublish: () => _togglePublierEtape(
                    doc.id,
                    statut,
                    ), 
                  );
                }).toList().cast<Widget>(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _etapeTile({
  required int ordre,
  required String titre,
  required String type,
  required String statut,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
  required VoidCallback onTogglePublish,
}) {
  final bool estPublie = statut == 'publie';

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: _bordure,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --------------------------------------------------
        // NUMERO DE L'ETAPE
        // --------------------------------------------------
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: estPublie
                ? _vert.withOpacity(0.10)
                : _orange.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$ordre',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: estPublie ? _vert : _orange,
            ),
          ),
        ),

        const SizedBox(width: 14),

        // --------------------------------------------------
        // INFORMATIONS
        // --------------------------------------------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _texte,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                _libelleTypeEtape(type),
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  color: _gris,
                ),
              ),

              const SizedBox(height: 8),

              // ------------------------------------------------
              // STATUT
              // ------------------------------------------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: estPublie
                      ? _vert.withOpacity(0.10)
                      : _orange.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estPublie ? 'Publié' : 'Brouillon',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: estPublie ? _vert : _orange,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // --------------------------------------------------
        // PUBLIER / DEPUBLIER
        // --------------------------------------------------
        IconButton(
          tooltip: estPublie ? 'Dépublier' : 'Publier',
          onPressed: onTogglePublish,
          icon: Icon(
            estPublie
                ? Icons.visibility_off_outlined
                : Icons.publish_outlined,
            color: estPublie ? _orange : _vert,
          ),
        ),

        // --------------------------------------------------
        // MODIFIER
        // --------------------------------------------------
        IconButton(
          tooltip: 'Modifier',
          onPressed: onEdit,
          icon: const Icon(
            Icons.edit_outlined,
          ),
        ),

        // --------------------------------------------------
        // SUPPRIMER
        // --------------------------------------------------
        IconButton(
          tooltip: 'Supprimer',
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.redAccent,
          ),
        ),
      ],
    ),
  );
}

  Future<void> _ajouterEtape() async {
    if (_moduleId == null || _thematiqueId == null) return;

    final titre = TextEditingController();
    final texte = TextEditingController();
    final videoUrl = TextEditingController();
    final illustrationUrl = TextEditingController();

    String type = 'decouvre';

    final situation = TextEditingController();
    final question = TextEditingController();
    final points = TextEditingController(text: '10');

    final choix = List.generate(3, (_) => _ChoixControllers());

    await _showEtapeDialog(
      titreDialog: 'Ajouter une étape',
      titre: titre,
      texte: texte,
      videoUrl: videoUrl,
      illustrationUrl: illustrationUrl,
      typeInitial: type,
      typeJeuInitial: 'qcm',
      question: question,
      situation: situation,
      points: points,
      choix: choix,
      onSave: ({required String type, required Map<String, dynamic>? jeu}) async {
        final snapshot = await _db
            .collection('modules')
            .doc(_moduleId)
            .collection('thematiques')
            .doc(_thematiqueId)
            .collection('etapes')
            .get();

        await _service.ajouterEtape(
          moduleId: _moduleId!,
          thematiqueId: _thematiqueId!,
          ordre: snapshot.docs.length + 1,
          type: type,
          titre: titre.text,
          texte: texte.text,
          videoUrl: videoUrl.text,
          illustrationUrl: illustrationUrl.text,
          jeu: jeu,
        );

        _message('Étape ajoutée.');
      },
    );

    _disposeChoix(choix);
  }

 Future<void> _modifierEtape(
  String id,
  Map<String, dynamic> data,
) async {
  if (_moduleId == null || _thematiqueId == null) return;

  // ============================================================
  // CONTENU
  // ============================================================

  final contenu = data['contenu'] is Map
      ? Map<String, dynamic>.from(
          data['contenu'] as Map,
        )
      : <String, dynamic>{};

  final titre = TextEditingController(
    text: _value(
      data['titre'],
      '',
    ),
  );

  final texte = TextEditingController(
    text: _value(
      contenu['texte'] ?? data['texte'],
      '',
    ),
  );

  final videoUrl = TextEditingController(
    text: _value(
      contenu['videoUrl'] ?? data['videoUrl'],
      '',
    ),
  );

  final illustrationUrl = TextEditingController(
    text: _value(
      contenu['illustrationUrl'] ?? data['illustrationUrl'],
      '',
    ),
  );

  // ============================================================
  // DONNÉES DE L'ACTIVITÉ
  // ============================================================

  final question = TextEditingController();

  final situation = TextEditingController();

  final points = TextEditingController(
    text: '10',
  );

  final jeuData = data['jeu'] is Map
      ? Map<String, dynamic>.from(
          data['jeu'] as Map,
        )
      : <String, dynamic>{};

  // Type de jeu :
  // qcm ou situation
  final typeJeuInitial =
      ['qcm', 'situation'].contains(
        _value(
          jeuData['typeJeu'],
          'qcm',
        ),
      )
          ? _value(
              jeuData['typeJeu'],
              'qcm',
            )
          : 'qcm';

  // Question du QCM
  question.text = _value(
    jeuData['question'],
    '',
  );

  // Situation de vie
  situation.text = _value(
    jeuData['situation'],
    '',
  );

  // Points
  points.text = _intValue(
    jeuData['pointsGagnes'],
    10,
  ).toString();

  // ============================================================
  // CHOIX DE RÉPONSES
  // ============================================================

  final choix = <_ChoixControllers>[];

  final choixData = jeuData['choix'] is List
      ? List<dynamic>.from(
          jeuData['choix'] as List,
        )
      : <dynamic>[];

  if (choixData.isEmpty) {
    choix.addAll(
      List.generate(
        3,
        (_) => _ChoixControllers(),
      ),
    );
  } else {
    for (final element in choixData) {
      if (element is Map) {
        final map = Map<String, dynamic>.from(
          element,
        );

        choix.add(
          _ChoixControllers(
            id: _value(
              map['id'],
              DateTime.now()
                  .microsecondsSinceEpoch
                  .toString(),
            ),
            texte: _value(
              map['texte'],
              '',
            ),
            feedback: _value(
              map['feedback'],
              '',
            ),
            correct: map['correct'] == true,
          ),
        );
      }
    }
  }

  // Sécurité : toujours au moins deux choix
  if (choix.length < 2) {
    while (choix.length < 2) {
      choix.add(
        _ChoixControllers(),
      );
    }
  }

  // ============================================================
  // TYPE D'ÉTAPE
  // ============================================================

  final type = _value(
    data['type'],
    'decouvre',
  );

  // ============================================================
  // OUVERTURE DU FORMULAIRE
  // ============================================================

  await _showEtapeDialog(
    titreDialog: 'Modifier l’étape',

    titre: titre,
    texte: texte,
    videoUrl: videoUrl,
    illustrationUrl: illustrationUrl,

    typeInitial: type,

    // Données activité
    typeJeuInitial: typeJeuInitial,
    question: question,
    situation: situation,
    points: points,
    choix: choix,

    onSave: ({
      required String type,
      required Map<String, dynamic>? jeu,
    }) async {
      await _service.modifierEtape(
        moduleId: _moduleId!,
        thematiqueId: _thematiqueId!,
        etapeId: id,
        ordre: _intValue(
          data['ordre'],
          1,
        ),
        type: type,
        titre: titre.text,
        texte: texte.text,
        videoUrl: videoUrl.text,
        illustrationUrl: illustrationUrl.text,
        jeu: jeu,
      );

      _message(
        'Étape modifiée.',
      );
    },
  );

  // ============================================================
  // LIBÉRATION DES CONTRÔLEURS
  // ============================================================

  question.dispose();
  _disposeChoix(choix);
}

 Future<void> _showEtapeDialog({
  required String titreDialog,
  required TextEditingController titre,
  required TextEditingController texte,
  required TextEditingController videoUrl,
  required TextEditingController illustrationUrl,
  required String typeInitial,

  // Données de l'activité
  required String typeJeuInitial,
  required TextEditingController question,
  required TextEditingController situation,
  required TextEditingController points,
  required List<_ChoixControllers> choix,

  required Future<void> Function({
    required String type,
    required Map<String, dynamic>? jeu,
  }) onSave,
}) async {
  String type = [
    'decouvre',
    'regarde',
    'observe',
    'retiens',
    'joue',
  ].contains(typeInitial)
      ? typeInitial
      : 'decouvre';

  // Type de jeu : qcm ou situation
  String typeJeu = ['qcm', 'situation'].contains(typeJeuInitial)
      ? typeJeuInitial
      : 'qcm';

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setLocalState) {
          final estJeu = type == 'joue';

          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Text(
              titreDialog,
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _texte,
              ),
            ),
            content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // =====================================================
                    // TITRE
                    // =====================================================
                    _field(
                      'Titre de l’étape',
                      titre,
                    ),

                    const SizedBox(height: 14),

                    // =====================================================
                    // TYPE D'ÉTAPE
                    // =====================================================
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: _decoration(
                        'Type d’étape',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'decouvre',
                          child: Text('Découvrir'),
                        ),
                        DropdownMenuItem(
                          value: 'regarde',
                          child: Text('Regarder'),
                        ),
                        DropdownMenuItem(
                          value: 'observe',
                          child: Text('Approfondir'),
                        ),
                        DropdownMenuItem(
                          value: 'retiens',
                          child: Text('Je retiens'),
                        ),
                        DropdownMenuItem(
                          value: 'joue',
                          child: Text('Activité'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() {
                            type = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    // =====================================================
                    // CONTENU PÉDAGOGIQUE
                    // =====================================================
                    if (!estJeu) ...[
                      _field(
                        'Contenu pédagogique',
                        texte,
                        maxLines: 7,
                      ),

                      const SizedBox(height: 14),

                      _field(
                        'URL de la vidéo',
                        videoUrl,
                      ),

                      const SizedBox(height: 14),

                      _field(
                        'URL de l’illustration',
                        illustrationUrl,
                      ),
                    ],

                    // =====================================================
                    // ACTIVITÉ
                    // =====================================================
                    if (estJeu)
                      _activityEditor(
                        typeJeu: typeJeu,
                        question: question,
                        situation: situation,
                        points: points,
                        choix: choix,
                        setLocalState: setLocalState,
                        onTypeJeuChanged: (value) {
                          setLocalState(() {
                          typeJeu = value;
                         });
                        },
                      ),
                  ],
                ),
              ),
            ),

            actionsPadding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              18,
            ),

            actions: [
              // =========================================================
              // ANNULER
              // =========================================================
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  'Annuler',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w700,
                    color: _gris,
                  ),
                ),
              ),

              // =========================================================
              // ENREGISTRER
              // =========================================================
              ElevatedButton(
                onPressed: () async {
                  // ---------------------------------------------------
                  // Vérification du titre
                  // ---------------------------------------------------
                  if (titre.text.trim().isEmpty) {
                    _message(
                      'Le titre de l’étape est obligatoire.',
                    );
                    return;
                  }

                  Map<String, dynamic>? jeu;

                  // ---------------------------------------------------
                  // Construction de l'activité
                  // ---------------------------------------------------
                  if (type == 'joue') {
                    final pointsValue =
                        int.tryParse(points.text.trim()) ?? 10;

                    final choixFiltres = choix
                        .where(
                          (c) => c.texte.text.trim().isNotEmpty,
                        )
                        .map(
                          (c) => {
                            'id': c.id,
                            'texte': c.texte.text.trim(),
                            'correct': c.correct,
                            'feedback': c.feedback.text.trim(),
                          },
                        )
                        .toList();

                    // =================================================
                    // QCM
                    // =================================================
                    if (typeJeu == 'qcm') {
                      if (question.text.trim().isEmpty) {
                        _message(
                          'La question du QCM est obligatoire.',
                        );
                        return;
                      }

                      if (choixFiltres.length < 2) {
                        _message(
                          'Ajoutez au moins deux choix de réponse.',
                        );
                        return;
                      }

                      final nombreBonnesReponses =
                          choixFiltres
                              .where(
                                (c) => c['correct'] == true,
                              )
                              .length;

                      if (nombreBonnesReponses != 1) {
                        _message(
                          'Un QCM doit avoir une seule bonne réponse.',
                        );
                        return;
                      }

                      jeu = {
                        'typeJeu': 'qcm',
                        'question': question.text.trim(),
                        'pointsGagnes': pointsValue,
                        'choix': choixFiltres,
                      };
                    }

                    // =================================================
                    // SITUATION DE VIE
                    // =================================================
                    else {
                      if (situation.text.trim().isEmpty) {
                        _message(
                          'La situation de l’activité est obligatoire.',
                        );
                        return;
                      }

                      if (choixFiltres.length < 2) {
                        _message(
                          'Ajoutez au moins deux choix de réponse.',
                        );
                        return;
                      }

                      jeu = {
                        'typeJeu': 'situation',
                        'situation': situation.text.trim(),
                        'pointsGagnes': pointsValue,
                        'choix': choixFiltres,
                      };
                    }
                  }

                  // Fermer la boîte de dialogue
                  Navigator.pop(dialogContext);

                  // Sauvegarder dans Firestore
                  await onSave(
                    type: type,
                    jeu: jeu,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vert,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Enregistrer',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

 Widget _activityEditor({
  required String typeJeu,
  required TextEditingController question,
  required TextEditingController situation,
  required TextEditingController points,
  required List<_ChoixControllers> choix,
  required void Function(void Function()) setLocalState,
  required void Function(String value) onTypeJeuChanged,
}) {
  final estQcm = typeJeu == 'qcm';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ============================================================
      // EN-TÊTE
      // ============================================================

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _rose.withOpacity(.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _rose.withOpacity(.18),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              estQcm
                  ? Icons.quiz_outlined
                  : Icons.forum_outlined,
              color: _rose,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                estQcm
                    ? 'Créez une question à choix multiples puis définissez les réponses proposées à l’adolescente.'
                    : 'Créez une situation de vie puis définissez les choix proposés à l’adolescente.',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  height: 1.4,
                  color: _texte,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),

      // ============================================================
      // TYPE D'ACTIVITÉ
      // ============================================================

      DropdownButtonFormField<String>(
        value: typeJeu,
        decoration: _decoration(
          'Type d’activité',
        ),
        items: const [
          DropdownMenuItem(
            value: 'qcm',
            child: Text('QCM'),
          ),
          DropdownMenuItem(
            value: 'situation',
            child: Text('Situation de vie'),
          ),
        ],
        onChanged: (value) {
  if (value != null) {
    onTypeJeuChanged(value);
  }
},
      ),

      const SizedBox(height: 14),

      // ============================================================
      // QUESTION QCM OU SITUATION
      // ============================================================

      if (estQcm)
        _field(
          'Question du QCM',
          question,
          maxLines: 4,
        )
      else
        _field(
          'Situation de l’activité',
          situation,
          maxLines: 5,
        ),

      const SizedBox(height: 14),

      // ============================================================
      // POINTS
      // ============================================================

      _field(
        'Points gagnés',
        points,
      ),

      const SizedBox(height: 18),

      // ============================================================
      // CHOIX
      // ============================================================

      Row(
        children: [
          Expanded(
            child: Text(
              estQcm
                  ? 'Réponses proposées'
                  : 'Choix proposés',
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _texte,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              setLocalState(() {
                choix.add(
                  _ChoixControllers(),
                );
              });
            },
            icon: const Icon(
              Icons.add,
              size: 17,
            ),
            label: const Text(
              'Ajouter',
            ),
          ),
        ],
      ),

      const SizedBox(height: 8),

      // ============================================================
      // LISTE DES CHOIX
      // ============================================================

      ...List.generate(
        choix.length,
        (index) {
          final item = choix[index];

          return Container(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _fond,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _bordure,
              ),
            ),
            child: Column(
              children: [
                // --------------------------------------------------
                // ENTÊTE DU CHOIX
                // --------------------------------------------------

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        estQcm
                            ? 'Réponse ${index + 1}'
                            : 'Choix ${index + 1}',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w800,
                          color: _texte,
                        ),
                      ),
                    ),

                    Checkbox(
                      value: item.correct,
                      activeColor: _vert,
                      onChanged: (value) {
                        setLocalState(() {
                          final nouvelleValeur =
                              value ?? false;

                          if (estQcm &&
                              nouvelleValeur) {
                            // Un QCM possède une seule
                            // bonne réponse.
                            for (final autre in choix) {
                              autre.correct = false;
                            }
                          }

                          item.correct =
                              nouvelleValeur;
                        });
                      },
                    ),

                    Text(
                      'Bonne réponse',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        color: _gris,
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        if (choix.length <= 2) {
                          _message(
                            'Une activité doit conserver au moins deux choix.',
                          );
                          return;
                        }

                        setLocalState(() {
                          item.dispose();
                          choix.removeAt(index);
                        });
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 19,
                        color: _rose,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // --------------------------------------------------
                // TEXTE DU CHOIX
                // --------------------------------------------------

                _field(
                  estQcm
                      ? 'Texte de la réponse'
                      : 'Texte du choix',
                  item.texte,
                  maxLines: 2,
                ),

                const SizedBox(height: 10),

                // --------------------------------------------------
                // FEEDBACK
                // --------------------------------------------------

                _field(
                  'Feedback après la réponse',
                  item.feedback,
                  maxLines: 2,
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}

  Future<void> _supprimerModule(String id, String titre) async {
    final confirmation = await _confirmation(
      'Supprimer le module ?',
      'Le module "$titre", ses thématiques et ses étapes seront supprimés.',
    );

    if (!confirmation) return;

    try {
      await _service.supprimerModule(id);

      setState(() {
        _moduleId = null;
        _moduleTitre = null;
        _thematiqueId = null;
        _thematiqueTitre = null;
      });

      _message('Module supprimé.');
    } catch (e) {
      _message('Impossible de supprimer le module.');
    }
  }

  Future<void> _supprimerThematique(String id, String titre) async {
    if (_moduleId == null) return;

    final confirmation = await _confirmation(
      'Supprimer la thématique ?',
      'La thématique "$titre" et ses étapes seront supprimées.',
    );

    if (!confirmation) return;

    try {
      await _service.supprimerThematique(moduleId: _moduleId!, thematiqueId: id);

      setState(() {
        _thematiqueId = null;
        _thematiqueTitre = null;
      });

      _message('Thématique supprimée.');
    } catch (e) {
      _message('Impossible de supprimer la thématique.');
    }
  }

  Future<void> _supprimerEtape(String id, String titre) async {
    if (_moduleId == null || _thematiqueId == null) return;

    final confirmation = await _confirmation(
      'Supprimer l’étape ?',
      'L’étape "$titre" sera supprimée.',
    );

    if (!confirmation) return;

    try {
      await _service.supprimerEtape(
        moduleId: _moduleId!,
        thematiqueId: _thematiqueId!,
        etapeId: id,
      );

      _message('Étape supprimée.');
    } catch (e) {
      _message('Impossible de supprimer l’étape.');
    }
  }

  Widget _buildUtilisateurs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader('Gestion des utilisateurs', 'Consultez les comptes et gérez leurs rôles.'),
        _sectionCard(
          title: 'Utilisateurs',
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _usersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _loading();
              }

              if (snapshot.hasError) {
                return _messageCard(Icons.error_outline, 'Impossible de charger les utilisateurs.');
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return _messageCard(Icons.people_outline, 'Aucun utilisateur.');
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data();
                  final role = _value(data['role'], 'non défini');
                  final nom = _value(data['surnom'] ?? data['nom'], 'Utilisateur');

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: _vert.withOpacity(.10),
                      child: const Icon(Icons.person_outline, color: _vert),
                    ),
                    title: Text(
                      nom,
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, color: _texte),
                    ),
                    subtitle: Text(
                      _libelleRole(role),
                      style: GoogleFonts.quicksand(color: _gris, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, color: _vert),
                      onPressed: () => _modifierRole(doc.id, role),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _modifierRole(String uid, String roleActuel) async {
    String role = ['adolescente', 'professionnel', 'administrateur'].contains(roleActuel)
        ? roleActuel
        : 'adolescente';

    await _showSimpleDialog(
      title: 'Modifier le rôle',
      child: StatefulBuilder(
        builder: (context, setLocalState) {
          return DropdownButtonFormField<String>(
            value: role,
            decoration: _decoration('Rôle'),
            items: const [
              DropdownMenuItem(value: 'adolescente', child: Text('Adolescente')),
              DropdownMenuItem(value: 'professionnel', child: Text('Professionnel')),
              DropdownMenuItem(value: 'administrateur', child: Text('Administrateur')),
            ],
            onChanged: (value) {
              if (value != null) {
                setLocalState(() {
                  role = value;
                });
              }
            },
          );
        },
      ),
      onSave: () async {
        await _db.collection('users').doc(uid).update({'role': role});
        _message('Rôle modifié.');
      },
    );
  }

  Widget _buildActivites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader('Gestion des activités', 'Gérez les activités interactives des parcours.'),
        _sectionCard(
          title: 'Activités',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Les activités sont rattachées aux étapes de type « Activité ».',
                style: GoogleFonts.quicksand(fontSize: 14, height: 1.5, color: _gris),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selection = 2;
                    _moduleId = null;
                    _thematiqueId = null;
                  });
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Configurer une activité depuis une étape'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vert,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(
          'Gestion des alertes',
          'Suivez les demandes nécessitant une orientation ou un accompagnement.',
        ),
        _sectionCard(
          title: 'Demandes d’accompagnement',
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _demandesOrderedStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _loading();
              }

              if (snapshot.hasError) {
                return _messageCard(Icons.error_outline, 'Impossible de charger les demandes.');
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return _messageCard(Icons.notifications_none_outlined, 'Aucune demande enregistrée.');
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data();

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: const Icon(Icons.notifications_none_outlined, color: _rose),
                    title: Text(
                      _value(data['codeAnonyme'], 'Demande'),
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, color: _texte),
                    ),
                    subtitle: Text(
                      _value(data['motif'], 'Demande d’accompagnement'),
                      style: GoogleFonts.quicksand(color: _gris),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatistiques() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader('Statistiques', 'Indicateurs généraux de la plateforme.'),
        _sectionCard(
          title: 'Répartition des utilisateurs',
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _usersStream,
            builder: (context, snapshot) {
              if (snapshot.hasError && snapshot.data == null) {
                return _messageCard(Icons.error_outline, 'Impossible de charger les utilisateurs.');
              }

              if (snapshot.data == null) {
                return _loading();
              }

              final docs = snapshot.data!.docs;

              int adolescentes = 0;
              int professionnels = 0;
              int administrateurs = 0;

              for (final doc in docs) {
                final role = doc.data()['role'];

                if (role == 'adolescente') adolescentes++;
                if (role == 'professionnel') professionnels++;
                if (role == 'administrateur') administrateurs++;
              }

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _smallStat('Adolescentes', adolescentes, _vert),
                  _smallStat('Professionnels', professionnels, _turquoise),
                  _smallStat('Administrateurs', administrateurs, _rose),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _smallStat(String title, int value, Color color) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _fond,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _bordure),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w600, color: _gris),
          ),
          const SizedBox(height: 5),
          Text(
            '$value',
            style: GoogleFonts.quicksand(fontSize: 25, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bordure),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w800, color: _texte),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // TUILE DE CONTENU (module ou thématique)
  // ============================================================
  //
  // NOUVEAU : paramètres 'statut' et 'onTogglePublish', optionnels.
  // Fournis uniquement pour les modules (les thématiques n'ont pas
  // de statut propre -- voir firestore.rules / thematique.dart).
  // Quand présents, une pastille Brouillon/Disponible et un bouton
  // de bascule s'affichent avant Modifier/Supprimer.

  Widget _contentTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    String? statut,
    VoidCallback? onTogglePublish,
  }) {
    final bool afficherStatut = statut != null && onTogglePublish != null;
    final bool estDisponible = statut == 'publie';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _fond,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _bordure),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: _vert.withOpacity(.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _vert, size: 22),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 14, color: _texte),
              ),
            ),
            if (afficherStatut) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: estDisponible ? _vert.withOpacity(.12) : _orange.withOpacity(.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estDisponible ? 'publie' : 'Brouillon',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: estDisponible ? _vert : _orange,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: subtitle.isEmpty
            ? null
            : Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.quicksand(fontSize: 12, color: _gris),
              ),
        trailing: SizedBox(
          width: afficherStatut ? 120 : 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (afficherStatut)
                IconButton(
                  tooltip: estDisponible ? 'Dépublier' : 'Publier',
                  onPressed: onTogglePublish,
                  icon: Icon(
                    estDisponible ? Icons.visibility_off_outlined : Icons.publish_outlined,
                    size: 19,
                    color: estDisponible ? _orange : _vert,
                  ),
                ),
              IconButton(
                tooltip: 'Modifier',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 19, color: _vert),
              ),
              IconButton(
                tooltip: 'Supprimer',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 19, color: _rose),
              ),
              const Icon(Icons.chevron_right_rounded, color: _gris),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(List<String> items, VoidCallback onBack) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onBack,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_rounded, size: 18, color: _vert),
            const SizedBox(width: 7),
            Text(
              items.join(' / '),
              style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w700, color: _vert),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: _vert,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        textStyle: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }

  Widget _loading() {
    return const Padding(
      padding: EdgeInsets.all(30),
      child: Center(child: CircularProgressIndicator(color: _vert, strokeWidth: 2.5)),
    );
  }

  Widget _messageCard(IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: _fond, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Icon(icon, size: 35, color: _gris),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.w600, color: _gris),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: _decoration(label),
      style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.w600, color: _texte),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.quicksand(fontSize: 13, color: _gris, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: _fond,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _bordure),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _bordure),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _vert, width: 1.5),
      ),
    );
  }

  Future<void> _showFormDialog({
    required String title,
    required List<Widget> fields,
    required Future<void> Function() onSave,
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            title,
            style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w800, color: _texte),
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < fields.length; i++) ...[
                    fields[i],
                    if (i != fields.length - 1) const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Annuler',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w700, color: _gris),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await onSave();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _vert,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text('Enregistrer', style: GoogleFonts.quicksand(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSimpleDialog({
    required String title,
    required Widget child,
    required Future<void> Function() onSave,
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            title,
            style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w800, color: _texte),
          ),
          content: SizedBox(width: 450, child: child),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await onSave();
              },
              style: ElevatedButton.styleFrom(backgroundColor: _vert, foregroundColor: Colors.white),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmation(String titre, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            titre,
            style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, color: _texte),
          ),
          content: Text(message, style: GoogleFonts.quicksand(color: _gris, height: 1.4)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Annuler',
                style: GoogleFonts.quicksand(color: _gris, fontWeight: FontWeight.w700),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _rose,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text('Supprimer', style: GoogleFonts.quicksand(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  String _value(dynamic value, String fallback) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }

  int _intValue(dynamic value, int fallback) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _libelleTypeEtape(String type) {
    switch (type) {
      case 'decouvre':
        return 'Découvrir';
      case 'regarde':
        return 'Regarder';
      case 'observe':
        return 'Approfondir';
      case 'retiens':
        return 'Je retiens';
      case 'joue':
        return 'Activité interactive';
      default:
        return 'Contenu pédagogique';
    }
  }

  String _libelleRole(String role) {
    switch (role) {
      case 'adolescente':
        return 'Adolescente';
      case 'professionnel':
        return 'Professionnel';
      case 'administrateur':
        return 'Administrateur';
      default:
        return role;
    }
  }

  void _disposeChoix(List<_ChoixControllers> choix) {
    for (final item in choix) {
      item.dispose();
    }
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.quicksand(fontWeight: FontWeight.w600)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

void _deconnexion() {
    _auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }
}

class _ChoixControllers {
  final String id;

  final TextEditingController texte;
  final TextEditingController feedback;

  bool correct;

  _ChoixControllers({
    String? id,
    String? texte,
    String? feedback,
    this.correct = false,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        texte = TextEditingController(text: texte ?? ''),
        feedback = TextEditingController(text: feedback ?? '');

  void dispose() {
    texte.dispose();
    feedback.dispose();
  }
}

class _MenuItem {
  final IconData icon;
  final String label;

  const _MenuItem(this.icon, this.label);
}