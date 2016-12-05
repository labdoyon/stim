function [quit, keysPressed, timePressed] = displayCustomCross(currentKeyboard, window, duration, nbKeys, color, size, center, wait_max)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, keysPressed, timePressed] = en_stimCross(duration, nbKeys, color,
% size, frequence, responseBox, timeOffset)
%
% White cross in the middle of the screen blinking at a certain pace
% Cogent is required. (ESC to exit)
%
% INPUT:
%   duration:       duration of the stimulus in secs (0 = infinite)
%   nbKeys:         number of keys pressed before exit (0 = unlimited)
%   color:          'red', 'green', 'blue', 'white', 'black', 'yellow', 'orange'
%   size:           font height ex: 20, 40, 60, 80... (default=100)
%   frequence:      frequence of the blinking in Hz (0 = no blink)
%   responseBox:    0: Current Design, default (cgKeyMap), 1: kinematic (KbCheck), 2: Current Design (Release button)
%   timeOffset:     offset to add to the time vector (optional default = 0)
% OUTPUT:
%   quit:           exited before the end (ESC)? (0: no   1:yes)
%   keysPressed:    vector containing keys that have been pressed 
%   timePressed:    vector containing the time when the keys were pressed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Init
if nargin < 9; timeOffset = 0; end
if nargin < 8; wait_max = 3600; end
if nargin < 7; center = 0; end
if nargin < 6; size = 100; end
if nargin < 5; color = 'white'; end
if nargin < 4; nbKeys = 0; end
if nargin < 3; duration = 0; end
if duration == 0; duration = 3600; end

quit = 0;
keysPressed = [];
timePressed = [];

switch color
    case 'red'
        color = [255, 0, 0, 255];
    case 'green'
        color = [0, 255, 0, 255];
    case 'blue'
        color = [0, 0, 255, 255];
    case 'black'
        color = [0, 0, 0, 255];
    case 'gold'
        color = [255, 215, 0, 255];
    case 'grey'
        color = [190 190 190];
    otherwise
        color = [255, 255, 255, 255];
end

color = [color; color]';

% Display cross    
myrects = [center.X-size/4 center.Y-10 center.X+size/4 center.Y+10; center.X-10 center.Y-size/4 center.X+10 center.Y+size/4]';

Screen('FillRect', window, color, myrects); %Start Point

Screen('Flip', window);
% Read Keyboard
timeStartReading = GetSecs;
[quit, keysPressed, timePressed] = ReadKeys(currentKeyboard, timeStartReading, ...
                                       duration, nbKeys, 0, wait_max);

