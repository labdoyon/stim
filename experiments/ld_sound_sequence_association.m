function [returnCode] = ld_sound_sequence_association(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = ld_sound_sequence_association(param)
%
% explained later
%
% param:            structure containing parameters (see en_parameters.m)
% returnCode:       error returned
%
%
% Thibault Vlieghe, 2022-08-03
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CREATION OF THE WINDOW, initializing experiment
window = createWindow(param);
logoriginal = [];
timeStartExperience = GetSecs;

onset = struct(...                              % onset vector         
    'rest',     [], ...
    'seq',      [], ...
    'seqDur',   [] ...
    );

logoriginal = [];
duration = 0;
standard = 0;

% load sound volume adjustment in dB
i_name = 1;
output_file_name = [param.outputDir, param.subject, '_', 'Step-1_sound-volume-adjustment', '_', ...
                                            num2str(i_name), '.mat'];
while exist(output_file_name, 'file')
    i_name = i_name+1;
    output_file_name = [param.outputDir, param.subject, '_', 'Step-1_sound-volume-adjustment', ...
                                    '_' , num2str(i_name), '.mat'];
end
i_name = i_name-1;
output_file_name = [param.outputDir, param.subject, '_', 'Step-1_sound-volume-adjustment', ...
                                '_' , num2str(i_name), '.mat'];
load(output_file_name, 'sound_adjustment')
param.sound_adjustment = sound_adjustment;


% Preload the sound
audio_signal = cell(length(param.sounds),1);
frequency = cell(length(param.sounds),1);
for index_sound = 1:length(param.sounds)
    sound_i = param.sounds{index_sound};
    sound_i_fullpath = ['stimuli\' sound_i];
    tmp_sound = ['stimuli\' 'sound' num2str(index_sound) '.wav'];
    command = horzcat(...
        'ffmpeg -loglevel quiet -y -i ', sound_i_fullpath,...
        ' -filter:a "volume=', ...
        num2str(param.sound_adjustment(index_sound)), 'dB" ', ...
        tmp_sound, ' -nostdin');
    disp(command)
    system(command);
    [audio_signal{index_sound}, frequency{index_sound}] = ...
        audioread(tmp_sound);
end

% Display first instruction
Screen('TextFont',window,'Arial');
Screen('TextSize',window, 40); 
gold = [255,215,0,255];
white = [255, 255, 255, 255];

DrawFormattedText(window,'ASSOCIATE THE SEQUENCE','center',100,gold);
DrawFormattedText(window,'WITH THE SOUND','center',200,gold);
DrawFormattedText(window,'... The task will begin momentarily ...','center',300,gold); %%
Screen('Flip', window);


% Wait for TTL (or keyboard input) before starting
% FlushEvents('keyDown');
[~, ~, keyCode] = KbCheck(-1);
strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
while isempty(strfind(strDecoded, '5'))
    [~, ~, keyCode] = KbCheck(-1);
    strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
end

% Randomization: starting with left or right
learning_sequence_a_or_b = [1;2];
learning_sequence_a_or_b = learning_sequence_a_or_b(...
    randperm(numel(learning_sequence_a_or_b)));

% LOOP: Associating sequence with sound
for i = 1:numel(learning_sequence_a_or_b)

    %%% PRELOAD
    if learning_sequence_a_or_b(i) == 1
        l_seqUsed = param.seqA;
        LeftOrRightHand = param.HandSoundSequenceAssociation.seqA.hand;
        tmp_sound = param.HandSoundSequenceAssociation.seqA.sound;
    elseif learning_sequence_a_or_b(i) == 2
        l_seqUsed = param.seqB;
        LeftOrRightHand = param.HandSoundSequenceAssociation.seqB.hand;
        tmp_sound = param.HandSoundSequenceAssociation.seqB.sound;
    end

    index_sound = find(strcmp(param.sounds, tmp_sound));
    
    if strcmp(LeftOrRightHand, 'left_hand')
        image_hand = imread([param.rawDir 'stimuli' filesep 'left-hand_with-numbers.png']); % Left Hand
        param.keyboard_key_to_task_element = param.left_hand_keyboard_key_to_task_element;
    elseif strcmp(LeftOrRightHand, 'right_hand')
        image_hand = imread([param.rawDir 'stimuli' filesep 'right-hand_with-numbers.png']); % Right Hand
        param.keyboard_key_to_task_element = param.right_hand_keyboard_key_to_task_element;
    end
    
    
    % display white cross for 200ms
    [quit, ~, ~] = displayCross(param.keyboard, window, 0.2, ...
                                        0, 0, 'white', 100, 0.2, false,...
                                        []);
    if quit
        Screen('CloseAll')
        break;
    end

    % PLAY THE SOUND
    sound(audio_signal{index_sound}, frequency{index_sound});

    % Show hand that will be used
    texture_hand = Screen('MakeTexture', window, image_hand);
    Screen('DrawTexture',window,texture_hand,[],[20 20 size(image_hand,2) size(image_hand,1)]);
    DrawFormattedText(window, '+', 'center', 'center', white);
    Screen('Flip', window);
    pause(4)  % TODO: put into experiments/ld_parameters.m

    % record keys
    % display red cross for 1 second
    [quit, ~, ~] = displayCross(param.keyboard, window, param.shortRest, ...
                                        0, 0, 'red', 100, param.shortRest, true, l_seqUsed);
    if quit
        Screen('CloseAll')
        break;
    end

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
                disp(quit)
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
    else
        break
    end
    % display red cross for 1 second
    [quit, ~, ~] = displayCross(param.keyboard, window, param.shortRest, ...
                                        0, 0, 'red', 100, param.shortRest, true, l_seqUsed);

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

end
