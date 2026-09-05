extends Node

## Группа для игрока
var _player: Node2D

## Группа для врагов
var _enemies: Array[Node]


func _ready() -> void:
	"""Инициализация менеджера ходов."""
	# Добавляем в группу turn_manager
	add_to_group("turn_manager")
	
	# Находим игрока
	_player = get_tree().get_first_node_in_group("player")
	
	# Получаем всех врагов
	_enemies = get_tree().get_nodes_in_group("enemies")


func on_player_turn_complete() -> void:
	"""Вызывается после завершения хода игрока."""
	# Запускаем ход всех врагов
	for enemy in _enemies:
		if enemy and is_instance_valid(enemy) and enemy.has_method("make_turn"):
			enemy.make_turn()
