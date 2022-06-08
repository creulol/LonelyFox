extends Node

export(int) var vida_max = 1 setget set_max_health
var vida = vida_max setget set_vida

signal sem_vida
signal health_changed(value)
signal max_health_changed(value)

func set_max_health(value):
	vida_max = value
	self.vida = min(vida, vida_max)
	emit_signal("max_health_changed", vida_max)

func set_vida(valor):
	vida = valor
	emit_signal("health_changed",vida)
	if vida <= 0:
		emit_signal("sem_vida")
		
func _ready():
	self.vida = vida_max
