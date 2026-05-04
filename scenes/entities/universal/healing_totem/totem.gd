extends Area2D
@onready var healing_cooldown: Timer = $healing_cooldown
@onready var line_2d: Line2D = $Line2D
@onready var healing_timer: Timer = $healing_timer
@onready var healing_tick: Timer = $healing_tick


func _ready() -> void:
	line_2d.visible = false
	healing_cooldown.start(2)

var target
var target_node
func _process(delta: float) -> void:
	if !healing_cooldown.is_stopped():
		return
	if healing_timer.is_stopped() and healing_cooldown.is_stopped():
		target = locate_healing_targets()
	if target == null:
		line_2d.visible = false
		line_2d.set_point_position(1, Vector2.ZERO)
		return
	if !is_instance_valid(target["node"]):
		target = null
		line_2d.set_point_position(1,Vector2.ZERO)
		return
	if healing_timer.is_stopped():
		healing_timer.start()
	if !target["node"].has_node("HP"):
		return
	target_node = to_local(target["node"].global_position)
	line_2d.visible = true
	line_2d.set_point_position(0,Vector2.ZERO + Vector2(0,-8))
	line_2d.set_point_position(1, target_node)
	var pulse = sin(Time.get_ticks_msec() * 0.01) * 2
	line_2d.width = 6 + pulse
	if healing_tick.is_stopped():
		target["node"].get_node("HP").damage_taken(-1)
		healing_tick.start()
	



func locate_healing_targets():
	var important_targets = []
	var targets =  get_overlapping_bodies()
	for body in targets:
		if body.is_in_group("enemy") and body.has_node("HP"):
			var cur_HP: float = body.get_node("HP").CURRENT_HEALTH
			var max_HP: float = body.get_node("HP").MAX_HEALTH
			var percent_HP:float  = cur_HP/max_HP
			if percent_HP < 0.5 and cur_HP>=1:
				important_targets.append({"node": body,"health": percent_HP})
	important_targets.sort_custom(func(a,b): return a["health"]<b["health"])
	if important_targets:
		return important_targets[0]
	else:
		return null


func _on_healing_timer_timeout() -> void:
	healing_cooldown.start()
	target = null
	line_2d.set_point_position(1,Vector2.ZERO)
	line_2d.visible = false
	


func _on_healing_cooldown_timeout() -> void:
	target = null
	line_2d.set_point_position(1,Vector2.ZERO)
	line_2d.visible = false
