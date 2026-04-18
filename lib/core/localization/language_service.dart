import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  korean('🇰🇷 한국어', 'ko'),
  english('🇺🇸 English', 'en');

  final String label;
  final String code;
  const AppLanguage(this.label, this.code);
}

class LanguageController extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english; // Default to Global
  bool _isLoaded = false;
  bool _hasLanguageSet = false;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isKorean => _currentLanguage == AppLanguage.korean;
  AppStrings get strings => AppStrings(_currentLanguage);
  bool get hasLanguageSet => _hasLanguageSet;
  bool get isLoaded => _isLoaded;

  LanguageController() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code');
    if (langCode != null) {
      _currentLanguage = AppLanguage.values.firstWhere(
        (e) => e.code == langCode,
        orElse: () => AppLanguage.english,
      );
      _hasLanguageSet = true;
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _currentLanguage = lang;
    _hasLanguageSet = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', lang.code);
  }

  void toggleLanguage() {
    setLanguage(_currentLanguage == AppLanguage.korean
        ? AppLanguage.english
        : AppLanguage.korean);
  }
}

class AppStrings {
  final AppLanguage language;

  AppStrings(this.language);

  // Home Screen
  String get appTitle => language == AppLanguage.korean ? 'SoarQ' : 'SoarQ';
  String get recentSessions =>
      language == AppLanguage.korean ? '최근 면접 기록' : 'Recent Sessions';
  String get startNewSession =>
      language == AppLanguage.korean ? '새로운 면접 시작' : 'Start New Session';
  String get startSessionSubtitle => language == AppLanguage.korean
      ? 'AI 면접관과 함께 실전 연습'
      : 'Practice with AI Interviewer';
  String get enterSessionTitle =>
      language == AppLanguage.korean ? '면접 세션의 이름을 정해주세요' : 'Name your session';
  String get defaultSessionTitle =>
      language == AppLanguage.korean ? '새로운 면접' : 'New Session';
  String get startButton => language == AppLanguage.korean ? '시작하기' : 'Start';
  String get cancelButton => language == AppLanguage.korean ? '취소' : 'Cancel';

  // Navigation
  String get navHome => language == AppLanguage.korean ? '홈' : 'Home';
  String get navLearning => language == AppLanguage.korean ? '학습' : 'Learning';
  String get navProfile => language == AppLanguage.korean ? '마이페이지' : 'My Page';

  // Subjects
  String get subjectNetwork =>
      language == AppLanguage.korean ? '네트워크' : 'Network';
  String get subjectArch =>
      language == AppLanguage.korean ? '컴퓨터구조' : 'Computer Architecture';
  String get subjectOS => language == AppLanguage.korean ? '운영체제' : 'OS';
  String get subjectDB =>
      language == AppLanguage.korean ? '데이터베이스' : 'Database';
  String get subjectDS =>
      language == AppLanguage.korean ? '자료구조' : 'Data Structure';
  String get subjectJava => 'Java'; // Same for now, or '자바'
  String get subjectJs => 'JavaScript'; // Same for now

  // Interview Screen
  String get interviewTitle =>
      language == AppLanguage.korean ? '실전 면접' : 'Mock Interview';
  String get question => language == AppLanguage.korean ? '질문' : 'Question';
  String get yourAnswer =>
      language == AppLanguage.korean ? '나의 답변' : 'Your Answer';
  String get hintText => language == AppLanguage.korean
      ? '답변을 입력하거나 마이크를 눌러 말해보세요.'
      : 'Type your answer or use the microphone.';
  String get tipShow => language == AppLanguage.korean ? '꿀팁 보기' : 'Show Tip';
  String get tipHide => language == AppLanguage.korean ? '꿀팁 숨기기' : 'Hide Tip';
  String get noTip =>
      language == AppLanguage.korean ? '등록된 팁이 없습니다.' : 'No tip available.';

