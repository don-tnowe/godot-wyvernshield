class_name StatusCarrierView
extends Spatial

export var icon_scene : PackedScene
export var show_duration := true

onready var sprite := $"Sprite"
onready var viewport := $"Viewport"
onready var box := $"Viewport/Status"

var effect_list := []
var effect_nodes := []


func _process(_delta):
	if !show_duration: return
	
	for i in effect_list.size():
		effect_nodes[i].get_node("Label").text = str(ceil(
			effect_list[i].expiration_time_sec - effect_list[i].carrier.time
		))


func _on_status_effect_applied(effect, insert_pos):
	var node = icon_scene.instance()

	effect_list.insert(insert_pos, effect)
	effect_nodes.insert(insert_pos, node)

	node.texture = effect.icon
	node.get_node("Label").text = ""
	node.visible = effect.icon != null

	box.add_child(node)
	update_viewport_size(node.rect_size)


func _on_status_effect_removed(_effect, insert_pos):
	effect_list.remove(insert_pos)
	update_viewport_size(effect_nodes[0].rect_size)
	effect_nodes[insert_pos].free()
	effect_nodes.remove(insert_pos)


func update_viewport_size(child_size):
	viewport.size = Vector2((child_size.x + 4) * effect_nodes.size() - 4, child_size.y)
	# I don't know why but the viewport feed becomes stretched when resized but these 2 lines seem to un-stretch it
	sprite.region_enabled = true
	sprite.region_enabled = false
		
