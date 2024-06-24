class_name EnvironmentChecker
extends Component

@export var ray_offset: Vector3;
@export var ray_length: float;
@export_flags_3d_physics var layer_mask: int;



func _physics_process(delta):
	CheckObstacle();
	

func CheckObstacle() -> void:
	var space_state: PhysicsDirectSpaceState3D = main_actor.get_world_3d().direct_space_state;
	var ray_origin: Vector3 = main_actor.global_position + ray_offset;
	
	var query: PhysicsRayQueryParameters3D  = PhysicsRayQueryParameters3D.create(ray_origin,ray_origin + (main_actor.global_transform.basis.z * -1)  * ray_length  
		,layer_mask, [main_actor]);
	var result: Dictionary = space_state.intersect_ray(query);
	
		
	if not result.is_empty():
		$"../MeshInstance3D".global_position = ray_origin + (main_actor.global_transform.basis.z * -1) * ray_length ;
		print(result)

