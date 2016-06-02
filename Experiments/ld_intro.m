function [returnCode] = ld_intro(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = en_intro(param)
%
% introduction to the sequence. Exiting after x successful sequences in a
% row
%
% param:            structure containing parameters (see en_parameters.m)
% returnCode:       error returned
%
%
% Vo An Nguyen 2010/10/07
% Arnaud Bore 2012/10/05, CRIUGM - arnaud.bore@gmail.com
% Arnaud Bore 2014/10/31 
% EG March 9, 2015 
% Arnaud Bore 2016/05/27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CREATION OF THE WINDOW
window = createWindow(param);

% Get information about the task
if strfind(param.task,'Condition_A')
    l_seqUsed = param.seqA;
elseif strfind(param.task, 'Condition_B')
    l_seqUsed = param.seqB;
elseif  strfind(param.task, 'Condition_C')
    l_seqUsed = param.seqC;
else
    error(strcat('No information is available for the task >>> ', param.task, ' >>> CHECK!!!'));
end

NbSeqOK = 0;
logoriginal = [];

timeStartExperience = GetSecs;

% Display instruction message
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 40); 
gold = [255, 215, 0, 255];

if param.language == 1
    DrawFormattedText(window, ...
            'VEUILLEZ RÉALISER LENTEMENT', ...
            'center', 100, gold);
    DrawFormattedText(window, ...
            'ET SANS ERREURS LA SÉQUENCE:', ...
            'center', 200, gold);
    DrawFormattedText(window,num2str(l_seqUsed), ...
            'center', 300, gold);
    DrawFormattedText(window, ...
            '... Êtes-vous prêt a continuer? ...', ...
            'center', 600, gold);
    Screen('Flip', window);
    
elseif param.language == 2

    DrawFormattedText(window,'PERFORM THE SEQUENCE SLOWLY','center',100,gold);
    DrawFormattedText(window,'AND WITHOUT ANY ERRORS:','center',200,gold);
    DrawFormattedText(window,num2str(l_seqUsed),'center',300,gold);

    DrawFormattedText(window,'... Are you ready to continue? ...','center',600,gold);
    Screen('Flip', window);
end

% Wait for TTL (or keyboard input) before starting
[~, ~, keyCode] = KbCheck; % keyIsDown, secs, keyCode
while (keyCode(1) == 0) && (keyCode(13) == 0) && (keyCode(53) == 0) && (keyCode(84) == 0)
    [~, ~, keyCode] = KbCheck; % keyIsDown, secs, keyCode
end

% Display Red cross
% quit, keyPressed, TimePressed
[quit, ~, ~] = displayCross(window, param.durRest, ...
                                        0, 0, 'red', 100); % 

if ~quit
    % Testing number of good sequences entered
    logoriginal{length(logoriginal)+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{length(logoriginal)}{2} = param.task;
    while (NbSeqOK < param.IntroNbSeq)

        % Sequence
        seqOK = 0;
        index = 0;
        keyTmp = [];
        while seqOK == 0
            [quit, key, timePressed] = displayCross(window,0,1,0,'green',100);
            if quit 
                break; 
            end
            key = convertOneKey(key);

            logoriginal{end+1}{1} = num2str(timePressed - timeStartExperience);
            logoriginal{end}{2} = 'rep';
            logoriginal{end}{3} = num2str(key);

            index = index + 1;
            keyTmp(index) = key;
            if index >= length(l_seqUsed)
                if keyTmp == l_seqUsed
                    seqOK = 1;
                    NbSeqOK = NbSeqOK + 1;
                else
                    keyTmp(1) = [];
                    index = index - 1;
                    NbSeqOK = 0;
                end
            end
        end % End while loop: check if sequence is ok 
        if quit 
            break; 
        end
    end
end
Screen('CloseAll');

% Save file.mat
i_name = 1;
output_file_name = [param.outputDir, param.sujet, '_', param.task, '_', ...
                                            num2str(i_name), '.mat'];
while exist(output_file_name, 'file')
    i_name = i_name+1;
    output_file_name = [param.outputDir, param.sujet, '_', param.task, ...
                                    '_' , num2str(i_name), '.mat'];
end
save(output_file_name, 'logoriginal', 'param'); 

returnCode = 0;