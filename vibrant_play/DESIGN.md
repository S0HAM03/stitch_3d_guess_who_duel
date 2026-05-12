---
name: Vibrant Play
colors:
  surface: '#f8f9fd'
  surface-dim: '#d9dade'
  surface-bright: '#f8f9fd'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3f7'
  surface-container: '#edeef2'
  surface-container-high: '#e7e8ec'
  surface-container-highest: '#e1e2e6'
  on-surface: '#191c1f'
  on-surface-variant: '#3e4852'
  inverse-surface: '#2e3134'
  inverse-on-surface: '#eff1f5'
  outline: '#6f7883'
  outline-variant: '#bec7d3'
  surface-tint: '#006399'
  primary: '#006399'
  on-primary: '#ffffff'
  primary-container: '#00a8ff'
  on-primary-container: '#003a5c'
  inverse-primary: '#95ccff'
  secondary: '#b9082c'
  on-secondary: '#ffffff'
  secondary-container: '#dd2d42'
  on-secondary-container: '#fffbff'
  tertiary: '#735c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#bb9e3f'
  on-tertiary-container: '#443600'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cde5ff'
  primary-fixed-dim: '#95ccff'
  on-primary-fixed: '#001d32'
  on-primary-fixed-variant: '#004a75'
  secondary-fixed: '#ffdad9'
  secondary-fixed-dim: '#ffb3b2'
  on-secondary-fixed: '#410008'
  on-secondary-fixed-variant: '#920020'
  tertiary-fixed: '#ffe083'
  tertiary-fixed-dim: '#e3c461'
  on-tertiary-fixed: '#231b00'
  on-tertiary-fixed-variant: '#564500'
  background: '#f8f9fd'
  on-background: '#191c1f'
  surface-variant: '#e1e2e6'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.2'
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '500'
    lineHeight: '1.5'
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-bold:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '700'
    lineHeight: '1.0'
    letterSpacing: 0.05em
  button-text:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '800'
    lineHeight: '1.0'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  safe-margin: 20px
---

## Brand & Style

The design system is centered on a **Tactile and Playful** aesthetic, specifically tailored for a fast-paced, 3D casual gaming experience. The target audience is broad, encompassing casual mobile gamers who seek instant gratification through intuitive, physically-inspired interfaces. 

The emotional response should be one of excitement, friendliness, and tactile satisfaction. This is achieved through a hybrid design style that blends **Skeuomorphic depth** with **Modern Vibrancy**. UI elements are not merely flat icons; they are objects with weight, glossy finishes, and "squishy" physical properties that respond to touch with realistic motion. The system leverages high-contrast environmental storytelling to ensure that the game board and UI remain distinct yet harmonious.

## Colors

This design system utilizes a high-energy, high-contrast palette designed to facilitate quick recognition during gameplay. 

- **Primary (Electric Blue):** Used for player-owned zones, confirmation actions, and primary navigation.
- **Secondary (Watermelon Red):** Dedicated to opponent zones, "No" or "Cancel" actions, and high-alert notification badges.
- **Tertiary (Golden Sun):** Employed for rewards, special characters, and highlight states to draw the eye to critical gameplay shifts.
- **Neutral (Cloud White/Soft Grey):** Provides a clean foundation for text containers and background panels, ensuring the 3D game world remains the focus.

The default mode is **Light**, utilizing soft-colored ambient occlusion to maintain a bright, morning-gameplay atmosphere.

## Typography

Typography in this design system prioritizes legibility and a "bubbly" personality. We use **Plus Jakarta Sans** for headlines and interactive labels due to its modern, rounded apertures that complement the 3D character models. 

For body text and chat interfaces, **Be Vietnam Pro** is used to provide a warm and inviting feel that remains clear even at smaller sizes on mobile screens. All caps should be used sparingly for "Label-Bold" tokens to denote UI headers or character names.

## Layout & Spacing

This design system follows a **Fluid Grid** model optimized for vertical mobile play. The layout is divided into three primary zones: 
1. **The Header:** Minimalist stats and settings.
2. **The Arena:** A central 3D viewport for the game board.
3. **The Interaction Tray:** A card-based area at the bottom for controls.

Rhythm is maintained through an 8px base unit. Spacing is generous to prevent accidental taps during intense gameplay. Buttons and cards utilize "sm" gutters (12px) to feel connected but distinct.

## Elevation & Depth

Hierarchy is established through **Ambient Shadows** and **Specular Gloss**. 

- **Level 1 (Base):** Subtle, soft shadows (15% opacity) for character cards sitting on the game board.
- **Level 2 (Interaction):** Floating UI panels use a deeper, diffused shadow with a slight color tint matching the panel's primary hue.
- **The Gloss Factor:** Interactive buttons feature a top-down "inner glow" or "sheen" to simulate a plastic, toy-like surface. When pressed, the elevation should visibly decrease (simulating a physical push) and the shadow should tighten.

## Shapes

The shape language is consistently **Rounded** to mirror the soft, semi-realistic geometry of the 3D characters. 

- **Primary Buttons:** Use a heavily rounded profile (rounded-xl) to appear safe and clickable.
- **Character Cards:** Feature a standard rounded-lg (1rem) corner to maximize the visible area of the 3D portrait while maintaining the friendly aesthetic.
- **Speech Bubbles:** Utilize "Pill-shaped" geometry for a classic comic-book feel.

## Components

### Glossy Action Buttons
Buttons are the core of the tactile experience. They feature a "3D thick base" (a darker shade of the button color on the bottom edge) and a bright specular highlight on the top edge. On-tap, the button should translate 2-4px downward.

### Character Selection Cards
Cards are vertical containers with a light neutral background and a subtle border. The character's name is placed in a high-contrast label at the bottom. When "knocked down," the card should animate with a 3D rotation, graying out the contents.

### Chat & Question Interface
Located at the bottom of the screen, this uses a "Shelf" layout. It consists of large, easy-to-tap pill buttons for "Yes/No" or a scrolling list of pre-set questions. The background is a semi-transparent blur to allow the 3D board to peek through.

### Player Boards
Boards are color-coded (Blue for the user, Red for the opponent). They act as the stage for character cards, featuring soft-indents (slots) where cards reside, reinforcing the physical board game metaphor.