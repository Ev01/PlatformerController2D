extends CharacterBody2D

class_name PlatformerController2D

signal jumped(is_ground_jump: bool)


# Set these to the name of your action (in the Input Map)
## Name of input action to move left.
@export var input_left : String = "move_left"
## Name of input action to move right.
@export var input_right : String = "move_right"
## Name of input action to jump.
@export var input_jump : String = "jump"


var _max_jump_height: float = 150
## The max jump height in pixels (holding jump).
@export var max_jump_height: float: 
	get:
		return _max_jump_height
	set(value):
		_max_jump_height = value
	
		default_gravity = calculate_gravity(_max_jump_height, jump_duration)
		jump_velocity = calculate_jump_velocity(_max_jump_height, jump_duration)
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)
			

var _min_jump_height: float = 40
## The minimum jump height (tapping jump).
@export var min_jump_height: float: 
	get:
		return _min_jump_height
	set(value):
		_min_jump_height = value
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)



var _double_jump_height: float = 100
## The height of your jump in the air.
@export var double_jump_height: float:
	get:
		return _double_jump_height
	set(value):
		_double_jump_height = value
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		

var _jump_duration: float = 0.3
## How long it takes to get to the peak of the jump in seconds.
@export var jump_duration: float:
	get:
		return _jump_duration
	set(value):
		_jump_duration = value
	
		default_gravity = calculate_gravity(max_jump_height, jump_duration)
		jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)
		
## Multiplies the gravity by this while falling.
@export var falling_gravity_multiplier = 1.5
## Amount of jumps allowed before needing to touch the ground again. Set to 2 for double jump.
@export var max_jump_amount = 1
@export var max_acceleration = 4000
@export var friction = 8
@export var can_hold_jump : bool = false
## You can still jump this many seconds after falling off a ledge.
@export var coyote_time : float = 0.1
## Pressing jump this many seconds before hitting the ground will still make you jump.
## Only neccessary when can_hold_jump is unchecked.
@export var jump_buffer : float = 0.1


# not used
var max_speed = 100
var acceleration_time = 10


# These will be calcualted automatically
var default_gravity : float
var jump_velocity : float
var double_jump_velocity : float
# Multiplies the gravity by this when we release jump
var release_gravity_multiplier : float


var jumps_left : int
var holding_jump := false


var acc = Vector2()

@onready var coyote_timer = Timer.new()
@onready var jump_buffer_timer = Timer.new()


func _init():
	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	
	
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
	release_gravity_multiplier = calculate_release_gravity_multiplier(
		jump_velocity, min_jump_height, default_gravity)
		
	print("Jump velocity = ", jump_velocity)
	print("Double Jump velocity = ", double_jump_velocity)
	print("release_gravity mult = ", release_gravity_multiplier)
	print("Default gravity = ", default_gravity)


func _ready():
	add_child(coyote_timer)
	coyote_timer.wait_time = coyote_time
	coyote_timer.one_shot = true
	
	add_child(jump_buffer_timer)
	jump_buffer_timer.wait_time = jump_buffer
	jump_buffer_timer.one_shot = true


func _input(event):
	handle_input(event)


func _physics_process(delta):
	if is_feet_on_ground():
		coyote_timer.start()
	if not coyote_timer.is_stopped():
		jumps_left = max_jump_amount
	
	if can_jump():
		jump()
	
	var gravity = apply_gravity_multipliers_to(default_gravity)
	acc.y = -gravity
	
	# Apply friction
	velocity.x *= 1 / (1 + (delta * friction))
	velocity += acc * delta

	move_and_slide()


func handle_input(_event):
	acc.x = 0
	if Input.is_action_pressed(input_left):
		acc.x = -max_acceleration
	
	if Input.is_action_pressed(input_right):
		acc.x = max_acceleration
	
	if Input.is_action_just_pressed(input_jump):
		holding_jump = true
		jump_buffer_timer.start()
	if Input.is_action_just_released(input_jump):
		holding_jump = false
	
	



