import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../model/in_app_message.dart';
import '../repository/messages_repository.dart';

enum MessagesStatus { loading, ready, error }

class MessagesState extends Equatable {
  const MessagesState({
    this.status = MessagesStatus.loading,
    this.messages = const [],
    this.error,
    this.unreadOnly = false,
    this.query = '',
  });

  final MessagesStatus status;
  final List<InAppMessage> messages;
  final String? error;
  final bool unreadOnly;
  final String query;

  List<InAppMessage> get visibleMessages {
    Iterable<InAppMessage> result = messages;
    if (unreadOnly) {
      result = result.where((m) => !m.read);
    }
    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      result = result.where(
        (m) =>
            m.title.toLowerCase().contains(lower) ||
            m.body.toLowerCase().contains(lower),
      );
    }
    return result.toList();
  }

  MessagesState copyWith({
    MessagesStatus? status,
    List<InAppMessage>? messages,
    String? error,
    bool? unreadOnly,
    String? query,
  }) {
    return MessagesState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [status, messages, error, unreadOnly, query];
}

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({required MessagesRepository repository})
      : _repository = repository,
        super(const MessagesState()) {
    _subscription = _repository.watchMessages().listen(
      (messages) {
        emit(state.copyWith(
          status: MessagesStatus.ready,
          messages: messages,
          error: null,
        ));
      },
      onError: (Object error, StackTrace stackTrace) {
        emit(state.copyWith(
          status: MessagesStatus.error,
          error: error.toString(),
        ));
      },
    );
  }

  final MessagesRepository _repository;
  StreamSubscription<List<InAppMessage>>? _subscription;

  void toggleUnreadOnly(bool value) {
    emit(state.copyWith(unreadOnly: value));
  }

  void setQuery(String value) {
    emit(state.copyWith(query: value));
  }

  void markRead(String id) {
    _repository.markRead(id);
  }

  void markAllRead() {
    _repository.markAllRead();
  }

  void addInfo({
    required String title,
    required String body,
    MessageCategory category = MessageCategory.activity,
  }) {
    _repository.addMessage(
      title: title,
      body: body,
      category: category,
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
