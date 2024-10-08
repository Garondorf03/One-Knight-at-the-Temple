extends CharacterBody2D

@onready var enemySprite = $AnimatedSprite2D

const speed = 30

var direction = -1
var playerChase = false
var player = null
var spottedPLayer: bool = false
var health = 100
var playerInAttackRange = false
var canTakeDamage = true

func enemy():
	pass

func _physics_process(delta):

	playerAttacksEnemy()
	checkEnemyHealth()
	updateHealth()

	# ENEMY SEES AND FOLLOWS PLAYER
	if playerChase:
		var direction = player.position - position
		# LOCK THE Y AXIS HERE SO THE ENEMY CANNOT FLY WHEN PLAYER JUMPS
		direction.y = 0
		position += direction.normalized() * speed * delta
		enemySprite.play("walk")
		
		if (player.position.x - position.x) < 0:
			enemySprite.flip_h = true
		else:
			enemySprite.flip_h = false
	else:
		enemySprite.play("idle")

func _on_detection_area_body_entered(body):
	# WHEN PLAYER GETS CLOSE TO ENEMY, ENEMY IS ALERTED
	player = body
	playerChase = true

func _on_detection_area_body_exited(body):
	# ENEMY LOSES SIGHT OF PLAYER
	player = null
	playerChase = false 

func _on_enemy_hitbox_body_entered(body):
	if body.is_in_group("players"):
		playerInAttackRange = true

func _on_enemy_hitbox_body_exited(body):
	if body.is_in_group("players"):
		playerInAttackRange = false
		
func playerAttacksEnemy():
	if playerInAttackRange and Global.isPlayerAttacking == true:
		if canTakeDamage == true:	
			health -= 20
			$takeDamageCooldown.start()
			canTakeDamage = false
		
func checkEnemyHealth():
	# KILL ENEMY IF HEALTH <= 0
	if health <= 0:
		health = 0
		self.queue_free()

func _on_take_damage_cooldown_timeout():
	canTakeDamage = true
	
func updateHealth():
	var healthBar = $healthbar
	healthBar.value = health
