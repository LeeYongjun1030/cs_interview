# Project Plan: CS Interview Interactive Training Coach

## 1. 프로젝트 개요 및 목표
### 1.1. 정체성 (Identity Pivot)
- **비전:** "읽는 공부에서 말하는 훈련으로"
- **정의:** 대한민국 모든 개발자 지망생들이 지식을 내재화하고 면접 압박 속에서도 자신감 있게 답할 수 있도록 돕는 **독립적인 '인터랙티브 트레이닝 코치'**.
- **핵심 가치:** 
    - 능동적 인출(Recall) 기반 학습.
    - AI를 통한 실전형 발화(Speech) 연습.

### 1.2. 기대 효과
- **사용자:** 7개 핵심 CS 과목 마스터, 기술 면접 실전 감각 극대화.
- **비즈니스:** 강의 수강생 락인(Lock-in), Pro 플랜 구독을 통한 수익 창출, 에듀테크 브랜드 강화.

## 2. 기능 기획 (Feature Planning)
### 2.1. 핵심 서비스
| 기능명 | 상세 설명 | 제공 가치 |
| :--- | :--- | :--- |
| **인터랙티브 플래시카드** | 7개 과목(NW, OS, DS, Algo, DB, Java, Design Pattern) 질문-답변 카드 학습. | 능동적 암기 및 효율적 복습 |
| **AI 모의 면접관 (Pro)** | STT 음성 인식 + LLM 키워드 분석 및 맞춤형 꼬리 질문 제공. | 실전 감각 및 대응력 강화 |
| **학습 관리 대시보드** | 과목별 숙련도(Mastery) 및 학습 연속 일수(Streak) 시각화. | 객관적 지표 확인 및 동기 부여 |
| **오답/취약 노트** | '다시 보기' 체크된 질문들만 모아 집중 트레이닝. | 학습 누수 방지 |

### 2.2. 쿠폰 및 멤버십 (BM)
- **시크릿 쿠폰 시스템:** 기존 강의 구매자에게 Pro Plan 1개월 무료 이용권 제공.
- **Freemium 전략:**
    - **General:** 기초 챕터(Chapter 1) 및 제한적 AI 면접 (월 3회).
    - **Pro:** 전체 과목 무제한, 상세 피드백, 상세 통계, 광고 제거.

## 3. UI/UX 디자인 기획
- **컨셉:** '디지털 스터디룸 (Digital Study Room)'.
- **스타일:** 
    - **High-End Dark Mode:** 장시간 집중을 위한 저자극 다크 테마.
    - **Micro Interaction:** 3D 카드 Flip, 음성 파형(Waveform) 애니메이션.
- **브랜드 컬러:**
    - Primary: **#2979FF** (Electric Blue)
    - Success: **#00E676** (Success Green)
    - Warning: **#FF9100** (Review Orange)

## 4. 기술 스택 (Technical Stack)
- **Frontend:** Flutter (Web/Mobile-First)
- **Backend:** Firebase (Auth, Firestore, Hosting, Cloud Functions)
- **AI Engine:** OpenAI GPT API (Analysis), Google STT (Voice to Text)
- **Payment:** Stripe Checkout

## 5. 단계별 개발 로드맵 (Todo List)

### Phase 1: Infrastructure & MVP Setup
- [ ] **Infrastructure**
    - [ ] Flutter Web 초기화 (`--web-renderer html`)
    - [ ] Firebase Hosting & CI/CD (GitHub Actions) 연동
    - [ ] PWA 및 SEO 최적화 (Meta tags)
- [ ] **Core Logic**
    - [ ] Firebase Auth (Google Social Login)
    - [ ] Firestore 데이터 스키마 설계 (Subject, Card, UserData)
    - [ ] 시크릿 쿠폰 검증 시스템 (Cloud Functions)
- [ ] **UI/UX**
    - [ ] 고해상도 다크 모드 테마 구축
    - [ ] 7개 과목 기초 데이터 세팅 및 플래시카드 UI 구현

### Phase 2: Growth & AI Integration
- [ ] **AI 면접 기능**
    - [ ] Google STT 연동 (음성인식)
    - [ ] OpenAI GPT API 연동 (답변 분석 및 꼬리 질문 생성)
    - [ ] 음성 파형(Waveform) 애니메이션 UI
- [ ] **수익화**
    - [ ] Stripe 결제 연동 (Web Checkout)
    - [ ] 구독 상태에 따른 기능 제어 로직
- [ ] **데이터 시각화**
    - [ ] Mastery 대시보드 및 학습 통계 페이지

### Phase 3: Optimization & Social
- [ ] **학습 고도화**
    - [ ] 오답 노트 및 복습 알고리즘 적용
    - [ ] 랭킹 시스템 및 사용자 성취도 공유 기능
- [ ] **폴리싱**
    - [ ] 전체 성능 최적화 및 브라우저 호환성 테스트
    - [ ] QA 및 버그 수정