  String get listening =>
      language == AppLanguage.korean ? '듣고 있습니다...' : 'Listening...';
  String get inputPlaceholderMain => language == AppLanguage.korean
      ? '질문에 대한 답변을 입력하거나 마이크를 켜세요.'
      : 'Type your answer or use the mic.';
  String get inputPlaceholderFollowUp => language == AppLanguage.korean
      ? '꼬리 질문에 답변하거나 패스하세요.'
      : 'Answer the follow-up or press Pass.';

  String get micPermissionError => language == AppLanguage.korean
      ? '음성 인식을 사용할 수 없습니다. 권한을 확인해주세요.'
      : 'Microphone permission denied.';
  String get emptyInputError => language == AppLanguage.korean
      ? '답변을 입력해주세요.'
      : 'Please enter your answer.';

  String get submitButton => language == AppLanguage.korean ? '제출하기' : 'Submit';
  String get passButton =>
      language == AppLanguage.korean ? '모르겠어요 (넘어가기)' : 'Pass (I don\'t know)';
  String get nextButton =>
      language == AppLanguage.korean ? '다음 문제' : 'Next Question';
  String get finishButton =>
      language == AppLanguage.korean ? '면접 종료' : 'Finish Interview';
  String get aiThinking => language == AppLanguage.korean
      ? 'AI 면접관이 답변을 분석중입니다...'
      : 'AI is analyzing your answer...';
  String get aiFeedbackTitle =>
      language == AppLanguage.korean ? 'AI 피드백' : 'AI Feedback';
  String get followUpTitle =>
      language == AppLanguage.korean ? '꼬리 질문' : 'Follow-up Question';

  // Result Screen
  String get resultTitle =>
      language == AppLanguage.korean ? '면접 결과' : 'Interview Result';
  String get overallScore =>
      language == AppLanguage.korean ? '종합 점수' : 'Overall Score';
  String get feedbackSummary =>
      language == AppLanguage.korean ? '피드백 요약' : 'Feedback Summary';
  String get homeButton =>
      language == AppLanguage.korean ? '홈으로 이동' : 'Go Home';
  String get retryButton => language == AppLanguage.korean ? '다시 도전' : 'Retry';

  // Result Screen
  String get resultReportTitle =>
      language == AppLanguage.korean ? '면접 결과 리포트' : 'Interview Result Report';
  String get myAnswer => language == AppLanguage.korean ? '나의 답변' : 'My Answer';
  String get aiFeedback => language == AppLanguage.korean
      ? 'AI 면접관의 피드백'
      : 'AI Interviewer\'s Feedback';
  String get noFeedback =>
      language == AppLanguage.korean ? '피드백 없음' : 'No Feedback';
  String get retrySameQuestions => language == AppLanguage.korean
      ? '같은 질문으로 다시 도전 (Retry)'
      : 'Retry with same questions';
  String get retryTitleDialog =>
      language == AppLanguage.korean ? '다시 도전하기' : 'Retry Session';
  String get retryContentDialog => language == AppLanguage.korean
      ? '이전 세션과 동일한 질문으로\n새로운 세션을 시작합니다.'
      : 'Start a new session with the\nsame questions as before.';
  String get strengthsTitle =>
      language == AppLanguage.korean ? '잘한 점' : 'Strengths';
  String get weaknessesTitle =>
      language == AppLanguage.korean ? '아쉬운 점' : 'Areas for Improvement';
  String get sessionNameLabel =>
      language == AppLanguage.korean ? '세션 이름' : 'Session Name';
  String get startAction => language == AppLanguage.korean ? '시작' : 'Start';
  String get lastStudied =>
      language == AppLanguage.korean ? '마지막 학습' : 'Last Studied';

