class_name PetResource
extends Resource

#### Definitions for each Pet ####
@export var pet_name: String
@export var behavior: Behavior

#### Behaviors we can pick ####
enum Behavior {
	Default,
	Cat,
	Dog,
	Pigeon,
}

class Pet extends Node:
	var pet_name: String
	var behavior: DefaultPetBehavior

class DefaultPetBehavior:
	func get_sound():
		return "Not defined"

class Dog extends DefaultPetBehavior:
	func get_sound():
		return "woof"

class Pigeon extends DefaultPetBehavior:
	func get_sound():
		return "???"

class Cat extends DefaultPetBehavior:
	func get_sound():
		return "meow"

var all_behaviors = {
	Behavior.Default: DefaultPetBehavior,
	Behavior.Dog: Dog,
	Behavior.Pigeon: Pigeon,
	Behavior.Cat: Cat,
}

func new() -> Pet:
	var pet = Pet.new()
	pet.pet_name = pet_name
	pet.behavior = all_behaviors[behavior].new()
	return pet
