import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DemandeAccompagnementScreen extends StatefulWidget {
  const DemandeAccompagnementScreen({super.key});

  @override
  State<DemandeAccompagnementScreen> createState() =>
      _DemandeAccompagnementScreenState();
}

class _DemandeAccompagnementScreenState
    extends State<DemandeAccompagnementScreen> {
  static const Color _rose = Color(0xFFD4537E);
  static const Color _fond = Color(0xFFFFF9FB);
  static const Color _texte = Color(0xFF302C2D);

  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  String? _motif;

  final List<String> _motifs = [
    'Besoin d’information',
    'Difficultés liées aux règles',
    'Santé sexuelle',
    'Contraception',
    'IST',
    'Situation préoccupante',
    'Autre',
  ];
Future<void> _envoyerDemande() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session utilisateur introuvable.'),
      ),
    );
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection('demandes_accompagnement')
        .add({
      'uidAdolescente': user.uid,
      'motif': _motif,
      'message': _messageController.text.trim(),
      'statut': 'en_attente',
      'professionnelId': '',
      'dateCreation': FieldValue.serverTimestamp(),
      'dateModification': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Ta demande a bien été envoyée.',
        ),
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Impossible d’envoyer la demande : $e',
        ),
      ),
    );
  }
}
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fond,
      appBar: AppBar(
        backgroundColor: _fond,
        elevation: 0,
        foregroundColor: _texte,
        title: Text(
          'Demander un accompagnement',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu peux demander de l’aide',
                  style: GoogleFonts.quicksand(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _texte,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Explique-nous ce dont tu as besoin. '
                  'Un professionnel pourra ensuite examiner ta demande.',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Motif de la demande',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _texte,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _motif,
                  decoration: InputDecoration(
                    hintText: 'Choisis un motif',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFEDE6E8),
                      ),
                    ),
                  ),
                  items: _motifs.map((motif) {
                    return DropdownMenuItem<String>(
                      value: motif,
                      child: Text(
                        motif,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _motif = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Choisis un motif.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 22),

                Text(
                  'Ton message',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _texte,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _messageController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText:
                        'Explique ce que tu souhaites partager...',
                    filled: true,
                    fillColor: Colors.white,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFEDE6E8),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Écris un message.';
                    }

                    if (value.trim().length < 5) {
                      return 'Ton message est trop court.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _envoyerDemande,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _rose,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Envoyer ma demande',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}