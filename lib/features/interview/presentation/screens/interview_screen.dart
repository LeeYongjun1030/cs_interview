import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/session_controller.dart';
import 'result_screen.dart';

// Since we are not using a real Dependency Injection yet for MVP,
// we will pass the controller or look it up (if using Provider).
// For simplicity in this step, I'll accept it as a parameter or create it if needed,
// but ideally it should be provided by `provider` package.
// Assuming the user hasn't set up `provider` package globally yet based on previous files,
// I will pass it from HomeScreen or create a singleton-like setup. 
// Actually, let's use a StatefulWidget and manage one instance, or expect it passed.

class InterviewScreen extends StatefulWidget {
  final SessionController controller;

  const InterviewScreen({super.key, required this.controller});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _isTipVisible = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답변을 입력해주세요.')),
      );
      return;
    }

    widget.controller.submitAnswer(_answerController.text);
    _answerController.clear();
    setState(() {
      _isTipVisible = false;
    });

    if (widget.controller.isSessionFinished) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to controller changes? 
    // Since SessionController extends ChangeNotifier, we should use AnimatedBuilder.
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final currentQuestion = widget.controller.currentQuestion;
        
        if (currentQuestion == null) {
          // Should not happen if isSessionFinished check works, but as fallback
          if (widget.controller.isSessionFinished) {
             // Just in case render happens before navigation
             return const SizedBox();
          }
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(), // Abort session
            ),
            title: Text(
              'Interview Session', 
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
            actions: [
               Padding(
                 padding: const EdgeInsets.only(right: 16),
                 child: Center(
                   child: Text(
                     '${widget.controller.currentIndex + 1}/${widget.controller.totalQuestions}',
                     style: AppTextStyles.titleLarge.copyWith(color: AppColors.accentCyan),
                   ),
                 ),
               )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Flashcard Area
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                    boxShadow: AppColors.neonShadow, // Dynamic tension glow could act here later
                  ),
                  child: Column(
                    children: [
                      Text(
                        currentQuestion.category.toUpperCase(), // e.g. NETWORK -> HTTP
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, letterSpacing: 2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentQuestion.question,
                        style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Tip Toggle
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isTipVisible = !_isTipVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isTipVisible ? Icons.visibility_off : Icons.lightbulb_outline,
                                color: _isTipVisible ? Colors.grey : AppColors.accentGreen,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isTipVisible ? '꿀팁 숨기기' : '꿀팁 보기',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: _isTipVisible ? Colors.grey : AppColors.accentGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isTipVisible) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentQuestion.tip.isEmpty ? '등록된 팁이 없습니다.' : currentQuestion.tip,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentGreen),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Input Area
                Text('답변 입력', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: _answerController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '질문에 대한 답변을 입력하거나 말해보세요...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                // Tools (Mic, etc - Visual Only for now)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic, color: Colors.white70),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('음성 입력은 아직 지원되지 않습니다.')),
                        );
                      }, 
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('제출하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      }
    );
  }
}
