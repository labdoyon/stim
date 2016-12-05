function [returnCode] = ld_gonogo(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = ld_gonogo(param)
%
% param:            structure containing parameters (see en_parameters..m)
% returnCode:       error returned
%
% Arnaud Bore 2016/11/24 
%   CTRL Task: GoNoGo
% `````````````````````````````````````````````````````````````````````
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INIT
% CREATION OF THE WINDOW
createWindow(param);
Screen('Preference', 'SkipSyncTests', 2);

onset = struct(...                              % onset vector         
    'rest',     [], ...
    'seq',      [], ...
    'seqDur',   [] ...
    );

logoriginal = [];
duration = 0;
gold = [255,215,0,255];
colorGrey = [190,190,190,190; 190,190,190,190]';

% Get information about the sequence
if strfind(param.task,'Day_One')
    l_nbBlock = param.nbBlocksDayOne;
elseif strfind(param.task, 'Day_Two')
    l_nbBlock = param.nbBlocksDayTwo;
else
    error(strcat('No information is available for the task >>> ', param.task, ' >>> CHECK!!!'));
end

% Get information about the task nbKey == nbTarget
l_nbTarget = param.nbKeys;

disp ('-------------------------------------------------------------------------------------------');
disp(['The task ' param.task]);
disp(['Num of Blocks ' num2str(l_nbBlock)]);
disp(['Num of Targets ' num2str(l_nbTarget)]);
disp ('::::::::::::::::::::::::::::::::::::::::::::');

whichScreen = 0; % If one monitor
param.view.res = get(0,'ScreenSize');
param.view.res = param.view.res(3:4);
if param.numMonitor == 1 && max(Screen('Screens')) == 2
    whichScreen = 2; % If two monitors
    res = Screen('Resolution', whichScreen);
    param.view.res = [res.width res.height];
end

param.view.monitor = sqrt(sum((param.view.res/get(0,'ScreenPixelsPerInch')).^2)); % Size in inches of the screen
param.view.screen = (((param.view.res(1)^2)+(param.view.res(2)^2))^0.5)/(param.view.monitor * 2.54); %Resolution / size of screen

param.target.distanceInCM = 1.5; % [cm] Distance from the centre of the screen to the target. 
param.target.distance = param.target.distanceInCM * param.view.screen;            % distance in CM to pixels
param.target.dimTarget = 0.4 * param.view.screen / 2;        % Target size in Cm to px

[param.targets, param.gonogo] = ld_createGonogoMatrices(l_nbTarget, l_nbBlock, 8, param.ratioNoGo);

param.clrdepth=32; % Hardcoded visualisation

if whichScreen == 2
    [window, theRect]=Screen('OpenWindow', whichScreen, [], [-param.view.res(1)*3/4 param.view.res(2)*1/4 -param.view.res(1)/4 param.view.res(2)*3/4], param.clrdepth);
else
    [window, theRect]=Screen('OpenWindow', whichScreen, 0, [param.view.res(1)/4 param.view.res(2)/4 param.view.res(1)*3/4 param.view.res(2)*3/4], param.clrdepth);
end

Screen('FillRect', window, BlackIndex(window));
param.view.X = theRect(RectRight)/2; %X coordinate for screen centre 
param.view.Y = theRect(RectBottom)/2; %Y coordinate for screen centre 
center.X = param.view.X;
center.Y = param.view.Y;

% Custom Cross
customCross = [center.X-param.target.dimTarget/4 center.Y-10 center.X+param.target.dimTarget/4 center.Y+10; center.X-10 center.Y-param.target.dimTarget/4 center.X+10 center.Y + param.target.dimTarget/4]';

% Position of 8 targets
for i=0:7
    param.posXtarget(i+1)=floor(floor(param.view.X)-(sind(360-(i*45)) * param.target.distance));
    param.posYtarget(i+1)=floor(floor(param.view.Y)-(cosd(360-(i*45)) * param.target.distance));
end

%% Show instructions
if param.language == 1 % French
    DrawFormattedText(window, 'PRESSEZ UNE TOUCHE ', 'center', 100, gold);
    DrawFormattedText(window, 'LORSQUE LA CIBLE EST VERTE', 'center', 200, gold);%%
    DrawFormattedText(window, '... La tache va bientôt commencer ...','center',300,gold);%%

elseif param.language == 2 % English

    DrawFormattedText(window,'PRESS A BUTTON','center',100,gold);
    DrawFormattedText(window,'WHEN THE TARGET IS GREEN','center',200,gold);
    DrawFormattedText(window,'... The task will begin momentarily ...','center',300,gold); %%
end

Screen('Flip', window);

%% Wait for TTL (or keyboard input) before starting
[quit, ~, keyCode] = KbCheck(-1);
strDecoded = ld_convertKeyCode(keyCode, param.keyboard);

while isempty(strfind(strDecoded, '5'))
    [~, ~, keyCode] = KbCheck(-1);
    strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
end

Screen('FillRect', window, BlackIndex(window));

%% Begining of the task
param.time = fix(clock);
timeStartExperience = GetSecs;

logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = param.task;
logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = 'START';

try
    for noBlock = 1:l_nbBlock  % nb blocks/run
        disp(['Block ' num2str(noBlock)]);
        
        %% Rest
        onset.rest(length(onset.rest)+1) = GetSecs - timeStartExperience;
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'Rest';
        
%         Display cross
        [quit, keysPressed, timePressed] = displayCustomCross(param.keyboard, window, param.durRest, 0, 'red', param.target.dimTarget, center);
        
%         Convert Keys
        keys = ld_convertMultipleKeys(keysPressed, param.keyboard);
               
        for nbKeys = 1:length(keys)
            logoriginal{end+1}{1} = num2str(timePressed(nbKeys) - timeStartExperience );
            logoriginal{end}{2} = 'rep';
            logoriginal{end}{3} = num2str(keys(nbKeys));
        end
        
        if quit
            % Record end of task
            logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
            logoriginal{end}{2} = 'STOP MANUALLY';
            savefile(param,logoriginal,onset);
            break;
        end
        
        %% Task         
        for noTarget = 1:l_nbTarget
            % Current trial
            position.X = param.posXtarget(param.targets(noBlock, noTarget));
            position.Y = param.posYtarget(param.targets(noBlock, noTarget));
            
            % Display cross
            Screen('FillRect', window, colorGrey, customCross); %Start Point
            
            if param.gonogo(noBlock, noTarget)==0 %NoGo --> Red Target
                currentColor = 'red';
            else %Go --> Green Target
                currentColor = 'green';
            end
            [quit, keysPressed, timePressed] = displayTarget(param.keyboard, window, duration, 1, currentColor, param.target.dimTarget, param.waitMax, position);

            % Convert Keys
            keys = ld_convertMultipleKeys(keysPressed, param.keyboard);            
            
            % Record Keys
            if isempty(keys) % If no response
                keys(1) = 9;
                timePressed(1) = 0;
            end
            
            % Record Keys
            for nbKeys = 1:length(keys)
                logoriginal{end+1}{1} = num2str(timePressed(nbKeys) - timeStartExperience );
                logoriginal{end}{2} = 'rep';
                logoriginal{end}{3} = num2str(keys(nbKeys));
            end
            
            if quit
                % Record end of task
                logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
                logoriginal{end}{2} = 'STOP MANUALLY';
                savefile(param,logoriginal,onset);
                break; 
            end
        end
        
        %% Last Rest
        onset.rest(length(onset.rest)+1) = GetSecs - timeStartExperience;
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'Rest';
%         Display cross
        [quit, keysPressed, timePressed] = displayCustomCross(param.keyboard, window, param.durRest, 0, 'red', param.target.dimTarget, center);
        
%         Convert Keys
        keys = ld_convertMultipleKeys(keysPressed, param.keyboard);
        
%         Record Keys
        for nbKeys = 1:length(keys)
            logoriginal{end+1}{1} = num2str(timePressed(nbKeys) - timeStartExperience );
            logoriginal{end}{2} = 'rep';
            logoriginal{end}{3} = num2str(keys(nbKeys));
        end
        if quit
            % Record end of task
            logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
            logoriginal{end}{2} = 'STOP MANUALLY';
%             savefile(param,logoriginal,onset);
            break;
        end      
    end
catch %#ok<CTCH>
    % Record end of task
    logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{end}{2} = 'CRASH';
    % Save file
    savefile(param,logoriginal,onset);
end
% Last rest after all the Blocks
if ~quit
    % Rest
    onset.rest(length(onset.rest)+1) = GetSecs - timeStartExperience;
    logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{end}{2} = 'Rest';
	[~, ~, ~] = displayCustomCross(param.keyboard, window, param.durRest, 0, 'red', param.target.dimTarget, center);
end

% Record end of task
logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = 'STOP';

% Save file
savefile(param, logoriginal, onset);

Screen('CloseAll');
disp('!!! FINISHED !!!');
returnCode = 0;