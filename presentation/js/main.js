const $ = (s, r = document) => r.querySelector(s),
  $$ = (s, r = document) => [...r.querySelectorAll(s)];

$("#burger")?.addEventListener("click", (event) => {
  const open = $(".links").classList.toggle("open");
  event.currentTarget.setAttribute("aria-expanded", String(open));
});
$$(".links a").forEach((a) =>
  a.addEventListener("click", () => {
    $(".links").classList.remove("open");
    $("#burger")?.setAttribute("aria-expanded", "false");
  }),
);
$("#tocbtn")?.addEventListener("click", (event) => {
  const open = $(".side").classList.toggle("open");
  event.currentTarget.setAttribute("aria-expanded", String(open));
});
$$(".side a").forEach((a) => a.addEventListener("click", () => {
  $(".side").classList.remove("open");
  $("#tocbtn")?.setAttribute("aria-expanded", "false");
}));

$$("pre").forEach((p) => {
  const b = document.createElement("button");
  b.className = "cp";
  b.type = "button";
  b.innerHTML = 'Copier <svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="8" y="8" width="12" height="12" rx="2"/><path d="M16 8V5a1 1 0 0 0-1-1H5a1 1 0 0 0-1 1v10a1 1 0 0 0 1 1h3"/></svg>';
  b.onclick = async () => {
    try {
      await navigator.clipboard.writeText(p.querySelector("code").innerText.trim());
      b.innerHTML = 'Copié <svg class="icon copy-check" viewBox="0 0 24 24" aria-hidden="true"><path d="m5 12 4 4L19 6"/></svg>';
    } catch {
      b.textContent = "Copie indisponible";
    }
    setTimeout(() => { b.innerHTML = 'Copier <svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="8" y="8" width="12" height="12" rx="2"/><path d="M16 8V5a1 1 0 0 0-1-1H5a1 1 0 0 0-1 1v10a1 1 0 0 0 1 1h3"/></svg>'; }, 1500);
  };
  p.appendChild(b);
});

const secs = $$(".doc h2[id]");
if (secs.length && "IntersectionObserver" in window) {
  const io = new IntersectionObserver((es) => es.forEach((e) => {
    if (e.isIntersecting) $$(".side-link").forEach((a) => {
      const active = a.hash === "#" + e.target.id;
      a.classList.toggle("on", active);
      if (active) a.setAttribute("aria-current", "location");
      else a.removeAttribute("aria-current");
    });
  }), { rootMargin: "-30% 0px -65% 0px" });
  secs.forEach((s) => io.observe(s));
}

