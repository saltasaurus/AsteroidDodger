# Asteroid Dodger Game Design Document
This is my first Godot4 game, initially based on the original Godot2D "[Your first 2D game][first-2d-game]".\
From there, I modified the source code to include my initial ideas.

[first-2d-game]: https://docs.godotengine.org/en/stable/getting_started/first_2d_game/index.html

## Core conepts
1. Space themed
1. Dodge asteroids
1. Use only mouse
1. Easy, Replayable, Quick

## Each round
Every round of play is completely independent. The score increases based on time alive, but the difficulty also increases with time.\
The only goal is to not get hit as asteroids spawn and fly into the screen.

## Physics
To simulate space, no gravity or air resistance/linear drag is applied. All collisions and bouncing are handled by the physics engine, with defaults applied except for bounciness, which is given a value of 1 (full bounciness - no loss of momentum).\
Asteroid mass is calculated based on their size so they have the correct collision handling.

## Visuals
Mainly pixel art, as all assets are hand drawn by myself except the background. This should give it a nice retro feel.
