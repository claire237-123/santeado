class UserProfile {
  final String role;
  final String surnom;
  final String langue;
  final String teintAvatar;
  final int points;
  final int niveau;
  final String titreNiveau;

  UserProfile({
    required this.role,
    required this.surnom,
    required this.langue,
    required this.teintAvatar,
    required this.points,
    required this.niveau,
    required this.titreNiveau,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    final avatar = data['avatar'] as Map<String, dynamic>? ?? {};

    return UserProfile(
      role: data['role'] ?? 'adolescente',
      surnom: data['surnom'] ?? '',
      langue: data['langue'] ?? 'fr',
      teintAvatar: avatar['teint'] ?? 'moyen',
      points: data['points'] ?? 0,
      niveau: data['niveau'] ?? 1,
      titreNiveau: data['titreNiveau'] ?? 'Débutante',
    );
  }
}