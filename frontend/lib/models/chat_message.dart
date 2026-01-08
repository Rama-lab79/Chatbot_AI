class ChatMessage {
  final String? id;
  final String role; // 'user' or 'ai'
  final String message;
  final DateTime? createdAt;

  ChatMessage({
    this.id,
    required this.role,
    required this.message,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'],
      role: json['role'],
      message: json['message'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  bool get isUser => role == 'user';
  bool get isAi => role == 'ai';
}
