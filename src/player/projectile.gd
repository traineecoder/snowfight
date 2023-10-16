extends Area2D

export(int) var speed=150
export(int) var damage = 25

var velocity = Vector2()
var direction = 1 
var starting_position=Vector2()
var myteam=''

func _ready() -> void:
	set_as_toplevel(true)


func _physics_process(delta: float) -> void:
	velocity.x = speed * delta * direction
	translate(velocity)
	#print(position)
	if(direction==-1 and starting_position.x - position.x > 200):
		queue_free()
	if(direction==1 and starting_position.x - position.x < -200):
		queue_free()	
	$AnimatedSprite.play("projectile")

func set_projectile_direction(dir):
	direction = dir
	if(dir==-1):
		$AnimatedSprite.flip_h=true

func set_position(snowball_positon):
	starting_position.x = snowball_positon.x
	#print(starting_position)



#func _on_VisibilityNotifier2D_screen_exited() -> void:
	#print('exited')
	#queue_free()
#	pass


func _on_projectile_body_entered(body: Node) -> void:
	#body.damage(damage)
	queue_free()
