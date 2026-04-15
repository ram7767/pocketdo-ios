# Design System Strategy: The Focused Curator

## 1. Overview & Creative North Star
The North Star for this design system is **"The Focused Curator."** In a world of cluttered productivity apps, this system rejects the "box-within-a-box" layout in favor of an expansive, editorial feel. We are moving away from traditional utility and toward a high-end digital workspace that feels like a premium physical planner.

To break the "template" look, this system utilizes **intentional asymmetry** (e.g., large left-aligned headlines paired with offset action items) and **tonal layering**. We prioritize white space as a functional element—breathing room is not "empty"; it is the boundary that allows the user to focus on a single task at a time.

---

## 2. Colors & Tonal Depth
We treat color not as a decoration, but as a structural material.

### Color Tokens (Reference)
*   **Primary:** `#3525cd` (A deep, authoritative Indigo)
*   **Secondary:** `#006e2f` (A lush, success-oriented Green)
*   **Surface Lowest:** `#ffffff` (Pure focus)
*   **Surface Low:** `#f3f4f5` (Subtle grounding)

### The "No-Line" Rule
**Explicit Instruction:** You are prohibited from using 1px solid borders to section off content. Traditional borders create visual noise that traps the eye. Instead:
*   Define boundaries through **Background Shifts**: A `surface-container-low` card sitting on a `surface` background provides all the separation required.
*   Define boundaries through **Negative Space**: Use the 8pt spacing system to create "islands" of content.

### Surface Hierarchy & Nesting
Treat the UI as a series of stacked sheets of fine paper. 
*   **Base:** The `background` token.
*   **Content Areas:** Use `surface-container-low`.
*   **Floating Components (Cards):** Use `surface-container-lowest` to create a "lifted" effect.
*   **The "Glass & Gradient" Rule:** For high-priority CTAs or the FAB, use a subtle linear gradient from `primary` to `primary_container`. This adds a "soul" to the component that flat hex codes lack.

---

## 3. Typography: Editorial Authority
The typography uses a high-contrast pairing between **Manrope** (Headlines) and **Inter** (Body/Labels).

*   **Display & Headlines (Manrope):** Use `headline-lg` (2rem) for "Today’s Focus." These should be bold and unapologetically large. The goal is to provide a sense of editorial importance to the user's daily life.
*   **Titles & Body (Inter):** Use `title-md` for task names. Inter provides the high X-height necessary for legibility at small sizes.
*   **Semantic Scale:** 
    *   `display-sm` (2.25rem) – Empty state "hero" text.
    *   `body-md` (0.875rem) – Task descriptions and notes.
    *   `label-sm` (0.6875rem) – Metadata and timestamps.

---

## 4. Elevation & Depth: Tonal Layering
We do not use structural lines. We use physics and light.

*   **The Layering Principle:** Depth is achieved by stacking. Place a `surface-container-lowest` card (Pure White) on a `surface-container` background (Light Grey). The eye perceives the white as closer to the user.
*   **Ambient Shadows:** For floating elements like the Bottom Navigation or FAB, use an **ultra-diffused shadow**. 
    *   *Shadow Setting:* `Y: 8px, Blur: 24px, Color: on-surface (opacity 4-6%)`. Never use pure black shadows; always tint the shadow with the `on-surface` color to mimic natural light.
*   **The "Ghost Border" Fallback:** If a border is required for accessibility in specific inputs, use the `outline-variant` token at **20% opacity**. It should be felt, not seen.
*   **Glassmorphism:** Use `backdrop-blur (12px)` on the Bottom Navigation bar to allow the task list to softly bleed through, making the app feel like a single cohesive environment rather than fragmented sections.

---

## 5. Components

### Floating Action Button (FAB)
*   **Style:** Extended FAB (Rounded `xl` - 1.5rem). 
*   **Visual:** Gradient fill (`primary` to `primary_container`). 
*   **Placement:** Offset from the bottom-right corner by 24px to maintain asymmetrical balance.

### Bottom Navigation
*   **Surface:** Semi-transparent `surface-container-lowest` with backdrop blur.
*   **Indicators:** Use a simple dot or a subtle `primary_fixed` glow—avoid heavy containers around icons.

### Chip-style Tags
*   **Construction:** Use `md` (0.75rem) roundedness. 
*   **Interaction:** Active chips should use a `secondary_fixed` background with `on_secondary_fixed` text. Inactive chips use a `surface-variant` with no border.

### Input Fields & Tasks
*   **Forbid Dividers:** Do not use lines between tasks in a list. Use `8px` or `12px` of vertical white space.
*   **State:** When a task is "Checked," don't just add a strikethrough. Change the container to `surface-dim` and drop the opacity of the text to 40%. It should visually "recede" into the background.

### Cards
*   **Corner Radius:** Consistently use `xl` (1.5rem) for main task cards and `lg` (1rem) for nested elements.

---

## 6. Do’s and Don’ts

### Do:
*   **Use Asymmetry:** Place your main headline high and left. Place the "Add Task" FAB lower and right.
*   **Trust the Spacing:** If a screen feels cluttered, increase the white space between sections rather than adding a divider line.
*   **Use Tonal Transitions:** Use `surface_container_high` for headers that need to feel "sticky" during scroll.

### Don’t:
*   **Don't Use Pure Black Shadows:** This kills the "premium" feel. Always use low-opacity, tinted shadows.
*   **Don't Use Standard 1px Borders:** This is the hallmark of "out-of-the-box" UI. Rely on color shifts.
*   **Don't Crowded the Corners:** Give your text at least 24px of horizontal padding from the edge of the screen to maintain the editorial look.
*   **Don't Over-Color:** Use the `primary` and `secondary` colors as "signals" for action and success. The rest of the UI should remain neutral and sophisticated.