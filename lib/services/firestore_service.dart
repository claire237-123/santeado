import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/module.dart';
import '../models/user_profile.dart';
import '../models/thematique.dart';
import '../models/etape.dart';
import '../models/progress.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // MODULES
  // ============================================================

  Stream<List<Module>> getModules() {
  return _db
      .collection('modules')
      .where('statut', isEqualTo: 'publie')
      .orderBy('ordre')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Module.fromFirestore(
                doc.id,
                doc.data(),
              ),
            )
            .toList(),
      );
}

  // ------------------------------------------------------------
  // Ajouter un module
  // ------------------------------------------------------------
  //
  // CORRIGÉ : un module créé par l'admin part désormais en
  // 'brouillon' -- invisible pour les adolescentes tant qu'il n'a
  // pas été explicitement publié via publierModule(). Auparavant,
  // 'statut' valait 'disponible' dès la création : tout contenu,
  // même vide ou incomplet, était immédiatement visible.

  Future<String> ajouterModule({
    required String titre,
    required String sousTitre,
    required String description,
    required int ordre,
    String couleur = '#D4537E',
  }) async {
    final doc = await _db.collection('modules').add({
      'titre': titre.trim(),
      'sousTitre': sousTitre.trim(),
      'description': description.trim(),
      'ordre': ordre,
      'couleur': couleur,
      'statut': 'brouillon',
      'nombreThematiques': 0,
      'dateCreation': FieldValue.serverTimestamp(),
      'dateModification': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ------------------------------------------------------------
  // Modifier un module
  // ------------------------------------------------------------

  Future<void> modifierModule({
    required String moduleId,
    required String titre,
    required String sousTitre,
    required String description,
    required int ordre,
    String? couleur,
    String? statut,
  }) async {
    final Map<String, dynamic> donnees = {
      'titre': titre.trim(),
      'sousTitre': sousTitre.trim(),
      'description': description.trim(),
      'ordre': ordre,
      'dateModification': FieldValue.serverTimestamp(),
    };

    if (couleur != null && couleur.trim().isNotEmpty) {
      donnees['couleur'] = couleur.trim();
    }

    if (statut != null && statut.trim().isNotEmpty) {
      donnees['statut'] = statut.trim();
    }

    await _db
        .collection('modules')
        .doc(moduleId)
        .update(donnees);
  }

  // ------------------------------------------------------------
  // Publier / dépublier un module
  // ------------------------------------------------------------
  //
  // NOUVEAU : c'est le seul endroit où un module passe en
  // 'disponible' (visible par les adolescentes). Un module
  // dépublié repasse en 'brouillon'. À brancher sur un bouton
  // "Publier" / "Dépublier" dans administrateur_screen.dart,
  // sur chaque tuile de module.

  Future<void> publierModule(String moduleId) async {
  await _db.collection('modules').doc(moduleId).update({
    'statut': 'publie',
    'datePublication': FieldValue.serverTimestamp(),
    'dateModification': FieldValue.serverTimestamp(),
  });
}

Future<void> depublierModule(String moduleId) async {
  await _db.collection('modules').doc(moduleId).update({
    'statut': 'brouillon',
    'dateModification': FieldValue.serverTimestamp(),
  });
}

  // ------------------------------------------------------------
  // Supprimer un module et ses sous-collections
  // ------------------------------------------------------------

  Future<void> supprimerModule(String moduleId) async {
    final moduleRef = _db.collection('modules').doc(moduleId);

    final thematiquesSnapshot =
        await moduleRef.collection('thematiques').get();

    for (final thematiqueDoc in thematiquesSnapshot.docs) {
      final etapesSnapshot =
          await thematiqueDoc.reference.collection('etapes').get();

      await _supprimerDocumentsParLots(etapesSnapshot.docs);

      await thematiqueDoc.reference.delete();
    }

    await moduleRef.delete();
  }

  // ============================================================
  // PROFIL ANONYME
  // ============================================================

  Future<bool> profilExiste(String uid) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .get();

    return doc.exists;
  }

  // ============================================================
  // CREATION DU PROFIL ADOLESCENTE
  // ============================================================

  Future<void> creerProfil(
    String uid, {
    required String surnom,
    required String langue,
    required Map<String, dynamic> avatar,
  }) async {
    await _db.collection('users').doc(uid).set({
      'role': 'adolescente',
      'surnom': surnom.trim(),
      'langue': langue,
      'avatar': avatar,
      'points': 0,
      'niveau': 1,
      'titreNiveau': 'Débutante',
      'dateCreation': FieldValue.serverTimestamp(),
      'derniereConnexion': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // MODIFICATION DU PROFIL
  // ============================================================

  Future<void> modifierSurnom(
    String uid,
    String surnom,
  ) async {
    await _db.collection('users').doc(uid).update({
      'surnom': surnom.trim(),
    });
  }

  Future<void> modifierLangue(
    String uid,
    String langue,
  ) async {
    await _db.collection('users').doc(uid).update({
      'langue': langue,
    });
  }

  Future<void> modifierTeint(
    String uid,
    String teint,
  ) async {
    await _db.collection('users').doc(uid).update({
      'avatar.teint': teint,
    });
  }

  // ============================================================
  // RECUPERATION DU PROFIL
  // ============================================================

  Stream<UserProfile?> getUserProfile(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return null;
      }

      return UserProfile.fromFirestore(
        doc.data()!,
      );
    });
  }

  // ============================================================
  // THEMATIQUES
  // ============================================================

  Stream<List<Thematique>> getThematiques(
    String moduleId,
  ) {
    return _db
        .collection('modules')
        .doc(moduleId)
        .collection('thematiques')
        .orderBy('ordre')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Thematique.fromFirestore(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  // ------------------------------------------------------------
  // Ajouter une thématique
  // ------------------------------------------------------------

  Future<String> ajouterThematique({
    required String moduleId,
    required String titre,
    required String description,
    required int ordre,
  }) async {
    final moduleRef =
        _db.collection('modules').doc(moduleId);

    final thematiquesRef =
        moduleRef.collection('thematiques');

    final thematiqueRef = await thematiquesRef.add({
      'titre': titre.trim(),
      'description': description.trim(),
      'ordre': ordre,
      'nombreEtapes': 5,
      'dateCreation': FieldValue.serverTimestamp(),
      'dateModification': FieldValue.serverTimestamp(),
    });

    // ==========================================================
    // Création automatique des 5 étapes
    // ==========================================================

    const etapes = [
      {
        'ordre': 1,
        'type': 'decouvre',
        'titre': 'Découvrir',
      },
      {
        'ordre': 2,
        'type': 'regarde',
        'titre': 'Comprendre',
      },
      {
        'ordre': 3,
        'type': 'observe',
        'titre': 'Approfondir',
      },
      {
        'ordre': 4,
        'type': 'retiens',
        'titre': 'Je retiens',
      },
      {
        'ordre': 5,
        'type': 'joue',
        'titre': 'Activité',
      },
    ];

    for (final etape in etapes) {
      final type = etape['type'] as String;

      final donnees = <String, dynamic>{
        'ordre': etape['ordre'],
        'type': type,
        'titre': etape['titre'],
        'statut': 'brouillon',
        'contenu': {
          'texte': '',
          'videoUrl': '',
          'illustrationUrl': '',
        },
        'dateCreation': FieldValue.serverTimestamp(),
        'dateModification': FieldValue.serverTimestamp(),
      };

      // Une étape de type "joue" possède un jeu.
      if (type == 'joue') {
        donnees['jeu'] = {
          'typeJeu': 'situation',
          'situation': '',
          'pointsGagnes': 10,
          'choix': [],
        };
      }

      await thematiqueRef
          .collection('etapes')
          .add(donnees);
    }

    // Mise à jour du nombre de thématiques du module.
    final moduleSnapshot = await moduleRef.get();

    final ancienNombre =
        moduleSnapshot.data()?['nombreThematiques'] ?? 0;

    final ancienNombreInt = ancienNombre is int
        ? ancienNombre
        : int.tryParse(
              ancienNombre.toString(),
            ) ??
            0;

    await moduleRef.update({
      'nombreThematiques': ancienNombreInt + 1,
      'dateModification': FieldValue.serverTimestamp(),
    });

    return thematiqueRef.id;
  }

  // ------------------------------------------------------------
  // Modifier une thématique
  // ------------------------------------------------------------

  Future<void> modifierThematique({
    required String moduleId,
    required String thematiqueId,
    required String titre,
    required String description,
    required int ordre,
  }) async {
    await _db
        .collection('modules')
        .doc(moduleId)
        .collection('thematiques')
        .doc(thematiqueId)
        .update({
      'titre': titre.trim(),
      'description': description.trim(),
      'ordre': ordre,
      'dateModification': FieldValue.serverTimestamp(),
    });
  }

  // ------------------------------------------------------------
  // Supprimer une thématique
  // ------------------------------------------------------------

  Future<void> supprimerThematique({
    required String moduleId,
    required String thematiqueId,
  }) async {
    final moduleRef =
        _db.collection('modules').doc(moduleId);

    final thematiqueRef =
        moduleRef.collection('thematiques').doc(thematiqueId);

    final etapesSnapshot =
        await thematiqueRef.collection('etapes').get();

    await _supprimerDocumentsParLots(
      etapesSnapshot.docs,
    );

    await thematiqueRef.delete();

    final moduleSnapshot = await moduleRef.get();

    final ancienNombre =
        moduleSnapshot.data()?['nombreThematiques'] ?? 0;

    final ancienNombreInt = ancienNombre is int
        ? ancienNombre
        : int.tryParse(
              ancienNombre.toString(),
            ) ??
            0;

    final nouveauNombre =
        ancienNombreInt > 0
            ? ancienNombreInt - 1
            : 0;

    await moduleRef.update({
      'nombreThematiques': nouveauNombre,
      'dateModification': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // ETAPES
  // ============================================================

 Future<List<Etape>> getEtapes(
  String moduleId,
  String thematiqueId,
) async {
  final snapshot = await _db
      .collection('modules')
      .doc(moduleId)
      .collection('thematiques')
      .doc(thematiqueId)
      .collection('etapes')
      .where('statut', isEqualTo: 'publie')
      .orderBy('ordre')
      .get();

  return snapshot.docs
      .map(
        (doc) => Etape.fromFirestore(
          doc.id,
          doc.data(),
        ),
      )
      .toList();
}

  // ------------------------------------------------------------
  // Ajouter une étape
  // ------------------------------------------------------------

  Future<String> ajouterEtape({
    required String moduleId,
    required String thematiqueId,
    required int ordre,
    required String type,
    required String titre,
    required String texte,
    String videoUrl = '',
    String illustrationUrl = '',
    Map<String, dynamic>? jeu,
  }) async {
    final donnees = <String, dynamic>{
      'ordre': ordre,
      'type': type,
      'titre': titre.trim(),
      'statut': 'brouillon',
      'contenu': {
        'texte': texte.trim(),
        'videoUrl': videoUrl.trim(),
        'illustrationUrl': illustrationUrl.trim(),
      },
      'dateCreation': FieldValue.serverTimestamp(),
      'dateModification': FieldValue.serverTimestamp(),
    };

    if (type == 'joue') {
  donnees['jeu'] = {
    'typeJeu': 'qcm',
    'question': '',
    'pointsGagnes': 10,
    'choix': [],
  };
}

    final doc = await _db
        .collection('modules')
        .doc(moduleId)
        .collection('thematiques')
        .doc(thematiqueId)
        .collection('etapes')
        .add(donnees);

    return doc.id;
  }

  // ------------------------------------------------------------
  // Modifier une étape
  // ------------------------------------------------------------

  Future<void> modifierEtape({
    required String moduleId,
    required String thematiqueId,
    required String etapeId,
    required int ordre,
    required String type,
    required String titre,
    required String texte,
    String videoUrl = '',
    String illustrationUrl = '',
    Map<String, dynamic>? jeu,
  }) async {
    final donnees = <String, dynamic>{
      'ordre': ordre,
      'type': type,
      'titre': titre.trim(),
      'contenu': {
        'texte': texte.trim(),
        'videoUrl': videoUrl.trim(),
        'illustrationUrl': illustrationUrl.trim(),
      },
      'dateModification': FieldValue.serverTimestamp(),
    };

    if (type == 'joue') {
      donnees['jeu'] = jeu ??
          {
            'typeJeu': 'situation',
            'situation': '',
            'pointsGagnes': 10,
            'choix': [],
          };
    } else {
      // Si l'administrateur transforme une étape "joue"
      // en étape de contenu, on supprime l'ancien jeu.
      donnees['jeu'] = FieldValue.delete();
    }

    await _db
        .collection('modules')
        .doc(moduleId)
        .collection('thematiques')
        .doc(thematiqueId)
        .collection('etapes')
        .doc(etapeId)
        .update(donnees);
  }

  // ------------------------------------------------------------
// Publier une étape
// ------------------------------------------------------------

Future<void> publierEtape({
  required String moduleId,
  required String thematiqueId,
  required String etapeId,
}) async {
  await _db
      .collection('modules')
      .doc(moduleId)
      .collection('thematiques')
      .doc(thematiqueId)
      .collection('etapes')
      .doc(etapeId)
      .update({
    'statut': 'publie',
    'datePublication': FieldValue.serverTimestamp(),
    'dateModification': FieldValue.serverTimestamp(),
  });
}

// ------------------------------------------------------------
// Dépublier une étape
// ------------------------------------------------------------

Future<void> depublierEtape({
  required String moduleId,
  required String thematiqueId,
  required String etapeId,
}) async {
  await _db
      .collection('modules')
      .doc(moduleId)
      .collection('thematiques')
      .doc(thematiqueId)
      .collection('etapes')
      .doc(etapeId)
      .update({
    'statut': 'brouillon',
    'dateModification': FieldValue.serverTimestamp(),
  });
}

  // ------------------------------------------------------------
  // Supprimer une étape
  // ------------------------------------------------------------

  Future<void> supprimerEtape({
    required String moduleId,
    required String thematiqueId,
    required String etapeId,
  }) async {
    await _db
        .collection('modules')
        .doc(moduleId)
        .collection('thematiques')
        .doc(thematiqueId)
        .collection('etapes')
        .doc(etapeId)
        .delete();
  }

  // ============================================================
  // PROGRESSION
  // ============================================================

  String _idProgress(
    String uid,
    String moduleId,
    String thematiqueId,
  ) {
    return '${uid}_${moduleId}_$thematiqueId';
  }

  // ============================================================
  // RECUPERER LA PROGRESSION D'UN MODULE
  // ============================================================

  Future<Map<String, Progress>> getProgressModule(
  String uid,
  String moduleId,
) async {
  try {
    debugPrint('===== TEST PROGRESSION =====');
    debugPrint('UID = $uid');
    debugPrint('MODULE = $moduleId');

    final snapshot = await _db
        .collection('progress')
        .where('uid', isEqualTo: uid)
        .get();

    debugPrint(
      'Nombre de documents progress = ${snapshot.docs.length}',
    );

    final Map<String, Progress> resultat = {};

    for (final doc in snapshot.docs) {
      debugPrint('Document progress = ${doc.id}');
      debugPrint('Données = ${doc.data()}');

      final data = doc.data();

      if (data['moduleId']?.toString() != moduleId) {
        continue;
      }

      final thematiqueId = data['thematiqueId'];

      if (thematiqueId == null) {
        continue;
      }

      resultat[thematiqueId.toString()] =
          Progress.fromMap(
        data,
        id: doc.id,
      );
    }

    debugPrint(
      'Progressions trouvées = ${resultat.length}',
    );

    return resultat;
  } catch (e, stackTrace) {
    debugPrint('===== ERREUR PROGRESSION =====');
    debugPrint('ERREUR = $e');
    debugPrint('STACK = $stackTrace');

    rethrow;
  }
}

  // ============================================================
  // MARQUER UNE THEMATIQUE COMME TERMINEE
  // ============================================================

  Future<void> marquerThematiqueTerminee({
  required String uid,
  required String moduleId,
  required String thematiqueId,
  required int score,
  required int pointsGagnes,
}) async {
  final docId = _idProgress(
    uid,
    moduleId,
    thematiqueId,
  );

  final docRef = _db.collection('progress').doc(docId);

  await docRef.set({
    'uid': uid,
    'moduleId': moduleId,
    'thematiqueId': thematiqueId,
    'statut': 'termine',
    'scoreMeilleur': score,
    'nombreEssais': 1,
    'dateMaj': FieldValue.serverTimestamp(),
  });
}

  // ============================================================
  // CALCUL DU NIVEAU À PARTIR DES POINTS TOTAUX
  // ============================================================
  //
  // Paliers identiques à ceux de recompenses_screen.dart : 0 / 100 /
  // 250 / 500 points -> Débutante / Curieuse / Confiante / Experte.

  ({int numero, String titre}) _calculerNiveau(int points) {
    const paliers = [
      (seuil: 0, numero: 1, titre: 'Débutante'),
      (seuil: 100, numero: 2, titre: 'Curieuse'),
      (seuil: 250, numero: 3, titre: 'Confiante'),
      (seuil: 500, numero: 4, titre: 'Experte'),
    ];

    var actuel = paliers.first;

    for (final palier in paliers) {
      if (points >= palier.seuil) {
        actuel = palier;
      }
    }

    return (numero: actuel.numero, titre: actuel.titre);
  }

  // ============================================================
  // UTILITAIRE : SUPPRESSION PAR LOTS
  // ============================================================

  Future<void> _supprimerDocumentsParLots(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    if (docs.isEmpty) {
      return;
    }

    const tailleLot = 450;

    for (
      int debut = 0;
      debut < docs.length;
      debut += tailleLot
    ) {
      final fin =
          (debut + tailleLot < docs.length)
              ? debut + tailleLot
              : docs.length;

      final batch = _db.batch();

      for (
        int i = debut;
        i < fin;
        i++
      ) {
        batch.delete(
          docs[i].reference,
        );
      }
      await batch.commit();
    }
  }
}