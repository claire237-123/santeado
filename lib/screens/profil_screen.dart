import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';
import '../services/firestore_service.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  static const Color _rose = Color(0xFFD4537E);
  static const Color _fond = Color(0xFFFDF8FA);
  static const Color _texte = Color(0xFF333333);
  static const Color _gris = Color(0xFF888888);

  // CORRIGÉ : mêmes seuils que recompenses_screen.dart (1, 3, 5, 7
  // thématiques terminées -> badges débloqués). Gardés synchronisés
  // manuellement entre les deux fichiers ; à factoriser dans un même
  // endroit si un 3e écran venait à afficher des badges.
  static const List<int> _seuilsBadges = [1, 3, 5, 7];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Aucune session active.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _fond,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,

        title: const Text(
          'Mon profil',
          style: TextStyle(
            color: _texte,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<UserProfile?>(
        stream: FirestoreService().getUserProfile(user.uid),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _rose),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Impossible de charger ton profil.',
                style: TextStyle(color: _gris),
              ),
            );
          }

          final profil = snapshot.data;

          if (profil == null) {
            return const Center(
              child: Text(
                'Profil introuvable.',
                style: TextStyle(color: _gris),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
            child: Column(
              children: [
                _carteIdentite(context, profil, user.uid),

                const SizedBox(height: 25),

                _titreSection('Personnalisation'),

                const SizedBox(height: 12),

                _optionProfil(
                  icon: Icons.person_outline,
                  titre: 'Mon surnom',
                  sousTitre: profil.surnom,
                  onTap: () {
                    _modifierSurnom(context, user.uid, profil.surnom);
                  },
                ),

                const SizedBox(height: 10),

                _optionProfil(
                  icon: Icons.face_retouching_natural_outlined,
                  titre: 'Mon avatar',
                  sousTitre: 'Modifier mon apparence',
                  onTap: () {
                    _modifierTeint(context, user.uid, profil.teintAvatar);
                  },
                ),

                const SizedBox(height: 10),

                _optionProfil(
                  icon: Icons.language_outlined,
                  titre: 'Langue',
                  sousTitre: profil.langue == 'fr' ? 'Français' : 'English',
                  onTap: () {
                    _modifierLangue(context, user.uid, profil.langue);
                  },
                ),

                const SizedBox(height: 25),

                _titreSection('Ma progression'),

                const SizedBox(height: 12),

                // CORRIGÉ : le nombre de badges affiché ici était figé
                // à '0'. On le calcule maintenant à partir des vraies
                // thématiques terminées, avec les mêmes seuils que
                // recompenses_screen.dart.
                _carteProgression(profil, user.uid),

                const SizedBox(height: 25),

                _titreSection('Confidentialité'),

                const SizedBox(height: 12),

                _carteConfidentialite(),

                const SizedBox(height: 25),

                _titreSection('Application'),

                const SizedBox(height: 12),

                _optionProfil(
                  icon: Icons.info_outline,
                  titre: 'À propos de SantéAdo',
                  sousTitre: 'Découvrir l’application',
                  onTap: () {
                    _aPropos(context);
                  },
                ),

                const SizedBox(height: 10),

                _optionProfil(
                  icon: Icons.help_outline,
                  titre: 'Aide',
                  sousTitre: 'Besoin d’aide ?',
                  onTap: () {
                    _aide(context);
                  },
                ),

                const SizedBox(height: 25),

                const Text(
                  'SantéAdo',
                  style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 12),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Version 1.0',
                  style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _carteIdentite(
    BuildContext context,
    UserProfile profil,
    String uid,
  ) {
    final teint = _couleurTeint(profil.teintAvatar);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEDFE5)),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: teint,
              border: Border.all(color: _rose, width: 2),
            ),
            child: const Icon(
              Icons.face_retouching_natural,
              color: Colors.white,
              size: 46,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profil.surnom,
            style: const TextStyle(
              color: _texte,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Profil anonyme',
            style: TextStyle(color: _gris, fontSize: 13),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFBEAF0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Niveau ${profil.niveau} · ${profil.titreNiveau}',
              style: const TextStyle(
                color: _rose,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _titreSection(String titre) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        titre,
        style: const TextStyle(
          color: _texte,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _optionProfil({
    required IconData icon,
    required String titre,
    required String sousTitre,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEEDFE5)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E6ED),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: _rose, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: const TextStyle(
                        color: _texte,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sousTitre,
                      style: const TextStyle(color: _gris, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFAAAAAA)),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _carteProgression(UserProfile profil, String uid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('progress')
          .where('uid', isEqualTo: uid)
          .where('statut', isEqualTo: 'termine')
          .snapshots(),
      builder: (context, snapshot) {
        final nombreTerminees = snapshot.data?.docs.length ?? 0;

        final badgesDebloques =
            _seuilsBadges.where((seuil) => nombreTerminees >= seuil).length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEEDFE5)),
          ),
          child: Row(
            children: [
              _elementProgression(
                Icons.star_outline,
                '${profil.points}',
                'Points',
              ),
              _separateur(),
              _elementProgression(
                Icons.layers_outlined,
                '${profil.niveau}',
                'Niveau',
              ),
              _separateur(),
              _elementProgression(
                Icons.workspace_premium_outlined,
                '$badgesDebloques',
                'Badges',
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _elementProgression(
    IconData icon,
    String valeur,
    String label,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _rose, size: 25),
          const SizedBox(height: 7),
          Text(
            valeur,
            style: const TextStyle(
              color: _texte,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: _gris, fontSize: 11),
          ),
        ],
      ),
    );
  }

  static Widget _separateur() {
    return Container(
      height: 45,
      width: 1,
      color: const Color(0xFFEEDFE5),
    );
  }

  static Widget _carteConfidentialite() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Color(0xFF3F8F5F),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ton profil reste anonyme',
                  style: TextStyle(
                    color: Color(0xFF3F8F5F),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Aucun nom réel n’est nécessaire. '
                  'Ton surnom sert uniquement à '
                  'personnaliser ton expérience.',
                  style: TextStyle(
                    color: Color(0xFF5C8068),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _modifierSurnom(
    BuildContext context,
    String uid,
    String surnomActuel,
  ) async {
    final controller = TextEditingController(text: surnomActuel);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool chargement = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Modifier ton surnom'),
              content: TextField(
                controller: controller,
                maxLength: 20,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Ton surnom',
                  prefixIcon: const Icon(Icons.person_outline, color: _rose),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: chargement
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: chargement
                      ? null
                      : () async {
                          final nouveauSurnom = controller.text.trim();

                          if (nouveauSurnom.length < 2) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Le surnom doit contenir '
                                  'au moins 2 caractères.',
                                ),
                              ),
                            );

                            return;
                          }

                          setDialogState(() {
                            chargement = true;
                          });

                          try {
                            await FirestoreService()
                                .modifierSurnom(uid, nouveauSurnom);

                            if (!context.mounted) return;

                            Navigator.pop(dialogContext);
                          } catch (e) {
                            setDialogState(() {
                              chargement = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Impossible de modifier le surnom.',
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _rose,
                    foregroundColor: Colors.white,
                  ),
                  child: chargement
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  static Future<void> _modifierTeint(
    BuildContext context,
    String uid,
    String teintActuel,
  ) async {
    const teints = {
      'clair': Color(0xFFF4C9A8),
      'moyen': Color(0xFFC68863),
      'fonce': Color(0xFF7A4B32),
    };

    String selection = teintActuel;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool chargement = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Modifier ton avatar'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choisis ton teint',
                    style: TextStyle(color: _gris, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: teints.entries.map((entry) {
                      final selectionne = selection == entry.key;

                      return GestureDetector(
                        onTap: chargement
                            ? null
                            : () {
                                setDialogState(() {
                                  selection = entry.key;
                                });
                              },
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: entry.value,
                            border: Border.all(
                              color:
                                  selectionne ? _rose : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: chargement
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: chargement
                      ? null
                      : () async {
                          setDialogState(() {
                            chargement = true;
                          });

                          try {
                            await FirestoreService()
                                .modifierTeint(uid, selection);

                            if (!context.mounted) return;

                            Navigator.pop(dialogContext);
                          } catch (e) {
                            setDialogState(() {
                              chargement = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Impossible de modifier l’avatar.',
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _rose,
                    foregroundColor: Colors.white,
                  ),
                  child: chargement
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> _modifierLangue(
    BuildContext context,
    String uid,
    String langueActuelle,
  ) async {
    String selection = langueActuelle;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool chargement = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Langue de l’application'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: 'fr',
                    groupValue: selection,
                    title: const Text('Français'),
                    activeColor: _rose,
                    onChanged: chargement
                        ? null
                        : (value) {
                            setDialogState(() {
                              selection = value!;
                            });
                          },
                  ),
                  RadioListTile<String>(
                    value: 'en',
                    groupValue: selection,
                    title: const Text('English'),
                    activeColor: _rose,
                    onChanged: chargement
                        ? null
                        : (value) {
                            setDialogState(() {
                              selection = value!;
                            });
                          },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: chargement
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: chargement
                      ? null
                      : () async {
                          setDialogState(() {
                            chargement = true;
                          });

                          try {
                            await FirestoreService()
                                .modifierLangue(uid, selection);

                            if (!context.mounted) return;

                            Navigator.pop(dialogContext);
                          } catch (e) {
                            setDialogState(() {
                              chargement = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Impossible de modifier la langue.',
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _rose,
                    foregroundColor: Colors.white,
                  ),
                  child: chargement
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _aPropos(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('À propos de SantéAdo'),
          content: const Text(
            'SantéAdo est une application ludique '
            'destinée à accompagner les adolescentes '
            'dans la découverte de leur santé et '
            'de leur corps à travers des contenus '
            'adaptés et progressifs.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  static void _aide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aide'),
          content: const Text(
            'Tu peux modifier ton surnom, ton avatar '
            'et la langue de l’application depuis '
            'la section Personnalisation de ton profil.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  static Color _couleurTeint(String teint) {
    switch (teint) {
      case 'clair':
        return const Color(0xFFF4C9A8);
      case 'fonce':
        return const Color(0xFF7A4B32);
      case 'moyen':
      default:
        return const Color(0xFFC68863);
    }
  }
}