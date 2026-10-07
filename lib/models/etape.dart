class Choix {
  final String id;
  final String texte;
  final bool correct;
  final String feedback;

  Choix({
    required this.id,
    required this.texte,
    required this.correct,
    required this.feedback,
  });

  factory Choix.fromMap(Map<String, dynamic> data) {
    return Choix(
      id: data['id']?.toString() ?? '',
      texte: data['texte']?.toString() ?? '',
      correct: data['correct'] == true,
      feedback: data['feedback']?.toString() ?? '',
    );
  }
}

class Jeu {
  final String typeJeu;
  final String situation;
  final int pointsGagnes;
  final List<Choix> choix;

  Jeu({
    required this.typeJeu,
    required this.situation,
    required this.pointsGagnes,
    required this.choix,
  });

  factory Jeu.fromMap(Map<String, dynamic> data) {
    final listeChoix = (data['choix'] as List<dynamic>? ?? [])
        .map(
          (c) => Choix.fromMap(
            Map<String, dynamic>.from(c as Map),
          ),
        )
        .toList();

    return Jeu(
      typeJeu: data['typeJeu']?.toString() ?? 'situation',
      situation: data['situation']?.toString() ?? '',
      pointsGagnes: data['pointsGagnes'] is int
          ? data['pointsGagnes']
          : int.tryParse(
                data['pointsGagnes']?.toString() ?? '',
              ) ??
              10,
      choix: listeChoix,
    );
  }
}

class Etape {
  final String id;
  final int ordre;
  final String type;
  final String titre;
  final String texte;
  final String videoUrl;
  final String illustrationUrl;
  final Jeu? jeu;

  Etape({
    required this.id,
    required this.ordre,
    required this.type,
    required this.titre,
    required this.texte,
    required this.videoUrl,
    required this.illustrationUrl,
    this.jeu,
  });

  factory Etape.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final contenu = data['contenu'] is Map
        ? Map<String, dynamic>.from(
            data['contenu'] as Map,
          )
        : <String, dynamic>{};

    final jeuData = data['jeu'] is Map
        ? Map<String, dynamic>.from(
            data['jeu'] as Map,
          )
        : null;

    return Etape(
      id: id,

      ordre: data['ordre'] is int
          ? data['ordre']
          : int.tryParse(
                data['ordre']?.toString() ?? '',
              ) ??
              0,

      type: data['type']?.toString() ?? 'decouvre',

      titre: data['titre']?.toString() ?? '',

      texte: contenu['texte']?.toString() ??
          data['texte']?.toString() ??
          '',

      videoUrl: contenu['videoUrl']?.toString() ??
          data['videoUrl']?.toString() ??
          '',

      illustrationUrl:
          contenu['illustrationUrl']?.toString() ??
              data['illustrationUrl']?.toString() ??
              '',

      jeu: (jeuData != null && jeuData.isNotEmpty)
          ? Jeu.fromMap(jeuData)
          : null,
    );
  }
}