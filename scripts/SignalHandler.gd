extends Node

signal MoveForwadPressed(value: int);
signal MoveBackwardPressed(value: int);
signal MoveLeftPressed(value: int);
signal MoveRigthPressed(value: int);
signal SprintPressed();
signal SprintReleased();
signal CouchPressed();
signal CouchReleased();

signal InputDirChanged(input_dir: Vector2);

signal JumpPressed();