  // Subject Screen
  String get searchQuestions =>
      language == AppLanguage.korean ? '질문 검색...' : 'Search questions...';
  String get noSearchResults =>
      language == AppLanguage.korean ? '검색 결과가 없습니다.' : 'No results found.';
  String get noQuestions => language == AppLanguage.korean
      ? '등록된 질문이 없습니다.'
      : 'No questions available.';
  String get loadFail => language == AppLanguage.korean
      ? '질문을 불러오는데 실패했습니다:'
      : 'Failed to load questions:';
  String get maxSelectionMessage => language == AppLanguage.korean
      ? '최대 3개의 질문까지 선택할 수 있습니다.'
      : 'You can select up to 3 questions.';
  String get startInterview =>
      language == AppLanguage.korean ? '인터뷰 시작' : 'Start Interview';

  // Login Screen
  String get loginTitle => 'SoarQ';
  String get loginSubtitle => language == AppLanguage.korean
      ? 'SoarQ와 함께하는 CS 인터뷰 준비'
      : 'Prepare for CS Interviews with SoarQ';
  String get signInGoogle =>
      language == AppLanguage.korean ? 'Google로 시작하기' : 'Sign in with Google';
  String get signInGitHub =>
      language == AppLanguage.korean ? 'GitHub로 시작하기' : 'Sign in with GitHub';
  String get signInApple =>
      language == AppLanguage.korean ? 'Apple로 시작하기' : 'Sign in with Apple';
  String get signingIn =>
      language == AppLanguage.korean ? '로그인 중...' : 'Signing in...';
  String get loginFooter => language == AppLanguage.korean
      ? '수천 명의 개발자와 함께 꿈의 직장을 준비하세요.'
      : 'Join thousands of developers preparing for their dream job.';
  String get loginConsentStart => language == AppLanguage.korean
      ? '계속 진행 시 '
      : 'By continuing, you agree to our ';
  String get loginConsentLink =>
      language == AppLanguage.korean ? '개인정보 처리방침' : 'Privacy Policy';
  String get loginConsentEnd =>
      language == AppLanguage.korean ? '에 동의하는 것으로 간주합니다.' : '.';

  // Common
  String get loading =>
      language == AppLanguage.korean ? '로딩중...' : 'Loading...';
  String get error => language == AppLanguage.korean ? '오류 발생' : 'Error';
  String get errorAccountExistsWithDifferentCredential => language ==
          AppLanguage.korean
      ? '이미 다른 계정(Google 등)으로 가입된 이메일입니다. 해당 계정으로 로그인해주세요.'
      : 'An account already exists with the same email. Please sign in with your existing provider.';

  // Home Screen Sections & UI
  String get sectionSubjectLearning =>
      language == AppLanguage.korean ? '과목별 학습' : 'Subject Learning';
  String get recentSessionBadge =>
      language == AppLanguage.korean ? '최근 학습 기록' : 'Latest Result';
  String get scorePrefix => language == AppLanguage.korean ? '점수' : 'Score';
  String get scoreSuffix => language == AppLanguage.korean ? '점' : 'pts';
  String get startInterviewButton =>
      language == AppLanguage.korean ? '실전 면접 시작' : 'Start Mock Interview';
  String get aiStandbyStatus =>
      language == AppLanguage.korean ? 'AI 면접관 대기중' : 'AI INTERVIEWER STANDBY';
  String get readyToInterview =>
      language == AppLanguage.korean ? '면접 준비 되셨나요?' : 'READY TO INTERVIEW?';
  String get membershipPlaceholder =>
      language == AppLanguage.korean ? '멤버십 화면 준비중' : 'Membership Coming Soon';

  // Dialogs
  String get sessionGoalHint => language == AppLanguage.korean
      ? '이번 면접 세션의 목표나 제목을 정해주세요.'
      : 'Set a goal or title for this session.';
  String get sessionTitleHint =>
      language == AppLanguage.korean ? '예: 네트워크 뿌시기' : 'e.g., Network Mastery';
  String get selectSubjectTitle =>
      language == AppLanguage.korean ? '출제 과목 선택' : 'Select Interview Subjects';
  String get selectSubjectSubtitle => language == AppLanguage.korean
      ? '원하는 과목을 선택해주세요. (복수 선택 가능)'
      : 'Select subjects to include. (Multiple allowed)';
  String get nextButtonLabel => language == AppLanguage.korean ? '다음' : 'Next';

