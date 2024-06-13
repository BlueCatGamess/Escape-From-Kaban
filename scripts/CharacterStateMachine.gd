class_name CharacterStateMachine
extends Component

@export var char_mov_component: CharacterMovement;
@export var anim_tree: AnimationTree;
var state_machine: AnimationNodeStateMachinePlayback ;
var state_machine2: AnimationNodeStateMachinePlayback ;
var current_state: Enums.BaseState = Enums.BaseState.IDLE;
var current_posture_state: Enums.PostureState = Enums.PostureState.STAND;

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
	state_machine2 = anim_tree["parameters/FALL/playback"];

func _physics_process(delta):
	if main_actor.velocity.y < 0.0:
		anim_tree.set("parameters/conditions/Falling",true);
	else:
		anim_tree.set("parameters/conditions/Falling",false);
		state_machine2.travel("Landing");
	match current_state:
		Enums.BaseState.IDLE:
			idle_state(delta);
			current_state = check_idle_state();
			change_posture_state()
			
		Enums.BaseState.MOVE:
			move_state(delta);
			current_state = check_move_state();
			change_posture_state()
			
		Enums.BaseState.SPRINT:
			sprint_state(delta);
			current_state = check_sprint_state();
			change_posture_state()
			
		Enums.BaseState.JUMP:
			jump_state(delta);
			current_state = check_jump_state();
		Enums.BaseState.STUN:
			pass
		Enums.BaseState.DIE:
			pass
		

func idle_state(delta):
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.direction,delta);

func check_idle_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if !(main_actor.velocity.x <= 0.2 and main_actor.velocity.x >= -0.2) or !(main_actor.velocity.z <= 0.2 and main_actor.velocity.z >= -0.2) :
		#anim_tree.set("parameters/conditions/IdleToWalk",true);
		state_machine.travel("MOVE");
		new_state = Enums.BaseState.MOVE;
	
	return new_state;

func move_state(delta):
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.GetDirectionFromInput(),delta);
	char_mov_component.RotateCharacter(delta);

func check_move_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if (main_actor.velocity.x <= 0.2 and main_actor.velocity.x >= -0.2) and (main_actor.velocity.z <= 0.2 and main_actor.velocity.z >= -0.2):
		#anim_tree.set("parameters/conditions/WalkToIdle",true);
		state_machine.travel("IDLE");
		new_state = Enums.BaseState.IDLE;
	
	if char_mov_component.move_speed_modifier > 0.0:
		state_machine.travel("SPRINT");
		new_state = Enums.BaseState.SPRINT;
	
	
	return new_state;

func sprint_state(delta):
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.GetDirectionFromInput(),delta);
	char_mov_component.RotateCharacter(delta);

func check_sprint_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if char_mov_component.move_speed_modifier == 0.0:
		state_machine.travel("IDLE");
		new_state = Enums.BaseState.IDLE;
	
	return new_state;


func jump_state(delta):
	char_mov_component.Jump();
	char_mov_component.ApplyGravity(delta);
	char_mov_component.MoveCharacter(char_mov_component.GetDirectionFromInput(),delta);

func check_jump_state() -> Enums.BaseState:
	var new_state: Enums.BaseState = current_state;
	
	if main_actor.is_on_floor():
		state_machine.travel("IDLE");
		new_state = Enums.BaseState.IDLE;

	
	return new_state;
	

func change_posture_state() -> void:
	match current_posture_state:
		Enums.PostureState.STAND:
			anim_tree.set("parameters/IDLE/PostureTransition/transition_request","Stand");
			anim_tree.set("parameters/MOVE/PostureTransition/transition_request","Stand");
			anim_tree.set("parameters/DROP/PostureTransition/transition_request","Stand");
		Enums.PostureState.COUCH:
			anim_tree.set("parameters/IDLE/PostureTransition/transition_request","Couch");
			anim_tree.set("parameters/MOVE/PostureTransition/transition_request","Couch");
			anim_tree.set("parameters/DROP/PostureTransition/transition_request","Couch");
		Enums.PostureState.FREEHANG:
			pass
		Enums.PostureState.BRACE:
			pass

func OnInputDirChanged(new_input_dir: Vector2) -> void:
	char_mov_component.input_dir = new_input_dir;
	char_mov_component.direction =  Vector3(new_input_dir.x, 0, new_input_dir.y).normalized()
	
func OnSprintPressed() -> void:
	char_mov_component.ApplySprint();

func OnSprintReleased() -> void:
	char_mov_component.DisableSprint();

func OnCouchPressed() -> void:
	char_mov_component.ApplyCouch();
	current_posture_state = Enums.PostureState.COUCH;
	
func OnCouchReleased() -> void:
	char_mov_component.DisableCouch();
	current_posture_state = Enums.PostureState.STAND;
	
func OnJumpPressed() -> void:
	if can_jump and  main_actor.is_on_floor():
		state_machine.travel("JUMP");
		current_state = Enums.BaseState.JUMP;


