function [quit, keysPressed, timePressed] = ReadKeys(timeStartReading ,duration, nbKeys, accept_ttl, wait_max)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, keysPressed, timePressed] = ReadKeys(timeStartReading ,duration, nbKeys);
%
% Record keys that have been pressed for a period of time. Reading at keys
% using KbCheck of the Psychtoolbox. (ESC to quit)
%
% INPUT:
%   timeStartReading
%   duration:       duration in sec before exiting (0 = no duration)
%   nbKeys:         number of keysPressed pressed before exiting (0 = unlimited)
%
% OUTPUT:
%   quit:           exited before the end (ESC)? (0: no   1:yes)
%   keysPressed:    vector containing all the keysPressed pressed
%   timePressed:    vector containing the time when the keysPressed were pressed
%
% Vo An Nguyen 2007/04/24
%
% 2008/02/14:   Add "previous" input parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init
% if nargin < 6 previous = 0; end
% if nargin < 5 keyBeep = 0; end
% if nargin < 4 clear = 1; end
% if nargin < 3 timeOffset = 0; end
% if nargin < 2 nbKey = 0; end
% if nargin < 1 duration = 0; end
if nargin < 5 wait_max = 3600; end % Check if a subject keeps pressing button
if nargin < 4 accept_ttl = 0; end % If we need the 5 to answer question
if duration == 0 duration = 3600; end % Duration of ReadKey
if nbKeys == 0 
    nbKeys = 3600; 
end
last_event = timeStartReading;
quit = 0;
keysPressed = [];
timePressed = [];

    index = 1;
    KeysWereDown = ones(1,256);
    
    while (index <= nbKeys) && (GetSecs-timeStartReading < duration) && (quit == 0) && (wait_max > GetSecs - last_event)
        [keyIsDown, secs, keyCode] = KbCheck;

        KeysPressed  = (keyCode==1) & (KeysWereDown==0);

        if ~isempty(find(KeysPressed))
            if keyCode(27)  % ESC6
                quit=1;
            elseif keyCode(53) && ~accept_ttl
                 % Do not record (TTL)
            elseif keyCode(84) && ~accept_ttl
                 % Do not record (TTL)
            elseif keyCode(160) && ~accept_ttl
                 % Do not record (TTL)
            else
                tmpKeys = find(KeysPressed);
                for i=1:length(tmpKeys)
                    timePressed(index) = secs;
                    keysPressed(index) = tmpKeys(i);
                    index = index + 1 ;
                end
                last_event = secs;
            end
        end
        KeysWereDown = keyCode;
    end
end