  String get inputLabel =>
      language == AppLanguage.korean ? '답변 입력' : 'Enter Answer';
  String get waitMessage =>
      language == AppLanguage.korean ? '잠시만 기다려주세요' : 'Please wait a moment';

  String get lectureScreenTitle =>
      language == AppLanguage.korean ? '과목별 학습' : 'Study by Subject';
  String get lectureScreenSubtitle => language == AppLanguage.korean
      ? '과목을 선택하고 질문을 탐색하세요'
      : 'Select a subject and explore questions';
  String get watchVideoLecture => language == AppLanguage.korean
      ? '🎬 동영상으로 학습하기'
      : '🎬 Watch Video Lecture';

  // Lecture Descriptions
  String get lectureDescArch =>
      language == AppLanguage.korean ? 'CS 개념의 뿌리' : 'Roots of CS Concepts';
  String get lectureDescOS => language == AppLanguage.korean
      ? '프로그램 실행의 원리'
      : 'Principles of Program Execution';
  String get lectureDescNetwork => language == AppLanguage.korean
      ? '서비스 연결의 핵심'
      : 'Core of Service Connectivity';
  String get lectureDescDB =>
      language == AppLanguage.korean ? '데이터 다루는 법' : 'How to Handle Data';
  String get lectureDescDS =>
      language == AppLanguage.korean ? '문제 해결의 시작' : 'Start of Problem Solving';
  String get lectureDescJava => language == AppLanguage.korean
      ? '프로그래밍 핵심 (Java)'
      : 'Core of Programming (Java)';
  String get lectureDescJs => language == AppLanguage.korean
      ? '프로그래밍 핵심 (JS)'
      : 'Core of Programming (JS)';
  // Profile Screen
  String get settingsTitle =>
      language == AppLanguage.korean ? '설정' : 'Settings';
  String get accountTitle => language == AppLanguage.korean ? '계정' : 'Account';
  String get languageSettingTitle =>
      language == AppLanguage.korean ? '언어 설정' : 'Language Settings';
  String get themeSettingTitle =>
      language == AppLanguage.korean ? '테마 설정' : 'Theme Settings';
  String get themeLight =>
      language == AppLanguage.korean ? '라이트 모드' : 'Light Mode';
  String get themeDark =>
      language == AppLanguage.korean ? '다크 모드' : 'Dark Mode';

  String get logoutLabel => language == AppLanguage.korean ? '로그아웃' : 'Logout';
  String get resetDataLabel =>
      language == AppLanguage.korean ? '기록 초기화' : 'Reset Data';

  String get resetDialogTitle =>
      language == AppLanguage.korean ? '데이터 초기화' : 'Reset Data';
  String get resetDialogContent => language == AppLanguage.korean
      ? '모든 인터뷰 기록이 영구적으로 삭제됩니다.\n정말 삭제하시겠습니까?'
      : 'All interview history will be deleted.\nAre you sure?';

  String get deleteSessionTitle =>
      language == AppLanguage.korean ? '세션 삭제' : 'Delete Session';
  String get deleteSessionContent => language == AppLanguage.korean
      ? '이 인터뷰 세션이 영구적으로 삭제됩니다.\n정말 삭제하시겠습니까?'
      : 'This session will be permanently deleted.\nAre you sure?';

  String get deleteAction => language == AppLanguage.korean ? '삭제' : 'Delete';

  String get deleteAccountLabel =>
      language == AppLanguage.korean ? '회원 탈퇴' : 'Delete Account';

  String get deleteAccountDialogTitle =>
      language == AppLanguage.korean ? '회원 탈퇴' : 'Delete Account';

