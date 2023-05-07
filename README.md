# PlatformerController2D

A 2D platformer class for godot.

## Changelog

### Version 2.0.2

- Fixed bug where falling off a cliff would give an extra jump

- Fixed bug where setting coyote_time or jump_buffer to 0 would raise an error

- Added ground_jump and double_jump functions

- Added separate functions for starting the jump_buffer or coyote timers and checking if they are running

### Version 2.0.1

- Removed the .godot and .import folders from the repository

### Version 2.0

- Updated to Godot 4.0
  
  - Removed set and get functions in favour of properties

- Can now have negative jump height, which will reverse gravity

- Gravity is now positive when pointing down, and negative when pointing up

- Added 'jumped' and 'hit_ground' signals

- Split the large `_physics_process` function into multiple functions

### Version 1.0.1

- Updated to Godot 3.4
- Fixed division by zero error when changing min jump height
- Other minor fixes

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

| <img src="https://github.com/Ev01/PlatformerController2D/raw/assets/jumping.GIF" width="500"> | <img src="https://github.com/Ev01/PlatformerController2D/raw/assets/jump_duration.GIF" width="500"> | <img src="https://github.com/Ev01/PlatformerController2D/raw/assets/jump_height.GIF" width="500"> |
| --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |

## Customization / Export variables

Here are the values that you can change in the inspector:

### max_jump_height

The max jump height in pixels. You reach this when you hold down jump.

### Min Jump Height

The minimum jump height (tapping jump).

### Double Jump Height

The height of your jump in the air (i.e. double jump, triple jump etc.).

### Jump Duration

How long it takes to get to the peak of the jump (in seconds).

### Falling Gravity Multiplier

Multiplies the gravity by this while falling.

### Max Jump Amount

How many times you can jump before hitting the ground. Set this to 2 for a double jump.

### Max Acceleration

How much you accelerate when you hold left or right (in pixels/sec^2).

### Friction

The higher this number, the more friction is on your character.

### Can Hold Jump

If this is off, you have to press jump down every time you land. If its on you can keep it held.

### Coyote Time

You can still jump this many seconds after falling off a ledge.

### Jump Buffer

Pressing jump this many seconds before hitting the ground will still make you jump.\
Note: This is only needed when can_hold_jump is off.

### Input Variables

`input_left`\
`input_right`\
`input_jump`\
 Set these to the names of your actions in the Input Map
