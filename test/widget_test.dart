// Test de fumée basique pour SantéAdo.
//
// CORRIGÉ : le test précédent était celui généré par défaut par
// `flutter create` (recherche d'un compteur "+1" qui n'existe pas dans
// cette application) -- il échouait systématiquement, ce qui aurait mal
// paru dans le dossier de tests remis en soutenance (Dossier 6).
//
// Ce test se contente de vérifier que l'application démarre sans lever
// d'exception et affiche bien l'écran de démarrage (SplashScreen, avec
// son icône). Il ne teste pas Firebase (non initialisé dans un test
// widget classique) -- un test plus complet nécessiterait de mocker
// Firebase Auth/Firestore, ce qui dépasse le cadre d'un test de fumée.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sante_ado/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen s’affiche sans erreur', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // L'écran de démarrage affiche l'icône SantéAdo avant la
    // redirection (Firebase.initializeApp n'étant pas appelé ici,
    // le routage vers WelcomeScreen ne se déclenche pas dans ce test).
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });
}