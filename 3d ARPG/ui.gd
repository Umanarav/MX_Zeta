extends Control

@onready var healthBar = get_node("HealthBar")
@onready var goldText = get_node("GoldText")
@onready var questTitle = get_node("QuestTitle")
@onready var questDescription = get_node("QuestTitle/QuestDescription")
@onready var questTracker = get_node("QuestTitle/QuestDescription/QuestTracker")
#@onready var ability1SecondsRemainingLabel = get_node("UI/Ability1Cooldown/Ability1SecondsRemainingLabel")

# called when we take damage
func update_health_bar (curHp, maxHp):
	healthBar.value = (100 / maxHp) * curHp

# called when our gold changes
func update_gold_text (gold):
	goldText.text = "Gold: " + str(gold)
	
#func update_ability1SecondsRemainingLabel ():
	#ability1SecondsRemainingLabel.text = str(timer.get_remaining_seconds())

# called when our quest changes
func get_quest_title_text_1 ():
	questTitle.text = "McGuffin Quest"
	questDescription.text = "Collect McGuffins"
func update_quest_title_text_1 (McGuffins):
	questTracker.text = str(McGuffins) + "/5"
func complete_quest_title_text_1 ():
	questTitle.text = ""
	questDescription.text = ""
