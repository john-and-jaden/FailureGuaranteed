Initial Case (randomization):
 - Ordered list of stats
1. Randomize the order of the list
2. Assign numbers randomly.

Example:
Quota = 100
Max Value = 50
Remainder = 100
Unassigned = 3
Stats Circular Queue: { Health, Damage, Speed }

1. Randomize order:
{ Damage, Health, Speed }

2. Random Value for first stat: (1 -> 50)
Damage = 50
Remainder = 50
Un = 2

3. Random Value for next stat: (1 -> 49)
Health = 49
Remainder = 1
Un = 1

4. Random Value for next stat: (1 -> 1)
Speed = 1
Remainder = 0
Un = 0

So, the formula is: 
stat += rand(constrain(Remainder - Unassigned, 1, Max Value - stat))

Calculate fitness of an enemy based on the following attributes:

- Lifetime
- Damage dealt to the player
- Amount of time spent in attack state
- Amount of time spent in track state

### Creating new child
1. Calculate the relative fitness of all enemies
2. Copy stats of strongest enemy
3. Transfer stats as follows
 a. Each enemy has a chance to transfer stats based on their relative fitness
 b. Assuming the enemy does transfer their stats, get the highest and lowest stat from that enemy
 c. decrease lowest and increase highest from b. in the child by static amount
