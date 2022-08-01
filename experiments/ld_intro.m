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

% % Get information about the task
% l_seqUsed = param.seqA;

NbSeqOK = 0;
logoriginal = [];

timeStartExperience = GetSecs;

% Display instruction message
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 40); 
gold = [255, 215, 0, 255];
black = [0, 0, 0, 255];

% Pre-experiment text
DrawFormattedText(window,'PERFORM THE SEQUENCES SLOWLY','center',100,gold);
DrawFormattedText(window,'AND WITHOUT ANY ERRORS:','center',200,gold);
DrawFormattedText(window,'... Are you ready to continue? ...','center',600,gold);
Screen('Flip', window);

% Wait for TTL (or keyboard input) before starting
% FlushEvents('keyDown');
[~, ~, keyCode] = KbCheck(-1);
strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
while isempty(strfind(strDecoded, '5'))
    [~, ~, keyCode] = KbCheck(-1);
    strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
end
Screen('FillRect', window, BlackIndex(window));

learning_sequence_a_or_b = [1;2];
learning_sequence_a_or_b = learning_sequence_a_or_b(...
    randperm(numel(learning_sequence_a_or_b)));

% LOOP: Learning sequences
for i = 1:numel(learning_sequence_a_or_b)

    if learning_sequence_a_or_b(i) == 1
        l_seqUsed = param.seqA;
        LeftOrRightHand = param.HandSoundSequenceAssociation.seqA.hand;
    elseif learning_sequence_a_or_b(i) == 2
        l_seqUsed = param.seqB;
        LeftOrRightHand = param.HandSoundSequenceAssociation.seqB.hand;
    end

    % Show hand that will be used
    if strcmp(LeftOrRightHand, 'left_hand')
        image_hand = imread([param.rawDir 'stimuli' filesep 'left-hand_with-numbers.png']); % Left Hand
        param.keyboard_key_to_task_element = param.left_hand_keyboard_key_to_task_element;
    elseif strcmp(LeftOrRightHand, 'right_hand')
        image_hand = imread([param.rawDir 'stimuli' filesep 'right-hand_with-numbers.png']); % Right Hand
        param.keyboard_key_to_task_element = param.right_hand_keyboard_key_to_task_element;
    end
    texture_hand = Screen('MakeTexture', window, image_hand);
    Screen('DrawTexture',window,texture_hand,[],[20 20 size(image_hand,2) size(image_hand,1)]);
    Screen('Flip', window);
    
    pause(3)
    Screen('FillRect', window, BlackIndex(window));
    
    % showing the seqquence
    Screen('TextFont', window, 'Arial');
    Screen('TextSize', window, 40); 
    DrawFormattedText(window,'PERFORM THE SEQUENCE SLOWLY','center',100,gold);
    DrawFormattedText(window,'AND WITHOUT ANY ERRORS:','center',200,gold);
    DrawFormattedText(window,num2str(l_seqUsed),'center',300,gold);
    Screen('Flip', window);
    pause(5)  # TODO: put durations into experiments/ld_param.m
    
    % display red cross for 1 second
    [quit, ~, ~] = displayCross(param.keyboard, window, param.shortRest, ...
                                        0, 0, 'red', 100, param.shortRest, true, l_seqUsed);

    % subject must type sequence once correctly
    if ~quit
        % Testing number of good sequences entered
        logoriginal{length(logoriginal)+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{length(logoriginal)}{2} = param.task;
        NbSeqOK = 0;
        while (NbSeqOK < param.IntroNbSeq)
    
            % Sequence
            seqOK = 0;
            index = 0;
            keyTmp = [];
            while seqOK == 0
                [quit, key, timePressed] = displayCross(param.keyboard, window,0,1,0,'green',100, 100, true, l_seqUsed);
                if quit 
                    break; 
                end

                strDecoded = ld_convertKeyCode(key, param.keyboard);
                key = ld_convertOneKey(strDecoded);

                try
                    key = param.keyboard_key_to_task_element(key);
                catch ME
                    switch ME.identifier
                        case 'MATLAB:Containers:Map:NoKey'
                            key = 0;
                        otherwise
                            ME.identifier
                            rethrow(ME)
                    end
                end

                disp(key)
                
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
end


Screen('CloseAll');

% Save file.mat
i_name = 1;
output_file_name = [param.outputDir, param.subject, '_', param.task, '_', ...
                                            num2str(i_name), '.mat'];
while exist(output_file_name, 'file')
    i_name = i_name+1;
    output_file_name = [param.outputDir, param.subject, '_', param.task, ...
                                    '_' , num2str(i_name), '.mat'];
end
save(output_file_name, 'logoriginal', 'param'); 

returnCode = 0;