// ===================== Konstanta penyimpanan =====================
const LS_USERS = "sinemasaku_users";
const LS_SESSION = "sinemasaku_session";
const LS_VIDEOS = "sinemasaku_videos";
const LS_COMMENTS = "sinemasaku_comments";
const LS_THEME = "sinemasaku_theme";

const AVATARS = ["🙂","🎬","🍿","🌙","🦊","🐧","👾","🎧","🌵","🔥"];

// ===================== Util penyimpanan =====================
function getUsers() { return JSON.parse(localStorage.getItem(LS_USERS) || "[]"); }
function saveUsers(u) { localStorage.setItem(LS_USERS, JSON.stringify(u)); }
function getVideos() { return JSON.parse(localStorage.getItem(LS_VIDEOS) || "[]"); }
function saveVideos(v) { localStorage.setItem(LS_VIDEOS, JSON.stringify(v)); }
function getComments() { return JSON.parse(localStorage.getItem(LS_COMMENTS) || "{}"); }
function saveComments(c) { localStorage.setItem(LS_COMMENTS, JSON.stringify(c)); }
function getSession() { return localStorage.getItem(LS_SESSION); }
function setSession(u) { localStorage.setItem(LS_SESSION, u); }
function clearSession() { localStorage.removeItem(LS_SESSION); }
function currentUser() {
  const username = getSession();
  if (!username) return null;
  return getUsers().find(u => u.username === username) || null;
}
function saveCurrentUser(updated) {
  const users = getUsers().map(u => u.username === updated.username ? updated : u);
  saveUsers(users);
}

// ===================== Seed akun dev =====================
function seedDevAccount() {
  const users = getUsers();
  if (!users.find(u => u.username === "dev")) {
    users.push(makeUser("dev", "dev123", "dev", "🎬", "warna favorit?", "oranye"));
    saveUsers(users);
  }
}
function makeUser(username, password, role, avatar, secQ, secA) {
  return {
    username, password, role, avatar,
    securityQuestion: secQ, securityAnswer: secA,
    watchHistory: {}, watchlist: [], favorites: [], ratings: {}
  };
}

// ===================== Toast =====================
function toast(msg) {
  const container = document.getElementById("toast-container");
  const el = document.createElement("div");
  el.className = "toast";
  el.textContent = msg;
  container.appendChild(el);
  setTimeout(() => el.remove(), 2600);
}

// ===================== Tema terang/gelap =====================
function applyTheme() {
  const theme = localStorage.getItem(LS_THEME) || "dark";
  document.documentElement.setAttribute("data-theme", theme);
}
function toggleTheme() {
  const current = localStorage.getItem(LS_THEME) || "dark";
  localStorage.setItem(LS_THEME, current === "dark" ? "light" : "dark");
  applyTheme();
}

// ===================== Validasi & embed tautan video =====================
function parseVideoUrl(url) {
  try {
    const u = new URL(url);
    const host = u.hostname.replace("www.", "");
    if (host === "youtube.com" || host === "m.youtube.com") {
      const id = u.searchParams.get("v");
      if (id) return { type: "youtube", id };
    }
    if (host === "youtu.be") {
      const id = u.pathname.slice(1);
      if (id) return { type: "youtube", id };
    }
    if (host === "vimeo.com") {
      const id = u.pathname.split("/").filter(Boolean)[0];
      if (id && /^\d+$/.test(id)) return { type: "vimeo", id };
    }
    if (/\.(mp4|webm|ogg|mov)$/i.test(u.pathname)) {
      return { type: "file", url };
    }
    return { type: "unknown", url };
  } catch (e) {
    return null;
  }
}
function buildEmbed(url, startSeconds) {
  const parsed = parseVideoUrl(url);
  if (!parsed) return `<p style="color:#9A9DB8;padding:16px;">Tautan video tidak valid.</p>`;
  const t = startSeconds ? Math.floor(startSeconds) : 0;
  if (parsed.type === "youtube") {
    return `<iframe src="https://www.youtube.com/embed/${parsed.id}${t ? "?start=" + t : ""}" allowfullscreen allow="autoplay; encrypted-media"></iframe>`;
  }
  if (parsed.type === "vimeo") {
    return `<iframe src="https://player.vimeo.com/video/${parsed.id}${t ? "#t=" + t + "s" : ""}" allowfullscreen allow="autoplay; fullscreen"></iframe>`;
  }
  if (parsed.type === "file") {
    return `<video controls id="active-video-el" src="${url}"></video>`;
  }
  return `<p style="color:#9A9DB8;padding:16px;">Tautan tidak dikenali sebagai YouTube, Vimeo, atau file video langsung.</p>`;
}
function isLinkValid(url) {
  const parsed = parseVideoUrl(url);
  return parsed && parsed.type !== "unknown";
}

