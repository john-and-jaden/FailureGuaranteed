## Player
- Movement in 4 directions using arrow keys
- Shooting in any direction based on mouse position
- Player has a "heat" trail of small fading objects

## Enemy
- Spawn in waves of "x" number of enemies
- Has a forward-facing direction used for bullets and vision
- Each enemies' stats and patterns are changed each wave
- Visible stats (health, damage)???
### Tracking
- Rotate in direction of player (FIGURE THIS OUT)
- Preset tracking speed

### Movement
- PVector using rotate() for rotation and scaling by some movementSpeed
- On touching a wall: invert the x or y of the vector

### Attributes to Randomize
#### Movement
- Movement Speed (+/- is direction)
- Rotation Speed (+/- is direction)
#### Vision
- Long forward line vision
- Proximity vision
- Heat tracing (turn in direction of increasing heat)
#### Offense (SEPARATE TRACKING/PATROL)
- Bullet damage
- Bullet speed
- Attack rate
#### Defense
- Health
