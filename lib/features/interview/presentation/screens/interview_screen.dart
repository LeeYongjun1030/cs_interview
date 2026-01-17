import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/session_controller.dart';
import 'result_screen.dart';

class InterviewScreen extends StatefulWidget {
  final SessionController controller;

  const InterviewScreen({super.key, required this.controller});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final TextEditingController _answerController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isSpeechAvailable = false;
  bool _isTipVisible = false;

  @override
  void initState() {
    super.initState();

    print('[InterviewScreen] initState');
    _speech = stt.SpeechToText();
    // Assuming controller needs initialization or likely already done in previous screen
    // widget.controller.startNewSession if not already?
    // It's usually called before navigating here.
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _isSpeechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) {
          if (mounted) setState(() => _isListening = false);
        },
      );
      if (mounted) setState(() {});
    } catch (e) {
      // debugPrint('STT Init Error: $e');
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _toggleListening() async {
    if (!_isSpeechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('음성 인식을 사용할 수 없습니다. 권한을 확인해주세요.')),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _answerController.text = result.recognizedWords;
          });
        },
        localeId: 'ko_KR',
      );
    }
  }

  Future<void> _handleSubmit() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답변을 입력해주세요.')),
      );
      return;
    }

    _answerController.clear();
    setState(() {
      _isTipVisible = false;
      _isListening = false;
    });
    _speech.stop();

    await widget.controller.submitAnswer(text);

    if (!mounted) return;

    if (widget.controller.isSessionFinished) {
      _navigateToResult();
    }
  }

  void _navigateToResult() {
    final rounds = widget.controller.rounds;
    double totalScore = 0;
    int count = 0;
    for (var round in rounds) {
      if (round.mainGrade != null) {
        totalScore += round.mainGrade!.score;
        count++;
      }
      if (round.followUpGrade != null) {
        totalScore += round.followUpGrade!.score;
        count++;
      }
    }
    final double averageScore = count > 0 ? totalScore / count : 0.0;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => InterviewResultScreen(
                rounds: rounds,
                averageScore: averageScore,
                controller: widget.controller,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          final round = widget.controller.currentRound;
          final currentQuestion = widget.controller.currentQuestion;

          if (currentQuestion == null) {
            if (widget.controller.isSessionFinished) return const SizedBox();
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          final isFollowUp = widget.controller.isFollowUpMode;
          final isThinking = widget.controller.isAiThinking;

          return Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.background,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    widget.controller.sessionTitle,
                    style:
                        AppTextStyles.titleMedium.copyWith(color: Colors.white),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Center(
                        child: Text(
                          '${widget.controller.currentIndex + 1}/${widget.controller.totalQuestions}',
                          style: AppTextStyles.titleLarge
                              .copyWith(color: AppColors.accentCyan),
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
                      // --- Main Question Card ---
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                          boxShadow: AppColors.neonShadow,
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_getSubjectKoreanName(currentQuestion.subject)} • ${currentQuestion.category.toUpperCase()}',
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary, letterSpacing: 2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentQuestion.question,
                              style: AppTextStyles.headlineSmall.copyWith(
                                  fontWeight: FontWeight.bold, height: 1.4),
                              textAlign: TextAlign.center,
                            ),
                            // Tip Section
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isTipVisible = !_isTipVisible;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isTipVisible
                                          ? Icons.visibility_off
                                          : Icons.lightbulb_outline,
                                      color: _isTipVisible
                                          ? Colors.grey
                                          : AppColors.accentGreen,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isTipVisible ? '꿀팁 숨기기' : '꿀팁 보기',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: _isTipVisible
                                            ? Colors.grey
                                            : AppColors.accentGreen,
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
                                  color: AppColors.accentGreen
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  currentQuestion.tip.isEmpty
                                      ? '등록된 팁이 없습니다.'
                                      : currentQuestion.tip,
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.accentGreen),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),

                      // --- Previous Answer (Main) ---
                      if (isFollowUp && round?.mainAnswer != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('나의 답변:',
                                  style: AppTextStyles.labelSmall
                                      .copyWith(color: Colors.white54)),
                              const SizedBox(height: 4),
                              Text(round!.mainAnswer!,
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],

                      // --- Follow-Up Question Card ---
                      if (isFollowUp) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.accentRed.withValues(
                                alpha: 0.1), // Danger/Attention color
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.accentRed),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.psychology,
                                      color: AppColors.accentRed),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI 꼬리 질문',
                                    style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.accentRed,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                round?.followUpQuestion ?? '',
                                style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold, height: 1.4),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // --- Input Area ---
                      Text(isFollowUp ? '꼬리 질문 답변 입력' : '답변 입력',
                          style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isListening
                                ? AppColors.accentRed
                                : Colors.white10,
                            width: _isListening ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _answerController,
                              maxLines: 5,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: _isListening
                                    ? '듣고 있습니다...'
                                    : (isFollowUp
                                        ? '꼬리 질문에 답변하거나 패스하세요.'
                                        : '질문에 대한 답변을 입력하거나 마이크를 켜세요.'),
                                hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3)),
                                filled: true,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                            // Toolbar
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: const BoxDecoration(
                                border: Border(
                                    top: BorderSide(color: Colors.white10)),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _isListening ? Icons.mic : Icons.mic_none,
                                      color: _isListening
                                          ? AppColors.accentRed
                                          : Colors.white70,
                                    ),
                                    onPressed: _toggleListening,
                                  ),
                                  if (_isListening)
                                    FadeTransition(
                                      opacity: const AlwaysStoppedAnimation(
                                          1.0), // Can animate later
                                      child: const Text('Recording...',
                                          style: TextStyle(
                                              color: AppColors.accentRed,
                                              fontSize: 12)),
                                    ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.send,
                                        color: AppColors.primary),
                                    onPressed: _handleSubmit,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: isFollowUp
                    ? SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    // SKIP FOLLOW UP
                                    widget.controller.passFollowUp();
                                    _answerController.clear();
                                    if (!context.mounted) return;
                                    if (widget.controller.isSessionFinished) {
                                      _navigateToResult();
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white54,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: const Text('잘 모르겠어요 (Pass)'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _handleSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentRed,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: const Text('제출하기',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('제출하기',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
              ),

              // --- AI Thinking Overlay ---
              if (isThinking)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                            color: AppColors.accentCyan),
                        const SizedBox(height: 24),
                        Text(
                          widget.controller.thinkingMessage,
                          style: AppTextStyles.titleMedium
                              .copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '잠시만 기다려주세요',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        });
  }

  String _getSubjectKoreanName(String subjectKey) {
    switch (subjectKey) {
      case 'computer_architecture':
        return '컴퓨터 구조';
      case 'operating_system':
        return '운영체제';
      case 'network':
        return '네트워크';
      case 'database':
        return '데이터베이스';
      case 'data_structure':
        return '자료구조';
      case 'java':
        return '자바';
      case 'javascript':
        return '자바스크립트';
      default:
        return '기타';
    }
  }
}
