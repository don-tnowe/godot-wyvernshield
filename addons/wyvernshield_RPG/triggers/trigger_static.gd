class_name TriggerStatic

# This file is generated automatically. Do NOT edit it manually.
# Please, open the linked trigger_library.tres file.
# Check its Force Update checkbox to update this file immediately.

# Triggers start

const TRIGGER_TICK := 0
const TRIGGER_COMBAT_MOVE := 1
const TRIGGER_COMBAT_MOVE_GET_COST := 2
const TRIGGER_HIT_LANDED := 3
const TRIGGER_HIT_RECEIVED := 4
const TRIGGER_STATUS_DOT_TICK := 5
const TRIGGER_STATUS_GET_PROPERTIES := 6
const TRIGGER_STATUS_APPLIED := 7
const TRIGGER_STATUS_RECEIVED := 8
const TRIGGER_NPC_DEFEATED := 9
const TRIGGER_ITEM_PICKUP := 10
const TRIGGER_MAX := 11

const TICK_DELTA_TIME := 0

const COMBAT_MOVE_ACTOR := 0
const COMBAT_MOVE_SPAWNED_OBJECTS := 1
const COMBAT_MOVE_DIRECTION_VEC := 2
const COMBAT_MOVE_COMBAT_MOVE := 3
const COMBAT_MOVE_WEAPON_COOLDOWN := 4
const COMBAT_MOVE_SPECIAL_COOLDOWN := 5
const COMBAT_MOVE_IS_BASIC_ATTACK := 6

const COMBAT_MOVE_GET_COST_ACTOR := 0
const COMBAT_MOVE_GET_COST_COMBAT_MOVE := 1
const COMBAT_MOVE_GET_COST_CAN_CAST := 2
const COMBAT_MOVE_GET_COST_COST_DICT := 3

const HIT_LANDED_TARGET := 0
const HIT_LANDED_HIT_BY_COMBAT_MOVE := 1
const HIT_LANDED_DAMAGE_DEALT := 2
const HIT_LANDED_IS_BASIC_ATTACK := 3

const HIT_RECEIVED_TARGET := 0
const HIT_RECEIVED_HIT_BY_ACTOR := 1
const HIT_RECEIVED_HIT_BY_COMBAT_MOVE := 2
const HIT_RECEIVED_DAMAGE_DEALT := 3

const STATUS_DOT_TICK_DAMAGE_DEALT := 0

const STATUS_GET_PROPERTIES_SENDER := 0
const STATUS_GET_PROPERTIES_STATUS := 1
const STATUS_GET_PROPERTIES_TARGET := 2
const STATUS_GET_PROPERTIES_RESULT_DURATION := 3
const STATUS_GET_PROPERTIES_RESULT_POTENCY := 4

const STATUS_APPLIED_ACTOR := 0
const STATUS_APPLIED_STATUS := 1
const STATUS_APPLIED_TARGET := 2
const STATUS_APPLIED_RESULT_DURATION := 3
const STATUS_APPLIED_RESULT_POTENCY := 4

const STATUS_RECEIVED_SENDER := 0
const STATUS_RECEIVED_STATUS := 1
const STATUS_RECEIVED_TARGET := 2

const NPC_DEFEATED_TARGET := 0
const NPC_DEFEATED_FINISHING_ATTACK := 1
const NPC_DEFEATED_DAMAGE_DEALT := 2

const ITEM_PICKUP_ITEM := 0


static func tick(delta_time) -> Array:
	return [delta_time]


static func combat_move(actor, spawned_objects, direction_vec, combat_move, weapon_cooldown, special_cooldown, is_basic_attack) -> Array:
	return [actor, spawned_objects, direction_vec, combat_move, weapon_cooldown, special_cooldown, is_basic_attack]


static func combat_move_get_cost(actor, combat_move, can_cast, cost_dict) -> Array:
	return [actor, combat_move, can_cast, cost_dict]


static func hit_landed(target, hit_by_combat_move, damage_dealt, is_basic_attack) -> Array:
	return [target, hit_by_combat_move, damage_dealt, is_basic_attack]


static func hit_received(target, hit_by_actor, hit_by_combat_move, damage_dealt) -> Array:
	return [target, hit_by_actor, hit_by_combat_move, damage_dealt]


static func status_dot_tick(damage_dealt) -> Array:
	return [damage_dealt]


static func status_get_properties(sender, status, target, result_duration, result_potency) -> Array:
	return [sender, status, target, result_duration, result_potency]


static func status_applied(actor, status, target, result_duration, result_potency) -> Array:
	return [actor, status, target, result_duration, result_potency]


static func status_received(sender, status, target) -> Array:
	return [sender, status, target]


static func npc_defeated(target, finishing_attack, damage_dealt) -> Array:
	return [target, finishing_attack, damage_dealt]


static func item_pickup(item) -> Array:
	return [item]

# Triggers end
