import 'dart:async';

import '../model/in_app_message.dart';

class MessagesRepository {
  MessagesRepository()
      : _controller = StreamController<List<InAppMessage>>.broadcast() {
    _controller.onListen = () {
      if (_messages.isNotEmpty) {
        _controller.add(_messages);
      }
    };

    _messages = [
      InAppMessage(
        id: _nextId(),
        title: 'Welcome back',
        body: 'Take a look at My Day and pick three priorities.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        category: MessageCategory.tip,
      ),
      InAppMessage(
        id: _nextId(),
        title: 'Demo tasks ready',
        body: 'We seeded a few sample tasks so you can explore quickly.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ];
    _emit();
  }

  final StreamController<List<InAppMessage>> _controller;
  late List<InAppMessage> _messages;
  int _counter = 0;

  Stream<List<InAppMessage>> watchMessages() => _controller.stream;

  void addMessage({
    required String title,
    required String body,
    MessageCategory category = MessageCategory.activity,
  }) {
    final message = InAppMessage(
      id: _nextId(),
      title: title,
      body: body,
      createdAt: DateTime.now(),
      category: category,
    );
    _messages = [message, ..._messages];
    _emit();
  }

  void markRead(String id) {
    _messages = [
      for (final m in _messages) m.id == id ? m.copyWith(read: true) : m,
    ];
    _emit();
  }

  void markAllRead() {
    _messages = [
      for (final m in _messages) m.copyWith(read: true),
    ];
    _emit();
  }

  String _nextId() => (++_counter).toString();

  void dispose() {
    _controller.close();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(_messages);
    }
  }
}