// ===================== Elemen DOM =====================
const authScreen = document.getElementById("auth-screen");
const appEl = document.getElementById("app");
const loginForm = document.getElementById("login-form");
const registerForm = document.getElementById("register-form");
const forgotForm = document.getElementById("forgot-form");
const authTabs = document.querySelectorAll(".auth-tab");
const loginError = document.getElementById("login-error");
const registerError = document.getElementById("register-error");
const forgotError = document.getElementById("forgot-error");
const devPanelBtn = document.getElementById("dev-panel-btn");
const logoutBtn = document.getElementById("logout-btn");
const videoGrid = document.getElementById("video-grid");
const emptyState = document.getElementById("empty-state");
const searchInput = document.getElementById("search-input");
const categoryFilter = document.getElementById("category-filter");
const sortSelect = document.getElementById("sort-select");
const tagFiltersEl = document.getElementById("tag-filters");
const accountAvatar = document.getElementById("account-avatar");

let activeTagFilter = null;

// ===================== Avatar picker (dipakai 2 tempat) =====================
function renderAvatarPicker(container, selected, onPick) {
  container.innerHTML = "";
  AVATARS.forEach(a => {
    const btn = document.createElement("div");
    btn.className = "avatar-option" + (a === selected ? " selected" : "");
    btn.textContent = a;
    btn.addEventListener("click", () => {
      container.querySelectorAll(".avatar-option").forEach(el => el.classList.remove("selected"));
      btn.classList.add("selected");
      onPick(a);
    });
    container.appendChild(btn);
  });
}
let registerAvatar = AVATARS[0];
renderAvatarPicker(document.getElementById("avatar-picker"), registerAvatar, a => registerAvatar = a);

// ===================== Tab auth =====================
authTabs.forEach(tab => {
  tab.addEventListener("click", () => {
    authTabs.forEach(t => t.classList.remove("active"));
    tab.classList.add("active");
    const target = tab.dataset.tab;
    loginForm.classList.toggle("hidden", target !== "login");
    registerForm.classList.toggle("hidden", target !== "register");
    forgotForm.classList.toggle("hidden", target !== "forgot");
  });
});

// ===================== Login =====================
loginForm.addEventListener("submit", e => {
  e.preventDefault();
  const username = document.getElementById("login-username").value.trim();
  const password = document.getElementById("login-password").value;
  const user = getUsers().find(u => u.username === username && u.password === password);
  if (!user) { loginError.textContent = "Username atau kata sandi salah."; return; }
  loginError.textContent = "";
  setSession(username);
  enterApp();
});

// ===================== Daftar =====================
registerForm.addEventListener("submit", e => {
  e.preventDefault();
  const username = document.getElementById("register-username").value.trim();
  const password = document.getElementById("register-password").value;
  const secQ = document.getElementById("register-secq").value.trim();
  const secA = document.getElementById("register-seca").value.trim();
  const users = getUsers();
  if (!username || !password || !secQ || !secA) return;
  if (users.find(u => u.username === username)) { registerError.textContent = "Username sudah dipakai."; return; }
  users.push(makeUser(username, password, "user", registerAvatar, secQ, secA));
  saveUsers(users);
  registerError.textContent = "";
  setSession(username);
  enterApp();
});

