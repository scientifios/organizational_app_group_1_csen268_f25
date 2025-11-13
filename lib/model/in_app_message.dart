import 'package:equatable/equatable.dart';

enum MessageCategory { reminder, activity, tip }

class InAppMessage extends Equatable {
  const InAppMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.category = MessageCategory.activity,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final MessageCategory category;
  final bool read;

  InAppMessage copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    MessageCategory? category,
    bool? read,
  }) {
    return InAppMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      read: read ?? this.read,
    );
  }

  @override
  List<Object?> get props => [id, title, body, createdAt, category, read];
}
