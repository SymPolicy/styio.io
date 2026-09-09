(function () {
  'use strict';
  var reduced = window.matchMedia('(prefers-reduced-motion: reduce)');
  var tabs = Array.from(document.querySelectorAll('[role="tab"]'));
  function activate(tab) {
    tabs.forEach(function (item) {
      var selected = item === tab;
      item.setAttribute('aria-selected', String(selected));
      item.tabIndex = selected ? 0 : -1;
      document.getElementById(item.getAttribute('aria-controls')).hidden = !selected;
    });
    var panel = document.getElementById(tab.getAttribute('aria-controls'));
    if (!reduced.matches && !document.documentElement.classList.contains('motion-paused')) {
      panel.animate([{ opacity: .35, transform: 'translateY(10px)' }, { opacity: 1, transform: 'translateY(0)' }], { duration: 450, easing: 'cubic-bezier(.16, 1, .3, 1)' });
    }
  }
  tabs.forEach(function (tab, index) {
    tab.addEventListener('click', function () { activate(tab); });
    tab.addEventListener('keydown', function (event) {
      var next;
      if (event.key === 'ArrowDown' || event.key === 'ArrowRight') next = (index + 1) % tabs.length;
      if (event.key === 'ArrowUp' || event.key === 'ArrowLeft') next = (index + tabs.length - 1) % tabs.length;
      if (event.key === 'Home') next = 0;
      if (event.key === 'End') next = tabs.length - 1;
      if (next !== undefined) { event.preventDefault(); activate(tabs[next]); tabs[next].focus(); }
    });
  });

  // Enhance visible headings when they enter; never hide content waiting for JS.
  var reveals = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
      if (!entry.isIntersecting) return;
      reveals.unobserve(entry.target);
      if (!reduced.matches && !document.documentElement.classList.contains('motion-paused')) {
        entry.target.animate([{ clipPath: 'inset(0 0 90% 0)', transform: 'translateY(15px)' }, { clipPath: 'inset(0)', transform: 'translateY(0)' }], { duration: 850, easing: 'cubic-bezier(.16, 1, .3, 1)' });
      }
    });
  }, { threshold: .25 });
  document.querySelectorAll('[data-reveal]').forEach(function (node) { reveals.observe(node); });

  // Animate only while the statement is in view; native scroll remains untouched.
  var statement = document.querySelector('.manifesto');
  if (statement) {
    var visible = false;
    var pending = 0;
    var lines = statement.querySelectorAll('.manifesto-line');
    function renderStatement() {
      pending = 0;
      if (!visible || reduced.matches || document.documentElement.classList.contains('motion-paused')) return;
      var position = (statement.getBoundingClientRect().top - innerHeight / 2) / innerHeight;
      lines[0].style.transform = 'translateX(' + (position * -35) + 'px)';
      lines[1].style.transform = 'translateX(' + (position * 35) + 'px)';
    }
    new IntersectionObserver(function (entries) { visible = entries[0].isIntersecting; if (visible) renderStatement(); }).observe(statement);
    window.addEventListener('scroll', function () { if (visible && !pending) pending = requestAnimationFrame(renderStatement); }, { passive: true });
    reduced.addEventListener('change', function () { lines.forEach(function (line) { line.style.transform = ''; }); });
  }
  var path = location.pathname.replace(/index\.html$/, '');
  document.querySelectorAll('.nav a, .side-nav a').forEach(function (link) {
    if (link.getAttribute('href') === path) link.setAttribute('aria-current', 'page');
  });
}());
