# PlatformerController2D

A 2D platformer class for godot.

## Installation

1. Add platformer_controller.gd to your project
2. Type `extends PlatformerController2D` to the top of your script
3. Add these input mappings in your project settings (or you can change the input variables in the inspector)
    - "move_left"
    - "move_right"
    - "jump"


## Features
- Double jump
- Coyote time
- Jump buffer
- Hold jump to go higher
- Defining jump height and duration (as opposed to setting gravity and jump velocity)
- Assymetrical jumps (falling faster than rising)

## Customization / Export variables
There are many value that you can change in the inspector:


`max_jump_height`\
The max jump height in pixels. You reach this when you hold down jump.


`min_jump_height`\
The minimum jump height (tapping jump).



`double_jump_height`\
The height of your jump in the air (i.e. double jump, triple jump etc.).



`jump_duration`\
How long it takes to get to the peak of the jump (in seconds).


`falling_gravity_multiplier`\
Multiplies the gravity by this while falling.


`max_jump_amount`\
How many times you can jump before hitting the ground. Set this to 2 for a double jump.


`max_acceleration`\
How much you accelerate when you hold left or right (in pixels/sec^2).


`friction`\
The higher this number, the more friction is on your character.


`can_hold_jump`\
If this is off, you have to press jump down every time you land. If its on you can keep it held.


`coyote_time`\
You can still jump this many seconds after falling off a ledge.


`jump_buffer`\
Pressing jump this many seconds before hitting the ground will still make you jump.\
Note: This is only needed when can_hold_jump is off.


`input_left`\
`input_right`\
`input_jump`\
 Set these to the names of your actions in the Input Map