// ===================== Lupa sandi =====================
let forgotUserRef = null;
document.getElementById("forgot-load-q").addEventListener("click", () => {
  const username = document.getElementById("forgot-username").value.trim();
  const user = getUsers().find(u => u.username === username);
  const qEl = document.getElementById("forgot-question");
  const answerWrap = document.getElementById("forgot-answer-wrap");
  const newpassWrap = document.getElementById("forgot-newpass-wrap");
  const submitBtn = document.getElementById("forgot-submit");
  if (!user) {
    qEl.textContent = "Akun tidak ditemukan.";
    answerWrap.classList.add("hidden"); newpassWrap.classList.add("hidden"); submitBtn.classList.add("hidden");
    return;
  }
  forgotUserRef = user;
  qEl.textContent = user.securityQuestion;
  answerWrap.classList.remove("hidden");
  newpassWrap.classList.remove("hidden");
  submitBtn.classList.remove("hidden");
});
forgotForm.addEventListener("submit", e => {
  e.preventDefault();
  if (!forgotUserRef) return;
  const answer = document.getElementById("forgot-answer").value.trim().toLowerCase();
  const newPass = document.getElementById("forgot-newpass").value;
  if (answer !== forgotUserRef.securityAnswer.toLowerCase()) {
    forgotError.textContent = "Jawaban keamanan salah.";
    return;
  }
  if (!newPass) return;
  const users = getUsers().map(u => u.username === forgotUserRef.username ? { ...u, password: newPass } : u);
  saveUsers(users);
  forgotError.textContent = "";
  toast("Sandi berhasil diganti, silakan masuk.");
  forgotForm.reset();
  document.querySelector('.auth-tab[data-tab="login"]').click();
});

// ===================== Keluar =====================
logoutBtn.addEventListener("click", () => {
  clearSession();
  appEl.classList.add("hidden");
  authScreen.classList.remove("hidden");
  loginForm.reset(); registerForm.reset();
});

// ===================== Masuk ke aplikasi =====================
function enterApp() {
  const user = currentUser();
  authScreen.classList.add("hidden");
  appEl.classList.remove("hidden");
  accountAvatar.textContent = user.avatar || "🙂";
  devPanelBtn.classList.toggle("hidden", !(user.role === "dev" || user.role === "editor"));
  populateCategoryFilter();
  renderTagFilters();
  renderVideos();
}

// ===================== Kategori & tag =====================
function populateCategoryFilter() {
  const cats = [...new Set(getVideos().map(v => v.category).filter(Boolean))];
  categoryFilter.innerHTML = '<option value="">Semua kategori</option>' +
    cats.map(c => `<option value="${escapeHtml(c)}">${escapeHtml(c)}</option>`).join("");
}
function renderTagFilters() {
  const tags = [...new Set(getVideos().flatMap(v => v.tags || []))];
  tagFiltersEl.innerHTML = "";
  tags.forEach(tag => {
    const chip = document.createElement("div");
    chip.className = "tag-chip" + (activeTagFilter === tag ? " active" : "");
    chip.textContent = tag;
    chip.addEventListener("click", () => {
      activeTagFilter = activeTagFilter === tag ? null : tag;
      renderTagFilters();
      renderVideos();
    });
    tagFiltersEl.appendChild(chip);
  });
}
categoryFilter.addEventListener("change", renderVideos);
sortSelect.addEventListener("change", renderVideos);
searchInput.addEventListener("input", renderVideos);

// ===================== Render katalog video =====================
function avgRating(video) {
  const users = getUsers();
  const scores = users.map(u => u.ratings && u.ratings[video.id]).filter(Boolean);
  if (!scores.length) return 0;
  return scores.reduce((a, b) => a + b, 0) / scores.length;
}
function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str || "";
  return div.innerHTML;
}
function isNewVideo(v) {
  return Date.now() - v.addedAt < 7 * 24 * 60 * 60 * 1000;
}

