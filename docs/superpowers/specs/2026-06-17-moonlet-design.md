# Moonlet Design Spec

## Overview

Moonlet is a minimal iOS app that users open once per day to watch a short animated story fragment shaped by the current lunar phase. It has no account, no social layer, no input-heavy interactions, and no content browsing mentality. The product promise is simple: each night reveals one small, emotionally resonant progression in an unfolding moonlit fable.

The app should feel quiet, cinematic, and inevitable. Users are not meant to manage anything. They arrive, witness tonight's fragment, linger for a moment, and leave with a subtle urge to return tomorrow.

## Product Goals

1. Create a daily ritual that takes 20 to 40 seconds and feels complete without feeling resolved.
2. Build anticipation through continuity, restraint, and controlled revelation rather than gamification.
3. Deliver a strong atmospheric identity through motion, pacing, sound, and sparse interface.
4. Make the lunar cycle a real storytelling system, not a decorative theme.

## Non-Goals

1. No accounts, profiles, or sync-dependent identity.
2. No social features, sharing loops, comments, likes, or messaging.
3. No content feed, episode list, or library-first navigation.
4. No task system, streak pressure, points, rewards, or collectible mechanics.
5. No branching narrative or user-authored choices in the MVP.

## Core Experience

The daily loop should be:

1. User opens the app.
2. The app fades directly into tonight's scene.
3. A 20 to 40 second animated fragment plays automatically.
4. The fragment ends on a breathing still frame with minimal metadata.
5. The user leaves.

The product should feel closer to "arriving at tonight's moonlit moment" than "opening a media app."

## Experience Principles

### 1. One Visit, One Moment

Each day should present one canonical fragment. The app must not overwhelm users with alternative pathways or visible backlog. The primary value is tonight's moment.

### 2. Reveal Less Than You Could

Every fragment should advance the story only slightly: a figure appears more clearly, a place opens, an object moves, a relationship becomes legible, or a consequence quietly lands. The user should feel forward motion without full explanation.

### 3. Interface Must Yield to Atmosphere

Controls, labels, and transitions should never feel louder than the scene itself. UI exists to frame the moment, not compete with it.

### 4. The Moon Changes Meaning

Lunar phase must affect what is visible, how motion behaves, and how much narrative information is granted. The moon phase is a storytelling grammar.

## Narrative Direction

Moonlet uses a `single-line lunar fable` structure. Each lunar cycle tells one complete poetic arc across the real lunar month, with one scene fragment per day. For authored content, the MVP should package this as 30 fragments mapped onto the live lunar cycle.

The recommended tone is `mysterious and airy`: emotionally legible, but not literal. The story should feel like a secret being uncovered by moonlight rather than a conventional serialized drama.

The narrative should center on recurring symbolic elements rather than dialogue-heavy scenes. Examples:

1. A distant figure crossing tidal flats.
2. A lantern, door, bird, or boat that changes meaning over time.
3. A shoreline, tower, garden, or flooded ruin that reveals more under brighter phases.

## Lunar Story System

The lunar cycle defines four storytelling states.

### New Moon

Purpose: concealment.

Characteristics:

1. Tight framing.
2. Low information density.
3. Slower motion with longer holds.
4. More silhouette, shadow, fog, reflection, and partial forms.

Emotional effect: uncertainty, invitation, first trace.

### Waxing Phases

Purpose: emergence.

Characteristics:

1. More of the environment becomes readable.
2. Repeated motifs begin to connect.
3. Camera motion can open slightly.
4. Character intent becomes more legible, but not explicit.

Emotional effect: curiosity, pattern recognition, approach.

### Full Moon

Purpose: near-revelation.

Characteristics:

1. Highest visual clarity.
2. Largest spatial read.
3. Most complete action within a fragment.
4. Strongest emotional or symbolic pivot in the cycle.

Emotional effect: awe, confirmation, exposure.

### Waning Phases

Purpose: consequence and echo.

Characteristics:

1. The revealed truth starts changing the world.
2. Motion becomes lighter, thinner, or more fragile.
3. Loss, departure, cost, or transformation takes focus.
4. Imagery shifts from discovery toward aftermath.

Emotional effect: melancholy, drift, return, unresolved completion.

## Story Progression Rules

To maintain anticipation:

1. Each day introduces only one meaningful progression beat.
2. Each fragment ends on a visual hook rather than a dramatic cliffhanger.
3. Hooks should be quiet but directional: a door opening, a gaze shifting, a light appearing offshore, a missing object returning, a reflected figure not matching reality.
4. The app should reward consecutive daily viewing emotionally, not mechanically.

## Information Architecture

The default product architecture should be nearly invisible.

### Entry

On open, the app should land directly in tonight's scene after a brief fade-in. There should be no mandatory home screen in the main flow.

### Playback

The fragment auto-plays immediately.

Playback UI should be minimal:

1. No visible progress bar by default.
2. No transport controls unless the user explicitly invokes them.
3. At most, a subtle dismiss gesture or tap-to-skip affordance.

### Post-Scene Rest

After playback, the scene settles into a breathing still frame. Only then may a small amount of metadata appear, such as:

