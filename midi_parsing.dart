import 'dart:io';
import 'package:dart_midi/dart_midi.dart';

void main() {
  getMidi();
}

getMidi() async {
  String fileName = 'belovedSon';
  var file = File('$fileName.mid');
  var parser = MidiParser();

  MidiFile parsedMidi = parser.parseMidiFromFile(file);

  var writer = MidiWriter();

  List<List<MidiEvent>> midiTracks = parsedMidi.tracks;

  var track = midiTracks[0];

  int chordBufferRange = 120;

  List<NoteOnEvent> adjustedNoteOns = [];

  int totalAdjustedDelta = 0;

  track.asMap().forEach((index, event) {
    if (event.type == 'noteOn') {
      NoteOnEvent newNote = event;
      if (event.deltaTime < chordBufferRange) {
        if (track
                .sublist(0, index)
                .where((event) => event.type == 'noteOn')
                .length >
            0) {
          // print(
          //     'adding index $index. note number added is:   ${newNote.noteNumber}');

          adjustedNoteOns.add(newNote);
          totalAdjustedDelta += newNote.deltaTime;
          newNote.deltaTime = 0;
        }
        track[index] = newNote;
      } else {
        track[index].deltaTime += totalAdjustedDelta;
        totalAdjustedDelta = 0;
      }
    }

    // else if (event.type == 'noteOff' && adjustedNoteOns.length > 0) {
    //   NoteOffEvent newNoteOff = event;
    //   print('found note off, adjustNoteOns is ${adjustedNoteOns}');
    //   print('current index in operation is $index');
    //   var i = adjustedNoteOns
    //       .indexWhere((noteOn) => noteOn.noteNumber == newNoteOff.noteNumber);
    //   print(newNoteOff.noteNumber);
    //   print('this is i $i');
    //   if (i >= 0) {
    //     print('trying to adjust');
    //     newNoteOff.deltaTime += adjustedNoteOns[i].deltaTime;
    //     track[index] = newNoteOff;
    //     print('removing adjustedNote at $i');
    //     adjustedNoteOns.removeAt(i);
    //   }
    // }
  });

  var midiFile = MidiFile([track], parsedMidi.header);

  writer.writeMidiToFile(midiFile, File('../${fileName}Converted.mid'));
}

void badParsingLogic() {
  String fileName = 'moreSimple';
  var file = File('$fileName.mid');
  var parser = MidiParser();

  MidiFile parsedMidi = parser.parseMidiFromFile(file);

  var writer = MidiWriter();

  List<List<MidiEvent>> midiTracks = parsedMidi.tracks;

  int chordBufferRange = 80;

  // List<NoteOnEvent> adjustedNoteOns = [];
  var track = midiTracks[0];
  for (var index = 0; index < track.length; index++) {
    MidiEvent event = track[index];

    if (event.type == 'noteOn' &&
        event.deltaTime < chordBufferRange &&
        event.deltaTime != 0) {
      print(
          'found a note on that is not 0 and lower than chordBuffer range. Index $index');
      // find start of chord
      int startIndexOfChord = 0;
      List<int> listOfNoteIndexesInChord = [];

      // find start of block chord
      for (var i = index; i > 0; i--) {
        print('here is the index of the first check for start of chord: $i');
        if (track[i].type == 'noteOn') {
          NoteOnEvent startOfChord = track[i];
          if (startOfChord.deltaTime > chordBufferRange) {
            startIndexOfChord = i;
            listOfNoteIndexesInChord.add(startIndexOfChord);
            print('breaking loop for starting index $i');
            break;
          }
        }
      }
      // get all indexes of notes in chord
      for (var i = startIndexOfChord; i < startIndexOfChord; i++) {
        print('trying to get the start indexes of all notes in chord');
        if (track[i].type == 'noteOn' &&
            track[i].deltaTime < chordBufferRange) {
          listOfNoteIndexesInChord.add(i);
          print('adding index of note in chord: $i');
        } else if (track[i].deltaTime > chordBufferRange) {
          print(
              'found the next note that is note part of the chord. Breaking now.');
          break;
        }
      }

      // move all notes in chord to line up with start of chord.

      listOfNoteIndexesInChord.forEach((index) {
        if (index > 0) {
          print('changing the delta time of index $index to 0');
          track[index].deltaTime = 0;
        }
      });
    }
  }
}
