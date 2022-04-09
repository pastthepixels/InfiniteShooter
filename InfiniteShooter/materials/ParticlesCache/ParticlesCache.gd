# Thanks, https://travismaynard.com/writing/caching-particle-materials-in-godot! Very cool
extends Spatial


var materials = [
	preload("res://materials/DispersionParticles.material"),
	preload("res://materials/HitParticles.material"),
	preload("res://materials/ExplosionParticles.material"),
	preload("res://materials/FireParticles.material"),
	preload("res://materials/IceParticles.material"),
	preload("res://materials/CorrosionParticles.material")
]

func _ready():
	for material in materials:
		var particles_instance = Particles.new()
		particles_instance.set_process_material(material)
		particles_instance.set_one_shot(true)
		particles_instance.set_emitting(true)
		particles_instance.draw_pass_1 = PlaneMesh.new()
		self.add_child(particles_instance)

# As stated in the tutorial, this basically creates new instances of particles
# so their materials are forced to be compiled and cached instead of compiling
# right when the first laser fires/such (which would get quite annoying after 
# a while)