function renderVideos() {
  const query = searchInput.value.trim().toLowerCase();
  const category = categoryFilter.value;
  const sort = sortSelect.value;
  let videos = getVideos().filter(v => {
    const matchQuery = v.title.toLowerCase().includes(query);
    const matchCat = !category || v.category === category;
    const matchTag = !activeTagFilter || (v.tags || []).includes(activeTagFilter);
    return matchQuery && matchCat && matchTag;
  });

  if (sort === "az") videos.sort((a, b) => a.title.localeCompare(b.title));
  else if (sort === "popular") videos.sort((a, b) => (b.views || 0) - (a.views || 0));
  else if (sort === "rating") videos.sort((a, b) => avgRating(b) - avgRating(a));
  else videos.sort((a, b) => b.addedAt - a.addedAt);

  videoGrid.innerHTML = "";
  emptyState.classList.toggle("hidden", getVideos().length > 0);

  videos.forEach(v => videoGrid.appendChild(renderVideoCard(v)));
}

function renderVideoCard(v, compact) {
  const card = document.createElement("div");
  card.className = compact ? "video-card similar-card" : "video-card";
  const rating = avgRating(v);
  const badge = v.featured ? '<span class="video-card-badge badge-featured">Pilihan Dev</span>'
    : isNewVideo(v) ? '<span class="video-card-badge">Baru</span>' : "";
  const thumbStyle = v.thumbnail ? `style="background-image:url('${v.thumbnail.replace(/'/g, "%27")}')"` : "";
  card.innerHTML = `
    <div class="video-card-thumb" ${thumbStyle}>
      ${v.thumbnail ? "" : "▶"}
      ${badge}
      ${v.duration ? `<span class="video-card-duration">${escapeHtml(v.duration)}</span>` : ""}
    </div>
    <div class="video-card-body">
      <h3 class="video-card-title">${escapeHtml(v.title)}${v.episode ? " · " + escapeHtml(v.episode) : ""}</h3>
      ${compact ? "" : `<p class="video-card-desc">${escapeHtml(v.description || "")}</p>
      <div class="video-card-meta">
        ${v.category ? `<span>${escapeHtml(v.category)}</span>` : ""}
        ${rating ? `<span class="video-card-rating">★ ${rating.toFixed(1)}</span>` : ""}
        <span>${v.views || 0}x ditonton</span>
      </div>`}
    </div>
  `;
  card.addEventListener("click", () => openPlayer(v));
  return card;
}

// ===================== Modal pemutar =====================
const playerModal = document.getElementById("player-modal");
const playerEmbed = document.getElementById("player-embed");
const playerTitle = document.getElementById("player-title");
const playerMeta = document.getElementById("player-meta");
const playerDesc = document.getElementById("player-desc");
const playerFavorite = document.getElementById("player-favorite");
const playerWatchlist = document.getElementById("player-watchlist");
const playerRating = document.getElementById("player-rating");
const playerAltlinks = document.getElementById("player-altlinks");
const playerTrailerBtn = document.getElementById("player-trailer");
let currentVideoRef = null;
let positionSaveInterval = null;

function openPlayer(video) {
  currentVideoRef = video;
  const user = currentUser();

  // hitung views
  const videos = getVideos().map(v => v.id === video.id ? { ...v, views: (v.views || 0) + 1 } : v);
  saveVideos(videos);
  video = videos.find(v => v.id === video.id);
  currentVideoRef = video;

  const resume = user.watchHistory && user.watchHistory[video.id];
  playerEmbed.innerHTML = buildEmbed(video.url, resume ? resume.position : 0);
  playerTitle.textContent = video.title + (video.episode ? " · " + video.episode : "");
  playerMeta.textContent = [video.category, video.duration, (video.views || 0) + "x ditonton"].filter(Boolean).join(" · ");
  playerDesc.textContent = video.description || "";

  // resume tracking khusus file video langsung
  clearInterval(positionSaveInterval);
  const videoEl = document.getElementById("active-video-el");
  if (videoEl) {
    if (resume) videoEl.currentTime = resume.position;
    positionSaveInterval = setInterval(() => {
      const u = currentUser();
      u.watchHistory[video.id] = { position: videoEl.currentTime, lastWatched: Date.now() };
      saveCurrentUser(u);
    }, 4000);
  } else {
    const u = currentUser();
    u.watchHistory[video.id] = { position: 0, lastWatched: Date.now() };
    saveCurrentUser(u);
  }

  // favorit & watchlist toggle state
  updateToolbarState();

  // rating
  renderRatingStars(video);

  // trailer
  playerTrailerBtn.classList.toggle("hidden", !video.trailerUrl);

  // alt links
  if (video.altLinks && video.altLinks.length) {
    playerAltlinks.classList.remove("hidden");
    playerAltlinks.innerHTML = `<option value="${video.url}">Sumber utama</option>` +
      video.altLinks.map(l => `<option value="${l.url}">${escapeHtml(l.label)}</option>`).join("");
  } else {
    playerAltlinks.classList.add("hidden");
  }

  renderComments(video.id);
  renderSimilar(video);

  playerModal.classList.remove("hidden");
  renderVideos();
}
playerAltlinks.addEventListener("change", () => {
  playerEmbed.innerHTML = buildEmbed(playerAltlinks.value);
});
playerTrailerBtn.addEventListener("click", () => {
  document.getElementById("trailer-embed").innerHTML = buildEmbed(currentVideoRef.trailerUrl);
  document.getElementById("trailer-modal").classList.remove("hidden");
});

