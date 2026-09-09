---
name: Styio
description: Experimental symbolic language design in cool black, fog white, electric color, and liquid chrome.
colors:
  cool-black: "#101116"
  dark-surface: "#181a23"
  fog-white: "#f4f5fb"
  dark-muted: "#acb0c1"
  dark-rule: "#363a4c"
  periwinkle: "#a6b6ff"
  cobalt-action: "#4054e8"
  electric-fuchsia: "#f6a5dc"
  electric-cyan: "#86ddff"
  action-white: "#ffffff"
  code-black: "#090b12"
  syntax-pink: "#f2a6d3"
  syntax-slate: "#9da7bd"
  light-fog: "#f3f4f8"
  light-surface: "#e6e9f3"
  light-ink: "#171c2d"
  light-muted: "#545f76"
  light-rule: "#cbd2e4"
  light-blue: "#354fbd"
  light-fuchsia: "#a62f7c"
  light-cyan: "#176b99"
  light-code: "#e5e9f3"
  light-syntax-blue: "#244ac2"
  light-syntax-slate: "#5b6680"
  manifesto-cobalt: "#2638ad"
  manifesto-rule: "#5161cc"
  manifesto-cyan: "#9cdeff"
  manifesto-pink: "#ffa6df"
typography:
  display:
    fontFamily: "Syne, sans-serif"
    fontSize: "clamp(80px, 10.55vw, 165px)"
    fontWeight: 500
    lineHeight: 0.97
    letterSpacing: "-0.04em"
  headline:
    fontFamily: "Syne, sans-serif"
    fontSize: "clamp(38px, 4.7vw, 72px)"
    fontWeight: 500
    lineHeight: 1.08
    letterSpacing: "-0.04em"
  body:
    fontFamily: "DM Sans, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.6
  label:
    fontFamily: "DM Sans, sans-serif"
    fontSize: "13px"
    fontWeight: 400
    lineHeight: 1.4
  code:
    fontFamily: "SFMono-Regular, Consolas, Liberation Mono, monospace"
    fontSize: "13px"
    fontWeight: 400
    lineHeight: 1.85
rounded:
  tag: "2px"
  control: "3px"
  panel: "4px"
  round: "50%"
spacing:
  gutter: "clamp(22px, 4.2vw, 80px)"
  control-y: "16px"
  control-x: "22px"
components:
  button-primary:
    backgroundColor: "{colors.cobalt-action}"
    textColor: "{colors.action-white}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    padding: "16px 22px"
    height: "54px"
  navigation-install:
    backgroundColor: "transparent"
    textColor: "{colors.fog-white}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    padding: "12px 18px"
  code-panel:
    backgroundColor: "{colors.code-black}"
    textColor: "{colors.fog-white}"
    typography: "{typography.code}"
    rounded: "{rounded.panel}"
    padding: "30px 25px"
  tag:
    backgroundColor: "{colors.dark-surface}"
    textColor: "{colors.dark-muted}"
    typography: "{typography.label}"
    rounded: "{rounded.tag}"
    padding: "2px 6px"
---

# Design System: Styio

## Overview

**Creative North Star: "Iridescent Direction"**

Styio turns its `>>` operator into substantial digital material. Monumental Syne typography, open composition, terse labels, and a liquid-chrome double-chevron sculpture make direction feel physical. Cool black and fog white establish the field; cobalt, cyan, fuchsia, and silver light carry action and flow.

The home page is vivid and kinetic. Documentation and error recovery use the same shell, typography, rules, and palette with a calmer reading rhythm. Content, navigation, and the hero artwork remain useful without animation or JavaScript.

**Key Characteristics:**
- Oversized display type paired with exact body and monospace text.
- Real language operators used as functional diagrams and graphic signatures.
- Flat interface surfaces contrasted with one luminous, material hero object.
- Fluid motion that stops with user preference, visibility, and viewport state.

