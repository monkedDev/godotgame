extends CharacterBody2D

## Размер клетки в пикселях
@export var cell_size: int = 16

## Текущая позиция в сетке
var grid_position: Vector2i = Vector2i.ZERO

## Флаг, движется ли игрок сейчас
var is_moving: bool = false

## Флаг наличия копья
var has_spear: bool = false

## Спрайт игрока
@onready var sprite: Sprite2D = $Sprite2D

## Текстуры
@onready var player_texture: Texture2D = preload("res://assets/player.png")
@onready var player_spear_texture: Texture2D = preload("res://assets/player_spear.png")


func _ready() -> void:
	"""Инициализация при запуске."""
	_update_grid_position()


func _unhandled_input(event: InputEvent) -> void:
	"""Обработка клика мыши для перемещения."""
	# Игнорируем события мыши, если это не клик ЛКМ
	if not (event is InputEventMouseButton):
		return
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
	
	# Если уже движемся, игнорируем ввод
	if is_moving:
		return
	
	var click_pos: Vector2 = get_global_mouse_position()
	_move_toward_click(click_pos)


func _update_grid_position() -> void:
	"""Обновление позиции в сетке на основе текущей глобальной позиции."""
	grid_position = Vector2i(global_position / float(cell_size))


func _move_toward_click(target_pos: Vector2) -> void:
	"""Перемещение на одну клетку в направлении клика."""
	var target_grid: Vector2i = Vector2i(target_pos / float(cell_size))
	
	# Не двигаемся, если уже в этой клетке
	if target_grid == grid_position:
		return
	
	# Вычисляем направление (только одна ось за раз - пошаговое движение)
	var direction: Vector2i = Vector2i.ZERO
	
	var diff_x: int = abs(target_grid.x - grid_position.x)
	var diff_y: int = abs(target_grid.y - grid_position.y)
	
	if diff_x > diff_y:
		# Движение по горизонтали
		direction.x = sign(target_grid.x - grid_position.x)
	else:
		# Движение по вертикали
		direction.y = sign(target_grid.y - grid_position.y)
	
	var next_grid: Vector2i = grid_position + direction
	var next_pos: Vector2 = Vector2(next_grid.x * cell_size, next_grid.y * cell_size)
	
	# Проверяем, есть ли копье в следующей клетке (для подбора)
	_check_and_pickup_spear(next_pos)
	
	# Запускаем движение
	is_moving = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", next_pos, 0.15).tween_completed(_on_move_completed)


func _check_and_pickup_spear(pos: Vector2) -> void:
	"""Проверка и подбор копья в указанной позиции."""
	# Ищем все узлы Spear в сцене
	var spears: Array[Node] = get_tree().get_nodes_in_group("spear")
	for spear_node in spears:
		if spear_node is Area2D:
			var spear_area: Area2D = spear_node as Area2D
			var spear_grid: Vector2i = Vector2i(spear_area.global_position / float(cell_size))
			var target_grid: Vector2i = Vector2i(pos / float(cell_size))
			
			if spear_grid == target_grid:
				_pickup_spear(spear_area)
				break


func _pickup_spear(spear: Area2D) -> void:
	"""Подбор копья."""
	has_spear = true
	if sprite:
		sprite.texture = player_spear_texture
	spear.queue_free()


func _on_move_completed() -> void:
	"""Завершение движения."""
	is_moving = false
	_update_grid_position()
