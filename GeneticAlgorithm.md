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
