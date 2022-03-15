extends Spatial

export(SpatialMaterial) var material_override

func _ready():
	if material_override != null:
		$MeshInstance.material_override = material_override
