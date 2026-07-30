(function () {
  "use strict";

  var copyIcon =
    '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
    '<rect x="9" y="9" width="10" height="10" rx="2"></rect>' +
    '<path d="M5 15V7a2 2 0 0 1 2-2h8"></path>' +
    "</svg>";
  var copiedIcon =
    '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
    '<path d="M20 6 9 17l-5-5"></path>' +
    "</svg>";

  var shellCommands = [
    "cat", "cd", "chmod", "curl", "echo", "env", "export", "gh", "grep", "install",
    "mkdir", "python", "python3", "rg", "scripts/validate-release-root.sh", "sh",
    "pafio", "styio", "tar", "test"
  ];
  var shellKeywords = [
    "case", "do", "done", "elif", "else", "esac", "false", "fi", "for", "function",
    "if", "in", "local", "readonly", "return", "set", "then", "true", "unset", "while"
  ];
  var shellSubcommands = [
    "create", "install", "release", "run", "workflow"
  ];
  var styioTypes = [
    "bool", "byte", "char", "double", "f32", "f64", "float", "i1", "i8", "i16",
    "i64", "i128", "int", "long", "str", "string"
  ];
  var styioLiterals = [
    "false", "true"
  ];
  var styioKeywords = [
    "schema"
  ];
  var styioSelectors = [
    "avg", "max", "min", "rsi", "std"
  ];

  function escapeHtml(value) {
    return value
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function wordPattern(words) {
    return new RegExp("\\b(?:" + words.map(function (word) {
      return word.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    }).join("|") + ")\\b", "g");
  }

  function addMatches(matches, text, type, regex, group) {
    var match;
    regex.lastIndex = 0;
    while ((match = regex.exec(text)) !== null) {
      var value = group ? match[group] : match[0];
      if (!value) {
        if (match[0].length === 0) regex.lastIndex += 1;
        continue;
      }

      var offset = group ? match[0].indexOf(value) : 0;
      var start = match.index + offset;
      matches.push({
        start: start,
        end: start + value.length,
        type: type
      });

      if (match[0].length === 0) regex.lastIndex += 1;
    }
  }

  function detectCodeKind(text) {
    if (/(^|\n)\s*(?:curl|pafio|styio|gh|python3|mkdir|tar|release_root=|scripts\/validate-release-root\.sh)\b/.test(text) || /\s--[A-Za-z]/.test(text)) {
      return "shell";
    }
    if (/(^|\n)\s*tools\//.test(text)) {
      return "path";
    }
    if (/(?:\[\||\|\]|:=|=>|>>|->|<-|<<|<\||>_|\?=|<~|~>|@(?:stdin|stdout|stderr|[A-Za-z_][A-Za-z0-9_]*(?=[{(]|\b))|\$[A-Za-z_][A-Za-z0-9_]*|\bschema\b|(^|\n)\s*#\s*[A-Za-z_][A-Za-z0-9_]*)/.test(text)) {
      return "styio";
    }
    return "plain";
  }

  function collectTokens(text, kind) {
    var matches = [];

    addMatches(matches, text, "url", /https?:\/\/[^\s"'<>]+/g);
    if (kind === "shell") {
      addMatches(matches, text, "comment", /#[^\n]*/g);
    }
    if (kind === "styio") {
      addMatches(matches, text, "comment", /\/\/[^\n]*/g);
      addMatches(matches, text, "comment", /\/\*[\s\S]*?\*\//g);
    }
    addMatches(matches, text, "string", /"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'/g);
    addMatches(matches, text, "variable", /\$\([^)]+\)|\$\{?[A-Za-z_][A-Za-z0-9_]*\}?/g);
    if (kind !== "styio") {
      addMatches(matches, text, "variable", /<[^>\n]+>/g);
    }
    addMatches(matches, text, "variable", /\b[A-Za-z_][A-Za-z0-9_]*(?==)/g);
    addMatches(matches, text, "path", /(?:\.{0,2}\/|\/|tools\/|assets\/|scripts\/)[A-Za-z0-9_./@%+-]+/g);

    if (kind === "shell") {
      addMatches(matches, text, "command", new RegExp("(^|[\\n|;&]\\s*)(" + shellCommands.map(function (word) {
        return word.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      }).join("|") + ")(?=\\s|$)", "g"), 2);
      addMatches(matches, text, "keyword", wordPattern(shellKeywords.concat(shellSubcommands)));
      addMatches(matches, text, "option", /(^|[\s])(--?[A-Za-z][A-Za-z0-9-]*(?:=[A-Za-z0-9_./:@%+-]+)?)/g, 2);
    } else if (kind === "styio") {
      addMatches(matches, text, "resource", /@[A-Za-z_][A-Za-z0-9_]*/g);
      addMatches(matches, text, "type", wordPattern(styioTypes));
      addMatches(matches, text, "literal", wordPattern(styioLiterals));
      addMatches(matches, text, "keyword", wordPattern(styioKeywords));
      addMatches(matches, text, "selector", wordPattern(styioSelectors));
    }

    if (kind === "styio") {
      addMatches(matches, text, "operator", /\[\||\|\]|<\||<-|->|<<|>>|>_|:=|\?=|=>|[#@]/g);
    } else {
      addMatches(matches, text, "number", /\b\d+(?:\.\d+)*(?:-[A-Za-z0-9]+)?\b/g);
      addMatches(matches, text, "operator", /\[\||\|\]|&&|\|\||\?\?|--|\.\.\.|<\||<-|->|<~|~>|<<|>>|>_|:=|\?=|=>|\+=|-=|\*=|\/=|==|!=|>=|<=|\*\*|[#$@|\\=<>?:+*\/%&^~!.,;()\[\]-]/g);
    }

    matches.sort(function (a, b) {
      if (a.start !== b.start) return a.start - b.start;
      return (b.end - b.start) - (a.end - a.start);
    });

    var filtered = [];
    var cursor = 0;
    matches.forEach(function (match) {
      if (match.start >= cursor) {
        filtered.push(match);
        cursor = match.end;
      }
    });

    return filtered;
  }

  function renderHighlightedCode(text, tokens) {
    var html = "";
    var cursor = 0;

    tokens.forEach(function (token) {
      html += escapeHtml(text.slice(cursor, token.start));
      html += '<span class="tok-' + token.type + '">' + escapeHtml(text.slice(token.start, token.end)) + "</span>";
      cursor = token.end;
    });

    html += escapeHtml(text.slice(cursor));
    return html;
  }

  function highlightCodeBlock(code) {
    if (!code || code.dataset.highlighted === "true") {
      return;
    }

    var text = code.textContent;
    var kind = detectCodeKind(text);
    if (kind === "plain") {
      code.dataset.highlighted = "true";
      return;
    }

    code.innerHTML = renderHighlightedCode(text, collectTokens(text, kind));
    code.dataset.highlighted = "true";
  }

  function copyWithFallback(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      return navigator.clipboard.writeText(text);
    }

    return new Promise(function (resolve, reject) {
      var textarea = document.createElement("textarea");
      textarea.value = text;
      textarea.setAttribute("readonly", "");
      textarea.style.position = "fixed";
      textarea.style.top = "-1000px";
      textarea.style.left = "-1000px";
      document.body.appendChild(textarea);
      textarea.select();

      try {
        if (document.execCommand("copy")) {
          resolve();
        } else {
          reject(new Error("copy command failed"));
        }
      } catch (error) {
        reject(error);
      } finally {
        document.body.removeChild(textarea);
      }
    });
  }

  function setButtonState(button, state) {
    window.clearTimeout(button._copyResetTimer);
    button.dataset.copyState = state;
    if (state === "copied") {
      button.innerHTML = copiedIcon + '<span class="visually-hidden">Copied</span>';
      button.setAttribute("aria-label", "Copied");
      button.setAttribute("title", "Copied");
      button._copyResetTimer = window.setTimeout(function () {
        setButtonState(button, "idle");
      }, 1600);
      return;
    }

    button.innerHTML = copyIcon + '<span class="visually-hidden">Copy code</span>';
    button.setAttribute("aria-label", "Copy code");
    button.setAttribute("title", "Copy code");
  }

  function attachCopyButton(pre) {
    var code = pre.querySelector(":scope > code");
    if (!code || pre.querySelector(":scope > .code-copy-button")) {
      return;
    }

    pre.classList.add("copyable-code");

    var button = document.createElement("button");
    button.className = "code-copy-button";
    button.type = "button";
    setButtonState(button, "idle");

    button.addEventListener("click", function () {
      copyWithFallback(code.textContent).then(
        function () {
          setButtonState(button, "copied");
        },
        function () {
          setButtonState(button, "idle");
          button.setAttribute("aria-label", "Copy failed");
          button.setAttribute("title", "Copy failed");
        }
      );
    });

    pre.appendChild(button);
  }

  function initCopyButtons() {
    document.querySelectorAll("pre > code").forEach(function (code) {
      highlightCodeBlock(code);
      attachCopyButton(code.parentElement);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initCopyButtons);
  } else {
    initCopyButtons();
  }
})();
