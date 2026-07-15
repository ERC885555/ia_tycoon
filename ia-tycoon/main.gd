extends Control

# ==========================
# REFERENCES
# ==========================

@onready var tokens_label = $ScrollContainer/VBoxContainer/TokensLabel
@onready var click_label = $ScrollContainer/VBoxContainer/ClickLabel
@onready var production_label = $ScrollContainer/VBoxContainer/ProductionLabel

@onready var mouse_label = $ScrollContainer/VBoxContainer/MouseLabel
@onready var gpu_label = $ScrollContainer/VBoxContainer/GpuLabel
@onready var notebook_label = $ScrollContainer/VBoxContainer/NotebookLabel
@onready var servidor_label = $ScrollContainer/VBoxContainer/ServidorLabel

# ==========================
# FEATURES
# ==========================

var autosave_timer = 0.0

# ==========================
# PLAYER STATS
# ==========================

var tokens: float = 0
var click_power: float = 1
var auto_production: float = 0

# ==========================
# UPGRADES
# ==========================

var upgrades = {}

var mouse
var gpu
var notebook
var servidor

# ==========================
# INICIO FUNCOES
# ==========================

func _ready():
	load_upgrades()
	mouse = get_upgrade("mouse")
	gpu = get_upgrade("gpu")
	notebook = get_upgrade("notebook")
	servidor = get_upgrade("servidor")
	# print(upgrades)
	load_game()
	update_ui()

func _process(delta):
	tokens += auto_production * delta
	autosave_timer += delta
	if autosave_timer >= 10:
		save_game()
		autosave_timer = 0
	update_ui()

func _on_train_button_pressed():
	tokens += click_power
	update_ui()

func update_ui():
	tokens_label.text = "Tokens: " + str(snapped(tokens, 0.1))
	click_label.text = "Por Clique: " + str(click_power)
	production_label.text = "Produção: " + str(auto_production) + "/s"
	gpu_label.text = get_upgrade_text(gpu)
	mouse_label.text = get_upgrade_text(mouse)
	notebook_label.text = get_upgrade_text(notebook)
	servidor_label.text = get_upgrade_text(servidor)

func load_upgrades():
	var file = FileAccess.open(
		"res://data/upgrades.json",
		FileAccess.READ
	)
	var json_text = file.get_as_text()
	# print(json_text)
	# print(upgrades)
	upgrades = JSON.parse_string(json_text)

func format_number(value):
	if value >= 1000000000000:
		return str(snapped(value / 1000000000000.0, 0.01)) + "T"
	if value >= 1000000000:
		return str(snapped(value / 1000000000.0, 0.01)) + "B"
	if value >= 1000000:
		return str(snapped(value / 1000000.0, 0.01)) + "M"
	return str(int(value))

func can_buy(cost):
	return tokens >= cost

func buy_upgrade(upgrade):
	if not can_buy(upgrade.cost):
		return
	tokens -= upgrade.cost
	upgrade.owned += 1
	if upgrade.type == "click":
		click_power += upgrade.value
	if upgrade.type == "production":
		auto_production += upgrade.value
	upgrade.cost *= upgrade.multiplier
	update_ui()

func get_upgrade(id):
	return upgrades[id]

func get_upgrade_text(upgrade):
	var text = ""
	text += upgrade.name
	text += "\n" + upgrade.description
	text += "\nCusto: " + str(int(upgrade.cost))
	text += "\nPossui: " + str(upgrade.owned)
	if upgrade.type == "click":
		text += "\n+" + str(upgrade.value) + " Clique"
	if upgrade.type == "production":
		text += "\n+" + str(upgrade.value) + " Produção/s"
	return text

func _on_buy_gpu_button_pressed():
	buy_upgrade(gpu)

func _on_buy_mouse_button_pressed():
	buy_upgrade(mouse)

func _on_buy_notebook_button_pressed():
	buy_upgrade(notebook)


func _on_buy_servidor_button_pressed():
	buy_upgrade(servidor)

func save_game():
	var save_data = {
		"tokens": tokens,
		"click_power": click_power,
		"auto_production": auto_production,
		"upgrades": upgrades
	}
	var file = FileAccess.open(
		"user://save.json",
		FileAccess.WRITE
	)
	file.store_string(
		JSON.stringify(save_data)
	)
	print("Jogo salvo!")

	
func load_game():
	if not FileAccess.file_exists(
		"user://save.json"
	):
		return
	var file = FileAccess.open(
		"user://save.json",
		FileAccess.READ
	)
	var data = JSON.parse_string(
		file.get_as_text()
	)
	if data == null:
		return
	tokens = data["tokens"]
	click_power = data["click_power"]
	auto_production = data["auto_production"]
	upgrades = data["upgrades"]
	mouse = get_upgrade("mouse")
	gpu = get_upgrade("gpu")
	notebook = get_upgrade("notebook")
	servidor = get_upgrade("servidor")
	print("Jogo carregado!")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
