# Thanks, https://travismaynard.com/writing/caching-particle-materials-in-godot! Very cool
extends Spatial

var DispersionParticlesMaterial = preload("res://materials/DispersionParticles.tres")
var HitParticlesMaterial = preload("res://materials/HitParticles.tres")
var ExplosionParticlesMaterial = preload("res://materials/ExplosionParticles.tres")

var materials = [
	DispersionParticlesMaterial,
	HitParticlesMaterial,
	ExplosionParticlesMaterial
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
