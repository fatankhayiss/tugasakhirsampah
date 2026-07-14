---
name: Eco-Systemic Enterprise
colors:
  surface: '#f6fbf1'
  surface-dim: '#d6dcd2'
  surface-bright: '#f6fbf1'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f5eb'
  surface-container: '#eaf0e5'
  surface-container-high: '#e5eae0'
  surface-container-highest: '#dfe4da'
  on-surface: '#181d17'
  on-surface-variant: '#3f493e'
  inverse-surface: '#2c322b'
  inverse-on-surface: '#edf2e8'
  outline: '#6f7a6c'
  outline-variant: '#bfcaba'
  surface-tint: '#026e25'
  primary: '#006320'
  on-primary: '#ffffff'
  primary-container: '#1e7d32'
  on-primary-container: '#c2ffbf'
  inverse-primary: '#7fdb83'
  secondary: '#006e1c'
  on-secondary: '#ffffff'
  secondary-container: '#91f78e'
  on-secondary-container: '#00731e'
  tertiary: '#0c621b'
  on-tertiary: '#ffffff'
  tertiary-container: '#2d7c31'
  on-tertiary-container: '#c4ffbb'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#9af89d'
  primary-fixed-dim: '#7fdb83'
  on-primary-fixed: '#002106'
  on-primary-fixed-variant: '#005319'
  secondary-fixed: '#94f990'
  secondary-fixed-dim: '#78dc77'
  on-secondary-fixed: '#002204'
  on-secondary-fixed-variant: '#005313'
  tertiary-fixed: '#a3f69c'
  tertiary-fixed-dim: '#88d982'
  on-tertiary-fixed: '#002204'
  on-tertiary-fixed-variant: '#005312'
  background: '#f6fbf1'
  on-background: '#181d17'
  surface-variant: '#dfe4da'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  title-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '700'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
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
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 20px
  gutter: 16px
---

## Brand & Style

The design system is engineered for an enterprise-grade recycling platform, balancing environmental advocacy with professional reliability. The brand personality is **authoritative, efficient, and restorative**. It aims to transform waste management from a chore into a structured, high-value logistics process.

The design style follows **Corporate Modernism** with a focus on **Tonal Clarity**. It prioritizes high legibility and a clean, spacious aesthetic to ensure that data-heavy screens (like waste collection schedules or payout histories) remain approachable for citizens. The interface uses high-quality whitespace and a disciplined grid to evoke a sense of order and institutional trust.

## Colors

The color palette is rooted in a spectrum of greens to reinforce the recycling mission while maintaining professional contrast ratios. 

- **Primary Emerald**: Used for primary actions, branding elements, and active states.
- **Secondary Leaf**: Applied to accent elements and secondary visual interest.
- **Functional Greens**: Success states utilize a deep emerald to distinguish from the primary brand green.
- **Neutrals**: The background utilizes a cool slate-tinted white (#F8FAFC) to reduce eye strain and provide a sophisticated canvas for pure white (#FFFFFF) cards.
- **Typography**: A tiered hierarchy of slate-based grays ensures that information density is managed through color-weighting.

## Typography

This design system utilizes **Plus Jakarta Sans** for its contemporary, geometric humanist traits that feel both friendly and professional. 

The type hierarchy is structured around the **Material 3 (M3) framework**, ensuring consistency across platform ecosystems. For mobile views, large display styles should be stepped down to prevent overflow, while maintaining the "Bold" and "SemiBold" weights to anchor the page's information architecture. Letter spacing is slightly tightened on larger headings to maintain a compact, premium feel.

## Layout & Spacing

The system is built on an **8pt Grid System**, ensuring all components align to a predictable rhythm. 

- **Layout Model**: A fluid grid for mobile and a 12-column fixed grid for desktop (max-width: 1280px).
- **Margins**: Use 16px or 20px side margins on mobile to ensure content doesn't touch the edge of the device.
- **Rhythm**: Vertical spacing between card components should ideally be 16px (md) or 24px (lg) to create clear logical groupings.
- **Padding**: Internal component padding follows the 8pt scale (e.g., buttons use 12px height / 24px width).

## Elevation & Depth

Hierarchy is established through **Tonal Layering** and **Ambient Shadows**.

- **Level-0 (Base)**: The background (#F8FAFC) is the lowest level.
- **Level-1 (Standard Cards)**: Uses a subtle shadow (Y: 2px, Blur: 4px, Color: 0,0,0, 0.05) to separate white surfaces from the scaffold.
- **Level-2 (Navigation & Heroes)**: Uses a more pronounced shadow (Y: 4px, Blur: 12px, Color: 0,0,0, 0.08) to indicate high-priority interactive layers or persistent headers.
- **Interactions**: On hover/press, cards may transition from Level-1 to Level-2 to provide tactile feedback.

## Shapes

The shape language is **Soft-Geometric**, utilizing varying radii to denote different component scales:

- **12px (radiusMD)**: Default for standard UI cards, bottom sheets, and input fields.
- **16px (radiusLG)**: Reserved for hero containers, large banners, and modal overlays.
- **24px (radiusXL)**: Applied to interactive chips, tags, and small buttons to create a "pill" look that stands out against rectangular layouts.
- **999px (radiusFull)**: Exclusively for avatars and circular icon buttons.

## Components

### Buttons
- **Primary**: Filled Emerald Green (#1E7D32) with white text. 24px (radiusXL) for high prominence.
- **Secondary**: Outlined Emerald Green with 1px border.
- **Ghost**: No border, Slate primary text, used for less frequent actions.

### Cards
- White background (#FFFFFF) with 12px corner radius and Level-1 shadow. 
- Padding should be 16px or 24px depending on content density.

### Inputs
- Height: 48px. 
- Border: 1px Solid Slate (#E2E8F0). 
- Label: Label Large (14px SemiBold) positioned above the field.

### Chips & Tags
- Height: 32px.
- Radius: 24px.
- Background: Secondary Leaf Green (#4CAF50) at 10% opacity for a soft, professional look.

### Iconography
- **Material Symbols Outlined**: 24px size with a 2px stroke weight to match the clean, professional aesthetic. Icons should always be centered within their hit areas.