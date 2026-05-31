const pois = [
  {
    id: "poi-1",
    name: "라멘트리 성수",
    address: "서울 성동구 연무장길 12",
    category: "음식점",
    distance: "성수역에서 6분",
  },
  {
    id: "poi-2",
    name: "무브커피",
    address: "서울 성동구 아차산로 9길 18",
    category: "카페",
    distance: "성수역에서 4분",
  },
  {
    id: "poi-3",
    name: "다이닝팔레트",
    address: "서울 성동구 성수이로 77",
    category: "음식점",
    distance: "성수역에서 9분",
  },
  {
    id: "poi-4",
    name: "플라자홀",
    address: "서울 성동구 왕십리로 88",
    category: "공연/행사",
    distance: "성수역에서 12분",
  },
  {
    id: "poi-5",
    name: "브릿지카페",
    address: "서울 성동구 둘레길 25",
    category: "카페",
    distance: "성수역에서 8분",
  },
];

const state = {
  partyTitle: "성수 맛커 탐방 같이 갈 사람",
  selectedPoiId: null,
  selectedPlaceId: null,
  candidates: [],
  messages: [
    {
      type: "system",
      author: "요기",
      body: "파티방이 열렸어요. 지도에서 첫 후보 장소를 추가해보세요.",
    },
    {
      type: "text",
      author: "민지",
      body: "성수역 근처면 다들 오기 편할 것 같아요.",
    },
  ],
};

const elements = {
  partyTitleInput: document.querySelector("#partyTitleInput"),
  visibilityInput: document.querySelector("#visibilityInput"),
  createPartyButton: document.querySelector("#createPartyButton"),
  partyTitle: document.querySelector("#partyTitle"),
  candidateMetric: document.querySelector("#candidateMetric"),
  statusMetric: document.querySelector("#statusMetric"),
  candidateCount: document.querySelector("#candidateCount"),
  candidateList: document.querySelector("#candidateList"),
  chatList: document.querySelector("#chatList"),
  chatForm: document.querySelector("#chatForm"),
  chatInput: document.querySelector("#chatInput"),
  placeSheet: document.querySelector("#placeSheet"),
  selectedBanner: document.querySelector("#selectedBanner"),
  selectedPlaceName: document.querySelector("#selectedPlaceName"),
  selectedPlaceAddress: document.querySelector("#selectedPlaceAddress"),
  toast: document.querySelector("#toast"),
};

function getPoi(id) {
  return pois.find((poi) => poi.id === id);
}

function getCandidate(id) {
  return state.candidates.find((candidate) => candidate.poiId === id);
}

function showToast(message) {
  elements.toast.textContent = message;
  elements.toast.classList.remove("is-visible");
  requestAnimationFrame(() => elements.toast.classList.add("is-visible"));
}

function addMessage(message) {
  state.messages.push(message);
  renderChat();
}

function selectPoi(poiId) {
  state.selectedPoiId = poiId;
  document.querySelectorAll(".poi-pin").forEach((pin) => {
    pin.classList.toggle("is-active", pin.dataset.poiId === poiId);
  });
  renderPlaceSheet();
}

function addCandidate(poiId) {
  const poi = getPoi(poiId);
  if (!poi) return;

  const existing = getCandidate(poiId);
  if (existing) {
    showToast("이미 후보에 추가된 장소입니다.");
    renderPlaceSheet();
    return;
  }

  state.candidates.push({
    id: `candidate-${Date.now()}`,
    poiId,
    agrees: 1,
    disagrees: 0,
    myReaction: "agree",
    comments: [{ author: "나", body: "일단 후보로 올려볼게요." }],
    status: "candidate",
  });

  addMessage({
    type: "place",
    author: "나",
    body: `후보 장소로 추가: ${poi.name}`,
  });
  showToast("후보 장소가 추가되고 채팅에 공유됐습니다.");
  render();
}

function setReaction(poiId, reaction) {
  const candidate = getCandidate(poiId);
  if (!candidate) return;

  if (candidate.myReaction === "agree") candidate.agrees -= 1;
  if (candidate.myReaction === "disagree") candidate.disagrees -= 1;

  candidate.myReaction = candidate.myReaction === reaction ? null : reaction;

  if (candidate.myReaction === "agree") candidate.agrees += 1;
  if (candidate.myReaction === "disagree") candidate.disagrees += 1;

  render();
}

