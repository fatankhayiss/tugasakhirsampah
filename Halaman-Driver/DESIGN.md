---
name: Waste Management Design System
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#3d4a3e'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#6d7b6d'
  outline-variant: '#bccabb'
  surface-tint: '#006d36'
  primary: '#006d36'
  on-primary: '#ffffff'
  primary-container: '#4ade80'
  on-primary-container: '#005e2d'
  inverse-primary: '#4de082'
  secondary: '#5f5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e2dfde'
  on-secondary-container: '#636262'
  tertiary: '#006c4e'
  on-tertiary: '#ffffff'
  tertiary-container: '#5fd9aa'
  on-tertiary-container: '#005d42'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#6dfe9c'
  primary-fixed-dim: '#4de082'
  on-primary-fixed: '#00210c'
  on-primary-fixed-variant: '#005227'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#80f9c8'
  tertiary-fixed-dim: '#62dcad'
  on-tertiary-fixed: '#002115'
  on-tertiary-fixed-variant: '#00513a'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  headline-xl:
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
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-margin: 20px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
  section-gap: 32px
---

## Brand & Style
The brand personality of this design system is centered on **Optimistic Sustainability**. It aims to transform the chore of waste management into a rewarding, community-driven experience. The target audience ranges from eco-conscious homeowners to municipal coordinators, requiring a balance between high-utility professional tools and a friendly, accessible interface.

The design style is a blend of **Modern Corporate and Soft Minimalism**. It prioritizes extreme clarity and ease of use while utilizing organic, rounded shapes and a vibrant color palette to evoke feelings of freshness and environmental health. The interface should feel "breathable," with generous whitespace and a calm, organized flow that reduces the cognitive load of scheduling and tracking waste services.

## Colors
The color palette is anchored by a vibrant **Mint Green (#4ADE80)**, which serves as the primary signal for action, growth, and eco-friendliness. This is contrasted against a **Deep Onyx (#1A1A1A)** used for headings and primary iconography to ensure high legibility and a sense of grounded authority.

The background uses a **Soft Grey (#F9FAFB)** to reduce screen glare and provide a clean canvas for white card elements. Accents of softer teals and light emeralds are used for secondary status indicators (like "Recycled" or "Collected"), while semantic reds and ambers are strictly reserved for missed pickups or urgent alerts.

## Typography
This design system utilizes **Plus Jakarta Sans** for all levels of the hierarchy to maintain a contemporary and welcoming tone. Headlines are set with tight letter-spacing and bold weights to provide a strong visual anchor on the page. 

Body text is prioritized for readability with generous line heights (1.5x) to ensure that service details and instructions are easily digestible. Labels and captions use medium to semi-bold weights to remain distinct even at smaller scales, ensuring that data points like "Weight" or "Pickup Time" are immediately recognizable.

## Layout & Spacing
The layout follows a **Fluid Grid** model optimized for mobile-first interaction. It utilizes a 4-column system for small screens with a standard 20px outer margin to provide breathing room from the edge of the device.

Spacing is based on an **8px base unit**. Component internals (like padding inside a card) should stick to 16px or 24px to match the roundedness of the shapes. Vertical rhythm is maintained by using 32px gaps between major sections (e.g., between "Upcoming Pickups" and "Eco Statistics") to signify clear content transitions.

## Elevation & Depth
Depth is communicated through **Ambient Shadows** and **Tonal Layering**. Instead of heavy, dark shadows, this design system uses soft, diffused shadows with a low-opacity black or a very slight green tint (`0px 8px 24px rgba(0, 0, 0, 0.04)`). 

Interactive cards sit on the highest elevation, while the main background remains flat. Secondary content, such as inactive schedule blocks, uses a subtle stroke or a slightly darker grey background rather than a shadow to indicate a lower priority in the visual stack.

## Shapes
The shape language is defined by **pronounced roundedness**, reinforcing the "friendly" and "approachable" brand pillars. 

Standard components like input fields and small buttons use a 12px-16px radius. Primary containers, feature cards, and modal sheets utilize a larger **24px radius** to create a distinct, modern look. This consistency in rounding helps soften the industrial nature of waste management, making the app feel more like a lifestyle assistant.

## Components
- **Buttons:** Primary buttons are solid Mint Green with white or dark onyx text, featuring a 16px corner radius. They should have a subtle lift (shadow) on hover/press states.
- **Cards:** White surfaces with a 24px radius and a soft ambient shadow. They are the primary container for service schedules and educational content.
- **Iconography:** Icons must use a **2px to 2.5px stroke weight** with rounded caps and joins. They are minimalist, avoiding complex detail to ensure clarity at small sizes.
- **Input Fields:** Large, 16px rounded containers with a light grey fill and no border in their default state. On focus, they transition to a Mint Green border.
- **Chips/Badges:** Pill-shaped (fully rounded) indicators used for waste categories (e.g., Plastic, Paper, Bio-waste). They use low-saturation background tints of the category color with high-contrast text.
- **Progress Trackers:** Smooth, rounded-end bars used for recycling goals. The "track" should be a light grey, and the "fill" should be the primary Mint Green.
- **Navigation Bar:** A floating or anchored bottom bar with thick-stroked icons. The active state is indicated by a Mint Green color shift or a soft background pill.