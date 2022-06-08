extends KinematicBody2D

const playerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

export var aceleracao = 500
export var velocidade_max = 80
export var friccao = 500
export var vel_rolagem = 125

enum{
	MOVE,
	ROLL,
	ATTACK
}

var estado = MOVE
var velocidade = Vector2.ZERO
var vetor_rolagem = Vector2.DOWN
var stats = PlayerStats

onready var animacaoBlink = $BlinkAnimationPlayer
onready var animacaoPlayer = $AnimationPlayer
onready var animacaoArvore = $AnimationTree
onready var animacaoEstado = animacaoArvore.get("parameters/playback")
onready var hitEspada = $HitboxPivot/SwordHitbox
onready var hurtBox = $Hurtbox

func _ready():
	randomize()
	stats.connect("sem_vida",self,"queue_free")
	animacaoArvore.active = true
	hitEspada.knockback_vector = vetor_rolagem

func _physics_process(delta):
	match estado:
		MOVE:
			move_state(delta)

		ROLL:
			roll_state(delta)
			
		ATTACK:
			attack_state(delta)
	
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		vetor_rolagem = input_vector
		hitEspada.knockback_vector = input_vector
		animacaoArvore.set("parameters/Idle/blend_position", input_vector)
		animacaoArvore.set("parameters/Run/blend_position", input_vector)
		animacaoArvore.set("parameters/Attack/blend_position", input_vector)
		animacaoArvore.set("parameters/Roll/blend_position", input_vector)
		animacaoEstado.travel("Run")
		
		velocidade = velocidade.move_toward(input_vector * velocidade_max, aceleracao * delta)
	else:
		animacaoEstado.travel("Idle")
		velocidade = velocidade.move_toward(Vector2.ZERO, friccao * delta)

	move()
	
	if Input.is_action_just_pressed("roll"):
		estado = ROLL
	
	if Input.is_action_just_pressed("attack"):
		estado = ATTACK

func roll_state(delta):
	velocidade = vetor_rolagem * vel_rolagem
	animacaoEstado.travel("Roll")
	move()

func attack_state(delta):
	velocidade = Vector2.ZERO
	animacaoEstado.travel("Attack")
	
func move():
	velocidade = move_and_slide(velocidade)

func roll_animation_finished():
	velocidade = velocidade * 0.8
	estado = MOVE

func attack_animation_finished():
	estado = MOVE
	

func _on_Hurtbox_area_entered(area):
	stats.vida -= area.dano
	hurtBox.start_invincibility(0.6)
	hurtBox.create_hit_effect()
	var playerHurtSounds = playerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSounds)


func _on_Hurtbox_invincibility_started():
	animacaoBlink.play("Start")


func _on_Hurtbox_invincibility_ended():
	animacaoBlink.play("Stop")
