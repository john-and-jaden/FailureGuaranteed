## Player
- Movement in 4 directions using arrow keys
- Shooting in any direction based on mouse position

### Heat Trails
- Player has a "heat" trail of small fading objects
- Each heat trail has a heat level that decreases over time
- Trail is destroyed when heat level is 0
- Enemies can only detect heat trail if the heat level is greater than their heat-sense threshold
- Trails store a reference to the next heat trail

## Enemy
- Spawn in waves of enemies
- Has a forward-facing direction used for bullets, movement and vision
- Each enemies' stats and patterns are changed each wave
- Visible stats (health, damage)???
### Attacking State
- Rotate in direction of player (FIGURE THIS OUT)
- Preset tracking speed

### Tracking State
- This is for following heat trails of the player
- A heat trail is "found" when the enemy collides with it
- Rotate in direction of next trail position
- Only track next position if heat level > heat sense threshold

### Patrol State
- PVector using rotate() for rotation and scaling by some movementSpeed
- On touching a wall: invert the x or y of the vector

### Attributes to Randomize
#### Movement
- Movement Speed (+/- is direction, -max to +max, distance/second)
- Rotation Speed (+/- is direction, -max to +max, angle/second)
#### Vision
- Forward Vision Length (0 to max, distance)
- Proximity Detection Radius (0 to max, distance)
- Heat Sense Threshold (0 to max, heat level)
#### Offense (DIFFERENT FOR ATTACK/TRACK/PATROL)
- Bullet damage
- Bullet speed
- Attack rate
#### Defense
- Health


## quota-ness of different attributes

- Non quota means that maxing out the attribute is not necessarily the best strategy for the enemy
- Quota means that maxing it out would always be the best strategy for the enemy

|               | Patrol | Tracking | Attacking |
|---------------|:------:|---------:|-----------|
| forwardSpeed  |        |          |           |
| rotationSpeed |        |          |           |
| shootCooldown |        |          |           |
