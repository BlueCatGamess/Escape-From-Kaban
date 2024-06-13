class_name CharacterMovement
extends Component

var move_speed_modifier: float = 0.0;

var input_dir: Vector2  = Vector2.ZERO;
var direction: Vector3 = Vector3.ZERO;

func _ready():
	assert(main_actor is CharacterBody3D, "This component must be assigned to a Node of type CharacterBody3D");


func GetDirectionFromInput() -> Vector3:
	direction =  Vector3(input_dir.x, 0, input_dir.y).normalized()
	return direction
	

func MoveCharacter(move_direction: Vector3, delta: float) -> void:
	if main_actor.is_on_floor():
		if move_direction != Vector3.ZERO:
			main_actor.velocity.x = lerp(main_actor.velocity.x, move_direction.x * (Constants.SPEED + (Constants.SPEED * move_speed_modifier)), 7.0 * delta)
			main_actor.velocity.z = lerp(main_actor.velocity.z, move_direction.z * (Constants.SPEED + (Constants.SPEED * move_speed_modifier)), 7.0 * delta)
		else:
			main_actor.velocity.x = lerp(main_actor.velocity.x, move_direction.x * (Constants.SPEED + (Constants.SPEED * move_speed_modifier)), 11.0 * delta)
			main_actor.velocity.z = lerp(main_actor.velocity.z, move_direction.z * (Constants.SPEED + (Constants.SPEED * move_speed_modifier)), 11.0 * delta)
			
	main_actor.move_and_slide()


func RotateCharacter(delta: float) -> void:
	main_actor.rotation.y = lerp_angle(main_actor.rotation.y, atan2(-main_actor.velocity.x, -main_actor.velocity.z), delta * 15)
	
func Jump() -> void:
	if main_actor.is_on_floor():
		main_actor.velocity.y = Constants.JUMP_VELOCITY;

func ApplyGravity(delta:float) -> void:
	if not main_actor.is_on_floor():
		main_actor.velocity.y -= Constants.GRAVITY * delta;

func ApplySprint() -> void:
	move_speed_modifier = Constants.SPRINT_FORCE;

func DisableSprint() -> void:
	move_speed_modifier = 0.0;

func ApplyCouch() -> void:
	move_speed_modifier = Constants.COACH_FORCE;

func DisableCouch() -> void:
	move_speed_modifier = 0.0;
