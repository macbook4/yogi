const cards = document.querySelectorAll(".motion-card");
const filters = document.querySelectorAll(".filter-button");

const motionSpecs = {
  squish: {
    title: "M01 · Tap Squish",
    trigger: "tap down / tap up",
    duration: "120-180ms",
    easing: "cubic(0.2, 1.2, 0.28, 1)",
    flutter: "AnimatedScale + AnimatedContainer",
    note: "가장 많이 쓰는 기본 촉감입니다. 모든 버튼에 과한 bounce를 주지 말고 CTA와 선택 칩 위주로 제한합니다.",
  },
  pin: {
    title: "M02 · Pin Bounce",
    trigger: "new marker / filter result / recommendation focus",
    duration: "520-680ms",
    easing: "cubic(0.2, 1.45, 0.28, 1)",
    flutter: "AnimationController + Transform.translate + Transform.scale",
    note: "위치 기반 정체성을 가장 잘 보여줍니다. 지도 전체가 흔들리지 않게 핀 단위로만 적용합니다.",
  },
  pop: {
    title: "M03 · Success Pop",
    trigger: "join complete / save complete / invite sent",
    duration: "700-900ms",
    easing: "cubic(0.2, 1.25, 0.28, 1)",
    flutter: "ScaleTransition + FadeTransition + OverlayEntry",
    note: "완료감이 필요한 순간에만 씁니다. confetti는 중요한 성공 액션으로 제한하는 게 좋습니다.",
  },
  card: {
    title: "M04 · Card Rise",
    trigger: "list mount / refresh / recommendation changed",
    duration: "360-480ms",
    easing: "cubic(0.2, 1.0, 0.28, 1)",
    flutter: "SlideTransition + FadeTransition, staggered by 80-120ms",
    note: "구조 전환용 모션입니다. 귀여움보다 안정감이 우선이라 bounce를 작게 둡니다.",
  },
  wiggle: {
    title: "M05 · Buddy Wiggle",
    trigger: "empty state / onboarding / mascot speech",
    duration: "1.2-1.6s loop",
    easing: "easeInOut",
    flutter: "RotationTransition + SlideTransition",
    note: "브랜드성은 강하지만 반복되면 피로합니다. 한 화면에 캐릭터 루프는 하나만 둡니다.",
  },
  pulse: {
    title: "M06 · Local Pulse",
    trigger: "location scanning / nearby refresh",
    duration: "1.6-2.0s loop",
    easing: "easeOut",
    flutter: "ScaleTransition + FadeTransition",
    note: "지도 탐색의 살아있는 느낌을 줍니다. 텍스트나 카드에는 적용하지 않습니다.",
  },
  sheet: {
    title: "M07 · Sheet Snap",
    trigger: "bottom sheet open / map-to-list transition",
    duration: "320-420ms",
    easing: "cubic(0.2, 1.08, 0.28, 1)",
    flutter: "DraggableScrollableSheet + custom snap curve",
    note: "요기 홈의 핵심 전환입니다. 통통함보다 손에 붙는 위치감이 더 중요합니다.",
  },
  magnet: {
    title: "M08 · Chip Magnet",
    trigger: "category selected / segmented control changed",
    duration: "220-300ms",
    easing: "cubic(0.2, 1.25, 0.28, 1)",
    flutter: "AnimatedAlign + AnimatedContainer",
    note: "Gen Z스러운 촉감이 강합니다. 필터가 자주 바뀌는 화면에서 앱의 성격을 만듭니다.",
  },
  route: {
    title: "M09 · Route Draw",
    trigger: "route reveal / travel course / detail map",
    duration: "800-1000ms",
    easing: "easeOutCubic",
    flutter: "CustomPainter + PathMetric animation",
    note: "여행 카테고리와 잘 맞습니다. 홈 기본 모션보다는 상세/코스 화면용으로 보는 게 맞습니다.",
  },
  avatar: {
    title: "M10 · Join Stack",
    trigger: "participant joined / social proof changed",
    duration: "460-620ms",
    easing: "cubic(0.2, 1.25, 0.28, 1)",
    flutter: "AnimatedPositioned + ScaleTransition",
    note: "모임이 살아있다는 느낌을 줍니다. 실시간성이 없는 화면에서는 과하게 쓰지 않습니다.",
  },
  loading: {
    title: "M11 · Bubble Loader",
    trigger: "short loading / nearby search pending",
    duration: "1.0-1.3s loop",
    easing: "easeInOut",
    flutter: "staggered ScaleTransition + SlideTransition",
    note: "짧은 로딩에 적합합니다. 2초 이상 걸리는 작업은 skeleton이나 진행 상태 문구가 필요합니다.",
  },
  empty: {
    title: "M12 · Empty Nudge",
    trigger: "empty result / no nearby meetings",
    duration: "600-760ms once",
    easing: "easeInOut",
    flutter: "RotationTransition + Transform.translate",
    note: "실패처럼 보이지 않게 부드럽게 안내합니다. 반복 재생하지 않는 것이 핵심입니다.",
  },
};

function replay(card) {
  card.classList.remove("is-playing");
  void card.offsetWidth;
  card.classList.add("is-playing");
}

function selectCard(card) {
  cards.forEach((item) => item.classList.toggle("is-selected", item === card));
  replay(card);

  const spec = motionSpecs[card.dataset.motion];
  if (!spec) return;

  document.querySelector("#spec-title").textContent = spec.title;
  document.querySelector("#spec-trigger").textContent = spec.trigger;
  document.querySelector("#spec-duration").textContent = spec.duration;
  document.querySelector("#spec-easing").textContent = spec.easing;
  document.querySelector("#spec-flutter").textContent = spec.flutter;
  document.querySelector("#spec-note").textContent = spec.note;
}

function applyFilter(filter) {
  filters.forEach((button) => {
    button.classList.toggle("is-active", button.dataset.filter === filter);
  });

  cards.forEach((card) => {
    const categories = card.dataset.category.split(" ");
    const shouldShow = filter === "all" || categories.includes(filter);
    card.classList.toggle("is-hidden", !shouldShow);
  });

  const firstVisible = [...cards].find((card) => !card.classList.contains("is-hidden"));
  if (firstVisible) selectCard(firstVisible);
}

cards.forEach((card) => {
  card.addEventListener("click", () => selectCard(card));
});

filters.forEach((button) => {
  button.addEventListener("click", () => applyFilter(button.dataset.filter));
});

cards.forEach((card, index) => {
  window.setTimeout(() => replay(card), index * 160);
});
