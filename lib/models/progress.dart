import 'package:cloud_firestore/cloud_firestore.dart';

class Progress {
  final String id;
  final String userId;
  final String moduleId;
  final String thematiqueId;
  final String statut; // verrouille | en_cours | termine
  final int derniereEtape;
  final int scoreMeilleur;
  final int nombreEssais;
  final DateTime? dateMaj;

  Progress({
    this.id = '',
    required this.userId,
    required this.moduleId,
    this.thematiqueId = '',
    required this.statut,
    required this.derniereEtape,
    required this.scoreMeilleur,
    required this.nombreEssais,
    this.dateMaj,
  });

  // Factory depuis DocumentSnapshot
  factory Progress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Progress.fromMap(data, id: doc.id);
  }

  // Factory depuis Map<String, dynamic> (pour compatibilité avec FirestoreService)
  //
  // CORRIGÉ : lisait auparavant la clé 'userId', qui n'existe pas dans
  // les documents réellement écrits par firestore_service.dart
  // (marquerThematiqueTerminee écrit sous la clé 'uid'). Résultat :
  // Progress.userId valait systématiquement '' après lecture. On lit
  // maintenant 'uid', avec un repli sur 'userId' pour ne pas casser
  // d'éventuels documents déjà écrits avec l'ancienne clé.
  factory Progress.fromMap(Map<String, dynamic> data, {String id = ''}) {
    return Progress(
      id: id,
      userId: data['uid'] ?? data['userId'] ?? '',
      moduleId: data['moduleId'] ?? '',
      thematiqueId: data['thematiqueId'] ?? '',
      statut: data['statut'] ?? 'verrouille',
      derniereEtape: (data['derniereEtape'] as num?)?.toInt() ?? 0,
      scoreMeilleur: (data['scoreMeilleur'] as num?)?.toInt() ?? 0,
      nombreEssais: (data['nombreEssais'] as num?)?.toInt() ?? 0,
      dateMaj: (data['dateMaj'] as Timestamp?)?.toDate(),
    );
  }

  // Conversion en Map pour écriture dans Firestore
  //
  // CORRIGÉ : écrit désormais sous la clé 'uid', pour rester cohérent
  // avec ce que firestore_service.dart écrit et avec ce que
  // firestore.rules attend (resource.data.uid == request.auth.uid).
  // Cette méthode n'est utilisée par aucun code vu jusqu'ici, mais
  // mieux vaut la corriger avant qu'elle ne serve.
  Map<String, dynamic> toMap() {
    return {
      'uid': userId,
      'moduleId': moduleId,
      'thematiqueId': thematiqueId,
      'statut': statut,
      'derniereEtape': derniereEtape,
      'scoreMeilleur': scoreMeilleur,
      'nombreEssais': nombreEssais,
      'dateMaj': dateMaj != null ? Timestamp.fromDate(dateMaj!) : FieldValue.serverTimestamp(),
    };
  }

  Progress copyWith({
    String? id,
    String? userId,
    String? moduleId,
    String? thematiqueId,
    String? statut,
    int? derniereEtape,
    int? scoreMeilleur,
    int? nombreEssais,
    DateTime? dateMaj,
  }) {
    return Progress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moduleId: moduleId ?? this.moduleId,
      thematiqueId: thematiqueId ?? this.thematiqueId,
      statut: statut ?? this.statut,
      derniereEtape: derniereEtape ?? this.derniereEtape,
      scoreMeilleur: scoreMeilleur ?? this.scoreMeilleur,
      nombreEssais: nombreEssais ?? this.nombreEssais,
      dateMaj: dateMaj ?? this.dateMaj,
    );
  }
}