class_name StatusCarrierView2D
extends HBoxContainer

export var icon_scene : PackedScene
export var show_duration := true

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
	
	add_child(node)


func _on_status_effect_removed(_effect, insert_pos):
	effect_list.remove(insert_pos)
	effect_nodes[insert_pos].free()
	effect_nodes.remove(insert_pos)