function addComment(poiId, input) {
  const candidate = getCandidate(poiId);
  const body = input.value.trim();
  if (!candidate || !body) return;

  candidate.comments.push({ author: "나", body });
  input.value = "";
  addMessage({
    type: "text",
    author: "나",
    body: `${getPoi(poiId).name}: ${body}`,
  });
  render();
}

function selectFinalPlace(poiId) {
  const candidate = getCandidate(poiId);
  const poi = getPoi(poiId);
  if (!candidate || !poi) return;

  state.selectedPlaceId = poiId;
  state.candidates.forEach((item) => {
    item.status = item.poiId === poiId ? "selected" : "candidate";
  });
  addMessage({
    type: "decision",
    author: "호스트",
    body: `최종 장소 확정: ${poi.name}`,
  });
  showToast("장소가 확정되었습니다.");
  render();
}

function renderPlaceSheet() {
  const poi = getPoi(state.selectedPoiId);
  if (!poi) {
    elements.placeSheet.innerHTML = `
      <p class="empty-title">지도에서 장소를 선택하세요</p>
      <p class="empty-copy">POI 핀을 누르면 장소 정보를 보고 파티 후보로 추가할 수 있습니다.</p>
    `;
    return;
  }

  const candidate = getCandidate(poi.id);
  elements.placeSheet.innerHTML = `
    <p class="eyebrow">${poi.category}</p>
    <p class="empty-title">${poi.name}</p>
    <p class="empty-copy">${poi.address}</p>
    <div class="place-meta">
      <span>${poi.distance}</span>
      <span>${candidate ? "후보 등록됨" : "지도 POI"}</span>
    </div>
    <div class="place-actions">
      <button type="button" data-add-candidate="${poi.id}">${candidate ? "후보 보기" : "후보 추가"}</button>
      <button class="secondary" type="button" data-open-chat>채팅 보기</button>
    </div>
  `;
}

function renderCandidateList() {
  elements.candidateMetric.textContent = String(state.candidates.length);
  elements.candidateCount.textContent = `${state.candidates.length}곳`;
  elements.statusMetric.textContent = state.selectedPlaceId ? "장소 확정" : "후보 수집";

  if (state.candidates.length === 0) {
    elements.candidateList.innerHTML = `<p class="empty-copy">아직 후보 장소가 없습니다.</p>`;
    return;
  }

  elements.candidateList.innerHTML = state.candidates
    .map((candidate) => {
      const poi = getPoi(candidate.poiId);
      const isSelected = candidate.status === "selected";
      const comments = candidate.comments
        .map((comment) => `<p><strong>${comment.author}</strong> ${comment.body}</p>`)
        .join("");

      return `
        <article class="candidate-card ${isSelected ? "is-selected" : ""}">
          <div class="candidate-top">
            <div>
              <strong>${poi.name}</strong>
              <span>${poi.address}</span>
            </div>
            <span class="badge">${isSelected ? "확정" : "후보"}</span>
          </div>
          <div class="vote-row">
            <button class="${candidate.myReaction === "agree" ? "is-active" : ""}" type="button" data-reaction="agree" data-poi-id="${poi.id}">찬성 ${candidate.agrees}</button>
            <button class="${candidate.myReaction === "disagree" ? "is-active" : ""}" type="button" data-reaction="disagree" data-poi-id="${poi.id}">반대 ${candidate.disagrees}</button>
          </div>
          <div class="comment-list">${comments}</div>
          <div class="comment-row">
            <input placeholder="한 줄 코멘트" aria-label="${poi.name} 코멘트" />
            <button type="button" data-comment="${poi.id}">등록</button>
          </div>
          <div class="candidate-actions">
            <button type="button" data-select-final="${poi.id}">호스트 확정</button>
            <button class="secondary" type="button" data-focus-poi="${poi.id}">지도 보기</button>
          </div>
        </article>
      `;
    })
    .join("");
}

