(function () {
  'use strict';
  var theme;
  try { theme = localStorage.getItem('styio-theme'); } catch (_) {}
  if (theme !== 'cool' && theme !== 'cool-dark') {
    theme = window.matchMedia('(prefers-color-scheme: light)').matches ? 'cool' : 'cool-dark';
  }
  document.documentElement.dataset.theme = theme;
  document.querySelector('meta[name="theme-color"]').content = theme === 'cool' ? '#f3f4f8' : '#101116';
}());
