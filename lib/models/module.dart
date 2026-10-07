class Module {
  final String id;
  final String titre;
  final String sousTitre;
  final String description;
  final int ordre;
  final String icone;
  final String couleur;
  final String statut;
  final int nombreThematiques;

  Module({
    required this.id,
    required this.titre,
    required this.sousTitre,
    required this.description,
    required this.ordre,
    required this.icone,
    required this.couleur,
    required this.statut,
    required this.nombreThematiques,
  });

  factory Module.fromFirestore(String id, Map<String, dynamic> data) {
    return Module(
      id: id,
      titre: data['titre'] ?? '',
      sousTitre: data['sousTitre'] ?? '',
      description: data['description'] ?? '',
      ordre: data['ordre'] ?? 0,
      icone: data['icone'] ?? '',
      couleur: data['couleur'] ?? '#4CAF50',
      // CORRIGÉ : le repli était 'a_venir', une 3e valeur de statut
      // différente de 'brouillon'/'disponible' utilisées partout
      // ailleurs (firestore_service.dart, firestore.rules,
      // parcours_screen.dart). Un module sans champ 'statut' -- un
      // ancien document créé avant la mise en place du workflow, par
      // exemple -- doit être traité comme un brouillon (donc invisible
      // pour les adolescentes), pas comme un 3e état non géré nulle
      // part ailleurs dans le code.
      statut: data['statut'] ?? 'brouillon',
      nombreThematiques: data['nombreThematiques'] ?? 0,
    );
  }
}