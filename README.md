# stim Task
Stimulation program using MATLAB for MSL tasks (motor sequence learning)

Current developer and curator: thibault.vlieghe@mcgill.ca
First author: arnaud.bore@gmail.com

# 1) Install

1/4 - Clone or download stim from github
https://github.com/labdoyon/stim
Don't move files around. Respect the file structure of the github repository

2/4 - Download and install Psychtoolbox
http://psychtoolbox.org/download

3/4 - Download and install FFMPEG
https://ffmpeg.org/
https://www.wikihow.com/Install-FFmpeg-on-Windows

4/4 - Add stim.m experiments/ stimuli/ analysis/ to MATLAB path
(Running stim.m will automatically add all required files to the path
for the current MATLAB session)

Advice: Keep master system volume consistent accross participants in order
to have meaningful data.

# 2) Sound Information

The values in decibel for both sounds are relative to 1) the equipment used
for the experiment and 2) the master system volume on the system at the time
of the experiment

Sometimes the first sound command of a task doesn't play. You can repeat the first sound command once. All other commands
Should complete successfully.
