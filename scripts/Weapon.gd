extends Area2D

## Тип оружия (по умолчанию "spear")
@export var weapon_type: String = "spear"

## Урон, который дает это оружие
@export var damage_bonus: int = 2

## Спрайт предмета
var _sprite: Sprite2D


func _ready() -> void:
	"""Инициализация предмета."""
	# Добавляем в группу weapons
	add_to_group("weapons")
	
	# Получаем спрайт
	_sprite = get_node_or_null("Sprite2D") as Sprite2D
	
	# Настраиваем зону столкновения
	collision_layer = 1
	collision_mask = 1
	
	# Подключаемся к сигналу body_entered
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	"""Обработка входа игрока в зону оружия."""
	if body.is_in_group("player"):
		pick_up(body)


func pick_up(player: Node2D) -> void:
	"""Подбор оружия игроком."""
	if player.has_method("_pickup_weapon"):
		# Вызываем метод подбора у игрока
		player._pickup_weapon(self)
	
	# Удаляем предмет с карты
	queue_free()
