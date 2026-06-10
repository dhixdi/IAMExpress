import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});
  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(text);
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent + 100, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant'), leading: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.smart_toy_outlined))),
      body: Column(
        children: [
          Expanded(
            child: chat.messages.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.smart_toy_outlined, size: 64, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text('Tanya apa saja tentang\npengiriman paket...', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                ])))
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: chat.messages.length + (chat.isLoading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == chat.messages.length) {
                      return const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.all(8), child: Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 8), Text('Mengetik...', style: TextStyle(color: AppColors.textMuted))])));
                    }
                    final msg = chat.messages[i];
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: msg.isUser ? AppColors.primary : AppColors.rowHover,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12), topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(msg.isUser ? 12 : 0),
                            bottomRight: Radius.circular(msg.isUser ? 0 : 12),
                          ),
                        ),
                        child: Text(msg.text, style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : AppColors.textPrimary)),
                      ),
                    );
                  },
                ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.borderLight))),
            child: SafeArea(
              child: Row(children: [
                Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Ketik pesan...', border: InputBorder.none), textInputAction: TextInputAction.send, onSubmitted: (_) => _send())),
                IconButton(onPressed: chat.isLoading ? null : _send, icon: const Icon(Icons.send_rounded), color: AppColors.primary),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
