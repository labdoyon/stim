function [quit, keysPressed, timePressed] = displayCross(...
    currentKeyboard, ...
    window, ...
    duration, ...
    nbKeys, ...
    frequency, ...
    color, ...
    size, ...
    wait_max, ...
    display_sequence_above_cross, ...
    sequence, ...
    text_size)
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
% if nargin < 7 timeOffset = 0; end
if nargin < 11; text_size = 40; end
if nargin < 9; display_sequence_above_cross = false; sequence=[]; end
if nargin < 8; wait_max = 3600; end
if nargin < 7; size = 100; end
if nargin < 6; color = 'white'; end
if nargin < 5; frequency = 0; end
if nargin < 4; nbKeys = 0; end
if nargin < 3; duration = 0; end
if duration == 0; duration = 3600; end

quit = 0;
keysPressed = [];
timePressed = [];
gold = [255, 215, 0, 255];


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
    otherwise
        color = [255, 255, 255, 255];
end
if (frequency == 0)
    % Display cross    
    Screen('TextFont', window, 'Arial');
    Screen('TextSize', window, text_size);
    if display_sequence_above_cross
        DrawFormattedText(window, num2str(sequence), 'center',100, gold);
    end
    Screen('TextSize', window, size);
    DrawFormattedText(window, '+', 'center', 'center', color);
    Screen('Flip', window);
    % Read Keyboard
    timeStartReading = GetSecs;
    [quit, keysPressed, timePressed] = ReadKeys(currentKeyboard, timeStartReading, ...
                                           duration, nbKeys, 0, wait_max);

else
    timeStartExperience = GetSecs;
    while (GetSecs-timeStartExperience) < duration
        % Display cross    
        timeStartReading = GetSecs;
        Screen('TextFont',window, 'Arial');
        Screen('TextSize',window, size );
        DrawFormattedText(window, '+', 'center', 'center', color);
        Screen('Flip', window);
        
        [quit, keysTmp, timeTmp] = ReadKeys(currentKeyboard, timeStartReading, ...
                                                (1/frequency)/2, 0);
        keysPressed = cat(2, keysPressed, keysTmp);
        timePressed = cat(2, timePressed, timeTmp);
        if quit; break; end
        if GetSecs-timeStartExperience >= duration; break; end    

        % Display black screen
        
        Screen('FillRect', window, BlackIndex(window));
        Screen('Flip', window);
        % Capture keys
        timeStartReading = GetSecs;
        [quit, keysTmp, timeTmp] = ReadKeys(currentKeyboard, timeStartReading, ...
                                                (1/frequency)/2, 0);
        keysPressed = cat(2, keysPressed, keysTmp);
        timePressed = cat(2, timePressed, timeTmp);
        if quit; break; end
    end
end
