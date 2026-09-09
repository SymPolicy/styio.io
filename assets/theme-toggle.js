(function () {
  'use strict';
  var root = document.documentElement;
  var toggle = document.getElementById('theme-toggle');
  var preference = window.matchMedia('(prefers-color-scheme: light)');
  function update() {
    document.querySelector('meta[name="theme-color"]').content = root.dataset.theme === 'cool' ? '#f3f4f8' : '#101116';
    if (toggle) toggle.setAttribute('aria-label', root.dataset.theme === 'cool' ? 'Switch to dark theme' : 'Switch to light theme');
    document.dispatchEvent(new Event('themechange'));
  }
  if (toggle) toggle.addEventListener('click', function () {
    root.dataset.theme = root.dataset.theme === 'cool' ? 'cool-dark' : 'cool';
    try { localStorage.setItem('styio-theme', root.dataset.theme); } catch (_) {}
    update();
  });
  preference.addEventListener('change', function (event) {
    var stored;
    try { stored = localStorage.getItem('styio-theme'); } catch (_) {}
    if (stored !== 'cool' && stored !== 'cool-dark') {
      root.dataset.theme = event.matches ? 'cool' : 'cool-dark';
      update();
    }
  });
  update();
}());
