class Task {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
