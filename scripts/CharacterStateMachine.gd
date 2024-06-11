class_name CharacterStateMachine
extends Component

@export var char_mov_component: CharacterMovement;

var current_state: Enums.BaseState = Enums.BaseState.IDLE;

var can_jump: bool = true;

func _ready():
	assert(main_actor is CharacterBody3D, "This component must be assigned to a Node of type CharacterBody3D");
	assert(char_mov_component != null, "A Character Movement Component must be provided");
	SignalHandler.JumpPressed.connect(OnJumpPressed);
	SignalHandler.InputDirChanged.connect(OnInputDirChanged);
	SignalHandler.SprintPressed.connect(OnSprintPressed);
	SignalHandler.SprintReleased.connect(OnSprintReleased);
	SignalHandler.CouchPressed.connect(OnCouchPressed);
	SignalHandler.CouchReleased.connect(OnCouchReleased);

func _physics_process(delta):
	match current_state:
		Enums.BaseState.IDLE:
			idle_state(delta);
			current_state = check_idle_state();
			
		Enums.BaseState.WALK:
			walk_state(delta);
			current_state = check_walk_state();
			
		Enums.BaseState.SPRINT:
			sprint_state(delta);
			current_state = check_sprint_state();
			
		Enums.BaseState.COUCH:
			couch_state(delta);
			current_state = check_couch_state();
			
		Enums.BaseState.JUMP:
			jump_state(delta);
			current_state = check_jump_state();
			
		Enums.BaseState.STUN:
			pass
		Enums.BaseState.DIE:
			pass
		

func idle_state(delta):
	char_mov_component.ApplyGravity(delta);

func check_idle_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if char_mov_component.input_dir != Vector2.ZERO:
		new_state = Enums.BaseState.WALK;
	
	return new_state;

func walk_state(delta):
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.GetDirectionFromInput(),delta);
	char_mov_component.RotateCharacter(delta);

func check_walk_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if char_mov_component.main_actor.velocity == Vector3(0, 0, 0):
		new_state = Enums.BaseState.IDLE;
	
	if char_mov_component.move_speed_modifier > 0.0:
		new_state = Enums.BaseState.SPRINT;
	
	if char_mov_component.move_speed_modifier < 0.0:
		new_state = Enums.BaseState.COUCH;
	
	return new_state;

func sprint_state(delta):
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.GetDirectionFromInput(),delta);
	char_mov_component.RotateCharacter(delta);

func check_sprint_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if char_mov_component.move_speed_modifier == 0.0:
		new_state = Enums.BaseState.IDLE;
	
	return new_state;


func couch_state(delta) -> void:
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.GetDirectionFromInput(),delta);
	char_mov_component.RotateCharacter(delta);

func check_couch_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if char_mov_component.move_speed_modifier == 0.0:
		new_state = Enums.BaseState.IDLE;
	
	return new_state;

func jump_state(_delta):
	char_mov_component.Jump();

func check_jump_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if main_actor.is_on_floor():
		new_state = Enums.BaseState.IDLE;
	
	return new_state;

func OnInputDirChanged(new_input_dir: Vector2) -> void:
	char_mov_component.input_dir = new_input_dir;
	
func OnSprintPressed() -> void:
	char_mov_component.ApplySprint();

func OnSprintReleased() -> void:
	char_mov_component.DisableSprint();

func OnCouchPressed() -> void:
	char_mov_component.ApplyCouch();
	
func OnCouchReleased() -> void:
	char_mov_component.DisableCouch();
	
func OnJumpPressed() -> void:
	if can_jump:
		current_state = Enums.BaseState.JUMP;
