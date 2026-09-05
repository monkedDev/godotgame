extends CharacterBody2D

## Размер клетки в пикселях (по умолчанию 16)
@export var cell_size: int = 16

## Скорость плавного перемещения (пикселей в секунду)
@export var move_speed: float = 10.0

## Флаг, показывающий, может ли игрок делать новый ход
var can_move: bool = true

## Внутренний флаг для отслеживания анимации движения
var _is_moving: bool = false

## Целевая позиция для перемещения
var _target_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	"""Инициализация при запуске сцены."""
	_target_position = global_position
	can_move = true
	_is_moving = false


func _physics_process(delta: float) -> void:
	"""Обработка физики каждый кадр для плавного движения."""
	if _is_moving:
		# Плавное движение к целевой позиции
		global_position = global_position.lerp(_target_position, move_speed * delta)
		
		# Проверка достижения цели (порог 0.5 пикселя)
		if global_position.distance_to(_target_position) < 0.5:
			global_position = _target_position
			_is_moving = false
			can_move = true


func _unhandled_input(event: InputEvent) -> void:
	"""Обработка ввода для пошагового движения (одно нажатие = один шаг)."""
	# Игнорируем повторные события при зажатой клавише
	if event.echo:
		return
	
	# Обрабатываем только нажатия клавиш
	if not (event is InputEventKey) or not event.pressed:
		return
	
	# Если игрок не может двигаться или уже движется, игнорируем ввод
	if not can_move or _is_moving:
		return
	
	var direction: Vector2 = _get_direction_from_input(event.keycode)
	
	if direction != Vector2.ZERO:
		_move_in_direction(direction)
		# Помечаем событие как обработанное
		get_viewport().set_input_as_handled()


func _get_direction_from_input(keycode: Key) -> Vector2:
	"""Получение направления движения из кода клавиши."""
	match keycode:
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
	"""Перемещение игрока ровно на одну клетку в указанном направлении."""
	can_move = false
	_is_moving = true
	_target_position = global_position + direction * cell_size
