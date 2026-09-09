(function () {
  'use strict';
  document.querySelectorAll('[data-site-footer]').forEach(function (footer) {
    footer.innerHTML = '<div class="wrap footer-top">' +
      '<a class="footer-wordmark" href="/" aria-label="Styio home">styio<span aria-hidden="true">.</span></a>' +
      '<p>A different way<br>to express what comes next.</p>' +
      '<nav aria-label="Footer navigation"><a href="/docs/install.html">Install Styio</a><a href="/docs/">Documentation</a><a href="https://github.com/SymPolicy/styio">GitHub <span aria-hidden="true">&nearr;</span></a></nav></div>' +
      '<div class="wrap footer-bottom"><span>Released under the <a href="https://github.com/SymPolicy/styio.io/blob/main/LICENSE">Apache 2.0 License</a>.</span>' +
      '<span>Copyright &copy; 2023-2026 Yizhuo Yang</span><a href="#top">Back to top <span aria-hidden="true">&uarr;</span></a></div>';
  });
}());
