class_name InputHandler
extends Component

@export var can_input: bool = true;

func _input(event):
	if can_input == false:
		return;
	
	if event.is_action_pressed("Jump"):
		SignalHandler.JumpPressed.emit();
	
	if event.is_action_pressed("Couch") and !Input.is_action_pressed("Sprint"):
		SignalHandler.CouchPressed.emit();
		
	if event.is_action_released("Couch"):
		SignalHandler.CouchReleased.emit();
		
	if event.is_action_pressed("Sprint") and !Input.is_action_pressed("Couch") :
		SignalHandler.SprintPressed.emit();
		
	if event.is_action_released("Sprint"):
		SignalHandler.SprintReleased.emit();

func _physics_process(_delta):
	if can_input == false:
		return;
		
	var input_dir = Input.get_vector("MoveLeft", "MoveRigth", "MoveFront", "MoveBack");
	
	SignalHandler.InputDirChanged.emit(input_dir);
	
	
