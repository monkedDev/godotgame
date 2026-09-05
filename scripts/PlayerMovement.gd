extends CharacterBody2D

## Скорость движения (пикселей в секунду)
@export var move_speed: float = 8.0

## Размер тайла в пикселях
const TILE_SIZE: int = 16

## Флаг, показывающий, может ли игрок двигаться (для пошаговости)
var can_move: bool = true

## Внутренний флаг для отслеживания движения
var _is_moving: bool = false

## Целевая позиция для перемещения
var _target_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	"""Инициализация при запуске сцены."""
	_target_position = global_position
	can_move = true
	_is_moving = false


func _physics_process(_delta: float) -> void:
	"""Обработка физики каждый кадр."""
	if _is_moving:
		# Плавное движение к целевой позиции
		global_position = global_position.lerp(_target_position, move_speed * _delta)
		
		# Проверка достижения цели
		if global_position.distance_to(_target_position) < 0.5:
			global_position = _target_position
			_is_moving = false
			can_move = true


func _input(event: InputEvent) -> void:
	"""Обработка ввода для пошагового движения."""
	if not can_move or _is_moving:
		return
	
	var direction: Vector2 = Vector2.ZERO
	
	if event is InputEventKey and event.pressed:
		direction = _get_direction_from_input(event)
		
		if direction != Vector2.ZERO:
			_move_in_direction(direction)


func _get_direction_from_input(event: InputEventKey) -> Vector2:
	"""Получение направления движения из нажатой клавиши."""
	match event.keycode:
		KEY_W, KEY_UP:
			return Vector2.UP
		KEY_S, KEY_DOWN:
			return Vector2.DOWN
		KEY_A, KEY_LEFT:
			return Vector2.LEFT
		KEY_D, KEY_RIGHT:
			return Vector2.RIGHT
		_:
			return Vector2.ZERO


func _move_in_direction(direction: Vector2) -> void:
	"""Перемещение игрока на одну клетку в указанном направлении."""
	can_move = false
	_is_moving = true
	_target_position = global_position + direction * TILE_SIZE
