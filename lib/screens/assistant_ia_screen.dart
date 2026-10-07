import 'package:flutter/material.dart';
import '../services/ia_service.dart';

class AssistantIAScreen extends StatefulWidget {
  const AssistantIAScreen({super.key});

  @override
  State<AssistantIAScreen> createState() => _AssistantIAScreenState();
}

class _AssistantIAScreenState extends State<AssistantIAScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];

  bool _chargement = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _envoyerQuestion() async {
    final question = _controller.text.trim();

    if (question.isEmpty || _chargement) {
      return;
    }

    setState(() {
      _messages.add({
        'role': 'utilisateur',
        'message': question,
      });

      _controller.clear();
      _chargement = true;
    });

    _faireDefiler();

    final resultat = await IAService.poserQuestion(question);

    if (!mounted) return;

    setState(() {
      _chargement = false;

      if (resultat['succes'] == true) {
        _messages.add({
          'role': 'ia',
          'message': resultat['reponse'] ?? '',
          'conseil': resultat['conseil'] ?? '',
          'titre': resultat['titre'] ?? '',
        });
      } else {
        _messages.add({
          'role': 'ia',
          'message': resultat['message'] ??
              'Une erreur est survenue. Réessaie dans quelques instants.',
        });
      }
    });

    _faireDefiler();
  }

  void _faireDefiler() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF176B5B),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome),
            SizedBox(width: 10),
            Text(
              'Assistant SantéAdo',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildAccueil()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(
                        _messages[index],
                      );
                    },
                  ),
          ),

          if (_chargement)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Je prépare une réponse...',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          _buildZoneSaisie(),
        ],
      ),
    );
  }

  Widget _buildAccueil() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F3EF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 36,
                color: Color(0xFF176B5B),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Comment puis-je t’aider ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF176B5B),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Pose une question sur ton corps, '
              'ton cycle, l’hygiène, la prévention '
              'ou la santé sexuelle.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 28),

            _suggestion('C’est quoi la puberté ?'),
            _suggestion('Qu’est-ce que le consentement ?'),
            _suggestion('Pourquoi mon cycle varie ?'),
            _suggestion('Comment éviter les IST ?'),
          ],
        ),
      ),
    );
  }

  Widget _suggestion(String texte) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          _controller.text = texte;
          _envoyerQuestion();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE4E7E6),
            ),
          ),
          child: Text(
            texte,
            style: const TextStyle(
              color: Color(0xFF176B5B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final bool utilisateur = message['role'] == 'utilisateur';

    return Align(
      alignment: utilisateur
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 340,
        ),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: utilisateur
              ? const Color(0xFFD4537E)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: utilisateur
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!utilisateur &&
                (message['titre'] ?? '').toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  message['titre'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF176B5B),
                  ),
                ),
              ),

            Text(
              message['message'] ?? '',
              style: TextStyle(
                color: utilisateur
                    ? Colors.white
                    : const Color(0xFF252525),
                fontSize: 15,
                height: 1.45,
              ),
            ),

            if (!utilisateur &&
                (message['conseil'] ?? '').toString().isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F8F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message['conseil'],
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF176B5B),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneSaisie() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12,
          10,
          12,
          10,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE8E8E8),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _envoyerQuestion(),
                decoration: InputDecoration(
                  hintText: 'Pose ta question...',
                  filled: true,
                  fillColor: const Color(0xFFF6F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              onPressed: _chargement
                  ? null
                  : _envoyerQuestion,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF176B5B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
              ),
              icon: const Icon(Icons.arrow_upward),
            ),
          ],
        ),
      ),
    );
  }
}