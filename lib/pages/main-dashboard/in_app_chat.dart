import 'package:flutter/material.dart';
import 'package:rechoice_app/components/dashboard/chat_bubble.dart';
import 'package:rechoice_app/models/model/chat_message_model.dart';

class InAppChat extends StatefulWidget {
  const InAppChat({super.key});

  @override
  State<InAppChat> createState() => _InAppChatState();
}

class _InAppChatState extends State<InAppChat> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialMessage();
  }

  void _loadInitialMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          id: '0',
          text:
              'Hello! 👋 Welcome to ReChoice Chat. I\'m here to help you find the perfect preloved items or answer any questions about our platform. How can I assist you today?',
          isUserMessage: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _messageController.text,
      isUserMessage: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate bot response with a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _generateBotResponse(userMessage.text);
    });
  }

  void _generateBotResponse(String userMessage) {
    final botResponse = _getBotResponse(userMessage);
    final botMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: botResponse,
      isUserMessage: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(botMessage);
      _isLoading = false;
    });

    _scrollToBottom();
  }

  String _getBotResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('help') || lowerMessage.contains('assist')) {
      return 'I can help you with:\n• Searching for items\n• Browsing categories\n• Placing orders\n• Tracking your purchases\n• Managing your account\n\nWhat would you like help with?';
    } else if (lowerMessage.contains('price') ||
        lowerMessage.contains('cost') ||
        lowerMessage.contains('expensive')) {
      return 'Our preloved items are priced competitively based on their condition and market value. Most items range from RM 10 to RM 500. You can filter by price when browsing. Would you like recommendations in a specific price range?';
    } else if (lowerMessage.contains('return') ||
        lowerMessage.contains('refund') ||
        lowerMessage.contains('exchange')) {
      return 'Our return policy allows returns within 7 days of purchase if items are in the condition described. Please contact our support team at support@rechoice.com for more details about your specific situation.';
    } else if (lowerMessage.contains('shipping') ||
        lowerMessage.contains('delivery') ||
        lowerMessage.contains('ship')) {
      return 'We offer standard and express shipping options. Standard shipping (5-7 days) is available throughout Malaysia, while express shipping (1-2 days) is available in selected areas. Shipping costs vary based on location and weight.';
    } else if (lowerMessage.contains('payment') ||
        lowerMessage.contains('pay')) {
      return 'We accept multiple payment methods:\n• Credit/Debit Cards\n• Online Banking\n• E-wallets (GCash, GCash, etc.)\n• Bank Transfer\n\nAll payments are secured with SSL encryption.';
    } else if (lowerMessage.contains('category') ||
        lowerMessage.contains('item') ||
        lowerMessage.contains('product')) {
      return 'We have 5 main categories:\n📱 Electronics\n👗 Fashion\n📚 Books\n🏠 Home & Living\n💄 Personal Care\n\nBrowse our catalog to find your favorite items!';
    } else if (lowerMessage.contains('account') ||
        lowerMessage.contains('profile') ||
        lowerMessage.contains('login')) {
      return 'You can manage your account by tapping your profile icon. There you can:\n• Update personal information\n• View order history\n• Manage addresses\n• Change password\n• View wishlist\n\nIs there anything specific you need help with?';
    } else if (lowerMessage.contains('sell') || lowerMessage.contains('list')) {
      return 'Great! To list an item for sale:\n1. Go to "My Products" in your profile\n2. Tap "Add New Product"\n3. Fill in item details and upload photos\n4. Set your price\n5. Submit for approval\n\nOur team reviews listings within 24 hours. Need more help?';
    } else if (lowerMessage.contains('thank')) {
      return 'You\'re welcome! 😊 Is there anything else I can help you with?';
    } else if (lowerMessage.contains('yes') || lowerMessage.contains('ok')) {
      return 'Great! How can I further assist you?';
    } else if (lowerMessage.contains('no') || lowerMessage.contains('nope')) {
      return 'No problem! Feel free to ask me anything about ReChoice. I\'m here to help! 😊';
    } else if (lowerMessage.isEmpty) {
      return 'I didn\'t catch that. Could you please rephrase your question?';
    } else {
      return 'That\'s a great question! For specific inquiries, please contact our support team at support@rechoice.com or visit our FAQ section. Is there anything else I can help you with?';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text('S', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seller',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text('💬', style: TextStyle(fontSize: 40)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start a Conversation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ask me anything about ReChoice',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return ChatBubble(
                          message: _messages[index].text,
                          isUserMessage: _messages[index].isUserMessage,
                          timestamp: _messages[index].timestamp,
                        );
                      },
                    ),
            ),

            // Loading Indicator
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.blue.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Typing...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Input Field
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.blue.shade600,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _sendMessage,
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
