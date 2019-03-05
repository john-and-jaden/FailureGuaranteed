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

Each attribute will have a standard value that will be scaled based on some curve.
- Standard Curve (Min 1/10; Mid 1; Max 4)
- Reverse Curve (Min 4; Mid 1; Max 1/10)
#### Movement
- Forward Speed (Min 0; Mid 6; Max 15)
- Rotation Speed
#### Vision
- Attack Vision Distance
- Attack Vision Angle
- Patrol Vision Length
- Proximity Detection Radius
- Heat Vision Length
- Heat Sense Threshold
#### Offense (DIFFERENT FOR ATTACK/TRACK/PATROL)
- Bullet damage
- Bullet speed
- Shoot coolDown
#### Defense
- Health
- Size

## quota-ness of different attributes

- Non quota means that maxing out the attribute is not necessarily the best strategy for the enemy (example: in tracking mode, the enemy might want to be slow enough to follow the heat trail)
- Quota means that maxing it out would always be the best strategy for the enemy (example: having more health is always good for the enemy)

|                            |   Patrol  |  Tracking | Attacking |
|----------------------------|:---------:|----------:|-----------|
| forwardSpeed               | non-quota | non-quota | non-quota |
| rotationSpeed              | non-quota | quota     | quota     |
| forward vision length      | quota     | quota     | quota     |
| proximity detection radius | quota     | quota     | quota     |
| heat sense threshold       | quota     | quota     | quota     |
| shootCooldown              | quota     | quota     | quota     |
| health                     | quota     | quota     | quota     |
