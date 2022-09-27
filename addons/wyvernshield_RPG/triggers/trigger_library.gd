tool
class_name TriggerLibrary
extends Resource

export(Array, Resource) var list setget _set_list

export var force_update := false setget _set_force_update

export var reaction_class : Script setget _set_reaction_class
export var static_class : Script setget _set_static_class


func _set_list(v):
	list = v
	update_classes()


func _set_force_update(_v):
	update_classes()


func _set_reaction_class(v):
	reaction_class = v
	update_classes()


func _set_static_class(v):
	static_class = v
	update_classes()


func update_classes():
	var name_list = PoolStringArray()
	name_list.resize(list.size())
	for i in name_list.size():
		if list[i] == null:
			list[i] = TriggerProperties.new()
			emit_changed()
			
		name_list[i] = list[i].trigger_name.to_upper()
		list[i].resource_name = list[i].trigger_name
	
	# In Static class, initialize static functions and values between the two comments.
	process_class(
		static_class, (
			join_list_of_constants(name_list, "TRIGGER")
			+ "\nconst TRIGGER_MAX := "
			+ str(name_list.size()) 
			+ "\n"
			+ join_list_of_constant_lists(name_list)
			+ join_list_of_constructors(name_list)
		), 
		"((.|\\n)*# Triggers start\\n)(.|\\n)*(\\n# Triggers end(.|\\n)*)",
		1, 4
	)
	# In Reaction class, search for the Trigger export property.
	process_class(
		reaction_class, join_list_into_export_enum(name_list), 
		"((.|\\n)*export\\(int,)(.|\\n)*(\\) var trigger(.|\\n)*)",
		1, 4
	)


func process_class(class_script : Script, replacement_text : String, regex_str : String, regex_group_before : int = 1, regex_group_after : int = 4):
	var regex = RegEx.new()
	regex.compile(regex_str)
	var regex_match = regex.search(class_script.source_code)
	# Group 1: before list, Group 4: after list
	class_script.source_code = (
		regex_match.get_string(regex_group_before)
		+ replacement_text
		+ regex_match.get_string(regex_group_after)
	)
	if ResourceSaver.save(class_script.resource_path, class_script) != OK:
		printerr("Error saving resource! (process_class in trigger_list.gd)")


func join_list_into_enum(enum_name : String, enum_members : Array) -> String:
	if enum_members.size() == 0:
		return "enum " + string_snake_to_naming_case(enum_name) + " {}"
	
	return "enum " + string_snake_to_naming_case(enum_name)\
		+ " {\n\t" + ",\n\t".join(enum_members) + ",\n\tMAX = " + str(enum_members.size()) + "\n}"


func join_list_into_export_enum(names : Array) -> String:
	names = names.duplicate()
	for i in names.size():
		names[i] = "\"" + string_snake_to_naming_case(names[i], true) + "\""
		
	return "\n\t" + ",\n\t".join(names) + "\n"


func join_list_of_enums(names : Array) -> String:
	names = names.duplicate()
	for i in names.size():
		names[i] = join_list_into_enum(names[i], list[i].prop_names.split("\n"))
		
	return "\n" + "\n".join(names) + "\n"


func join_list_of_constants(names : Array, name_prefix : String = "", values_are_strings : bool = false) -> String:
	names = names.duplicate()
	for i in names.size():
		names[i] = "const " + name_prefix\
		+ ("_" if name_prefix != "" else "")\
		+ names[i].to_upper() + " := "\
		+ ("\"" + names[i].to_lower() + "\"" if values_are_strings else str(i))

	return "\n" + "\n".join(names)


func join_list_of_constant_lists(names : Array, values_are_strings : bool = false) -> String:
	names = names.duplicate()
	for i in names.size():
		names[i] = join_list_of_constants(list[i].prop_names.split("\n"), names[i].to_upper(), values_are_strings)

	return "\n".join(names) + "\n"


func join_list_of_constructors(names : Array) -> String:
	names = names.duplicate()
	for i in names.size():
		var params_split = list[i].prop_names.split("\n")
		for j in params_split.size():
			params_split[j] = params_split[j].to_lower()

		names[i] = "\n\nstatic func " + names[i].to_lower() + "(" + ", ".join(params_split) + ") -> Array:\n"\
			+ "\treturn [" + ", ".join(params_split) + "]"

	return "\n".join(names) + "\n"



func string_snake_to_naming_case(string : String, add_spaces : bool = false) -> String:
	var split = string.split("_")
	for i in split.size():
		split[i] = split[i][0].to_upper() + split[i].substr(1).to_lower()
	
	return (" " if add_spaces else "").join(split)
