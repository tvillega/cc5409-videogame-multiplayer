extends Node


func play_stream(stream: AudioStream, volume = -20, pitch_scale = 1) -> void:
	if not stream:
		return
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.stream = stream
	audio_stream_player.bus = "SFX"
	audio_stream_player.volume_db = volume
	audio_stream_player.pitch_scale = pitch_scale
	add_child(audio_stream_player)
	audio_stream_player.play()
	await audio_stream_player.finished
	audio_stream_player.queue_free()
