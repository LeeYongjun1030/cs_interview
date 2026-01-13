Flutter Web + Firebase AI 에이전틱 개발 워크플로우 (Web-Specific)

본 문서는 AI 에이전트가 Flutter Web 프로젝트를 개발, 관리 및 배포하기 위한 표준 지침서이다. 웹 플랫폼의 특수성(SEO, 반응형 UI, 웹 전용 결제 등)을 고려하여 작업을 진행한다.

0. [Phase 0] 기획 및 사양 정의 지침 (Standard Planning SOP)
* 새로운 프로젝트를 시작하거나 대규모 기능을 추가할 때, AI는 반드시 다음 5가지 요소를 포함하여 `plan.md`를 먼저 작성(또는 업데이트)해야 한다.
* 
* ### 1) 앱의 본질 정의 (Core Identity)
* - **목적(Purpose):** 이 앱이 해결하려는 궁극적인 문제는 무엇인가?
* - **타겟(Target):** 페르소나를 구체화하라. 누가, 언제, 어디서 이 앱을 쓰는가?
* - **비즈니스 모델(BM):** 수익화 구조(광고, 구독, 유료 결제) 또는 가치 창출 방식을 정의하라.
* 
* ### 2) 기능 명세 (Feature Specification)
* - **핵심 기능:** 목적 달성을 위해 반드시 필요한 3~5가지 기능.
* - **부가 기능:** 사용자 경험을 개선하는 확장 기능.
* 
* ### 3) 단계별 로드맵 (Roadmap)
* - **MVP (Minimum Viable Product):** 스토어 배포가 가능한 최소 기능 단위.
* - **Version 1.0 ~ 2.0:** 고도화 및 비즈니스 모델 적용 단계.
* 
* ### 4) Todo List 생성 원칙
* - 모든 Todo는 **'검증 가능(Testable)'**해야 한다. 
* - **종속성 순서:** 인프라(Firebase) -> 백엔드 로직 -> UI/UX -> QA -> 배포 순으로 배치한다.

1. 프로젝트의 본질 정의 (Mobile-First Web)
* 모바일 우선: 모든 UI는 웹 브라우저가 아닌 **스마트폰 세로 화면(360x800)**을 기준으로 설계함
* 웹앱의 역할: 앱 스토어 심사 없이도 사용자가 URL을 통해 즉시 앱을 경험하게 하거나, 개발 중 실시간으로 기능을 검증하는 용도로 활용함
* 결제 핵심: 모바일 웹 환경에서 가장 매끄럽게 작동하는 Stripe Web 결제를 도입함


2. 기술 스택 및 인프라 (Mobile Optimized)
* 프레임워크: Flutter Web (모바일 브라우저 최적화 모드)
* 렌더링 방식: --web-renderer html 방식을 사용하여 모바일 브라우저에서 초기 로딩 속도를 극대화함
* 배포처: Firebase Hosting (커스텀 도메인 연결을 통해 앱처럼 접근 가능하게 함)
* 인프라 제어: Firebase MCP를 활용해 보안 규칙 및 호스팅 설정을 자동화함


3. [Phase 1] 초기 웹 인프라 및 CI/CD 구축 (최우선 과제)
1. Git 초기화: 프로젝트 루트에서 Git 초기화 및 GitHub 레포지토리 연결.
2. Firebase Hosting 설정: firebase init hosting을 통해 프로젝트를 연결하고, 웹 전용 설정을 완료한다.
3. GitHub Actions 설정: .github/workflows/deploy-web.yml 작성.
    * main 브랜치 Push 시 flutter build web 실행.
    * Firebase Extended/action-hosting-deploy를 사용하여 실서버 자동 배포.
    * Pull Request 발생 시 Preview Channel에 자동 배포하여 미리보기 링크 생성.
4. Secrets 관리: Firebase Service Account Key를 GitHub Secrets에 등록하여 무중단 배포 환경 구축.


4. [Phase 2] 핵심 기능 구현 가이드라인
A. 인증 (Auth)
* Web 전용 Firebase Auth 구현 (Google Redirect/Popup 방식 설정).
* 웹 브라우저의 지속성(Persistence) 설정 (Local/Session).
B. 데이터베이스 (Firestore)
* NoSQL 구조 설계 및 웹 환경에서의 데이터 캐싱 전략 수립.
* firestore.rules 보안 규칙 작성 (웹은 소스 코드가 노출되므로 보안 규칙이 핵심).
C. 웹 최적화 (Web Performance)
* PWA(Progressive Web App) 설정: manifest.json 및 서비스 워커 설정을 통해 설치 가능한 웹 앱 구현.
* SEO: index.html 내 메타 태그 및 Open Graph 설정 자동화.


5. [Phase: 결제 및 수익화] 지침 (Web Monetization SOP)
웹 앱의 수익화를 위해 Stripe를 기본 결제 수단으로 사용한다.
1) 시스템 선택: Stripe Checkout
* Stripe Firebase Extension: 'Run Payments with Stripe' 익스텐션을 사용하여 서버리스 결제 시스템 구축.
* Stripe Customer Portal: 사용자가 직접 구독을 관리하고 취소할 수 있는 포털 연결.
2) 구현 체크리스트 (AI 필수 수행 작업)
* 익스텐션 설치: Firebase 콘솔에서 Stripe 익스텐션 활성화 및 API 키 설정.
* 결제 세션 생성: firestore의 checkout_sessions 컬렉션에 문서를 생성하여 Stripe 결제 페이지로 리다이렉트하는 로직 구현.
* 구독 상태 동기화: Webhook을 통해 customers/{uid}/subscriptions 정보를 실시간 동기화하여 프리미엄 기능 접근 제어.
* 성공/실패 페이지: 결제 완료(success_url) 및 취소(cancel_url) 시 돌아올 라우팅 처리.
3) 보안 및 검증
* 모든 결제 상태 확인은 클라이언트가 아닌 Firestore의 customers 컬렉션 보안 규칙을 통해 검증.


6. 에이전트 명령(Prompt) 템플릿
"web-workflow.md 파일을 읽고, [Phase 1]의 'Firebase Hosting 기반 CI/CD'를 구축해줘. 특히 GitHub Actions를 통해 main 브랜치 푸시 시 실서버로 자동 배포되고, PR 시 프리뷰 링크가 생성되는 환경을 만드는 것이 최우선이야."



7. AI 에이전트 작업 루프 (Web State Management)
(모바일 지침과 동일하되, 검증 단계에서 '크롬 브라우저 상의 렌더링 확인' 및 '반응형 레이아웃 체크'를 명시적으로 수행)