  String get deleteAccountDialogContent => language == AppLanguage.korean
      ? '계정을 삭제하면 모든 인터뷰 기록과 보유 크레딧이 영구적으로 삭제되며 복구할 수 없습니다.\n정말 탈퇴하시겠습니까?'
      : 'Deleting your account will permanently remove all interview records and credits. This action cannot be undone.\nAre you sure?';

  String get deleteAccountSuccess => language == AppLanguage.korean
      ? '회원 탈퇴가 완료되었습니다.'
      : 'Account deleted successfully.';

  String get deleteAccountReauth => language == AppLanguage.korean
      ? '보안을 위해 다시 로그인 후 시도해주세요.'
      : 'Please sign in again to confirm deletion.';

  // Support
  String get supportTitle => language == AppLanguage.korean ? '지원' : 'Support';
  String get contactLabel =>
      language == AppLanguage.korean ? '문의하기' : 'Contact Us';
  String get privacyLabel =>
      language == AppLanguage.korean ? '개인정보 처리방침' : 'Privacy Policy';

  // Ads & Shop
  String get shopTitle =>
      language == AppLanguage.korean ? '에너지 충전소 ⚡' : 'Energy Shop ⚡';
  String get shopMessage => language == AppLanguage.korean
      ? '광고를 보고 에너지를 충전하시겠습니까?'
      : 'Watch an ad to recharge energy?';

  String get notEnoughEnergy =>
      language == AppLanguage.korean ? '에너지가 부족합니다' : 'Not Enough Energy';
  String get needEnergyMessage => language == AppLanguage.korean
      ? '면접을 시작하려면 에너지가 필요합니다.\n'
      : 'You need energy to start an interview.\n';
  String get watchAdAction =>
      language == AppLanguage.korean ? '광고 보고 충전하기' : 'Watch Ad to Recharge';
  String get dailyBonusMessage => language == AppLanguage.korean
      ? '🎉 매일 접속 보너스! +1 에너지를 획득했습니다.'
      : '🎉 Daily Bonus! +1 Energy Added';
  String get adLoadFailed => language == AppLanguage.korean
      ? '광고를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.'
      : 'Failed to load ad. Please try again later.';
  String get rewardSuccessMessage => language == AppLanguage.korean
      ? '충전 완료!\n+1 에너지를 획득했습니다.'
      : 'Recharge Complete!\n+1 Energy added.';
  String get notEnoughEnergySnack => language == AppLanguage.korean
      ? '에너지가 부족합니다. 충전소에서 충전해주세요.'
      : 'Not enough energy. Please recharge.';

  // Max Credit Warning
  String get maxCreditReachedTitle =>
      language == AppLanguage.korean ? '최대 충전 한도 도달' : 'Max Limit Reached';
  String get maxCreditReachedMessage => language == AppLanguage.korean
      ? '현재 최대 한도(50개)까지 에너지가 충전되어 있습니다.\n면접 연습을 통해 에너지를 사용하신 후 다시 충전해주세요!'
      : 'You have reached the maximum limit of 50 credits.\nPlease use some credits to practice first!';
  // Time Ago
  String get justNow => language == AppLanguage.korean ? '방금 전' : 'Just now';
  String get minutesAgo =>
      language == AppLanguage.korean ? '분 전' : 'minutes ago';
  String get hoursAgo => language == AppLanguage.korean ? '시간 전' : 'hours ago';
  String get daysAgo => language == AppLanguage.korean ? '일 전' : 'days ago';
  String get yesterday => language == AppLanguage.korean ? '어제' : 'Yesterday';

  String get subjectQuestionsGuide => language == AppLanguage.korean
      ? '질문을 탭하여 학습하세요.'
      : 'Tap a question to study.';
  String get viewAnswer =>
      language == AppLanguage.korean ? '정답 보기' : 'View Answer';

  // ======================================================================
  // NEW: Training App Strings
  // ======================================================================

  // Navigation (4 tabs)
  String get navTraining => language == AppLanguage.korean ? '훈련' : 'Training';
  String get navRecords => language == AppLanguage.korean ? '기록' : 'Records';

