extends CharacterBody2D

## Размер клетки в пикселях (по умолчанию 16)
@export var cell_size: int = 16

## Скорость плавного перемещения (пикселей в секунду)
@export var move_speed: float = 15.0

## Флаг, показывающий, может ли игрок делать новый ход
var can_move: bool = true

## Внутренний флаг для отслеживания анимации движения
var _is_moving: bool = false

## Целевая позиция для перемещения
var _target_position: Vector2 = Vector2.ZERO

## Ссылка на TileMapLayer для проверки коллизий
var _tile_map: TileMapLayer

## Текущее оружие игрока (None или "spear")
var current_weapon: String = ""

## Урон игрока
var damage: int = 1


func _ready() -> void:
	"""Инициализация при запуске сцены."""
	_target_position = global_position
	can_move = true
	_is_moving = false
	# Добавляем игрока в группу player
	add_to_group("player")
	# Находим TileMapLayer в сцене
	_tile_map = get_tree().get_first_node_in_group("tile_map") as TileMapLayer


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
			# Сообщаем менеджерам ходов, что ход завершен
			_notify_turn_complete()


func _unhandled_input(event: InputEvent) -> void:
	"""Обработка ввода для пошагового движения (одно нажатие = один шаг)."""
	# Игнорируем события, не являющиеся клавиатурными
	if not event is InputEventKey:
		return
	
	var key_event: InputEventKey = event as InputEventKey
	
	# Игнорируем повторные события при зажатой клавише
	if key_event.echo:
		return
	
	# Обрабатываем только нажатия клавиш
	if not key_event.pressed:
		return
	
	# Если игрок не может двигаться или уже движется, игнорируем ввод
	if not can_move or _is_moving:
		return
	
	var direction: Vector2 = _get_direction_from_input(key_event.keycode)
	
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
	var new_position: Vector2 = global_position + direction * cell_size
	
	# Проверяем столкновение со стенами
	if _is_wall_at_position(new_position):
		return
	
	# Проверяем, есть ли враг в целевой клетке
	var enemy: Node2D = _get_enemy_at_position(new_position)
	if enemy:
		# Атакуем врага вместо движения
		_attack_enemy(enemy)
		return
	
	# Проверяем, есть ли предмет (копье) в целевой клетке
	var weapon_item: Node2D = _get_weapon_at_position(new_position)
	if weapon_item:
		# Подбираем копье
		_pickup_weapon(weapon_item)
	
	# Выполняем движение
	can_move = false
	_is_moving = true
	_target_position = new_position


func _is_wall_at_position(position: Vector2) -> bool:
	"""Проверка наличия стены в указанной позиции."""
	if not _tile_map:
		return false
	
	# Преобразуем глобальную позицию в координаты тайла
	var tile_coords: Vector2i = _tile_map.local_to_map(position - global_position + _tile_map.position)
	
	# Получаем источник тайла (в Godot 4.x TileMapLayer принимает только один аргумент)
	var tile_data: TileData = _tile_map.get_cell_tile_data(tile_coords)
	if not tile_data:
		return false
	
	# Проверяем, является ли тайл стеной (по имени или custom data)
	# Здесь можно настроить проверку по custom data в TileSet
	var tile_name: String = tile_data.get_custom_data("type") if tile_data.has_custom_data("type") else ""
	return tile_name == "wall"


func _get_enemy_at_position(position: Vector2) -> Node2D:
	"""Поиск врага в указанной позиции."""
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var enemy_node: Node2D = enemy as Node2D
		if enemy_node and enemy_node.global_position.distance_to(position) < 1.0:
			return enemy_node
	return null


func _get_weapon_at_position(position: Vector2) -> Node2D:
	"""Поиск оружия в указанной позиции."""
	var weapons: Array[Node] = get_tree().get_nodes_in_group("weapons")
	for weapon in weapons:
		var weapon_node: Node2D = weapon as Node2D
		if weapon_node and weapon_node.global_position.distance_to(position) < 1.0:
			return weapon_node
	return null


func _attack_enemy(enemy: Node2D) -> void:
	"""Атака врага."""
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
	# После атаки ход завершается (игрок не двигается)
	can_move = false
	_is_moving = true
	# Сразу завершаем "анимацию" атаки
	await get_tree().create_timer(0.3).timeout
	can_move = true
	_is_moving = false
	_notify_turn_complete()


func _pickup_weapon(weapon: Node2D) -> void:
	"""Подбор оружия."""
	if weapon.has_method("pick_up"):
		weapon.pick_up(self)
	else:
		# Если метод pick_up отсутствует, просто удаляем оружие
		current_weapon = "spear"
		damage = 3
		# Меняем спрайт игрока
		var sprite: Sprite2D = get_node_or_null("Sprite2D")
		if sprite:
			sprite.texture = load("res://assets/player_spear.png")
		weapon.queue_free()


func _notify_turn_complete() -> void:
	"""Сообщение всем врагам и менеджерам о завершении хода игрока."""
	var turn_manager: Node = get_tree().get_first_node_in_group("turn_manager")
	if turn_manager and turn_manager.has_method("on_player_turn_complete"):
		turn_manager.on_player_turn_complete()
