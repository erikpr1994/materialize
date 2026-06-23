---
name: ui-ux-pro-max
description: "UI/UX design guidelines (colors, typography, spacing, interactions, charts, stacks)."
---

# UI/UX Pro Max

UI/UX design intelligence database supporting multiple stacks and design domains. All recommendations and data are queried via the search script.

## Workflow

1. **Generate Design System (Required first step)**:
   ```bash
   python3 .agents/skills/ui-ux-pro-max/scripts/search.py "<product_type> <tone> <keywords>" --design-system --persist -p "<ProjectName>"
   ```
   This generates a global design system in `design-system/MASTER.md`.
   To create a page-specific override:
   ```bash
   python3 .agents/skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system --persist -p "<ProjectName>" --page "<page_name>"
   ```
   This saves the page-specific override in `design-system/pages/<page_name>.md`.

2. **Run Detailed Domain Searches (As needed)**:
   ```bash
   python3 .agents/skills/ui-ux-pro-max/scripts/search.py "<query>" --domain <domain>
   ```
   *Available domains*: `product`, `style`, `color`, `typography`, `landing`, `chart`, `ux`, `google-fonts`, `react`, `web`, `prompt`.

3. **Run Stack-Specific Queries**:
   ```bash
   python3 .agents/skills/ui-ux-pro-max/scripts/search.py "<query>" --stack <stack_name>
   ```
   *Available stacks*: `react-native`, `react`, `nextjs`, `vue`, `svelte`, `astro`, `swiftui`, `flutter`, `nuxtjs`, `nuxt-ui`, `html-tailwind`, `shadcn`, `jetpack-compose`, `threejs`, `angular`, `laravel`, `javafx`.

## UI/UX Validation Checklist

Before delivering any UI code, verify these standards:

### Visual & Styles
- Use vector assets (SVG), never emojis as icons.
- Ensure pressed/hover states do not shift layout bounds or cause jitter.
- Use semantic theme tokens (e.g. primary, background) instead of hardcoded hex values.

### Interaction & Touch
- Interactive targets must be >= 44x44pt on iOS / 48x48dp on Android (use hitSlop/padding if needed).
- Micro-interactions must timing-transition within 150-300ms.
- Disable buttons during async submission and display a loading spinner.

### Mode Contrast & Spacing
- Ensure body text contrast is >= 4.5:1 against the background in both light and dark modes.
- Respect system safe areas (notch, status bar, gesture indicators).
- Use a consistent 4pt/8dp grid rhythm for margins, padding, and gaps.

### Accessibility (a11y)
- Screen reader focus order must match visual order.
- Provide descriptive `accessibilityLabel` or alt text on non-text elements.
- Never convey critical information using color alone (supplement with icons or labels).