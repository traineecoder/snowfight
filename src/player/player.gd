extends KinematicBody2D

const SPEED =50
const GRAVITY=10
const JUMP_POWER=-250
const FLOOR=Vector2(0,-1)
const MAX_HP = 100

enum Action { LEFT, RIGHT,JUMP,SHOOT, NONE}

const PROJECTILE=preload("res://src/player/projectile.tscn")

slave var slave_position=Vector2()
slave var slave_movement = Action.NONE

var health_points = MAX_HP

var velocity=Vector2()
var on_ground=false
var is_attacking=false
var is_slave_attacking =false
var is_dead=false

func _ready() -> void:
	$jumpSound.get_stream().loop = false
	$shootSound.get_stream().loop = false
	_update_health_bar()

func _physics_process(delta: float) -> void:
	var action = Action.NONE
	velocity.y+=GRAVITY
	if is_network_master() and !is_dead:
		$Camera2D.current=true
		if Input.is_action_pressed("left"):
			action=Action.LEFT
		elif Input.is_action_pressed("right"):
			action=Action.RIGHT
		if Input.is_action_just_pressed("shoot"):
			if $ShootTimer.is_stopped():
				$shootSound.play()
			action = Action.SHOOT
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				$jumpSound.play()
			action = Action.JUMP
		rset_unreliable('slave_position',position)
		rset('slave_movement',action)
		_move(action)
	else:
		_move(slave_movement)
		position=slave_position
	if get_tree().is_network_server():
		Network.update_position(int(name),position)

func _move(action):
	match action:
		Action.NONE:
			velocity.x=0
			if is_on_floor() && $ShootTimer.is_stopped():
				$AnimatedSprite.play('idle')
			velocity = move_and_slide(velocity,FLOOR)
		Action.JUMP:
			if is_on_floor():
				velocity.y = JUMP_POWER
				if $ShootTimer.is_stopped():
					$AnimatedSprite.play("jump")
			velocity = move_and_slide(velocity,FLOOR)
		Action.LEFT:
			if $ShootTimer.is_stopped() || !is_on_floor():
				$AnimatedSprite.flip_h = true
				if(sign($Position2D.position.x)==1):
							$Position2D.position.x *=-1
				if is_on_floor():
					$AnimatedSprite.play('run')
				velocity.x= -SPEED
				velocity = move_and_slide(velocity,FLOOR)
		Action.RIGHT:
			if $ShootTimer.is_stopped() || !is_on_floor():
				$AnimatedSprite.flip_h = false
				if(sign($Position2D.position.x)==-1):
							$Position2D.position.x *=-1
				if is_on_floor():
					$AnimatedSprite.play('run')
				else:
					pass #fall
				velocity.x = SPEED
				velocity = move_and_slide(velocity,FLOOR)
		Action.SHOOT:
			rpc('_shoot')
			
sync func _dead():
	is_dead=true
	velocity=Vector2.ZERO
	$AnimatedSprite.play("dead")
	queue_free()

func _update_health_bar():
	$GUI/HealthBar.value = health_points

func damage(value):
	health_points -= value
	if health_points <= 0:
		health_points = 0
		rpc('_dead')
	_update_health_bar()

sync func _shoot():
	if $ShootTimer.is_stopped():
				$ShootTimer.start()
				$AnimatedSprite.frame=1
				$AnimatedSprite.play("shoot")
				var snowball=PROJECTILE.instance()
				if(sign($Position2D.position.x)==1):
					snowball.set_projectile_direction(1)
				else:
					snowball.set_projectile_direction(-1)
				get_parent().add_child(snowball)
				snowball.position=$Position2D.global_position
				snowball.set_position(snowball.position)

#func _on_AnimatedSprite_animation_finished() -> void:
#	is_attacking =false


func init(nickname, start_position, is_slave):
	$GUI/Nickname.text = nickname
	global_position = start_position
	if is_slave:
		$AnimatedSprite.modulate = Color(0.901961, 0.270588, 0.270588)

func _on_ShootTimer_timeout() -> void:
	$ShootTimer.stop()
