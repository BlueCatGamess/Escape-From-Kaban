class_name CharacterStateMachine
extends Component

@export var char_mov_component: CharacterMovement;
@export var anim_tree: AnimationTree;
var state_machine: AnimationNodeStateMachinePlayback ;

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
	state_machine = anim_tree["parameters/playback"];

func _physics_process(delta):
	match current_state:
		Enums.BaseState.IDLE:
			idle_state(delta);
			current_state = check_idle_state();
			
		Enums.BaseState.MOVE:
			move_state(delta);
			current_state = check_move_state();
			
		Enums.BaseState.SPRINT:
			sprint_state(delta);
			current_state = check_sprint_state();
			
		Enums.BaseState.JUMP:
			jump_state(delta);
			current_state =  check_jump_state();
			
		Enums.BaseState.FALL:
			fall_state(delta)
			current_state = check_fall_state();
			
		Enums.BaseState.CROUCH_IDLE:
			crouch_idle_state(delta);
			current_state = check_crouch_idle_state();
			
		Enums.BaseState.CROUCH_MOVE:
			crouch_move_state(delta);
			current_state = check_crouch_move_state();
			
		Enums.BaseState.STUN:
			pass
		Enums.BaseState.DIE:
			pass
		

func idle_state(delta):
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.direction,delta);

func check_idle_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if not is_idling():
		state_machine.travel("MOVE");
		new_state = Enums.BaseState.MOVE;
		
	if is_falling():
		new_state = Enums.BaseState.FALL;
		anim_tree.set("parameters/conditions/Falling",true);
		
	if is_sprinting() and not is_idling():
		state_machine.travel("SPRINT");
		new_state = Enums.BaseState.SPRINT;
		
	if is_crouching() and is_idling():
		state_machine.travel("CROUCH_IDLE");
		new_state = Enums.BaseState.CROUCH_IDLE;
		
	if is_crouching() and is_moving():
		state_machine.travel("CROUCH_MOVE");
		new_state = Enums.BaseState.CROUCH_MOVE;
		
	return new_state;

func move_state(delta):
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.GetDirectionFromInput(),delta);
	char_mov_component.RotateCharacter(delta);

func check_move_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if is_idling():
		state_machine.travel("IDLE");
		new_state = Enums.BaseState.IDLE;
		
	if is_falling():
		anim_tree.set("parameters/conditions/Falling",true);
		new_state = Enums.BaseState.FALL;
		
	
	if is_sprinting():
		state_machine.travel("SPRINT");
		new_state = Enums.BaseState.SPRINT;
	
	if is_crouching():
		state_machine.travel("CROUCH_MOVE");
		new_state = Enums.BaseState.CROUCH_MOVE;
	
	
	return new_state;

func sprint_state(delta):
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.GetDirectionFromInput(),delta);
	char_mov_component.RotateCharacter(delta);

func check_sprint_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;

	if not is_sprinting() or is_idling() :
		state_machine.travel("SPRINT-TO-IDLE");
		new_state = Enums.BaseState.IDLE;
		
	if not is_sprinting():
		state_machine.travel("MOVE");
		new_state = Enums.BaseState.MOVE;
		
	if is_falling():
		anim_tree.set("parameters/conditions/Falling",true);
		new_state = Enums.BaseState.FALL;
	
	return new_state;


func jump_state(delta):
	char_mov_component.Jump();
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.GetDirectionFromInput(),delta);

func check_jump_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if is_falling():
		anim_tree.set("parameters/conditions/Falling",true);
		new_state = Enums.BaseState.FALL;

	
	return new_state;
	

func fall_state(delta):
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.GetDirectionFromInput(),delta);

func check_fall_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if not is_falling():
		new_state = Enums.BaseState.IDLE;
		state_machine.travel("IDLE");
		anim_tree.set("parameters/conditions/Falling",false);
	return new_state;

func crouch_idle_state(delta):
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.GetDirectionFromInput(),delta);

func check_crouch_idle_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if is_crouching() and not is_idling():
		state_machine.travel("CROUCH_MOVE");
		new_state = Enums.BaseState.CROUCH_MOVE;
		
	if !is_crouching() and is_idling():
		state_machine.travel("IDLE");
		new_state = Enums.BaseState.IDLE;
		
	if is_falling():
		new_state = Enums.BaseState.FALL;
		anim_tree.set("parameters/conditions/Falling",true);
		
	#if char_mov_component.move_speed_modifier > 0.0 and !(main_actor.velocity.x <= 0.2 and main_actor.velocity.x >= -0.2) or !(main_actor.velocity.z <= 0.2 and main_actor.velocity.z >= -0.2):
		#state_machine.travel("SPRINT");
		#new_state = Enums.BaseState.SPRINT;
		
	return new_state;
	
func crouch_move_state(delta):
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.GetDirectionFromInput(),delta);
	char_mov_component.RotateCharacter(delta);

func check_crouch_move_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if is_crouching() and is_idling():
		state_machine.travel("CROUCH_IDLE");
		new_state = Enums.BaseState.CROUCH_IDLE;
	
	if !is_crouching() and !is_idling():
		state_machine.travel("MOVE");
		new_state = Enums.BaseState.MOVE;
	
	if is_falling():
		new_state = Enums.BaseState.FALL;
		anim_tree.set("parameters/conditions/Falling",true);
		
	return new_state;

func is_crouching() -> bool:
	return char_mov_component.move_speed_modifier < 0.0;

func is_sprinting() -> bool:
	return char_mov_component.move_speed_modifier > 0.0;
	
func is_idling() -> bool:
	return (main_actor.velocity.x <= 0.2 and main_actor.velocity.x >= -0.2) and (main_actor.velocity.z <= 0.2 and main_actor.velocity.z >= -0.2);

func is_falling() -> bool:
	return main_actor.velocity.y < 0.0;
	
func is_moving() -> bool:
	return (main_actor.velocity.x <= 0.2 and main_actor.velocity.x >= -0.2) or (main_actor.velocity.z <= 0.2 and main_actor.velocity.z >= -0.2)


func OnInputDirChanged(new_input_dir: Vector2) -> void:
	char_mov_component.input_dir = new_input_dir;
	char_mov_component.direction =  Vector3(new_input_dir.x, 0, new_input_dir.y).normalized()
	
func OnSprintPressed() -> void:
	char_mov_component.ApplySprint();

func OnSprintReleased() -> void:
	char_mov_component.DisableSprint();

func OnCouchPressed() -> void:
	char_mov_component.ApplyCouch();

func OnCouchReleased() -> void:
	char_mov_component.DisableCouch();

	
func OnJumpPressed() -> void:
	if can_jump and main_actor.is_on_floor():
		state_machine.travel("JUMP");
		current_state = Enums.BaseState.JUMP;


