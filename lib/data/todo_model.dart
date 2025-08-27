class ToDo {
  final int id;
  final String title;
  final bool completed;
  final int userId;
  final bool pending; // local change not yet synced

  ToDo({required this.id, required this.title, required this.completed, required this.userId, this.pending = false});

  ToDo copyWith({int? id, String? title, bool? completed, int? userId, bool? pending}) => ToDo(
    id: id ?? this.id,
    title: title ?? this.title,
    completed: completed ?? this.completed,
    userId: userId ?? this.userId,
    pending: pending ?? this.pending,
  );

  factory ToDo.fromJson(Map<String, dynamic> data) => ToDo(
    id: data['id'] as int,
    title: data['title'] as String,
    completed: data['completed'] as bool,
    userId: data['userId'] as int,
    pending: (data['pending'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
    'userId': userId,
    'pending': pending,
  };
}
