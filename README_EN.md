# Breath Held Demo

2D Top-Down Action Adventure　／　Portfolio Project

---

## Overview

A 2D action-adventure game demo built with Godot 4 / GDScript, currently in development.  
Created as a portfolio piece to demonstrate engine-agnostic system design and implementation skills, with a primary focus on UE5 / C++ as my main professional stack.

| | |
|---|---|
| Engine | Godot 4 (GDScript) |
| Genre | 2D Top-Down Action Adventure |
| Development | Solo (design, implementation, and debugging handled independently) |
| Period | 2026 – present (ongoing) |

---

## Screenshots

<!-- TODO: Add screenshots here -->

---

## Implemented Systems

| System | Overview |
|---|---|
| Character Base Class | Abstract base class encapsulating shared logic for Player and Enemy |
| Component System | Component-based design allowing modular functionality to be attached to any Actor |
| Item System | Resource-based data tables with a factory class for runtime item instantiation |
| Effect System | General-purpose effect manager handling hit effects, status effects, etc. |
| Player Attribute System | Centralized management of HP, stamina, and other player stats |
| HUD / UI System | In-game HUD with real-time binding to player attributes |
| Autoload Architecture | Two-tier singleton design separating Global and InGame scopes |
| Combat System | Unified combat framework covering melee, ranged, and throwable attacks |
| Tilemap | 2D world environment including floors, obstacles, and collision |
| Enemy AI State Machine | FSM managing Idle / Chase / Attack / Dead state transitions |

---

## Design Highlights

### Component System

Components do not share a common base class — each inherits from a parent suited to its purpose, keeping the design flexible. Components are divided into two categories:

- **General-purpose components** (`Components/`): Can be attached to any Actor. Separates concerns such as attribute management, effect application, and hitbox handling into independent units.
- **AI-specific components** (`Components/AIComponents/`): Includes Sensor (player detection) and Movement (locomotion control). Works in conjunction with the AI state machine, activating only the components needed for each state.

### Item & Weapon Inheritance

```
ItemBase
├── WeaponBase
│   ├── MeleeWeaponBase
│   └── LongRangeWeaponBase   # Manages ammo loading and firing as a launcher
└── PropBase
```

`LongRangeWeaponBase` acts as a launcher, handling ammo loading and firing logic, while the instantiated projectile object manages its own trajectory.

### Two-Tier Autoload Management

```
Global (global function)
├── ResourceManager   # Loads and provides data table Resources globally
└── GameManager       # Manages scene transitions and cross-scene event broadcasting

InGame (in-game function)
├── PlayerController    # Handles player input and character control
├── PlayerDataManager   # Manages inventory, stat values, and change callbacks
├── UIManager           # Controls all in-game UI
└── SpeedManager        # Centralizes game speed adjustment
```

---

## Project Structure

```
BreathHeld/
├── Assets/          # Images, styleboxes, and other assets
├── Content/         # Scene files (.tscn)
│   ├── Actors/      # Characters, components, items
│   ├── UI/          # UI scenes
│   └── Worlds/      # Maps and world scenes
└── Source/
    ├── GDScript/    # Scripts (.gd)
    │   ├── Actors/
    │   ├── Effect/
    │   ├── System/  # Autoload (Global / InGame)
    │   └── UI/
    └── Resource/    # Data definitions (Resource / DataTable)
```

---

## Requirements & How to Run

1. Install [Godot 4](https://godotengine.org/)
2. Clone the repository
   ```bash
   git clone https://github.com/YazawaTsukasa/breath_held_demo.git
   ```
3. Open Godot and import `project.godot`
4. Press `F5` to run

---

## Roadmap (Target: August 2026)

- Save / Load system
- Quest system
- Additional enemy types and boss encounter
- UI/UX polish (animations, feedback improvements)

---

## Author

**Ichiho Kai**　／　Gameplay / Systems-Oriented Game Engineer  
UE5 / C++, Godot 4 / GDScript, UI Systems, Python / FastAPI / AWS (fundamentals)
