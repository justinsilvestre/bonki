class_name PendingDig


extends Node

var start_unix_time: float
var duration_seconds: int
var appearance: BonkiAppearanceParameters

static func create(start_unix_time: float, duration_seconds: int, appearance: BonkiAppearanceParameters):
	var dig := PendingDig.new()
	dig.start_unix_time = start_unix_time
	dig.duration_seconds = duration_seconds
	dig.appearance = appearance
	return dig
	
func complete_time():
	return start_unix_time + duration_seconds

static func fromJSON(json):
	var dig := PendingDig.new()
	dig.start_unix_time = json["start_unix_time"]
	dig.duration_seconds = json["duration_seconds"]
	dig.appearance = BonkiAppearanceParameters.fromJSON(json["appearance"])
	return dig
	
func toJSON():
	return {
		"start_unix_time": start_unix_time,
		"duration_seconds": duration_seconds,
		"appearance": appearance.toJSON()
	}
