import 'package:flutter/material.dart';

enum AppLanguage {
  korean('🇰🇷 한국어', 'ko'),
  english('🇺🇸 English', 'en');

  final String label;
  final String code;
  const AppLanguage(this.label, this.code);
}

class LanguageController extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english; // Default to Global

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isKorean => _currentLanguage == AppLanguage.korean;

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == AppLanguage.korean
        ? AppLanguage.english
        : AppLanguage.korean;
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    if (_currentLanguage != lang) {
      _currentLanguage = lang;
      notifyListeners();
    }
  }
}

class AppStrings {
  final AppLanguage language;

  AppStrings(this.language);

  // Home Screen
  String get appTitle =>
      language == AppLanguage.korean ? 'CS 면접 코치' : 'CS Interview Coach';
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
  String get aiFeedback =>
      language == AppLanguage.korean ? 'AI 피드백' : 'AI Feedback';
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
  String get sessionNameLabel =>
      language == AppLanguage.korean ? '세션 이름' : 'Session Name';
  String get startAction => language == AppLanguage.korean ? '시작' : 'Start';
  String get lastStudied =>
      language == AppLanguage.korean ? '마지막 학습' : 'Last Studied';

  // Subject Screen
  String get noQuestions => language == AppLanguage.korean
      ? '등록된 질문이 없습니다.'
      : 'No questions available.';
  String get loadFail => language == AppLanguage.korean
      ? '질문을 불러오는데 실패했습니다:'
      : 'Failed to load questions:';

  // Login Screen
  String get loginTitle => 'CS Interview Coach';
  String get loginSubtitle => language == AppLanguage.korean
      ? 'AI 면접관과 함께하는 CS 인터뷰 준비'
      : 'Prepare for CS Interviews with AI Coach';
  String get signInGoogle =>
      language == AppLanguage.korean ? 'Google로 시작하기' : 'Sign in with Google';
  String get signingIn =>
      language == AppLanguage.korean ? '로그인 중...' : 'Signing in...';
  String get loginFooter => language == AppLanguage.korean
      ? '수천 명의 개발자와 함께 꿈의 직장을 준비하세요.'
      : 'Join thousands of developers preparing for their dream job.';

  // Common
  String get loading =>
      language == AppLanguage.korean ? '로딩중...' : 'Loading...';
  String get error => language == AppLanguage.korean ? '오류 발생' : 'Error';

  // Navigation
  String get navHome => language == AppLanguage.korean ? '홈' : 'Home';
  String get navMembership =>
      language == AppLanguage.korean ? '멤버십' : 'Membership';
  String get navProfile => language == AppLanguage.korean ? '프로필' : 'Profile';

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
}
