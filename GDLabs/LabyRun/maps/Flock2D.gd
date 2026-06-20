extends Node2D

export (PackedScene) var bird_scene
var targets
var bird
var birds = []
var current_target_index = 0
export var idle = true
var time = 0.0

func _ready():
	# Spawna fågeln
	bird = spawn_bird(Vector2(0, 0))
	birds.append(spawn_bird(Vector2(-100, 0)))
	birds.append(spawn_bird(Vector2(-200, 0)))
	
	# Här skickar vi med målen till fågeln så att den vet vart den ska
	# Vi antar att målen finns i en nod som heter "Targets" i din huvudscen
	targets = get_parent().get_node("Targets").get_children()
	# bird.set_targets(targets)

func _process(delta):
	time += delta
	if targets.size() > 0 and current_target_index < targets.size():
		var target_pos = targets[current_target_index].global_position
		
		# Beräkna riktning och rörelse
		if not idle:
			var direction = (target_pos - bird.global_position).normalized()
			bird.rotation_degrees = direction.x * 45
			bird.global_position += direction * 100 * delta # 200 är farten
			bird.speed_scale =  -direction.y;
		else:
			bird.global_position.x = target_pos.x + cos(time * 2.0) * 200
			bird.global_position.y = target_pos.y + sin(time * 2.0) * 100
			bird.rotation_degrees = -cos(time * 2.0) * 45
			bird.speed_scale =  -sin(time * 2.0);

		# var second_direction = (bird.global_position - birds[0].global_position).normalized()
		var i = 0
		for e in birds:
			var d = 0.0
			if i == 0:
				e.set_direction((bird.global_position - birds[i].global_position).normalized())
				d = e.global_position.distance_to(bird.global_position)
			else:
				e.set_direction((birds[i-1].global_position - birds[i].global_position).normalized())				
				d = e.global_position.distance_to(birds[i-1].global_position)
			#e.set_direction(Vector2(-1,-1))
			
			print(d)
			e.global_position += e.direction * d * delta
			e.rotation_degrees = e.direction.x * 45
			e.speed_scale = -e.direction.y;
			i += 1
		
		# Kolla om vi är nära målet
		if bird.global_position.distance_to(target_pos) < 5:
			# Byt till nästa mål
			current_target_index += 1
	else:
		# Här kan du hantera vad som händer när alla mål är nådda
		current_target_index = 0
func spawn_bird(pos: Vector2):
	if bird_scene:
		var new_bird = bird_scene.instance()
		new_bird.global_position = pos # Använd global_position direkt
		add_child(new_bird)
		return new_bird

