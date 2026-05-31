# Yogi Motion Catalog

이 문서는 요기 디자인 시스템에서 transition, motion, micro-interaction을 이야기할 때 쓰는 공통 기준표입니다.
화면 쇼케이스는 `motion.html`에서 확인합니다.

## Conversation Format

모션 피드백은 아래처럼 짧게 말합니다.

```text
M02를 조금 약하게. duration은 유지하고 translateY만 24px에서 14px 정도로.
M07은 좋아. 다만 sheet overshoot은 더 줄이자.
M05는 홈에서는 과하고 빈 상태에서만 쓰자.
```

## Core Rules

- Touch feedback: 120-180ms.
- Structural transition: 320-480ms.
- Celebration feedback: 700-900ms.
- Ambient loop: one or two loops per screen at most.
- Do not animate dense text, maps, or full screens unless the transition requires it.
- Use playful motion at decision moments: discover, select, join, complete.
- Keep map motion local to pins, route, pulse, or sheet. The map itself should remain stable.

## Catalog

| ID | Name | Trigger | Duration | Intensity | Flutter Hint | Recommended Use |
| --- | --- | --- | --- | --- | --- | --- |
| M01 | Tap Squish | tap down / tap up | 120-180ms | Low | `AnimatedScale`, `AnimatedContainer` | Buttons, chips, tabs |
| M02 | Pin Bounce | marker appears / recommendation focus | 520-680ms | Medium | `AnimationController`, `Transform.translate`, `Transform.scale` | Map pins, featured locations |
| M03 | Success Pop | join/save/invite complete | 700-900ms | Medium | `OverlayEntry`, `ScaleTransition`, `FadeTransition` | Success toast, completion |
| M04 | Card Rise | list mount / refresh | 360-480ms | Low | `SlideTransition`, `FadeTransition` | Meeting cards, recommendations |
| M05 | Buddy Wiggle | mascot speech / empty state | 1.2-1.6s loop | High | `RotationTransition`, `SlideTransition` | Onboarding, empty state, mascot moments |
| M06 | Local Pulse | location scan / nearby refresh | 1.6-2.0s loop | Low | `ScaleTransition`, `FadeTransition` | Current location, scanning |
| M07 | Sheet Snap | bottom sheet open / map-to-list | 320-420ms | Low | `DraggableScrollableSheet`, custom curve | Home map/list transition |
| M08 | Chip Magnet | category selected | 220-300ms | Medium | `AnimatedAlign`, `AnimatedContainer` | Filters, segmented controls |
| M09 | Route Draw | route/course reveal | 800-1000ms | Low | `CustomPainter`, `PathMetric` | Travel detail, route preview |
| M10 | Join Stack | participant joined | 460-620ms | Medium | `AnimatedPositioned`, `ScaleTransition` | Participant stack, social proof |
| M11 | Bubble Loader | short loading | 1.0-1.3s loop | Low | staggered `ScaleTransition` | Nearby search loading |
| M12 | Empty Nudge | empty result | 600-760ms once | Low | `RotationTransition`, `Transform.translate` | Empty states |

## Default Set

The default app-wide set should be:

- `M01` for touch.
- `M02` for discovery on maps.
- `M03` for completion.
- `M07` for the home map/list transition.
- `M08` for category and filter selection.

Use `M05`, `M09`, `M10`, `M11`, and `M12` only where the screen context calls for them.