  // Dashboard / Home Tab
  String get dashboardTitle =>
      language == AppLanguage.korean ? '대시보드' : 'Dashboard';
  String get todayTraining =>
      language == AppLanguage.korean ? '오늘의 훈련' : "Today's Training";
  String get startTodayTraining =>
      language == AppLanguage.korean ? '훈련 시작하기' : 'Start Training';
  String get myAbilityRadar =>
      language == AppLanguage.korean ? '나의 면접 분석' : 'My Interview Analysis';
  String get myAnalysisTitle =>
      language == AppLanguage.korean ? '나의 면접 분석' : 'My Interview Analysis';
  String get recentTrainingContinue => language == AppLanguage.korean
      ? '최근 훈련 이어하기'
      : 'Continue Recent Training';
  String get noTrainingYet => language == AppLanguage.korean
      ? '아직 훈련 기록이 없습니다.\n첫 번째 훈련을 시작해보세요!'
      : 'No training records yet.\nStart your first training!';

  // Greetings
  String get greetingMorning =>
      language == AppLanguage.korean ? '좋은 아침이에요' : 'Good morning';
  String get greetingAfternoon =>
      language == AppLanguage.korean ? '좋은 오후예요' : 'Good afternoon';
  String get greetingEvening =>
      language == AppLanguage.korean ? '좋은 저녁이에요' : 'Good evening';

  // Training streak / retention
  String trainingStreakMessage(int count) => language == AppLanguage.korean
      ? '총 $count회 훈련 완료!'
      : '$count trainings completed!';

  // Analysis info dialog
  String get analysisExplanation => language == AppLanguage.korean
      ? '훈련을 완료하면 AI가 6개 항목을 평가합니다.\n\n• 한문장 요약\n• 원리 설명\n• 예시/경험\n• 키워드 활용\n• 전달력\n• 꼬리질문 대응\n\n각 점수는 기존 점수와 새 평가를 7:3 비율로 반영하여 누적됩니다.'
      : 'After each training, AI evaluates 6 areas:\n\n• Summary\n• Principle\n• Example\n• Keywords\n• Clarity\n• Follow-up\n\nScores blend 70% existing + 30% new evaluation.';
  String get confirmButton => language == AppLanguage.korean ? '확인' : 'OK';

  // Exit training confirmation
  String get exitTrainingTitle =>
      language == AppLanguage.korean ? '훈련을 종료할까요?' : 'End training?';
  String get exitTrainingMessage => language == AppLanguage.korean
      ? '지금 나가시면 진행 사항이 기록되지 않으며\n훈련이 종료됩니다.'
      : 'If you leave now, your progress will not be saved\nand training will end.';
  String get skippedTrainingLabel =>
      language == AppLanguage.korean ? '모범 답안만 확인 (평가 건너뜀)' : 'Answer skipped (Model answer only)';
  String get skippedFollowUpLabel =>
      language == AppLanguage.korean ? '꼬리질문 (건너뜀)' : 'Follow-up (Skipped)';
  String get skippedBadge =>
      language == AppLanguage.korean ? '스킵' : 'Skipped';
  String get continueTraining =>
      language == AppLanguage.korean ? '계속하기' : 'Continue';
  String get exitAnyway => language == AppLanguage.korean ? '나가기' : 'Exit';

  // Radar Chart Axes
  String get axisSummary =>
      language == AppLanguage.korean ? '한문장 요약' : 'Summary';
  String get axisPrinciple =>
      language == AppLanguage.korean ? '원리 설명' : 'Principle';
  String get axisExample =>
      language == AppLanguage.korean ? '예시/경험' : 'Example';
  String get axisKeyword =>
      language == AppLanguage.korean ? '핵심 키워드' : 'Keywords';
  String get axisClarity =>
      language == AppLanguage.korean ? '흐름/명확성' : 'Clarity';
  String get axisFollowUp =>
      language == AppLanguage.korean ? '꼬리질문 대응' : 'Follow-up';