1. `Night 11`
2. `Waxing Gibbous`
3. An optional one-line poetic caption

### Optional Secondary Surface

If a secondary screen exists in MVP, it should be a hidden or low-emphasis `moon calendar` view. Its purpose is reflective context, not browsing. It may show:

1. Current cycle position.
2. Previously unlocked nights as dim marks or thumbnails.
3. The sense of continuity across the month.

It must not turn the experience into a scrolling catalog.

## Visual Direction

The visual system should aim for restraint, depth, and legibility in darkness.

### Visual Traits

1. Deep night palette with silver-blue highlights, softened blacks, and selective pale contrast.
2. Large soft gradients, mist, reflection, moon glow, and low-frequency movement.
3. Sparse geometry and negative space over busy illustrative detail.
4. Recurring motifs that become more visible across the cycle.

### Composition

1. Prefer one focal action per scene.
2. Use distance and scale shifts sparingly so they feel meaningful.
3. Let empty space carry mood and anticipation.

## Motion Principles

Motion quality is central to the product and should carry more value than UI complexity.

### Motion Rules

1. Movement should feel fluid, suspended, and deliberate rather than snappy.
2. Most motion should be continuous or gently easing, not abruptly keyed.
3. Layered parallax, fog drift, reflection lag, and slow camera drift should create depth.
4. Rare sharper motions should only occur when story significance justifies them.

### Pacing

1. Start fragments with immediate atmosphere, not exposition.
2. Hold longer than a typical social video would.
3. Avoid over-editing; one to three meaningful internal beats is enough.
4. End on an image that still feels alive.

### Haptics and Sound

Sound should be optional but strongly considered in the product design:

1. Low-volume ambient bed.
2. Sparse tonal accents tied to revelation beats.
3. Haptics reserved for rare moments of contact, threshold crossing, or emotional pivot.

Silence should remain acceptable; the app must still work beautifully muted.

## Content System

The MVP content model should be structured enough to scale without overbuilding.

### Unit of Content

Each day has one `fragment` with:

1. Cycle day index.
2. Lunar phase classification.
3. Scene asset package.
4. Hook type.
5. Optional caption.

### Arc Structure

Each monthly arc includes:

1. One core symbolic conflict or longing.
2. Three to five recurring visual motifs.
3. A full-moon pivot.
4. A waning aftermath.
5. A final image that leaves emotional residue without fully closing the universe.

### Repeatability

For MVP, one authored monthly arc is enough. The system should support future arcs that can rotate monthly or seasonally without changing the core app structure.

## MVP Scope

The MVP should prove the emotional loop, not the maximum platform surface.

### Must Have

1. Automatic detection of current date and lunar phase.
2. One authored 30-fragment story arc mapped onto the current lunar cycle.
3. One fragment per day.
4. Direct-to-scene launch.
5. Minimal post-scene metadata.
6. Optional hidden moon calendar view.
7. Polished motion, transitions, and audio behavior.

### Nice to Have, Not MVP-Critical

1. Downloaded alternate arcs.
2. Localization beyond the default launch language.
3. Accessibility narration for captions.
4. Lock screen widgets or reminders.
5. Archive browsing beyond the current cycle view.

### Explicitly Out of Scope for MVP

1. Accounts and cloud sync.
2. User choice branches.
3. Social sharing layers.
4. Generative story assembly.
5. Streaks, badges, or progression systems.

## Success Criteria

The design succeeds if:

1. A new user understands the product within one launch.
2. The experience feels premium and emotionally coherent without explanation.
3. The fragment leaves a clear sense that something is still unfolding.
4. Returning tomorrow feels natural, not obligation-driven.
5. The interface is remembered less than the mood and imagery.

## Risks and Mitigations

### Risk: Too Little Happens

If fragments are too minimal, the app feels inert rather than intriguing.

Mitigation:
Each fragment must contain one clearly perceptible progression beat, even when subtle.

### Risk: Too Much Lore

If the worldbuilding becomes too explicit, the product loses elegance and ritual simplicity.

Mitigation:
Keep exposition implicit and symbol-driven. Prefer recurring imagery over explanation.

### Risk: Interface Starts Expanding

If archive, settings, and recovery flows become too prominent, the product stops feeling minimal.

Mitigation:
Protect the direct-to-scene default as a product invariant.

### Risk: Motion Looks Generic

If animation style resembles social templates or generic onboarding motion, the product loses its identity.

Mitigation:
Prioritize atmospheric depth, slow timing, and restrained choreography over quantity of animation.

## Design Invariants

These rules should remain true unless the product strategy changes:

1. The app is a daily ritual, not a content feed.
2. The current moon phase changes narrative delivery.
3. The primary interaction is watching, not controlling.
4. Anticipation comes from subtle continuation, not reward mechanics.
5. Minimalism must increase emotional focus, not strip away meaning.

## Recommended Next Step

Translate this design into an implementation plan for:

1. App architecture and scene sequencing.
2. Lunar phase calculation and fragment selection.
3. Motion system and rendering approach in SwiftUI or a hybrid animation stack.
4. Content packaging for the first 30-fragment arc.
