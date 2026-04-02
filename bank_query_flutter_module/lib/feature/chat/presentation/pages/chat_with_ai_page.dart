import 'package:bank_query_flutter_module/core/utils/image_constant.dart';
import 'package:bank_query_flutter_module/feature/chat/presentation/pages/talk_with_ai_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/ai_assistant_bloc.dart';
import '../bloc/ai_assistant_event.dart';
import '../bloc/ai_assistant_state.dart';
import '../widgets/chat_bubble.dart';

class ChatWithAiPage extends StatelessWidget {
  ChatWithAiPage({super.key});

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  void _send(BuildContext context, String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();
    context.read<AiAssistantBloc>().add(AskAi(text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(

          backgroundColor: Colors.white,
          elevation: 2,
          leading: const BackButton(color: Colors.black),
          titleSpacing: 0,
          title: Row(
            children: [
              Image.asset(ImageConstant.app_icon, height: 28, width: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "FinAI",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Always here to help",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 12),
          //     child: Image.asset(
          //       "assets/images/santander.png",
          //       height: 22,
          //     ),
          //   )
          // ],
        ),
      ),

      body: BlocListener<AiAssistantBloc, AiAssistantState>(
        listener: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scroll.hasClients) {
              _scroll.animateTo(
                _scroll.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        },
        child: BlocBuilder<AiAssistantBloc, AiAssistantState>(
          builder: (context, state) {
            final chat = state as AiChatState;

            return Column(
              children: [
              Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),

                    /// ✅ +1 FOR GREETING MESSAGE
                    itemCount:
                        chat.messages.length +
                        (chat.isThinking ? 1 : 0) +
                        (chat.messages.isEmpty ? 1 : 0),

                    itemBuilder: (context, index) {
                      /// ✅ SHOW GREETING FIRST
                      if (chat.messages.isEmpty && index == 0) {
                        return ChatBubble(
                          isSpeaking: false,
                          isUser: false,
                          text:
                              "Hi Sarah! I'm FinAI, you can ask me anything about your finances.",
                        );
                      }

                      /// ✅ FIX INDEX SHIFT
                      final msgIndex =
                          chat.messages.isEmpty ? index - 1 : index;

                      /// ✅ THINKING STATE
                      if (chat.isThinking && msgIndex == chat.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "Thinking...",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      if (msgIndex < 0 || msgIndex >= chat.messages.length) {
                        return const SizedBox.shrink();
                      }

                      final msg = chat.messages[msgIndex];

                      return ChatBubble(
                          isSpeaking: false,
                          text: msg.text, isUser: msg.isUser);
                    },
                  ),
                ),

                /// ✅ INPUT
                _inputBar(context),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------- UI WIDGETS ----------------

  Widget _inputBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Ask me anything ...",
                  suffixIcon: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return TalkWithAiPage();
                          },
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.mic_none_rounded,
                      color: Colors.red,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (v) => _send(context, v),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () => _send(context, _controller.text),
              child: Image.asset(
                ImageConstant.send_icon,
                height: 20,
                width: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(String text) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        shape: StadiumBorder(),
        side: const BorderSide(color: Colors.red),
      ),
      child: Text(text, style: const TextStyle(color: Colors.red)),
    );
  }
}
