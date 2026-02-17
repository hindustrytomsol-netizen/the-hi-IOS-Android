/// Minimal profile entity for the current user.
class ProfileEntity {
  const ProfileEntity({
    required this.id,
    this.displayName,
    this.username,
    this.avatarUrl,
    this.createdAt,
  });

  final String id;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final DateTime? createdAt;

  /// Create a ProfileEntity from a Supabase row map.
  ///
  /// Defensively handles missing keys to avoid crashes.
  factory ProfileEntity.fromMap(Map<String, dynamic> row) {
    DateTime? parseCreatedAt(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is DateTime) {
        return value;
      }
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return ProfileEntity(
      id: row['id']?.toString() ?? '',
      displayName: row['display_name']?.toString(),
      username: row['username']?.toString(),
      avatarUrl: row['avatar_url']?.toString(),
      createdAt: parseCreatedAt(row['created_at']),
    );
  }
}
