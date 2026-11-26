---
name: Aura Flow
colors:
  surface: '#f9f9ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#3e494c'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#6e797c'
  outline-variant: '#bdc8cc'
  surface-tint: '#006879'
  primary: '#006879'
  on-primary: '#ffffff'
  primary-container: '#29a0b8'
  on-primary-container: '#00313a'
  inverse-primary: '#6bd5ee'
  secondary: '#006876'
  on-secondary: '#ffffff'
  secondary-container: '#7fe9fe'
  on-secondary-container: '#006977'
  tertiary: '#4f6264'
  on-tertiary: '#ffffff'
  tertiary-container: '#83979a'
  on-tertiary-container: '#1c2f32'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#aaedff'
  primary-fixed-dim: '#6bd5ee'
  on-primary-fixed: '#001f26'
  on-primary-fixed-variant: '#004e5c'
  secondary-fixed: '#a1efff'
  secondary-fixed-dim: '#6ad5ea'
  on-secondary-fixed: '#001f25'
  on-secondary-fixed-variant: '#004e59'
  tertiary-fixed: '#d1e6e9'
  tertiary-fixed-dim: '#b6cacd'
  on-tertiary-fixed: '#0b1e21'
  on-tertiary-fixed-variant: '#374a4d'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  label-lg:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system embraces an airy, modern, high-clarity aesthetic rooted in energy-tech and frictionless utility. The design language is characterized by luminous cyan-tinted gradients, crisp pure white surfaces, soft environmental shadows, and pill-shaped touchpoints. 

The emotional tone balances trust, effortless speed, and calm accessibility. Targeted at contemporary mobile users navigating mobility, contactless transactions, and quick utility tasks, the visual style fuses soft modernism with subtle tactile cues:
- **Atmospheric Headers:** Smooth, light gradient backdrops providing gentle visual depth at top-of-screen anchor zones.
- **Card-Centric Modularity:** Pure `#FFFFFF` elevated surfaces sitting atop an ultra-soft cool-tinted ground (`#F6F9FA`).
- **Tactile Softness:** Generous corner radiuses (16px to 24px) paired with pill-form buttons and floating controls that invite effortless interaction.

## Colors

The palette is engineered around clean aquatic teals and pure neutrals to convey pristine reliability and crisp legibility.

### Palette Architecture
- **Primary Accent (`#29A0B8`):** The functional hero tone used for high-emphasis CTAs, filled interactive states, and active navigation indicators. Meets WCAG AA contrast criteria against light surfaces for essential UI controls.
- **Secondary Cyan (`#48B8CC`):** The bright, energetic companion tone, ideal for subtle gradient transitions, brand text highlights, and vibrant focal points.
- **Atmospheric Light Gradient:** Composed of a directional top-to-bottom blend from `#48B8CC` down through `#6ED4E3` to `#E0F5F8`, creating dynamic immersion in onboarding headers and hero areas.
- **Tertiary Tint (`#E0F5F8`):** A soft, pale cyan wash used for active pill backgrounds, chip fills, soft status badges, and secondary utility highlights.
- **Neutral Stack:**
  - `Surface Base`: `#F6F9FA` (soft cool-grey canvas background)
  - `Surface Elevated`: `#FFFFFF` (pristine white card containers)
  - `Text Primary`: `#1E293B` (deep charcoal-slate providing stark, crisp contrast)
  - `Text Secondary`: `#64748B` (refined slate for descriptive labels and helper copy)
  - `Border / Divider`: `#E2E8F0` (ultra-soft borders for subtle enclosure without heaviness)
- **Functional States:**
  - `Success`: `#10B981` (emerald green badge/indicator)
  - `Warning`: `#F59E0B` (warm amber indicator)
  - `Critical`: `#EF4444` (clear error alert)

## Typography

The type system is powered by **Inter**, chosen for its tall x-height, neutral precision, and superb readability on high-density mobile screens.

### Hierarchy & Usage
- **Hero / Display (`display-lg`, `display-lg-mobile`):** Used primarily in onboarding displays and greeting banners. Often set with bright contrast (white over gradient cyan headers or deep charcoal `#1E293B` on `#FFFFFF`).
- **Section Titles (`headline-md`, `title-md`):** Provide immediate orientation for grouping sections, input modules, and location list headers.
- **Body & Secondary Copy (`body-md`, `body-lg`):** Kept lean with open line-heights for quick scanning in dynamic environments.
- **Labels & Micro-copy (`label-lg`, `label-md`, `label-sm`):** Tuned for buttons, form labels, metadata pills, and status tags with tighter tracking and bold weights.

## Layout & Spacing

A mobile-first fluid grid anchors all views, relying on a unified 4px / 8px incremental baseline to maintain breathing room and ease of one-handed thumb interaction.

