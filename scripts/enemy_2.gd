extends CharacterBody2D

@onready var animatedEnemySprite = $AnimatedSprite2D

const speed = 30

var direction = -1
var playerChase = false
var player = null
var spottedPLayer: bool = false


func _physics_process(delta):

	# ENEMY SEES AND FOLLOWS PLAYER
	if playerChase:
		var direction = player.position - position
		# LOCK THE Y AXIS HERE SO THE ENEMY CANNOT FLY WHEN PLAYER JUMPS
		direction.y = 0
		position += direction.normalized() * speed * delta
		animatedEnemySprite.play("walk")
		
		if (player.position.x - position.x) < 0:
			animatedEnemySprite.flip_h = true
		else:
			animatedEnemySprite.flip_h = false
	else:
		animatedEnemySprite.play("idle")

func _on_detection_area_body_entered(body):
	# WHEN PLAYER GETS CLOSE TO ENEMY, ENEMY IS ALERTED
	player = body
	playerChase = true

func _on_detection_area_body_exited(body):
	# ENEMY LOSES SIGHT OF PLAYER
	player = null
	playerChase = false 

