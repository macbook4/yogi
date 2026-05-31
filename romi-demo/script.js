document.querySelectorAll(".phone").forEach((phone) => {
  const chips = phone.querySelectorAll(".chip");
  const cards = phone.querySelectorAll(".meeting-card");
  const pins = phone.querySelectorAll(".pin");
  const toast = phone.querySelector(".toast");
  const count = phone.querySelector(".count");

  function setFilter(filter) {
    let visibleCount = 0;

    chips.forEach((chip) => {
      chip.classList.toggle("is-active", chip.dataset.filter === filter);
    });

    cards.forEach((card) => {
      const shouldShow = filter === "all" || card.dataset.kind === filter;
      card.classList.toggle("is-hidden", !shouldShow);
      if (shouldShow) visibleCount += 1;
    });

    if (count) count.textContent = `${visibleCount}개`;

    pins.forEach((pin) => {
      const shouldShow = filter === "all" || pin.dataset.kind === filter;
      pin.style.opacity = shouldShow ? "1" : "0.22";
      pin.style.scale = shouldShow ? "1" : "0.9";
    });
  }

  chips.forEach((chip) => {
    chip.addEventListener("click", () => setFilter(chip.dataset.filter));
  });

  phone.querySelectorAll(".join-button").forEach((button) => {
    button.addEventListener("click", () => {
      button.classList.add("is-done");
      button.textContent = button.textContent === "찜" ? "찜완료" : "완료";
      if (!toast) return;
      toast.classList.remove("is-visible");
      requestAnimationFrame(() => toast.classList.add("is-visible"));
    });
  });
});
