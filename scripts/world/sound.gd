extends Node
var player: AudioStreamPlayer
var impact: AudioStreamWAV
var wood: AudioStreamWAV

func setup() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	impact = make_sample(93.0)
	wood = make_sample(180.0)

func make_sample(frequency: float) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var samples: int = 4410
	var bytes := PackedByteArray()
	bytes.resize(samples*2)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(frequency)
	for i in range(samples):
		var t: float = float(i)/22050.0
		var envelope: float = exp(-t*28.0)
		var sample: int = int((sin(t*TAU*frequency)*0.6+rng.randf_range(-0.35,0.35))*envelope*16000)
		bytes.encode_s16(i*2,sample)
	stream.data = bytes
	return stream

func hit(is_wood: bool) -> void:
	if player==null:
		return
	player.stream = wood if is_wood else impact
	player.volume_db = -13
	player.play()
