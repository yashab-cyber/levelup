# LevelUp - 2D Pixel Dungeon Crawler

A complete 2D pixel art dungeon crawler game inspired by Solo Leveling, built with Godot Engine and GDScript.

## 🎮 Game Features

### Core Gameplay
- **8-direction movement** with WASD controls
- **Random dungeon generation** with rooms, corridors, and walls
- **Combat system** with melee attacks (Space) and magic projectiles (E)
- **Enemy AI** with different behaviors (idle, patrol, chase, attack)
- **Leveling system** with XP gain and stat progression
- **Inventory management** with drag-and-drop functionality
- **Skill tree** with unlockable abilities

### Player Systems
- Health and XP bars with visual feedback
- Level-based stat increases (HP, attack power, defense)
- Equipment system (weapons and armor)
- Invincibility frames after taking damage
- Death and respawn mechanics

### Dungeon Features
- Procedurally generated levels with increasing difficulty
- Multiple enemy types with floor-based scaling
- Random loot drops (health potions, weapons, armor)
- Exit doors to progress to next floor
- Dynamic camera system

### User Interface
- Health and XP bars
- Level indicator
- Inventory screen (I key)
- Skill tree (T key)
- Pause menu (ESC key)
- Game over screen

### Items & Equipment
- **Health Potions**: Restore player health
- **Weapons**: Increase attack damage with rarity system
- **Armor**: Increase defense with different types
- **Rarity system**: Common, Uncommon, Rare, Epic, Legendary

### Skills & Abilities
- **Sword Mastery**: Increases sword damage
- **Vitality**: Increases max health
- **Dash**: Unlocks dash ability
- **Fireball**: Unlocks fireball spell
- **Critical Strike**: Chance for critical hits
- **Magic Shield**: Absorbs damage

## 🎯 Controls

- **WASD / Arrow Keys**: Move player
- **Space**: Melee attack
- **E**: Cast magic projectile
- **I**: Toggle inventory
- **T**: Toggle skill tree
- **ESC**: Pause menu

## 🏗️ Project Structure

```
LevelUp/
├── assets/
│   ├── player/          # Player sprites and animations
│   ├── enemies/         # Enemy sprites and animations
│   ├── tilesets/        # Dungeon tiles and environment
│   ├── items/           # Item and equipment sprites
│   └── ui/              # UI elements and icons
├── scenes/
│   ├── MainMenu.tscn    # Main menu scene
│   ├── Dungeon.tscn     # Main game scene
│   ├── Player.tscn      # Player character
│   ├── Enemy.tscn       # Enemy template
│   └── UI.tscn          # Game UI elements
├── scripts/
│   ├── Player.gd        # Player controller and stats
│   ├── Enemy.gd         # Enemy AI and behavior
│   ├── DungeonGenerator.gd  # Procedural generation
│   ├── Combat.gd        # Combat calculations
│   ├── Inventory.gd     # Inventory management
│   ├── GameManager.gd   # Save/load and scene management
│   └── Item.gd          # Item base class
├── sounds/
│   ├── bgm/             # Background music
│   └── sfx/             # Sound effects
└── project.godot        # Godot project configuration
```

## 🚀 Getting Started

### Prerequisites
- Godot Engine 4.3 or later
- VS Code (optional, for script editing)

### Running the Game
1. Open the project in Godot Engine
2. Set the main scene to `scenes/MainMenu.tscn`
3. Press F5 or click "Play" to run the game

### Development Setup
1. Clone this repository
2. Open in Godot Engine
3. The project is configured for pixel-perfect rendering
4. Use the provided scripts as base for further development

## 🎨 Art Style

- **Pixel art** aesthetic inspired by classic 16-bit RPGs
- **Tile-based** dungeon generation (32x32 tiles)
- **Animated sprites** for player and enemies
- **Particle effects** for magic and combat
- **Dark theme** inspired by Solo Leveling

## 🔧 Customization

### Adding New Enemies
1. Create a new scene inheriting from Enemy.tscn
2. Modify stats in the Enemy script
3. Add custom sprites and animations
4. Register in DungeonGenerator for spawning

### Creating New Items
1. Extend the Item class for new item types
2. Create corresponding scene files
3. Add to loot tables in Enemy script
4. Implement item effects in Player script

### Expanding Skills
1. Add new skill definitions in SkillTree script
2. Implement skill effects in Player script
3. Create UI elements for skill display
4. Balance skill requirements and effects

## 🎮 Game Balance

- **Health**: Base 100, +20 per level, +50 with Vitality skill
- **Attack**: Base 10, +5 per level, +25% with Sword Mastery
- **Defense**: Base 5, +2 per level, enhanced by armor
- **XP Requirements**: Exponential scaling (100 * 1.2^level)
- **Enemy Scaling**: +30% stats per floor level

## 🐛 Known Issues

- Sprite animations require actual sprite sheets to be added
- Audio system needs sound files to be implemented
- Tileset needs to be configured with actual tile graphics
- Some UI elements need visual polish

## 🔮 Future Enhancements

- **Boss fights** every 5 floors
- **Multiple dungeon themes** (fire, ice, shadow)
- **Online leaderboards** for speedruns
- **Character customization** system
- **More enemy types** and behaviors
- **Advanced skill trees** with branching paths
- **Multiplayer support**

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Feel free to submit issues, feature requests, and pull requests to improve the game!

---

**Note**: This is a complete, functional game framework. To make it fully playable, you'll need to add:
1. Sprite graphics for player, enemies, and tiles
2. Sound effects and background music
3. Additional visual polish and particle effects
4. Testing and balancing of game mechanics