  // Training Tab
  String get trainingTabTitle =>
      language == AppLanguage.korean ? '훈련' : 'Training';
  String get selectSubjectToTrain => language == AppLanguage.korean
      ? '과목을 선택하고 훈련을 시작하세요'
      : 'Select a subject to start training';

  // Question Detail (branch)
  String get quickViewButton =>
      language == AppLanguage.korean ? '빠르게 보기' : 'Quick View';
  String get trainButton =>
      language == AppLanguage.korean ? '훈련하기' : 'Start Training';
  String get tipLabel => language == AppLanguage.korean ? '답변 팁' : 'Answer Tip';
  String get keywordsLabel =>
      language == AppLanguage.korean ? '핵심 키워드' : 'KEY WORDS';
  String get quickViewDescription => language == AppLanguage.korean
      ? '모범답안과 핵심 포인트 확인'
      : 'Check model answer & key points';
  String get trainDescription => language == AppLanguage.korean
      ? '단계별로 답변을 작성하고 AI 피드백 받기'
      : 'Write answers step-by-step & get AI feedback';
  String get showAnswer =>
      language == AppLanguage.korean ? '답변 보기' : 'Show Answer';
  String get hideAnswer =>
      language == AppLanguage.korean ? '답변 숨기기' : 'Hide Answer';

  // Quick View Screen
  String get quickViewTitle =>
      language == AppLanguage.korean ? '빠르게 보기' : 'Quick View';
  String get keySummary =>
      language == AppLanguage.korean ? '핵심 요약' : 'Key Summary';
  String get keyKeywords =>
      language == AppLanguage.korean ? '핵심 키워드' : 'Key Keywords';
  String get interviewTip =>
      language == AppLanguage.korean ? '꿀팁' : 'Interview Tip';
  String get referenceAnswer =>
      language == AppLanguage.korean ? '참고 답안' : 'Reference Answer';
  String get startTrainingCTA =>
      language == AppLanguage.korean ? '훈련하기' : 'Start Training';

  // Training Flow Steps
  String get stepATitle =>
      language == AppLanguage.korean ? '한 문장 답변' : 'One-Sentence Answer';
  String get stepAHint => language == AppLanguage.korean
      ? '핵심을 한 문장으로 요약해 보세요.'
      : 'Summarize the key point in one sentence.';
  String get stepBTitle =>
      language == AppLanguage.korean ? '원리와 함께 설명' : 'Explain with Principle';
  String get stepBHint => language == AppLanguage.korean
      ? '동작 원리를 2~3문장으로 설명해 보세요.'
      : 'Explain the principle in 2-3 sentences.';
  String get stepCTitle =>
      language == AppLanguage.korean ? '예시 추가' : 'Add Example';
  String get stepCHint => language == AppLanguage.korean
      ? '예시, 경험, 또는 비유를 추가해 보세요.'
      : 'Add an example, experience, or analogy.';
  String get nextStep => language == AppLanguage.korean ? '다음' : 'Next';
  String get previousStep => language == AppLanguage.korean ? '이전' : 'Back';
  String get receiveFollowUp =>
      language == AppLanguage.korean ? '꼬리질문 받기' : 'Get Follow-up';
  String get followUpQuestionLabel =>
      language == AppLanguage.korean ? '꼬리 질문' : 'Follow-up Question';
  String get followUpAnswerHint => language == AppLanguage.korean
      ? '꼬리 질문에 대한 답변을 입력하세요.'
      : 'Enter your answer to the follow-up question.';
  String get submitEvaluation =>
      language == AppLanguage.korean ? '평가 받기' : 'Get Evaluation';
  String get generatingFollowUp => language == AppLanguage.korean
      ? '꼬리 질문을 생성하고 있습니다...'
      : 'Generating follow-up question...';
  String get evaluatingAnswers => language == AppLanguage.korean
      ? '답변을 평가하고 있습니다...'
      : 'Evaluating your answers...';

