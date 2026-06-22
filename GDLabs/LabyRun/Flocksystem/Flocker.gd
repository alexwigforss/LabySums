extends Node2D

var speed = 2.0
var heading = 0.0

# Justera vikterna här för att ändra beteendet!
# (t.ex. 0.8 drift och 0.2 step gör dem mycket mer fokuserade på musen)
var weight_drift = 0.8
var weight_step = 0.2

var target_node: Node2D = null

onready var anim_sprite = $AnimatedSprite

func _ready():
	add_to_group("flockers")
	var screen_size = get_viewport_rect().size
	global_position = Vector2(rand_range(0, screen_size.x), rand_range(0, screen_size.y))
	heading = rand_range(0, TAU)
	anim_sprite.scale = Vector2(0.5, 0.5)
	anim_sprite.play()

func _process(_delta):
	# OPTIMERING: Hämta listan EN gång per frame och skicka med den in i beteendena
	var flock = get_tree().get_nodes_in_group("flockers")
	
	# 1. Hämta önskad RIKTNING (som en Vector2) från varje beteende
	var dir_drift = get_drift_vector()
	var dir_step = get_step_vector(flock)
	
	# 2. Slå ihop vektorerna baserat på deras vikter
	var combined_dir = (dir_drift * weight_drift) + (dir_step * weight_step)
	
	# Så länge vi faktiskt har en riktning (så att de inte tar ut varandra helt till 0)
	if combined_dir.length_squared() > 0.001:
		# Gör om den kombinerade vektorn till en målvinkel (radianer)
		var target_angle = combined_dir.angle()
		
		# 3. Din exakta logik för att förhindra 350 -> 10 graders buggen
		if heading - target_angle > PI:
			target_angle += TAU
		elif target_angle - heading > PI:
			target_angle -= TAU
			
		# Mjuk sväng mot målvinkeln
		if heading < target_angle:
			heading += PI / 40.0
		else:
			heading -= PI / 40.0
			
	# 4. EN ENDA FÖRFLYTTNING PER FRAME
	# Eftersom vi bara flyttar en gång, kan du öka multiplikatorn (t.ex. till 5.0) för att matcha farten
	global_position.x += cos(heading) * (speed * 5.0)
	global_position.y += sin(heading) * (speed * 5.0)
	
	# Uppdatera spritens rotation
	anim_sprite.rotation = (heading / 4.0) + (PI / 2.0)

"""
func get_drift_vector() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	# `.normalized()` ger oss en vektor med längden 1 som bara pekar mot musen
	return (mouse_pos - global_position).normalized()
"""
func get_drift_vector() -> Vector2:
	# 2. Kolla om vi har fått en målnod från Main
	if target_node and is_instance_valid(target_node):
		# Använd målnodens globala position istället för musen!
		return (target_node.global_position - global_position).normalized()
	else:
		# Fallback: Om målnoden saknas av någon anledning, styr mot musen som förr
		return (get_global_mouse_position() - global_position).normalized()

func get_step_vector(flock: Array) -> Vector2:
	var closest_distance_sq = 100000.0
	var closest_flocker = null
	
	for f in flock:
		if f != self:
			var dist_sq = global_position.distance_squared_to(f.global_position)
			
			# OBS! FIXAT LOGIKFEL FRÅN ORIGINALKODEN:
			# Om du har "dist_sq > 40000" (200 pixlar) här, kommer loopen ALDRIG hitta fåglar
			# som är närmare än 200 pixlar. Då kan de inte undvika varandra!
			# Vi letar nu efter den absolut närmaste fågeln (upp till max 500 pixlar bort).
			if dist_sq < closest_distance_sq and dist_sq < 250000.0: 
				closest_distance_sq = dist_sq
				closest_flocker = f
				
	var mouse_pos = get_global_mouse_position()
	
	# Om ingen fågel är i närheten, sök dig mot musen
	if closest_flocker == null:
		return (mouse_pos - global_position).normalized()
		
	# Räkna ut riktningen till den närmaste fågeln
	var dir_to_closest = (closest_flocker.global_position - global_position).normalized()
	
	# SEPARATION: Om den närmaste fågeln är FÖR nära (under 200 pixlar / 40000 i kvadrat)
	if closest_distance_sq < 40000.0:
		# Genom att sätta ett minustecken framför vektorn vänder vi den helt om! 
		# Fågeln vill nu fly i motsatt riktning.
		return -dir_to_closest 
	else:
		# Annars vill den flyga mot sin granne (Cohesion)
		return dir_to_closest
