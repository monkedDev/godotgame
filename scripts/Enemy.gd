extends CharacterBody2D

## Размер клетки в пикселях
@export var cell_size: int = 16

## Скорость плавного перемещения
@export var move_speed: float = 8.0

## Здоровье врага
@export var max_health: int = 3

## Текущее здоровье
var health: int = 3

## Флаг движения
var _is_moving: bool = false

## Целевая позиция
var _target_position: Vector2 = Vector2.ZERO

## Ссылка на игрока
var _player: Node2D

## Спрайт врага
var _sprite: Sprite2D

## Спрайт получения урона
var _damaged_texture: Texture2D

## Оригинальная текстура
var _original_texture: Texture2D


func _ready() -> void:
	"""Инициализация врага."""
	health = max_health
	_is_moving = false
	_target_position = global_position
	
	# Находим игрока
	_player = get_tree().get_first_node_in_group("player")
	
	# Получаем спрайт и текстуры
	_sprite = get_node_or_null("Sprite2D") as Sprite2D
	if _sprite:
		_original_texture = _sprite.texture
		_damaged_texture = load("res://assets/player_damaged.png")
	
	# Добавляем в группу enemies
	add_to_group("enemies")


func _physics_process(delta: float) -> void:
	"""Плавное движение к целевой позиции."""
	if _is_moving:
		global_position = global_position.lerp(_target_position, move_speed * delta)
		
		if global_position.distance_to(_target_position) < 0.5:
			global_position = _target_position
			_is_moving = false


func make_turn() -> void:
	"""Враг делает ход после игрока."""
	if not _player or _is_moving:
		return
	
	# Вычисляем направление к игроку
	var direction: Vector2 = _get_direction_to_player()
	
	if direction == Vector2.ZERO:
		return
	
	var new_position: Vector2 = global_position + direction * cell_size
	
	# Проверяем, не занято ли место другим врагом или стеной
	if _is_position_occupied(new_position):
		return
	
	# Двигаемся к игроку
	_is_moving = true
	_target_position = new_position


func _get_direction_to_player() -> Vector2:
	"""Вычисление направления к игроку."""
	if not _player:
		return Vector2.ZERO
	
	var diff: Vector2 = _player.global_position - global_position
	
	# Нормализуем направление по сетке
	var dir_x: int = 0
	var dir_y: int = 0
	
	if abs(diff.x) > cell_size / 2:
		dir_x = 1 if diff.x > 0 else -1
	
	if abs(diff.y) > cell_size / 2:
		dir_y = 1 if diff.y > 0 else -1
	
	# Выбираем основное направление (по той оси, где расстояние больше)
	if abs(diff.x) > abs(diff.y):
		return Vector2(dir_x, 0)
	elif abs(diff.y) > 0:
		return Vector2(0, dir_y)
	
	return Vector2.ZERO


func _is_position_occupied(position: Vector2) -> bool:
	"""Проверка, занята ли позиция другим врагом или игроком."""
	# Проверяем других врагов
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy != self and enemy.global_position.distance_to(position) < 1.0:
			return true
	
	# Проверяем игрока
	if _player and _player.global_position.distance_to(position) < 1.0:
		return true
	
	return false


func take_damage(amount: int) -> void:
	"""Получение урона."""
	health -= amount
	
	# Визуальный эффект получения урона
	if _sprite:
		_sprite.texture = _damaged_texture
		await get_tree().create_timer(0.2).timeout
		_sprite.texture = _original_texture
	
	# Проверяем смерть
	if health <= 0:
		die()


func die() -> void:
	"""Смерть врага."""
	remove_from_group("enemies")
	queue_free()
