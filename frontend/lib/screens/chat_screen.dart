import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  ChatMode _mode = ChatMode.listening;
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    final messages = await ChatService.getTodayChats();
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() => _isSending = true);

    final result = await ChatService.sendMessage(text, _mode);

    if (result['success']) {
      setState(() {
        _messages.add(result['userMessage']);
        _messages.add(result['aiResponse']);
      });
      _scrollToBottom();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _isSending = false);
  }

  Future<void> _deleteChats() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Delete all of today\'s messages?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await ChatService.deleteTodayChats();
      setState(() => _messages = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteChats,
                tooltip: 'Delete chat'),
        ],
      ),
      body: Column(
        children: [
          // Mode toggle
          Container(
            padding: const EdgeInsets.all(12),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                const Text('Mode: ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                _ModeChip(
                    label: 'Listening',
                    selected: _mode == ChatMode.listening,
                    onTap: () => setState(() => _mode = ChatMode.listening)),
                const SizedBox(width: 8),
                _ModeChip(
                    label: 'Solution',
                    selected: _mode == ChatMode.solution,
                    onTap: () => setState(() => _mode = ChatMode.solution)),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(32),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('Start a conversation',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Share how you\'re feeling today.',
                              style: TextStyle(color: Colors.grey.shade500)),
                        ]),
                      ))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) =>
                            _MessageBubble(message: _messages[i]),
                      ),
          ),
          // Disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.amber.shade50,
            child: Text(
              'This is for support only, not professional advice.',
              style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
              textAlign: TextAlign.center,
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2))
            ]),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                          hintText: 'Type a message...',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12)),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: _isSending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.white, size: 20),
                            onPressed: _sendMessage),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.primary)),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : theme.colorScheme.primary,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
            top: 8, left: isUser ? 48 : 0, right: isUser ? 0 : 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: isUser ? theme.colorScheme.primary : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16)),
        child: Text(message.message,
            style: TextStyle(color: isUser ? Colors.white : Colors.black87)),
      ),
    );
  }
}