  // Evaluation Result (Step F)
  String get evaluationTitle =>
      language == AppLanguage.korean ? '평가 결과' : 'Evaluation Result';
  String get totalScoreLabel =>
      language == AppLanguage.korean ? '총점' : 'Total Score';
  String get improvementPointsLabel =>
      language == AppLanguage.korean ? '개선 포인트' : 'Improvement Points';
  String get tryAgain => language == AppLanguage.korean ? '다시 도전' : 'Try Again';
  String get viewRecords =>
      language == AppLanguage.korean ? '기록 보기' : 'View Records';
  String get backToHome => language == AppLanguage.korean ? '홈으로' : 'Go Home';

  // Training Flow — New
  String get trainingTitle =>
      language == AppLanguage.korean ? '답변 훈련' : 'Answer Training';
  String get feedbackTitle =>
      language == AppLanguage.korean ? '피드백' : 'Feedback';
  String get answerHint => language == AppLanguage.korean
      ? '면접에서 말할 것처럼 답변을 작성해 보세요'
      : 'Write your answer as you would speak in an interview';
  String get submitForFeedback =>
      language == AppLanguage.korean ? '평가 받기' : 'Get Feedback';
  String get strengthsLabel =>
      language == AppLanguage.korean ? '잘한 점' : 'Strengths';
  String get improvementsLabel =>
      language == AppLanguage.korean ? '개선할 점' : 'To Improve';
  String get missingKeywordsLabel =>
      language == AppLanguage.korean ? '빠진 키워드' : 'Missing Keywords';
  String get coreKeywordsLabel =>
      language == AppLanguage.korean ? '핵심 키워드' : 'Core Keywords';
  String get showHintsLabel =>
      language == AppLanguage.korean ? '힌트 보기' : 'Show Hints';
  String get referenceAnswerLabel =>
      language == AppLanguage.korean ? '모범 답변' : 'Reference Answer';
  String get tryFollowUp =>
      language == AppLanguage.korean ? '꼬리질문 도전' : 'Try Follow-up';
  String get completeTraining =>
      language == AppLanguage.korean ? '완료' : 'Done';
  String get seeModelAnswer =>
      language == AppLanguage.korean ? '모범 답안 보기' : 'See Model Answer';
  String get myAnswerLabel =>
      language == AppLanguage.korean ? '내 답변' : 'My Answer';
  String get trainingComplete => language == AppLanguage.korean
      ? '훈련 완료!'
      : 'Training Complete!';

  // Records Tab / Dashboard
  String get recordsTitle =>
      language == AppLanguage.korean ? '훈련 기록' : 'Training Records';
  String get noRecordsYet => language == AppLanguage.korean
      ? '훈련 기록이 없습니다.'
      : 'No training records yet.';
  String get recordDetailTitle =>
      language == AppLanguage.korean ? '훈련 상세' : 'Training Detail';
  String get averageScoreLabel =>
      language == AppLanguage.korean ? '평균 점수' : 'Average Score';
  String get totalTrainingsLabel =>
      language == AppLanguage.korean ? '총 훈련 횟수' : 'Total Trainings';
  String get retryTraining => language == AppLanguage.korean
      ? '이 문제로 다시 훈련'
      : 'Retry with this question';
  String get questionNotFound =>
      language == AppLanguage.korean ? '질문을 찾을 수 없습니다.' : 'Question not found.';
  String get confirmTrainingTitle =>
      language == AppLanguage.korean ? '훈련을 시작할까요?' : 'Start training?';
  String get confirmTrainingMessage => language == AppLanguage.korean
      ? '에너지 1개가 소모됩니다. 시작하시겠습니까?'
      : 'This will cost 1 energy. Do you want to start?';
  String get notificationToggle =>
      language == AppLanguage.korean ? '훈련 리마인더' : 'Training Reminder';
}
