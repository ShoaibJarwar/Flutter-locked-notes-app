class NotesModel {
  final int? id;
  final String title;
  final String content;
  final bool isLocked;
  final bool isFavorite;
  final int createdAt;

  const NotesModel({
    this.id,
    required this.title,
    required this.content,
    required this.isLocked,
    required this.isFavorite,
    required this.createdAt,
  });

  NotesModel copyWith({
    int? id,
    String? title,
    String? content,
    bool? isLocked,
    bool? isFavorite,
    int? createdAt,
  }) {
    return NotesModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isLocked: isLocked ?? this.isLocked,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'isLocked': isLocked ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  factory NotesModel.fromMap(Map<String, dynamic> map) {
    return NotesModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      isLocked: (map['isLocked'] as int?) == 1,
      isFavorite: (map['isFavorite'] as int?) == 1,
      createdAt: (map['createdAt'] as int?) ?? 0,
    );
  }

  @override
  String toString() => 'Note(id: $id, title: $title, locked: $isLocked)';
}
