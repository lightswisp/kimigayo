SAMPLE_RATE        = 8000.0  # 8Khz means it plays 8000 samples per second
PLAYBACK_SPEED     = 1
N_ITER             = (SAMPLE_RATE / PLAYBACK_SPEED).to_i
# this is just a base frequency table
NOTES              = { 
  "C"  => 16.35,
  "C#" => 17.32,
  "D"  => 18.35,
  "D#" => 19.45,
  "E"  => 20.60,
  "F"  => 21.83,
  "F#" => 23.12,
  "G"  => 24.50,
  "G#" => 25.96,
  "A"  => 27.50,
  "A#" => 29.14,
  "B"  => 30.87
}
LOW  = [0xCE].pack("c")
HIGH = [0x32].pack("c")
VOLUME = 0.9 
Note = Struct.new(:frequency, :samples_per_period, :semi_period)
Chord = Struct.new(:note, :duration)
WAVE_TYPE = 0

def get_note(note, octave)
  semitone = NOTES[note]
  return (semitone * 2**octave).round(2)
end

def get_note_by_text(note)
  n, octave = note.split("/")
  return get_note(n, octave.to_i)
end

def square_wave(i, note)
  sample_quant = i % note[:samples_per_period]
  return HIGH.unpack1("c") if sample_quant >= note[:semi_period]
  return LOW.unpack1("c")
end

def sine_wave(i, note, amplitude)
  sample_quant = i % note[:samples_per_period]
  return ((amplitude * Math.sin(Math::PI * 2 * i / (SAMPLE_RATE / note[:frequency]))))
end

def clamp(amplitude)
  return HIGH if amplitude >= HIGH.unpack1("c")
  return LOW  if amplitude <= LOW.unpack1("c")
  return [amplitude].pack("c")
end

def get_chord(notes, duration)
  # 8000 samples -> 1 sec
  samples = (duration * SAMPLE_RATE).to_i
  pcm_data = []
  samples.times do |i| 
    sum = 0
    notes.each do |note| 
      if WAVE_TYPE == 0
        sum += sine_wave(i, note, VOLUME * 100.0 / notes.length) 
      else 
        sum += square_wave(i, note) 
      end
    end
    sum_clamped = sum.round.clamp(-127*VOLUME, 127*VOLUME)
    pcm_data << [sum_clamped].pack("c") 
  end
  return pcm_data
end


ALL_NOTES = {}
# generate 12 octaves
12.times do |i|
  NOTES.each_key do |note|
    note_and_octave = "#{note}/#{i}" 
    frequency = get_note_by_text(note_and_octave)
    samples_per_period = SAMPLE_RATE / frequency
    semi_period = samples_per_period / 2
    note_final = Note.new(frequency, samples_per_period, semi_period)
    ALL_NOTES[note_and_octave] = note_final
  end
end


