# LevelUp - Build Instructions

## Building the Game

### For Development
1. Open Godot Engine
2. Import the project by selecting `project.godot`
3. Press F5 to run the game

### For Distribution

#### Windows
1. Go to Project > Export
2. Add a new export template for Windows Desktop
3. Configure the template with:
   - Name: "LevelUp Windows"
   - Export Path: "builds/windows/LevelUp.exe"
   - Binary Format: "64 bit"
4. Click "Export Project"

#### Linux
1. Go to Project > Export
2. Add a new export template for Linux/X11
3. Configure the template with:
   - Name: "LevelUp Linux"
   - Export Path: "builds/linux/LevelUp.x86_64"
   - Binary Format: "64 bit"
4. Click "Export Project"

#### Web (HTML5)
1. Go to Project > Export
2. Add a new export template for Web
3. Configure the template with:
   - Name: "LevelUp Web"
   - Export Path: "builds/web/index.html"
4. Click "Export Project"

### Required Export Templates
- Download export templates from Godot's website
- Install them via Editor > Manage Export Templates

## Testing
- Test all builds on their respective platforms
- Verify save/load functionality works correctly
- Check performance on lower-end hardware

## Distribution
- Upload to itch.io, Steam, or other platforms
- Include README and controls information
- Package with any required redistributables
