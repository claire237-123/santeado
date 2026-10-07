import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get utilisateurActuel => _auth.currentUser;

  String? get uid => _auth.currentUser?.uid;

  // Connexion anonyme pour l'adolescente
  Future<User?> connexionAnonyme() async {
    if (_auth.currentUser != null) {
      return _auth.currentUser;
    }

    final resultat = await _auth.signInAnonymously();
    return resultat.user;
  }

  // Connexion d'un professionnel ou d'un administrateur
  Future<User?> connexionEmailMotDePasse(
    String email,
    String motDePasse,
  ) async {
    final resultat = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: motDePasse,
    );

    return resultat.user;
  }

  // Récupération du rôle depuis Firestore
  //
  // CORRIGÉ : les print() précédents affichaient l'uid, l'existence
  // du document et son contenu en clair dans les logs -- à éviter
  // pour une app manipulant des données de mineures, même en debug.
  // debugPrint() est conservé UNIQUEMENT en mode debug (kDebugMode)
  // et sans exposer le contenu du document.
  Future<String?> recupererRole(String uid) async {
    final document = await _db.collection('users').doc(uid).get();

    if (kDebugMode) {
      debugPrint(
        'AuthService.recupererRole : document trouvé = ${document.exists}',
      );
    }

    if (!document.exists) {
      return null;
    }

    final donnees = document.data();

    return donnees?['role'] as String?;
  }

  Future<void> deconnexion() async {
    await _auth.signOut();
  }
}