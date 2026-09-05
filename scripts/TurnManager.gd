extends Node

## Группа для игрока
var _player: Node2D

## Группа для врагов
var _enemies: Array[Node]


func _ready() -> void:
	"""Инициализация менеджера ходов."""
	# Добавляем в группу turn_manager
	add_to_group("turn_manager")
	
	# Находим игрока с небольшой задержкой, чтобы все узлы успели инициализироваться
	await get_tree().process_frame
	_player = get_tree().get_first_node_in_group("player")
	
	# Обновляем список врагов
	_update_enemies()


func _update_enemies() -> void:
	"""Обновление списка врагов."""
	_enemies = get_tree().get_nodes_in_group("enemies")


func on_player_turn_complete() -> void:
	"""Вызывается после завершения хода игрока."""
	# Обновляем список врагов (некоторые могли умереть)
	_update_enemies()
	
	# Запускаем ход всех врагов по очереди
	for enemy in _enemies:
		if enemy and is_instance_valid(enemy) and enemy.has_method("make_turn"):
			enemy.make_turn()
			# Ждем завершения движения врага перед следующим
			await get_tree().create_timer(0.3).timeout
