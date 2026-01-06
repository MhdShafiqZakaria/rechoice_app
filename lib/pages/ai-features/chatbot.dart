import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isTyping = false; // AI typing indicator

  Future<String> sendToGemini(String userMessage) async {
    const String apiKey =
        "AIzaSyCEKVUWOU6Kf5s7-9Ytu4RyQCbAxv1a14Q"; // Paste your Gemini API key

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": userMessage},
            ],
          },
        ],
      }),
    );

    final data = jsonDecode(response.body);

    try {
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } catch (e) {
      return "Error: ${data.toString()}";
    }
  }

  /// Send message + show typing animation
  void sendMessage() async {
    String text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      isTyping = true; // Start typing animation
    });

    controller.clear();
    scrollToBottom();

    String reply = await sendToGemini(text);

    setState(() {
      isTyping = false; // Stop typing animation
      messages.add({"sender": "bot", "text": reply.trim()});
    });

    scrollToBottom();
  }

  /// For auto-scrolling to latest message
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /// Typing indicator widget
  Widget typingIndicator() {
    return Row(
      children: [
        const CircleAvatar(child: Icon(Icons.smart_toy)),
        const SizedBox(width: 10),
        const Text(
          "AI is typing",
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
        const SizedBox(width: 6),
        const AnimatedDots(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("ReBot"),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // Show typing animation as last line
                if (isTyping && index == messages.length) {
                  return typingIndicator();
                }

                final msg = messages[index];
                final isUser = msg["sender"] == "user";

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 6, bottom: 2),
                    padding: const EdgeInsets.all(14),
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated three dots (...) for typing
class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  _AnimatedDotsState createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<int> dotAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    dotAnimation = IntTween(begin: 0, end: 3).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dotAnimation,
      builder: (context, child) {
        String dots = "." * dotAnimation.value;
        return Text(dots, style: const TextStyle(fontSize: 18));
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