### Breakpoints & Fluidity
- **Mobile (<640px):** Single-column layout with fixed outer margin `1.25rem` (20px) and column gap `1rem` (16px). Form fields and CTAs span the full content width.
- **Tablet / Large Canvas (≥640px):** Content wraps into a centered fluid container with a maximum width of 480px for mobile app viewports, or maps across a 6-to-12 column grid with margins expanding to `2rem`.

### Spacing Rules
- **Component Padding:** Cards standardly utilize `space-md` (16px) or `space-lg` (24px) inner padding.
- **Input & Control Height:** Form fields and primary action buttons maintain a minimum target height of `52px` to guarantee comfortable mobile touch targets.
- **Stack Spacing:** Related elements (e.g., input and label) are separated by `space-xs` (4px) to `space-sm` (8px); independent form modules sit apart by `space-md` (16px).

## Elevation & Depth

Visual hierarchy uses soft atmospheric elevation rather than harsh outlines, establishing clear layering between the canvas, functional cards, and floating interactive triggers.

### Surface Tiers
1. **Base Ground (`#F6F9FA`):** The canvas beneath standard pages, providing a calm, non-glare foundation.
2. **Atmospheric Header Layer:** Top-aligned viewport slices dressed in gradient teal-cyan, framing identity and directional cues.
3. **Resting Cards (`#FFFFFF`):** High-surface containers using subtle ambient shadows:
   - *Box-shadow:* `0px 4px 20px rgba(41, 160, 184, 0.06), 0px 1px 4px rgba(0, 0, 0, 0.04)`
   - Creates a signature featherlight cyan tint in the ambient shadow rather than dead black/grey.
4. **Floating Action Controls & Circular Nav:** Back buttons, quick-action FABs, and active modals utilize a slightly deeper lift:
   - *Box-shadow:* `0px 8px 24px rgba(15, 23, 42, 0.08), 0px 2px 6px rgba(41, 160, 184, 0.08)`
5. **Hairline Separation:** Where border separation is required (e.g., social login options, text field boundaries), use a 1px border tinted in `#E2E8F0` or `#EDF2F7`.

## Shapes

The shape system expresses a friendly, polished, ergonomic feel centered around generous 16px–24px card radii and fully rounded pill contours for actions.

### Radius Scale
- **Pill / Circular (`9999px`):** Reserved for primary and secondary action buttons, round navigation chips, search inputs, pagination pills, and floating circular back buttons.
- **Large Container Radius (`1.5rem` / 24px):** Applied to primary elevated content cards, bottom sheets, and hero image frames.
- **Medium Container Radius (`1rem` / 16px):** Applied to standard input fields, modal alerts, list cards, and segmented options.
- **Badge Radius (`0.5rem` / 8px):** Applied to status badges and micro-tags.

## Components

### Buttons
- **Primary Action Button:** Fully rounded pill shape (`border-radius: 9999px`), 52px height, full width on mobile. Solid `#29A0B8` background, `#FFFFFF` text (`label-lg`). Hover/pressed state shifts to `#218A9E`.
- **Secondary / Social Button:** White background `#FFFFFF`, subtle 1px border `#E2E8F0`, pill shape, 52px height. Displays icon alongside label in `#1E293B`.
- **Circular Icon Button:** 44px × 44px circle, `#FFFFFF` background with soft ambient shadow. Houses navigation icons like `<` (Chevron Left) in `#1E293B`.

### Form Inputs
- **Text Field:** 50px–52px height, pure `#FFFFFF` fill, 16px corner radius, thin `#EDF2F7` border or shadow-only elevation. Placeholder copy set in `#94A3B8`.
- **Focused State:** Border transitions to `#29A0B8` with an ultra-soft cyan glow (`box-shadow: 0 0 0 3px rgba(41, 160, 184, 0.15)`).
- **Password Variant:** Includes trailing interactive eye icon button in `#64748B`.

### Cards & List Items
- **Location / Fuel Card:** Pure white background, 20px–24px roundedness, soft cyan-tinted ambient drop shadow. Contains location title, metadata pill, status badge, and distance callout.
- **Profile / Info Row:** Clean horizontal layout with 48px rounded icon or avatar on the left, primary text stacked over secondary metadata, and trailing chevron in `#94A3B8`.

### Chips & Status Indicators
- **Status Badges:** Compact pills with `0.5rem` radius, 24px height, light tinted background (`#E0F5F8` for active, `#ECFDF5` for success), paired with high-contrast text (`#29A0B8` or `#059669`).
- **Live Indicator Dot:** 8px circular beacon with a pulsing concentric outer ring for real-time station or payment readiness.

### Pagination Indicators
- **Pill Indicators:** Active step represented as an elongated cyan pill (`width: 24px`, `height: 8px`, `border-radius: 4px`, `#FFFFFF` or `#29A0B8`); inactive steps rendered as small semi-transparent dots (`width: 8px`, `height: 8px`, opacity 0.5).