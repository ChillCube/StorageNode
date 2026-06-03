@icon("res://addons/StorageNode/icon-block-crate.png")
extends Node
class_name Storage

@export var inventory: Inventory
@export var capacity_per_item: Array[ItemCapacity] = []
@export var total_capacity: int = 100

func _get_item_limit(item: Item) -> int:
	for cap in capacity_per_item:
		if cap.type == item:
			return cap.amount
	return -1

func add_item(amount : int, item : Item) -> int:
	if inventory == null:
		return 0
	if capacity_per_item.size() > 0 and _get_item_limit(item) == -1:
		return 0
	var added := 0
	for i in range(amount):
		if total_capacity > 0 and inventory.get_all_items_count() >= total_capacity:
			break
		var item_limit := _get_item_limit(item)
		if item_limit >= 0 and inventory.get_amount(item) >= item_limit:
			break
		if inventory.add_item(item):
			added += 1
	return added

func add_inventory(_inventory : Inventory) -> Inventory:
	# takes an inventory as input, adds all items that the filter accepts and spits out the remaining items that it rejected as an inventory
	if inventory == null:
		return _inventory
	var rejected := Inventory.new()
	for i in range(_inventory.items.size()):
		var item := _inventory.items[i]
		if item == null:
			continue
		var count := _inventory.counts[i] if i < _inventory.counts.size() else 1
		for _j in range(count):
			if add_item(1, item) == 0:
				rejected.add_item(item)
	return rejected

func request_item(amount : int, item : Item) -> Inventory:
	var output := Inventory.new()
	if inventory == null:
		return output
	var to_remove := mini(amount, inventory.get_amount(item))
	if to_remove > 0 and inventory.remove_item(item, to_remove):
		for _i in range(to_remove):
			output.add_item(item)
	return output
