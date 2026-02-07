This shall become a mobile app for jazz musicians with tools for daily practice

## Design principles

keep it simple! UI design should be very clean and sober. 
Use good UX practices

## functionality

A first functionality shall be a random piano note generator.
The user can select the tonal range of their instrument freely within the range of a grand piano. Offer range presets for Tenor Saxophone and Alto Flute

Then, the user can define the tempo:
* number of beats per note (default 4)
* bpm (default 80)

based on these settings, the app generates Piano notes randomly within the range configured

A switch will turn on/off Piano output
Another switch will on/off the metronome clicks (one per beat) 

The user shall be able to make changes in real time, so ensure whatever sound library you use is reactive and strictly keeps time when changes are made.

Make use of sound libraries available under some CC license.



## Project Context
This is a Flutter Android project using Dart.

## Commands
- `flutter analyze` — run before suggesting code is done
- `flutter test` — run tests
- `flutter build apk` — build Android APK
- `dart format .` — format code

## Conventions
- Use Riverpod for state management
- Follow Material 3 design guidelines
- All widgets should be const where possible
- Prefer composition over inheritance for widgets
- Write widget tests for all screens

## Project Structure
- lib/src/features/ — feature-first organization
- lib/src/common/ — shared widgets and utilities
- test/ — mirrors lib/ structure
