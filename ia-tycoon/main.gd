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
@onready var freelancer_label = $ScrollContainer/VBoxContainer/FreelancerLabel


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
var freelancer

# ==========================
# INICIO FUNCOES
# ==========================

func _ready():
	load_upgrades()
	mouse = get_upgrade("mouse")
	gpu = get_upgrade("gpu")
	notebook = get_upgrade("notebook")
	freelancer = get_upgrade("freelancer")
	# print(upgrades)
	update_ui()

func _process(delta):
	tokens += auto_production * delta
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
	freelancer_label.text = get_upgrade_text(freelancer)

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


func _on_buy_freelancer_button_pressed():
	buy_upgrade(freelancer)

func save_game():
	pass
	
func load_game():
	pass
