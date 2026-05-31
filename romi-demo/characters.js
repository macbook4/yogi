const characterMeta = {
  pinny: {
    name: "피니",
    line: "근처 모임을 콕 찍어줄게요.",
    empty: "아직 근처 모임이 없어요",
    success: "참여 요청을 보냈어요",
  },
  mori: {
    name: "모리",
    line: "혼자 고르기 어렵다면 같이 볼까요?",
    empty: "오늘은 조용하네요. 곧 새 모임을 찾아올게요",
    success: "좋아요, 모리도 같이 기대 중!",
  },
  forky: {
    name: "포키",
    line: "지금 입맛에 맞는 모임을 골라봤어요.",
    empty: "근처 맛집 모임을 더 뒤져볼게요",
    success: "맛있는 약속 하나 잡혔어요",
  },
  packo: {
    name: "패코",
    line: "가볍게 떠날 여행 모임을 챙겨왔어요.",
    empty: "아직 출발할 여행 모임이 없어요",
    success: "여행 준비 리스트에 넣어둘게요",
  },
  compa: {
    name: "콤파",
    line: "가까운 방향부터 차근차근 안내할게요.",
    empty: "위치를 조금 넓혀서 다시 찾아볼게요",
    success: "길을 잃지 않게 표시해뒀어요",
  },
  stampy: {
    name: "스탬피",
    line: "참여하고 기록으로 남기면 더 재밌어요.",
    empty: "첫 스탬프를 찍을 모임을 찾는 중",
    success: "참여 스탬프를 꾹 찍었어요",
  },
  bubble: {
    name: "버블",
    line: "같이 갈 사람들과 대화를 열어볼까요?",
    empty: "아직 말 걸 모임이 없어요",
    success: "초대 메시지를 띄워뒀어요",
  },
  spark: {
    name: "스파크",
    line: "지금 뜨는 모임을 빠르게 보여줄게요.",
    empty: "핫한 모임이 뜨면 바로 알려줄게요",
    success: "인기 모임에 빠르게 올라탔어요",
  },
};

const cards = document.querySelectorAll(".character-card");
let previewCharacter = document.querySelector(".preview-character");
const previewName = document.querySelector(".preview-name");
const previewLine = document.querySelector(".preview-line");
const emptyCopy = document.querySelector(".empty-copy");
const successCopy = document.querySelector(".success-copy");

function selectCharacter(id) {
  const meta = characterMeta[id];
  const selectedCard = document.querySelector(`[data-character="${id}"]`);
  if (!meta) return;

  cards.forEach((card) => {
    card.classList.toggle("is-selected", card.dataset.character === id);
  });

  const characterClone = selectedCard.querySelector(".char").cloneNode(true);
  characterClone.classList.add("preview-character");
  previewCharacter.replaceWith(characterClone);
  previewCharacter = characterClone;
  previewName.textContent = meta.name;
  previewLine.textContent = meta.line;
  emptyCopy.textContent = meta.empty;
  successCopy.textContent = meta.success;
}

cards.forEach((card) => {
  card.addEventListener("click", () => selectCharacter(card.dataset.character));
});

document.querySelectorAll(".filter-chip").forEach((chip) => {
  chip.addEventListener("click", () => {
    const filter = chip.dataset.filter;

    document.querySelectorAll(".filter-chip").forEach((item) => {
      item.classList.toggle("is-active", item === chip);
    });

    cards.forEach((card) => {
      card.classList.toggle("is-hidden", filter !== "all" && card.dataset.group !== filter);
    });

    const selectedCard = document.querySelector(".character-card.is-selected");
    if (selectedCard && selectedCard.classList.contains("is-hidden")) {
      const firstVisibleCard = document.querySelector(".character-card:not(.is-hidden)");
      if (firstVisibleCard) selectCharacter(firstVisibleCard.dataset.character);
    }
  });
});

selectCharacter("pinny");
