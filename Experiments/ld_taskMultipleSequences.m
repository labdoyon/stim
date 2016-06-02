function [returnCode] = ld_taskMultipleSequences(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = en_task(param)
%
% block of rest followed by a block of sequence
%
% param:            structure containing parameters (see en_parameters..m)
% returnCode:       error returned
%
% Arnaud Bore 2015/04/16 
%                   CoRe project : 
%                        - Creation of task_mvpa file
% Arnaud Bore 2017/05/28
%                   ld project :
%                        - Task with 2 sequences random or not
% `````````````````````````````````````````````````````````````````````
% % Arnaud Bore 2016/02/06
%                   ld_stim : minor modifications
%                       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INIT
% CREATION OF THE WINDOW
window = createWindow(param);

onset = struct(...                              % onset vector         
    'rest',     [], ...
    'seq',      [], ...
    'seqDur',   [], ...
    'instruction', [] ...
    );

logoriginal = [];
duration = 0;
standard = 0;

% Display first instruction
Screen('TextFont',window,'Arial');
Screen('TextSize',window, 40 );
gold = [255,215,0,255];

% Get sequences used
% ---------------------------
try
    allSeqs = regexp(param.listSequences, ' ', 'split');
catch %#ok<CTCH>
    allSeqs = strplit(param.listSequences, ' ', 'split');
end

allSeqs = allSeqs(1:end-1);

nbSeqs = length(allSeqs);
seq_info = cell(1, nbSeqs);

for seq_i = 1:nbSeqs
    seq_info{seq_i}.seq_desc = allSeqs{seq_i};
    seq_info{seq_i}.seq = param.(seq_info{seq_i}.seq_desc);
end

% get and display the # of keys for each blcoks as well as the # of blocks for each sequence used for MVPA
% ---------------------------------------------------------------------------------------------------------
l_nbKey = param.nbKeys;
l_nbBlocks = param.nbBlocks;
disp ('-------------------------------------------------------------------------------------------');
disp(['The task ' param.task]);

if param.sequencesOrderMethod==0
    nbRepetitions = l_nbBlocks / nbSeqs + 1;
    seq_matrix =  repmat(1:nbSeqs,[1 nbRepetitions]);
elseif param.sequencesOrderMethod==1
    nbRepetitions = l_nbBlocks / nbSeqs + 1;
    seq_matrix =  repmat(1:nbSeqs,[1 nbRepetitions]);
    perm = randperm(length(seq_matrix));
    seq_matrix = seq_matrix(perm);
else
    seq_matrix = param.sequencesOrder;
end
    
disp(['Order of sequences: ' num2str(seq_matrix)])

if param.language == 1
    DrawFormattedText(window,'... Le scan va bientôt commencer ...','center',600,gold);
    Screen('Flip', window);
    
elseif param.language == 2
    DrawFormattedText(window,'... The scan will begin immediately ...','center',600,gold);
    Screen('Flip', window);
end

% Wait for TTL (or keyboard input) before starting [keyIsDown,secs,keyCode]
[quit, ~, keyCode] = KbCheck;
while (keyCode(1) == 0) && (keyCode(13) == 0) && (keyCode(53) == 0) && (keyCode(84) == 0)
    [ quit, ~, keyCode] = KbCheck;
end

param.time = fix(clock);
timeStartExperience = GetSecs;

logoriginal{length(logoriginal)+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{length(logoriginal)}{2} = param.task;
logoriginal{length(logoriginal)+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{length(logoriginal)}{2} = 'START';

% try
    for noBlock=1:l_nbBlocks  % nb Blocks/run
        l_seqUsed = seq_info{seq_matrix(noBlock)}.seq;
        l_seqUsed_Display = param.(seq_info{seq_matrix(noBlock)}.seq_desc);
        
        disp(['Block' num2str(noBlock), ' - sequence used : ' num2str(l_seqUsed)]);
        % Rest
        onset.rest(end+1) = GetSecs - timeStartExperience;
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'Rest';
        
        %     Display cross
        [quit, keysPressed, timePressed] = displayCross(window,param.durRest,0,0,'red',100);
        
        % End Rest
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'End Rest';
        
        %     Convert Keys
        [keys] = convertMultipleKeys(keysPressed);
        
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
        
        StartInstructions = GetSecs;
        onset.instruction(length(onset.instruction)+1) = StartInstructions - timeStartExperience;
        logoriginal{end+1}{1} = num2str(StartInstructions - timeStartExperience);
        logoriginal{end}{2} = 'Instruction';
        
        while (GetSecs-StartInstructions) < param.instructionDuration
            DrawFormattedText(window,num2str(l_seqUsed_Display),'center','center',gold);
            Screen('Flip', window);
        end
        
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'End Instruction';
        
        % Sequence
        onset.seq(end+1) = GetSecs - timeStartExperience;
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'Practice';
        logoriginal{end}{3} = ['Block', num2str(noBlock)];
        timeBlock = GetSecs - timeStartExperience;
        
        % Display cross
        %   Size: 100 
        %   Wait Max: 5 seconds
        [quit, keysPressed, timePressed] = displayCross(window,0,l_nbKey,0,'green',100,5);
        
        onset.seqDur(end+1) = (GetSecs-timeStartExperience) - onset.seq(end);
        
        % Convert Keys
        [keys] = convertMultipleKeys(keysPressed);
        
        % Find Good sequences
        str_keys = num2str(keys);
        str_l_seqUsed = num2str(l_seqUsed);
        
        % Display good sequences and total time
        disp([num2str(size(strfind(str_keys,str_l_seqUsed),2)) ' good sequences  ;  ' num2str(round(10*((GetSecs - timeStartExperience) - timeBlock))/10) ' s']);
        %     disp(num2str(round(10*onset.seqDur)/10));
        
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
            % Record end of task
            logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
            logoriginal{end}{2} = 'STOP MANUALLY';
            savefile(param,logoriginal,onset);
            break;
        end
    end
% catch
    % Record end of task
    logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{end}{2} = 'CRASH';
    % Save file
    savefile(param,logoriginal,onset);
% end


% Last rest after all the Blocks
if ~quit
    % Rest
    onset.rest(length(onset.rest)+1) = GetSecs - timeStartExperience;
    logoriginal{length(logoriginal)+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{length(logoriginal)}{2} = 'Rest';
    [quit, keysPressed, timePressed] = displayCross(window, ...
                            param.durRest, 0, 0, 'red', 100); %#ok<ASGLU>
    
%     Conversion Key
    [keys] = convertMultipleKeys(keysPressed);

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

% Save file.mat
savefile(param, logoriginal, onset, seq_info, seq_matrix);

Screen('CloseAll');
disp('!!! FINISHED !!!');
returnCode = 0;