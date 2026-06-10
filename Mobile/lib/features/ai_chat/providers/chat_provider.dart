import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_service.dart';
import '../domain/chat_message_model.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  const ChatState({this.messages = const [], this.isLoading = false});
  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) => ChatState(messages: messages ?? this.messages, isLoading: isLoading ?? this.isLoading);
}

class ChatNotifier extends StateNotifier<ChatState> {
  final AiService _service;
  ChatNotifier(this._service) : super(const ChatState());

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(text: text, isUser: true, timestamp: DateTime.now());
    state = state.copyWith(messages: [...state.messages, userMsg], isLoading: true);
    try {
      final reply = await _service.chat(text);
      final aiMsg = ChatMessage(text: reply, isUser: false, timestamp: DateTime.now());
      state = state.copyWith(messages: [...state.messages, aiMsg], isLoading: false);
    } catch (e) {
      final errMsg = ChatMessage(text: 'Maaf, terjadi kesalahan. Coba lagi.', isUser: false, timestamp: DateTime.now());
      state = state.copyWith(messages: [...state.messages, errMsg], isLoading: false);
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) => ChatNotifier(ref.watch(aiServiceProvider)));
