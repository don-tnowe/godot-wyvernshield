tool
class_name StatSheet
extends Resource

export(String, MULTILINE) var stats_as_text setget _set_stats_as_text
export(Array, Resource) var subsheets
export var all_multiplier := 1.0

var stats_add := {}
var stats_multi := {}


func _set_stats_as_text(v):
	stats_as_text = v
	recalculate_children()


func _on_child_changed():
	recalculate_children()


func load_from_text(v : String):
	var v_split = v.split("\n")
	for x in v_split:
		var x_split = x.split(" ")
		
		if x_split.size() != 3: continue

		var key = x_split[0]
		if x_split[1] == "+":
			stats_add[key] = stats_add.get(key, 0.0) + str2var(x_split[2]) * all_multiplier
			
		if x_split[1] == "-":
			stats_add[key] = stats_add.get(key, 0.0) - str2var(x_split[2]) * all_multiplier
			
		if x_split[1] == "*" || x_split[1] == "x":
			stats_multi[key] = stats_multi.get(key, 1.0) * ((str2var(x_split[2]) - 1.0) * all_multiplier + 1.0)


func add_subsheet(subsheet : StatSheet, with_multiplier : float = 1.0) -> Resource:
	# If I make it non-conditional then FOR SOME REASON all stops working COMPLETELY, multiplied or not. Bonkers.
	if with_multiplier != 1.0:
		subsheet = subsheet.duplicate()
		subsheet.all_multiplier = with_multiplier

	subsheets.append(subsheet)
	subsheet.recalculate_recursively()
	
	if subsheet.connect("changed", self, "_on_child_changed") != OK:
		printerr("Error connecting signal StatSheet::recalculate_children! (add_subsheet in stat_sheet.gd)")
	
	recalculate_children()
	return subsheet


func remove_subsheet(subsheet : StatSheet):
	subsheet.disconnect("changed", self, "_on_child_changed")
	subsheets.erase(subsheet)

	recalculate_children()


func get_subsheet_by_name(sheet_name : String) -> StatSheet:
	for x in subsheets:
		if x.resource_name == sheet_name:
			return x

	return null


func set_stat(stat : String, value, is_multiplier : bool = false):
	if is_multiplier:
		stats_multi[stat] = value
	
	else:
		stats_add[stat] = value

	emit_changed()


func get_stat(stat : String, default = 0.0):
	return stats_add.get(stat, default) * stats_multi.get(stat, 1.0)


func recalculate_recursively():
	for x in subsheets:
		x.recalculate_recursively()

	recalculate_children()


func recalculate_children():
	stats_add.clear()
	stats_multi.clear()
	load_from_text(stats_as_text)
	for x in subsheets:
		recalculate_child(x)
		
	emit_changed()


func recalculate_child(child : StatSheet):
	for k in child.stats_add:
		stats_add[k] = stats_add.get(k, 0.0) + child.stats_add[k]
		
	for k in child.stats_multi:
		stats_multi[k] = stats_multi.get(k, 1.0) * child.stats_multi[k]


func duplicate_recursively() -> Resource:
	var me_duplicated := duplicate()
	me_duplicated.subsheets = subsheets.duplicate()
	for i in me_duplicated.subsheets.size():
		me_duplicated.subsheets[i] = subsheets[i].duplicate_recursively()
		me_duplicated.subsheets[i].connect("changed", me_duplicated, "_on_child_changed")
	
	me_duplicated.recalculate_children()
	return me_duplicated
