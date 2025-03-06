class_name SwarmScene extends Node3D

@export
var vsg : vSG

@export
var camera : FreeLookCamera

func disable_camera():
	camera.active = false

func enable_camera():
	camera.active = true

func play():
	vsg.play = !vsg.play

func step():
	vsg.step = true

func end():
	vsg.clean_up()