The interaction ambition draws from [Active Theory V5](https://www.awwwards.com/sites/active-theory-v5) and [Lusion V3](https://www.awwwards.com/websites/%23DAF0F6/?page=14), without copying their compositions.

## Colors

The dark theme is the native expression: cool black, fog white, and luminous electric color. The light theme translates the same hierarchy into pale blue-gray surfaces and deeper cobalt, cyan, and fuchsia. The `cool` and `cool-dark` values remain only as stable theme attributes for `localStorage.styio-theme`; they no longer name palette families.

### Primary
- **Cobalt Action:** Fills primary actions and anchors the solid-blue manifesto field.
- **Periwinkle Signal:** Marks links, focus, display emphasis, status, and active flow in dark mode.
- **Deep Light Blue:** Performs the same semantic work on light surfaces.

### Secondary
- **Electric Fuchsia:** Selects symbolic operators and colors variable syntax; its deeper counterpart serves light mode.
- **Electric Cyan:** Colors string syntax and reflected light; its deeper counterpart serves light mode.

### Tertiary
- **Liquid Silver:** Lives inside the authored sculpture and its masked reflection, giving the symbolic object material depth without becoming a general UI neutral.

### Neutral
- **Cool Black and Light Fog:** Page backgrounds for dark and light modes.
- **Dark and Light Surfaces:** Raised sections, controls, tags, and selected navigation surfaces.
- **Fog White and Light Ink:** Primary text in their respective themes.
- **Muted and Rule Tones:** Supporting copy, coordinates, metadata, and fine separators.
- **Code Black and Light Code:** Dedicated reading surfaces for code specimens and commands.

**The Electric Signal Rule.** Use saturated color to identify action, flow, selection, syntax, and the signature artwork; let neutral fields preserve its impact.

## Typography

**Display Font:** Syne, self-hosted variable font with a sans-serif fallback.

**Body Font:** DM Sans, self-hosted variable font with a sans-serif fallback.

**Code Font:** SFMono-Regular with Consolas, Liberation Mono, and monospace fallbacks.

**Character:** Syne supplies broad, unconventional display shapes; DM Sans keeps navigation and reading copy direct. Both bundled font files retain their SIL Open Font License texts.

### Hierarchy
- **Display:** Medium Syne at a fluid monumental scale with tight tracking and near-solid leading; use for the home hero, manifesto, footer wordmark, and large symbolic numerals.
- **Headline:** Medium Syne with balanced wrapping; use for section, document, and recovery headings.
- **Body:** Regular DM Sans with relaxed leading; documentation paragraphs stop near 72 characters and ledes near 57 characters.
- **Label:** Compact DM Sans for navigation, metadata, actions, and controls.
- **Code:** Monospace with generous leading for commands, examples, operators, and diagrams.

**The Type Carries the Field Rule.** Let scale, line breaks, and operators form the composition around the single sculptural hero.

## Layout

Content spans a centered 1600px maximum with a fluid horizontal gutter. The home page alternates open asymmetrical grids: text and sculpture overlap in the hero, language tabs pair with a live explanation panel, and code narrative pairs with a specimen. Large section spacing and hairline boundaries create rhythm.

At 1100px the shell and paired grids tighten. At 760px major grids stack, the hero artwork returns to document flow, the docs sidebar becomes a wrapped horizontal index, and tables scroll within a labeled region. At 390px controls and navigation compact further. Interactive targets preserve practical touch areas, including the 44px theme control and 54px primary button where space allows.

Documentation uses a sticky 210px side index beside a reading column, then collapses to a single column on mobile. The 404 composition follows the same two-column-to-stack behavior so recovery feels part of the product.

## Elevation & Depth

The interface uses no box shadows. Depth comes from tonal surfaces, one-pixel rules, typography scale, and the spatial overlap of the hero. The double-chevron alone uses photographic chrome, blurred colored aura, perspective tilt, and an alpha-masked screen reflection to create real material depth.

**The One Sculpture Rule.** Keep ordinary surfaces flat and structural so the authored chrome operator remains the visual event.

## Shapes

Most controls and containers are nearly square with 2px to 4px corners. Borders stay thin and low contrast. Circles are reserved for the status dot, theme control, and large next-step link, giving round geometry a clear interactive or stateful role. The paired chevrons provide the signature directional silhouette.

## Components

### Shared Shell
- A sticky 96px header uses a bottom rule, bold wordmark, terse nav, bordered install action, and circular theme toggle; it compacts to 78px on mobile.
- The shared footer pairs an oversized wordmark with a short statement, essential links, license, copyright, and back-to-top action.
- Theme initialization reads `localStorage.styio-theme`, follows system preference when unset, and updates the browser theme color for both modes.

### Buttons and Links
- The primary button is cobalt with white text, a slight corner, and a directional arrow. Hover inverts to the current ink and background while the arrow advances.
- Text links use a fine underline boundary and turn to the theme accent on hover.
- The circular next-step link fills with cobalt and rotates its arrow on hover.

### Operator Tabs
- Vertical tabs combine a large monospace operator, Syne title, DM Sans explanation, and directional icon. Selection moves fuchsia to the operator and reveals the matching panel.
- Arrow keys, Home, and End move focus and selection. The implementation follows the [WAI-ARIA Tabs Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/tabs/) with linked tab and tabpanel roles.

### Code and Install Surfaces
- Code specimens sit on the dedicated code tone with compact metadata bars, relaxed monospace leading, and syntax colors tied to semantic token groups.
- Every direct `pre > code` block gains an icon copy control. Copied state uses the accent; failure changes its accessible label without inventing a new visual state.
- Install previews use the same code and copy behaviors in a quieter raised surface.

### Documentation and Recovery
- The docs index uses rule-separated link cards whose arrow and heading respond on hover. Tables scroll on small screens, tags use the tightest radius, and inline code uses the raised surface with accent text.
- The 404 page combines a monumental symbolic glyph, direct explanation, primary route home, documentation route, and installation recovery link.

### Double-Chevron Sculpture
- A transparent WebP image supplies the authored liquid-chrome `>>` silhouette and its cobalt, cyan, fuchsia, and silver reflections.
- Separate layers provide a blurred aura, a slow 10-second float, pointer-driven perspective tilt, and a 7-second light sweep masked to the sculpture alpha.
- The requestAnimationFrame loop runs only while pointer pose is settling. Floating and reflection animations pause offscreen, while hidden, after user pause, and for reduced motion. Reduced motion hides the control and presents the static sculpture.

## Do's and Don'ts

### Do:
- **Do** use real Styio operators as diagrams, signatures, and navigation cues.
- **Do** preserve the shared shell, persistent theme choice, dynamic browser theme color, and readable static state.
- **Do** use electric color to communicate action, selection, focus, syntax, flow, or reflected light.
- **Do** keep documentation typography, code tools, installation steps, and recovery paths clear before adding expression.

### Don't:
- **Don't** restore the retired multi-family palette model behind the retained theme attribute names.
- **Don't** add generic gradients, glossy cards, or decorative blobs to ordinary interface surfaces.
- **Don't** animate hidden or offscreen work, run pose frames after settling, or make content depend on motion.
- **Don't** create claims, telemetry, or user-data collection that the static product does not have.