function renderChat() {
  elements.chatList.innerHTML = state.messages
    .map(
      (message) => `
        <div class="chat-message ${message.type}">
          <strong>${message.author}</strong> ${message.body}
        </div>
      `,
    )
    .join("");
  elements.chatList.scrollTop = elements.chatList.scrollHeight;
}

function renderPins() {
  document.querySelectorAll(".poi-pin").forEach((pin) => {
    const candidate = getCandidate(pin.dataset.poiId);
    pin.classList.toggle("is-added", Boolean(candidate));
    pin.classList.toggle("is-selected", state.selectedPlaceId === pin.dataset.poiId);
  });
}

function renderSelectedBanner() {
  const poi = getPoi(state.selectedPlaceId);
  elements.selectedBanner.hidden = !poi;
  if (!poi) return;

  elements.selectedPlaceName.textContent = poi.name;
  elements.selectedPlaceAddress.textContent = poi.address;
}

function render() {
  elements.partyTitle.textContent = state.partyTitle;
  renderPins();
  renderPlaceSheet();
  renderCandidateList();
  renderChat();
  renderSelectedBanner();
}

function setPanel(panelName) {
  document.querySelectorAll("[data-panel]").forEach((button) => {
    button.classList.toggle("is-active", button.dataset.panel === panelName);
  });
  document.querySelectorAll("[data-panel-view]").forEach((panel) => {
    panel.classList.toggle("is-visible", panel.dataset.panelView === panelName);
  });
}

document.querySelectorAll(".poi-pin").forEach((pin) => {
  pin.addEventListener("click", () => selectPoi(pin.dataset.poiId));
});

document.querySelectorAll("[data-title]").forEach((button) => {
  button.addEventListener("click", () => {
    elements.partyTitleInput.value = button.dataset.title;
  });
});

document.querySelectorAll("[data-panel]").forEach((button) => {
  button.addEventListener("click", () => setPanel(button.dataset.panel));
});

elements.createPartyButton.addEventListener("click", () => {
  state.partyTitle = elements.partyTitleInput.value.trim() || "새 파티";
  state.candidates = [];
  state.selectedPoiId = null;
  state.selectedPlaceId = null;
  state.messages = [
    {
      type: "system",
      author: "요기",
      body: `${state.partyTitle} 파티방이 열렸어요.`,
    },
    {
      type: "system",
      author: "요기",
      body:
        elements.visibilityInput.value === "organization_only"
          ? "학교 이메일 인증을 완료한 멤버만 입장할 수 있어요."
          : "초대 링크를 가진 멤버가 입장할 수 있어요.",
    },
  ];
  document.querySelectorAll(".poi-pin").forEach((pin) => pin.classList.remove("is-active"));
  showToast("파티가 생성되었습니다. 첫 후보 장소를 추가해보세요.");
  render();
});

elements.placeSheet.addEventListener("click", (event) => {
  const addButton = event.target.closest("[data-add-candidate]");
  const chatButton = event.target.closest("[data-open-chat]");

  if (addButton) addCandidate(addButton.dataset.addCandidate);
  if (chatButton) setPanel("chat");
});

elements.candidateList.addEventListener("click", (event) => {
  const reactionButton = event.target.closest("[data-reaction]");
  const commentButton = event.target.closest("[data-comment]");
  const finalButton = event.target.closest("[data-select-final]");
  const focusButton = event.target.closest("[data-focus-poi]");

  if (reactionButton) {
    setReaction(reactionButton.dataset.poiId, reactionButton.dataset.reaction);
  }

  if (commentButton) {
    const input = commentButton.parentElement.querySelector("input");
    addComment(commentButton.dataset.comment, input);
  }

  if (finalButton) {
    selectFinalPlace(finalButton.dataset.selectFinal);
  }

  if (focusButton) {
    selectPoi(focusButton.dataset.focusPoi);
  }
});

elements.chatForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const body = elements.chatInput.value.trim();
  if (!body) return;

  elements.chatInput.value = "";
  addMessage({ type: "text", author: "나", body });
});

document.querySelector("#copyInviteButton").addEventListener("click", () => {
  showToast("초대 링크가 복사된 상태로 가정합니다.");
});

render();
