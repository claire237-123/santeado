class Thematique {
  final String id;
  final String titre;
  final int ordre;
  final String description;
  final int nombreEtapes;

  Thematique({
    required this.id,
    required this.titre,
    required this.ordre,
    required this.description,
    required this.nombreEtapes,
  });

  factory Thematique.fromFirestore(String id, Map<String, dynamic> data) {
    return Thematique(
      id: id,
      titre: data['titre'] ?? '',
      ordre: data['ordre'] ?? 0,
      description: data['description'] ?? '',
      nombreEtapes: data['nombreEtapes'] ?? 0,
    );
  }
}