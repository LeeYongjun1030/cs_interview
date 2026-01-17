import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/language_service.dart';
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
        SnackBar(
            content: Text(
                Provider.of<LanguageController>(context, listen: false).isKorean
                    ? '음성 인식을 사용할 수 없습니다. 권한을 확인해주세요.'
                    : 'Microphone permission denied.')),
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
    final langController =
        Provider.of<LanguageController>(context, listen: false);
    final strings = AppStrings(langController.currentLanguage);

    final text = _answerController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.emptyInputError)),
      );
      return;
    }

    _answerController.clear();
    setState(() {
      _isTipVisible = false;
      _isListening = false;
    });
    _speech.stop();

    await widget.controller
        .submitAnswer(text, languageCode: langController.currentLanguage.code);

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

          final langController = Provider.of<LanguageController>(context);
          final strings = AppStrings(langController.currentLanguage);

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
                              '${_getSubjectName(currentQuestion.subject, strings)} • ${currentQuestion.getLocalizedCategory(langController.currentLanguage.code).toUpperCase()}',
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary, letterSpacing: 2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentQuestion.getLocalizedQuestion(
                                  langController.currentLanguage.code),
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
                                      _isTipVisible
                                          ? strings.tipHide
                                          : strings.tipShow,
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
                                  currentQuestion
                                          .getLocalizedTip(langController
                                              .currentLanguage.code)
                                          .isEmpty
                                      ? strings.noTip
                                      : currentQuestion.getLocalizedTip(
                                          langController.currentLanguage.code),
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
                              Text(strings.yourAnswer,
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
                                    strings.followUpTitle,
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
                      Text(strings.inputLabel, // Simplified & Localized
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
                                    ? strings.listening
                                    : (isFollowUp
                                        ? strings.inputPlaceholderFollowUp
                                        : strings.inputPlaceholderMain),
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
                                      child: Text(strings.listening,
                                          style: const TextStyle(
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
                                  child: Text(strings.passButton),
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
                                  child: Text(strings.submitButton,
                                      style: const TextStyle(
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
                            child: Text(strings.submitButton,
                                style: const TextStyle(
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
                          strings.waitMessage,
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

  String _getSubjectName(String subjectId, AppStrings strings) {
    switch (subjectId) {
      case 'computer_architecture':
        return strings.subjectArch;
      case 'operating_system':
        return strings.subjectOS;
      case 'network':
        return strings.subjectNetwork;
      case 'database':
        return strings.subjectDB;
      case 'data_structure':
        return strings.subjectDS;
      case 'java':
        return strings.subjectJava;
      case 'javascript':
        return strings.subjectJs;
      default:
        return subjectId;
    }
  }
}
