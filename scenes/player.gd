extends CharacterBody3D

@onready var head = $Head
@onready var standing_mesh = $StandingMesh
@onready var standing_collision_shape = $StandingCollisionShape

@onready var crouching_mesh = $CrouchingMesh
@onready var crouching_collision_shape = $CrouchingCollisionShape


# Get the gravity from the project settings to be synced with RigidBody nodes.
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")
const JUMP_VELOCITY: float = 4.5
const WALKING_SPEED: float = 5.0
const SPRINTING_SPEED: float = 8.0
const CROUCHING_SPEED: float = 3.0
const LERP_SPEED: float = 10
const MOUSE_SENSITIVTY: float = 0.1
const CROUCHING_DEPTH = 0.3

var direction = Vector3.ZERO
var current_speed = 5.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVTY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVTY))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
func _physics_process(delta: float):	
	handle_character_properties(delta)

	handle_gravity(delta)
	handle_character_movement(delta)
	
	move_and_slide()

func handle_gravity(delta: float) -> void: 
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

func handle_character_properties(delta: float) -> void:

	
	if Input.is_action_pressed("sprint"):
		current_speed = SPRINTING_SPEED
		enable_standing_model()
		set_default_head_position(delta)
		
		
	elif Input.is_action_pressed("crouch"):
		current_speed = CROUCHING_SPEED
		enable_crouching_model()
		head.position.y = lerp(head.position.y, 0.6 - CROUCHING_DEPTH, delta * LERP_SPEED)
		
		
	else :
		current_speed = WALKING_SPEED
		enable_standing_model()
		set_default_head_position(delta)
		
func set_default_head_position(delta: float) -> void:
	head.position.y = lerp(head.position.y, 0.6, delta * LERP_SPEED)

func enable_crouching_model() -> void:
	standing_collision_shape.disabled = true
	standing_mesh.visible = false
	crouching_collision_shape.disabled = false
	crouching_mesh.visible = true
	
func enable_standing_model() -> void:
	standing_collision_shape.disabled = false
	standing_mesh.visible = true
	crouching_collision_shape.disabled = true
	crouching_mesh.visible = false

func handle_character_movement(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * LERP_SPEED)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
