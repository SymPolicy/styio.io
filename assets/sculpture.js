(function () {
  'use strict';
  var art = document.querySelector('.sculpture-art');
  if (!art) return;
  var control = document.getElementById('motion-toggle');
  var reduced = window.matchMedia('(prefers-reduced-motion: reduce)');
  var paused = reduced.matches;
  var visible = false;
  var frame = 0;
  var targetX = 0, targetY = 0, currentX = 0, currentY = 0;
  function playing() { return visible && !document.hidden && !paused && !reduced.matches; }
  function pose() {
    frame = 0;
    if (!playing()) return;
    currentX += (targetX - currentX) * .1;
    currentY += (targetY - currentY) * .1;
    art.style.setProperty('--pose-x', currentX.toFixed(3) + 'deg');
    art.style.setProperty('--pose-y', currentY.toFixed(3) + 'deg');
    if (Math.abs(targetX - currentX) + Math.abs(targetY - currentY) > .015) frame = requestAnimationFrame(pose);
  }
  function requestPose() { if (!frame && playing()) frame = requestAnimationFrame(pose); }
  function update() {
    art.classList.toggle('is-playing', playing());
    document.documentElement.classList.toggle('motion-paused', paused || reduced.matches);
    control.hidden = reduced.matches;
    control.innerHTML = paused ? 'Resume motion <span aria-hidden="true">&#9655;</span>' : 'Pause motion <span aria-hidden="true">&#x2161;</span>';
    if (!playing() && frame) { cancelAnimationFrame(frame); frame = 0; }
    if (playing()) requestPose();
  }
  art.addEventListener('pointermove', function (event) {
    if (!playing() || event.pointerType === 'touch') return;
    var bounds = art.getBoundingClientRect();
    targetX = -((event.clientY - bounds.top) / bounds.height - .5) * 14;
    targetY = ((event.clientX - bounds.left) / bounds.width - .5) * 18;
    requestPose();
  }, { passive: true });
  art.addEventListener('pointerleave', function () { targetX = 0; targetY = 0; requestPose(); });
  control.addEventListener('click', function () { paused = !paused; update(); });
  reduced.addEventListener('change', function (event) {
    paused = event.matches;
    if (paused) { targetX = 0; targetY = 0; currentX = 0; currentY = 0; art.style.removeProperty('--pose-x'); art.style.removeProperty('--pose-y'); }
    update();
  });
  document.addEventListener('visibilitychange', update);
  new IntersectionObserver(function (entries) { visible = entries[0].isIntersecting; update(); }).observe(art);
  update();
}());
