# Thanks, https://travismaynard.com/writing/caching-particle-materials-in-godot! Very cool
extends Spatial

var dispersion_particles = preload("res://materials/DispersionParticles.material")
var hit_particles = preload("res://materials/HitParticles.material")
var explosion_particles = preload("res://materials/ExplosionParticles.material")
var fire_particles = preload("res://materials/FireParticles.material")
var ice_particles = preload("res://materials/IceParticles.material")
var corrosion_particles = preload("res://materials/CorrosionParticles.material")

var materials = [
	dispersion_particles,
	hit_particles,
	explosion_particles,
	fire_particles,
	ice_particles,
	corrosion_particles
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
