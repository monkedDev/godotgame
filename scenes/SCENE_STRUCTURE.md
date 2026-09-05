# Структура главной сцены (MainScene.tscn)

## Иерархия узлов:

```
MainScene (Node2D)
├── TileMapLayer (TileMapLayer)
│   └── [TileSet ресурс с тайлами 16x16]
└── Player (CharacterBody2D)
    ├── Sprite (Sprite2D)
    │   └── texture: [спрайт игрока]
    ├── CollisionShape2D (CollisionShape2D)
    │   └── shape: RectangleShape2D (16x16)
    └── script: PlayerMovement.gd
```

## Описание узлов:

### 1. MainScene (Node2D)
- Корневой узел сцены
- Содержит все игровые объекты

### 2. TileMapLayer (TileMapLayer)
- Слой для отрисовки тайловой карты
- Используется для статических объектов: пол, стены, декорации
- Требует настроенный TileSet ресурс
- **Настройки TileSet:**
  - Размер тайла: 16x16 пикселей
  - Separation: 1x1 пиксель (для спрайтлистов Kenney)

### 3. Player (CharacterBody2D)
- Узел игрока с физикой CharacterBody2D
- Начальная позиция: (0, 0) или любая другая
- Подключён скрипт PlayerMovement.gd

#### Дочерние узлы Player:

**Sprite (Sprite2D)**
- Отображает визуальное представление игрока
- texture: ссылка на спрайт из Kenney Pack

**CollisionShape2D (CollisionShape2D)**
- Определяет область коллизии игрока
- shape: RectangleShape2D размером 16x16 пикселей

---

## Как использовать:

1. Откройте `scenes/MainScene.tscn` в редакторе Godot
2. Для TileMapLayer настройте TileSet согласно инструкции в IMPORT_INSTRUCTIONS.md
3. Для игрока выберите подходящий спрайт в узле Sprite
4. Настройте CollisionShape2D (размер 16x16)
5. Запустите сцену и управляйте игроком через WASD или стрелочки
