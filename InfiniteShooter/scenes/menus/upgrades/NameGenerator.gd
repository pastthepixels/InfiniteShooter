extends Node

export (Array, String) var name_bases = [
	"eviction notice",
	"lamp",
	"spoon",
	"pizza",
	"crowbar", 
	"violation",
	"dinner",
	"bathroom",
	"hamburger",
	"banana",
	"house",
	"potato",
	"advertisement",
	"holiday",
	"carpet",
	"table",
	"golf course",
	"hole",
	"grass",
	"newspaper",
	"opinion",
	"tax",
	"cake",
	"sock",
	"gnome",
	"egg",
	"box",
	"bath",
	"problem",
	"stone",
	"weather",
	"robbery",
	"coffee",
	"explanation",
	"improvement",
	"exam",
	"excitement"
]

export (Array, String) var name_adjectives = [
	"robust",
	"bland",
	"tense",
	"mind numbing",
	"outrageous",
	"perfect",
	"helpful",
	"beefy",
	"comfortable",
	"confusing",
	"horrific",
	"naughty",
	"cruel",
	"cumbersome",
	"acidic",
	"clean",
	"embarrassing",
	"fancy",
	"expensive"
]


func generate_upgrade_name():
	return ("the " + name_adjectives[randi() % name_adjectives.size()] + " " + name_bases[randi() % name_bases.size()]).capitalize()