function updateToolbarState() {
  const user = currentUser();
  const isFav = user.favorites.includes(currentVideoRef.id);
  const isWatchlist = user.watchlist.includes(currentVideoRef.id);
  playerFavorite.textContent = isFav ? "♥" : "♡";
  playerFavorite.classList.toggle("active", isFav);
  playerWatchlist.textContent = isWatchlist ? "✔ Nanti" : "➕ Nanti";
  playerWatchlist.classList.toggle("active", isWatchlist);
}
playerFavorite.addEventListener("click", () => {
  const user = currentUser();
  const idx = user.favorites.indexOf(currentVideoRef.id);
  if (idx === -1) { user.favorites.push(currentVideoRef.id); toast("Ditambahkan ke favorit."); }
  else { user.favorites.splice(idx, 1); toast("Dihapus dari favorit."); }
  saveCurrentUser(user);
  updateToolbarState();
});
playerWatchlist.addEventListener("click", () => {
  const user = currentUser();
  const idx = user.watchlist.indexOf(currentVideoRef.id);
  if (idx === -1) { user.watchlist.push(currentVideoRef.id); toast("Ditambahkan ke tonton nanti."); }
  else { user.watchlist.splice(idx, 1); toast("Dihapus dari tonton nanti."); }
  saveCurrentUser(user);
  updateToolbarState();
});

function renderRatingStars(video) {
  const user = currentUser();
  const myRating = user.ratings[video.id] || 0;
  playerRating.innerHTML = "";
  for (let i = 1; i <= 5; i++) {
    const star = document.createElement("span");
    star.className = "star" + (i <= myRating ? " filled" : "");
    star.textContent = "★";
    star.addEventListener("click", () => {
      const u = currentUser();
      u.ratings[video.id] = i;
      saveCurrentUser(u);
      renderRatingStars(video);
      renderVideos();
    });
    playerRating.appendChild(star);
  }
}

function renderSimilar(video) {
  const wrap = document.getElementById("similar-videos");
  const others = getVideos().filter(v => v.id !== video.id && (
    (v.category && v.category === video.category) ||
    (v.tags || []).some(t => (video.tags || []).includes(t))
  )).slice(0, 4);
  if (!others.length) { wrap.innerHTML = ""; return; }
  wrap.innerHTML = `<h3 class="dev-subtitle">Video serupa</h3><div class="similar-grid"></div>`;
  const grid = wrap.querySelector(".similar-grid");
  others.forEach(v => grid.appendChild(renderVideoCard(v, true)));
}

function closePlayer() {
  clearInterval(positionSaveInterval);
  playerModal.classList.add("hidden");
  playerEmbed.innerHTML = "";
}

// ===================== Komentar =====================
const commentForm = document.getElementById("comment-form");
const commentList = document.getElementById("comment-list");
commentForm.addEventListener("submit", e => {
  e.preventDefault();
  const input = document.getElementById("comment-input");
  const text = input.value.trim();
  if (!text || !currentVideoRef) return;
  const comments = getComments();
  const list = comments[currentVideoRef.id] || [];
  list.push({ username: currentUser().username, text, at: Date.now() })
