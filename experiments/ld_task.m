function [returnCode] = ld_task(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = en_task(param)
%
% block of rest followed by a block of sequence
%
% param:            structure containing parameters (see en_parameters..m)
% returnCode:       error returned
%
%
% Vo An Nguyen 2010/10/07
% Arnaud Bore 2012/10/05, CRIUGM - arnaud.bore@gmail.com
% Arnaud Boré 2012/08/11 switch toolbox psychotoolbox 3.0
% `````````````````````````````````````````````````````````````````````
% Arnaud Bore 2014/10/31 
%                   CoRe project : 
%                        - add variable param.task to know what to do
% `````````````````````````````````````````````````````````````````````
% EG March 9, 2015  
%
% Arnaud Boutin 2015/06/25
% - Edit "createWindow.m" to induce horizontal flip of the screen
% Search for "PsychImaging"
% Arnaud Bore 2016/02/06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INIT
% CREATION OF THE WINDOW
window = createWindow(param);

onset = struct(...                              % onset vector         
    'rest',     [], ...
    'seq',      [], ...
    'seqDur',   [] ...
    );

logoriginal = [];
duration = 0;
standard = 0;

% Display first instruction
Screen('TextFont',window,'Arial');
Screen('TextSize',window, 40); 
gold = [255,215,0,255];

% Get information about the sequence: TSeq or IntSeq
% if strfind(param.task,'Day_One')
%     l_nbBlock = param.nbBlocksDayOne;
% elseif strfind(param.task, 'Day_Two')
%     l_nbBlock = param.nbBlocksDayTwo;
% else
%     error(strcat('No information is available for the task >>> ', param.task, ' >>> CHECK!!!'));
% end

l_nbBlock = param.nbBlocks;

% Get information about the task
l_nbKey = param.nbKeys;
l_seqUsed = param.seqA;
disp ('-------------------------------------------------------------------------------------------');
disp(['The task ' param.task]);
disp(['The sequence ' num2str(l_seqUsed)]);
disp(['Num of Blocks ' num2str(l_nbBlock)]);
disp(['Num of Keys ' num2str(l_nbKey)]);
disp ('::::::::::::::::::::::::::::::::::::::::::::');

if param.language == 1 % French
    DrawFormattedText(window,'REPRODUISEZ LA SÉQUENCE LE PLUS','center',100,gold);
    DrawFormattedText(window,'RAPIDEMENT ET PRECISEMENT POSSIBLE','center',200,gold);%%
    DrawFormattedText(window,num2str(l_seqUsed),'center',300,gold); %%
    DrawFormattedText(window,'... La tâche va bientôt commencer ...','center',500,gold);%%

elseif param.language == 2 % English

    DrawFormattedText(window,'PERFORM THE SEQUENCE AS FAST','center',100,gold);
    DrawFormattedText(window,'AND ACCURATE AS POSSIBLE:','center',200,gold);
    DrawFormattedText(window,num2str(l_seqUsed),'center',300,gold);
    DrawFormattedText(window,'... The task will begin momentarily ...','center',500,gold); %%
end

Screen('Flip', window);

% Wait for TTL (or keyboard input) before starting
[quit, ~, keyCode] = KbCheck(-1);
strDecoded = ld_convertKeyCode(keyCode, param.keyboard);

while isempty(strfind(strDecoded, '5'))
    [~, ~, keyCode] = KbCheck(-1);
    strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
end

param.time = fix(clock);
timeStartExperience = GetSecs;

logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = param.task;
logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = 'START';

try
    for noBlock = 1:l_nbBlock  % nb blocks/run    
        disp(['Block ' num2str(noBlock)]);
        % Rest
        onset.rest(length(onset.rest)+1) = GetSecs - timeStartExperience;
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'Rest';

        % Display cross
        [quit, keysPressed, timePressed] = displayCross(param.keyboard, window,param.durRest,0,0,'red',100);

        % Convert Keys
        keys = ld_convertMultipleKeys(keysPressed, param.keyboard);

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

        % Sequence
        onset.seq(end+1) = GetSecs - timeStartExperience;
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'Practice';
        logoriginal{end}{3} = ['Block', num2str(noBlock)];
        timeBlock = GetSecs - timeStartExperience;

        [quit, keysPressed, timePressed] = displayCross(param.keyboard, window,0,l_nbKey,0,'green',100);

        onset.seqDur(end+1) = (GetSecs-timeStartExperience) - onset.seq(end);

        % Convert keysPressed
        keys = ld_convertMultipleKeys(keysPressed, param.keyboard);

        % Find Good sequences
        str_keys = num2str(keys);
        str_l_seqUsed = num2str(l_seqUsed);

        % Display good sequences and total time 
        disp([num2str(size(strfind(str_keys,str_l_seqUsed),2)) ' good sequences  ;  ' num2str(round(10*((GetSecs - timeStartExperience) - timeBlock))/10) ' s']);
        disp(num2str(round(10*onset.seqDur)/10));

        % Record Keys
        for nbKeys = 1:length(keys)
            logoriginal{end+1}{1} = num2str(timePressed(nbKeys) - timeStartExperience );
            logoriginal{end}{2} = 'rep';
            logoriginal{end}{3} = num2str(keys(nbKeys));        
        end

        % % % % % % % % % % % % % % % 
        % Stats 
        duration(noBlock) = (GetSecs - timeStartExperience) - timeBlock;
        timeTmp = timePressed;
        for nTime = 2:length(timePressed)
            timeTmp(nTime) = timePressed(nTime) - timePressed(nTime-1);
        end
        standard(noBlock) = std(timeTmp);
    % % % % % % % % % % % % % % % 
        if quit
            logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
            logoriginal{end}{2} = 'STOP MANUALLY';
            savefile(param,logoriginal,onset);
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
    [quit, keysPressed, timePressed] = displayCross(param.keyboard, window, ...
                                    param.durRest, 0, 0, 'red', 100);
    
    % Convert keysPressed
    keys = ld_convertMultipleKeys(keysPressed, param.keyboard);

%     Record keys logoriginal
    for nbKeys = 1:length(keys)
        logoriginal{end+1}{1} = num2str(timePressed(nbKeys) - timeStartExperience);
        logoriginal{end}{2} = 'rep';
        logoriginal{end}{3} = num2str(keys(nbKeys));        
    end    
end

% Record end of task
logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = 'STOP';

% Save file
savefile(param, logoriginal, onset);

Screen('CloseAll');
disp('!!! FINISHED !!!');
returnCode = 0;