class CustomMidiEvent {
  MidiEventType type;
  int controllerType;
  int controllerValue;
  int startTime;
  int endTime;
  int noteOnIndex;
  int controllerDeltaTime;
  int noteOnDeltaTime;
  int noteNumber;
  int noteOnVelocity;
  int noteOffDeltaTime;
  int noteOffIndex;
  int duration;
  int channel;
  CustomMidiEvent({
    MidiEventType type,
    int controllerType,
    int controllerValue,
    int startTime,
    int endTime,
    int noteOnIndex,
    int controllerDeltaTime,
    int noteOnDeltaTime,
    int noteNumber,
    int noteOnVelocity,
    int noteOffDeltaTime,
    int noteOffIndex,
    int duration,
    int channel,
  }) {
    this.type = type;
    this.controllerType = controllerType;
    this.controllerValue = controllerValue;
    this.startTime = startTime;
    this.endTime = endTime;
    this.noteOnDeltaTime = noteOnDeltaTime;
    this.controllerDeltaTime = controllerDeltaTime;
    this.noteOnIndex = noteOnIndex;
    this.noteNumber = noteNumber;
    this.noteOnVelocity = noteOnVelocity;
    this.noteOffDeltaTime = noteOffDeltaTime;
    this.noteOffIndex = noteOffIndex;
    this.duration = duration;
    this.channel = channel;
  }
}

enum MidiEventType { note, controller }
