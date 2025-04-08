# ece532-project
Pong on Xilinx Nexys 4 DDR board.

### Overview
This repository contains many of the checkpoints for our game. The important files to find are:
- \milestone7_full-game
    - contains all required source and constraints file to run the latest version of the game
    - including all .src files and the .xdc files in this folder should be enough to run the project. Make sure that the top level is game_connect.v
        - for sound it will be required to run the MicroBlaze. This will require opening "game_sound_bsp" on the SDK. Note that "sound_bsp" is an older version and will not run as intended.
- Final Project Presentation.pdf
    - contains info about the development of our game
