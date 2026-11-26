class UserModel {
  final String userId;
  final String name;
  final String avatar;
  final String password;
  final String createdAt;
  final String updatedAt;

  const UserModel({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: (json['user_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      avatar: (json['avatar'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar': avatar,
      'password': password,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? avatar,
    String? password,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NoteModel {
  final int? localId;
  final String noteId;
  final String userId;
  final String title;
  final String description;
  final String latitude;
  final String longitude;
  final int status;
  final String createdAt;
  final String updatedAt;
  final bool isSynced;
  final String syncAction; // 'none', 'create', 'update', 'delete'

  const NoteModel({
    this.localId,
    required this.noteId,
    required this.userId,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = true,
    this.syncAction = 'none',
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    final parsedStatus = rawStatus is int
        ? rawStatus
        : int.tryParse(rawStatus?.toString() ?? '0') ?? 0;

    return NoteModel(
      noteId: (json['note_id'] ?? json['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      latitude: (json['latitude'] ?? '').toString(),
      longitude: (json['longitude'] ?? '').toString(),
      status: parsedStatus.clamp(0, 100),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
      isSynced: true,
      syncAction: 'none',
    );
  }

  factory NoteModel.fromLocalMap(Map<String, dynamic> map) {
    final rawStatus = map['status'];
    final parsedStatus = rawStatus is int
        ? rawStatus
        : int.tryParse(rawStatus?.toString() ?? '0') ?? 0;
    final rawSynced = map['is_synced'];
    final synced = rawSynced is bool
        ? rawSynced
        : (int.tryParse(rawSynced?.toString() ?? '1') ?? 1) == 1;

    return NoteModel(
      localId: map['local_id'] is int
          ? map['local_id'] as int
          : int.tryParse(map['local_id']?.toString() ?? ''),
      noteId: (map['note_id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      latitude: (map['latitude'] ?? '').toString(),
      longitude: (map['longitude'] ?? '').toString(),
      status: parsedStatus.clamp(0, 100),
      createdAt: (map['created_at'] ?? '').toString(),
      updatedAt: (map['updated_at'] ?? '').toString(),
      isSynced: synced,
      syncAction: (map['sync_action'] ?? 'none').toString(),
    );
  }

  Map<String, dynamic> toLocalMap({bool includeLocalId = false}) {
    final map = <String, dynamic>{
      'note_id': noteId,
      'user_id': userId,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_synced': isSynced ? 1 : 0,
      'sync_action': syncAction,
    };
    if (includeLocalId && localId != null) {
      map['local_id'] = localId;
    }
    return map;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'userId': userId,
    };
  }

  NoteModel copyWith({
    int? localId,
    String? noteId,
    String? userId,
    String? title,
    String? description,
    String? latitude,
    String? longitude,
    int? status,
    String? createdAt,
    String? updatedAt,
    bool? isSynced,
    String? syncAction,
  }) {
    return NoteModel(
      localId: localId ?? this.localId,
      noteId: noteId ?? this.noteId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncAction: syncAction ?? this.syncAction,
    );
  }
}