composition = [
  get_chord([ALL_NOTES["D/2"], ALL_NOTES["D/3"], ALL_NOTES["D/4"]], 1.091),
  get_chord([ALL_NOTES["C/3"], ALL_NOTES["C/4"], ALL_NOTES["C/2"]], 1.091),
  get_chord([ALL_NOTES["D/4"], ALL_NOTES["D/3"], ALL_NOTES["D/2"]], 1.091),
  get_chord([ALL_NOTES["E/4"], ALL_NOTES["E/2"], ALL_NOTES["E/3"]], 1.091),
  get_chord([ALL_NOTES["G/2"], ALL_NOTES["G/4"], ALL_NOTES["G/3"]], 1.091),
  get_chord([ALL_NOTES["E/4"], ALL_NOTES["E/3"], ALL_NOTES["E/2"]], 1.091),
  get_chord([ALL_NOTES["D/3"], ALL_NOTES["D/2"], ALL_NOTES["D/4"]], 1.909),
  get_chord([ALL_NOTES["E/4"]], 0.273),
  get_chord([ALL_NOTES["E/4"], ALL_NOTES["C/2"], ALL_NOTES["E/3"], ALL_NOTES["C/4"]], 1.091),
  get_chord([ALL_NOTES["G/4"], ALL_NOTES["G/3"], ALL_NOTES["E/2"], ALL_NOTES["C/4"]], 1.091),
  get_chord([ALL_NOTES["F/4"], ALL_NOTES["A/4"], ALL_NOTES["F/2"], ALL_NOTES["A/3"]], 1.091),
  get_chord([ALL_NOTES["E/4"], ALL_NOTES["G/4"], ALL_NOTES["G/3"], ALL_NOTES["E/2"]], 0.545),
  get_chord([ALL_NOTES["F/4"], ALL_NOTES["A/4"], ALL_NOTES["G/3"], ALL_NOTES["F/2"]], 0.545),
  get_chord([ALL_NOTES["F#/4"], ALL_NOTES["D/5"], ALL_NOTES["F#/3"], ALL_NOTES["F#/2"]], 1.091),
  get_chord([ALL_NOTES["G/4"], ALL_NOTES["B/4"], ALL_NOTES["G/2"], ALL_NOTES["B/2"]], 1.091),
  get_chord([ALL_NOTES["F#/4"], ALL_NOTES["D/3"], ALL_NOTES["D/2"], ALL_NOTES["A/4"]], 0.545),
  get_chord([ALL_NOTES["F#/4"], ALL_NOTES["D#/3"], ALL_NOTES["D#/2"], ALL_NOTES["A/4"]], 0.545),
  get_chord([ALL_NOTES["E/4"], ALL_NOTES["G/4"], ALL_NOTES["E/3"], ALL_NOTES["E/2"]], 1.091),
  get_chord([ALL_NOTES["E/4"], ALL_NOTES["C/3"], ALL_NOTES["C/2"], ALL_NOTES["C/4"]], 1.091),
  get_chord([ALL_NOTES["G/4"], ALL_NOTES["E/3"], ALL_NOTES["E/2"], ALL_NOTES["C/4"]], 1.091),
  get_chord([ALL_NOTES["C/3"], ALL_NOTES["F/4"], ALL_NOTES["C/2"], ALL_NOTES["A/4"]], 1.091),
  get_chord([ALL_NOTES["C/3"], ALL_NOTES["F/4"], ALL_NOTES["A/4"], ALL_NOTES["F/2"]], 1.091),
  get_chord([ALL_NOTES["F/4"], ALL_NOTES["D/5"], ALL_NOTES["D/2"], ALL_NOTES["A/3"]], 1.091),
  get_chord([ALL_NOTES["C/5"], ALL_NOTES["A/1"], ALL_NOTES["E/4"], ALL_NOTES["A/3"]], 1.091),
  get_chord([ALL_NOTES["F/4"], ALL_NOTES["D/5"], ALL_NOTES["D/2"], ALL_NOTES["A/3"]], 1.091),
  get_chord([ALL_NOTES["F/4"], ALL_NOTES["D/5"], ALL_NOTES["D/2"], ALL_NOTES["A/3"]], 0.545),
  get_chord([ALL_NOTES["D/2"]], 0.545),
  get_chord([ALL_NOTES["E/4"], ALL_NOTES["C/3"], ALL_NOTES["C/4"], ALL_NOTES["A/2"]], 1.091),
  get_chord([ALL_NOTES["G/2"], ALL_NOTES["G/4"], ALL_NOTES["C/4"], ALL_NOTES["E/3"]], 1.091),
  get_chord([ALL_NOTES["C/3"], ALL_NOTES["F/4"], ALL_NOTES["A/4"], ALL_NOTES["F/2"]], 1.091),
  get_chord([ALL_NOTES["E/2"], ALL_NOTES["C/3"], ALL_NOTES["G/4"], ALL_NOTES["C/4"]], 1.091),
  get_chord([ALL_NOTES["E/4"], ALL_NOTES["C/3"], ALL_NOTES["C/2"], ALL_NOTES["C/4"]], 0.955),
  get_chord([ALL_NOTES["C/3"], ALL_NOTES["C/2"], ALL_NOTES["C/4"]], 0.136),
  get_chord([ALL_NOTES["E/4"], ALL_NOTES["E/3"], ALL_NOTES["E/2"], ALL_NOTES["C/4"]], 0.545),
  get_chord([ALL_NOTES["G/4"], ALL_NOTES["E/3"], ALL_NOTES["E/2"], ALL_NOTES["C/4"]], 0.545),
  get_chord([ALL_NOTES["D/3"], ALL_NOTES["G/2"], ALL_NOTES["B/3"], ALL_NOTES["D/4"]], 1.636),
  get_chord([ALL_NOTES["A/4"]], 0.545),
  get_chord([ALL_NOTES["A/4"], ALL_NOTES["F/2"], ALL_NOTES["C/4"]], 1.091),
  get_chord([ALL_NOTES["F/4"], ALL_NOTES["C/5"], ALL_NOTES["F/2"], ALL_NOTES["A/3"]], 1.091),
  get_chord([ALL_NOTES["F/4"], ALL_NOTES["F/2"], ALL_NOTES["D/5"], ALL_NOTES["D/3"]], 2.182),
  get_chord([ALL_NOTES["E/4"], ALL_NOTES["C/5"], ALL_NOTES["A/2"], ALL_NOTES["E/3"]], 1.091),
  get_chord([ALL_NOTES["F/4"], ALL_NOTES["D/2"], ALL_NOTES["D/5"], ALL_NOTES["D/3"]], 1.091),
  get_chord([ALL_NOTES["A/1"], ALL_NOTES["A/4"], ALL_NOTES["A/3"]], 1.091),
  get_chord([ALL_NOTES["G/4"], ALL_NOTES["G/3"], ALL_NOTES["G/1"]], 1.091),
  get_chord([ALL_NOTES["A/1"], ALL_NOTES["A/4"], ALL_NOTES["A/3"]], 1.091),
  get_chord([ALL_NOTES["G/4"], ALL_NOTES["G/3"], ALL_NOTES["G/1"]], 0.545),
  get_chord([ALL_NOTES["E/4"], ALL_NOTES["E/3"], ALL_NOTES["E/1"]], 0.545),
  get_chord([ALL_NOTES["D/2"], ALL_NOTES["D/3"], ALL_NOTES["D/4"]], 2.318),
]


loop do 
  composition.each do |chord| 
    chord.each do |sample| 
      print(sample)
    end
  end
end
