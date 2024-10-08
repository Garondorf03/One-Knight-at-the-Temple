extends CharacterBody2D

# ANIMATED_SPRITE_2D REFERENCE
@onready var playerSprite = $PlayerSprite

# MOVEMENT CONSTANTS
const speed = 130.0
const jumpVelocity = -300.0

# VARIABLES
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var isAttacking: bool = false
var direction = Input.get_axis("move_left", "move_right")
var enemy = null
var enemyInAttackRange = false
var enemyAttackCooldown = true
var health = 200
var playerAlive = true

func player():
	pass

func _physics_process(delta):
	
	# GET DIRECTION OF SPRITE
	direction = Input.get_axis("move_left", "move_right")
	
	walk()
	jump(delta)
	attack()
	idle()
	flipSprite()
	enemyAttacksPlayer()
	checkToKillPlayer()
	updateHealth()
		
	# STOPS PLAYER FROM SLIDING WHILST ATTACKING
	if not isAttacking:
		move_and_slide()
		
func walk():
	if isAttacking == false:
		if direction > 0 || direction < 0:
			playerSprite.play("run")
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
func idle():
	if direction == 0 and isAttacking == false and is_on_floor():
		playerSprite.play("idle")
		
func jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpVelocity
	if not is_on_floor():
		playerSprite.play("jump")
	if not is_on_floor():
		velocity.y += gravity * delta
		
func attack():
	if Input.is_action_just_pressed("attack") and is_on_floor():
		Global.isPlayerAttacking = true
		isAttacking = true
		playerSprite.play("attack")
		$dealAttackCooldown.start()
		await playerSprite.animation_finished
		
func flipSprite():
	if direction > 0:
		playerSprite.flip_h = false
	elif direction < 0:
		playerSprite.flip_h = true
		
func _on_player_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		enemyInAttackRange = true

func _on_player_hitbox_body_exited(body):
	if body.is_in_group("enemies"):
		enemyInAttackRange = false
		
func enemyAttacksPlayer():
	if enemyInAttackRange and enemyAttackCooldown == true:
		health -= 20
		enemyAttackCooldown = false
		$attackCooldown.start()
		
func _on_attack_cooldown_timeout():
	enemyAttackCooldown = true
	
func checkToKillPlayer():
	# KILL PLAYER IF HEALTH <= 0 OR IF THEY HAVE FALLEN OFF THE MAP
	if health <= 0 || position.y >= 430:
		playerAlive = false 
		health = 0
		get_tree().change_scene_to_file("res://scenes/game_over.tscn") # SEND PLAYER TO GAME OVER SCREEN
		
func _on_deal_attack_cooldown_timeout():
	$dealAttackCooldown.stop()
	Global.isPlayerAttacking = false
	isAttacking = false
	
func updateHealth():
	var healthbar = $Healthbar
	healthbar.value = health

func _on_regen_cooldown_timeout():
	if health < 200:
		health += 20
		if health > 200:
			health = 200
	if health <= 0:
		health = 0
	