func can_jump() -> bool:
	if jumps_left > 0:
		# Check for ground jumps when we cannot hold jump
		if not can_hold_jump:
			if not jump_buffer_timer.is_stopped() and is_feet_on_ground():
				return true
		
		# Check for ground jumps when we can hold jump
		if can_hold_jump:
			if Input.is_action_pressed(input_jump):
				# Dont use double jump when holding down
				if is_feet_on_ground():
					return true
		
		# Check for jumps in the air
		if Input.is_action_just_pressed(input_jump):
			if not is_feet_on_ground():
				print("air jump")
				return true
	
	return false


## Same as is_on_floor(), but also returns true if gravity is reversed and you are on the ceiling
func is_feet_on_ground():
	if is_on_floor() and default_gravity <= 0:
		return true
	if is_on_ceiling() and default_gravity >= 0:
		return true
	
	return false
	


func jump():
	if jumps_left == max_jump_amount and coyote_timer.is_stopped():
		# Your first jump must be used when on the ground.
		# If your first jump is used in the air, an additional jump will be taken away.
		jumps_left -= 1
		
	if jumps_left < max_jump_amount: # If we are double jumping
		velocity.y = -double_jump_velocity
		emit_signal("jumped", false)
	else:
		velocity.y = -jump_velocity
		emit_signal("jumped", true)
	
	jumps_left -= 1
	
	coyote_timer.stop()


func apply_gravity_multipliers_to(gravity) -> float:
	
	if velocity.y * -sign(default_gravity) > 0: # If we are falling
		gravity *= falling_gravity_multiplier
	
	# if we released jump and are still rising
	elif velocity.y * -sign(default_gravity) < 0:
		if not holding_jump: 
			if not jumps_left < max_jump_amount - 1: # Always jump to max height when we are using a double jump
				gravity *= release_gravity_multiplier # multiply the gravity so we have a lower jump
	
	return gravity


## Calculates the desired gravity from jump height and jump duration.  [br]
## Formula is from [url=https://www.youtube.com/watch?v=hG9SzQxaCm8]this video[/url] 
func calculate_gravity(p_max_jump_height, p_jump_duration):
	return (-2 *p_max_jump_height) / pow(p_jump_duration, 2)


## Calculates the desired jump velocity from jump height and jump duration.
func calculate_jump_velocity(p_max_jump_height, p_jump_duration):
	return (2 * p_max_jump_height) / (p_jump_duration)


## Calculates jump velocity from jump height and gravity.  [br]
## Formula from 
## [url]https://sciencing.com/acceleration-velocity-distance-7779124.html#:~:text=in%20every%20step.-,Starting%20from%3A,-v%5E2%3Du[/url]
func calculate_jump_velocity2(p_max_jump_height, p_gravity):
	return sqrt(abs(2 * p_gravity * p_max_jump_height)) * sign(p_max_jump_height)


## Calculates the gravity when the key is released based off the minimum jump height and jump velocity.  [br]
## Formula is from [url]https://sciencing.com/acceleration-velocity-distance-7779124.html[/url]
func calculate_release_gravity_multiplier(p_jump_velocity, p_min_jump_height, p_gravity):
	var release_gravity = -pow(p_jump_velocity, 2) / (2 * p_min_jump_height)
	return release_gravity / p_gravity


## Returns a value for friction that will hit the max speed after 90% of time_to_max seconds.  [br]
## Formula from [url]https://www.reddit.com/r/gamedev/comments/bdbery/comment/ekxw9g4/?utm_source=share&utm_medium=web2x&context=3[/url]
func calculate_friction(time_to_max):
	return 1 - (2.30259 / time_to_max)


## Formula from [url]https://www.reddit.com/r/gamedev/comments/bdbery/comment/ekxw9g4/?utm_source=share&utm_medium=web2x&context=3[/url]
func calculate_speed(p_max_speed, p_friction):
	return (p_max_speed / p_friction) - p_max_speed



