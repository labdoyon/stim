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

% defining local durations
white_cross_before_sound_duration  = 0.2; % in seconds
show_hand_duration  = 3; % in seconds
red_cross_duration = 3; % in seconds

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
Screen('TextSize',window, param.textSize);
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
quit = false;

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
    
    subject_has_completed_introNb_sequences = false;
    while ~subject_has_completed_introNb_sequences && ~quit
        % display white cross for 200ms
        [quit, ~, ~] = displayCross(param.keyboard, window, white_cross_before_sound_duration, ...
                                            0, 0, 'white', 100, white_cross_before_sound_duration, false,...
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
        pause(show_hand_duration)
        
        % record keys
        % display red cross for 1 second
        [quit, ~, ~] = displayCross(param.keyboard, window, red_cross_duration, ...
                                            0, 0, 'red', 100, red_cross_duration, true, l_seqUsed);
        if quit
            Screen('CloseAll')
            break;
        end
    
        if ~quit
            % Testing number of good sequences entered
            logoriginal{length(logoriginal)+1}{1} = num2str(GetSecs - timeStartExperience);
            logoriginal{length(logoriginal)}{2} = param.task;
        
            [quit, keysPressed, timePressed] = displayCross(...
                param.keyboard, window,...
                0,param.nbSeqPerMiniBlock*length(l_seqUsed),...
                0,'green',100, 100, true, l_seqUsed);
    
            [keys_as_sequence_element,  keys_source_keyboard_value] = ...
                ld_convertMultipleKeys(keysPressed, param.keyboard, ...
                param.keyboard_key_to_task_element);
    
            % Find Good sequences
            str_keys = num2str(keys_as_sequence_element);
            str_l_seqUsed = num2str(l_seqUsed);
    
            % Display good sequences and total time
            disp([num2str(size(strfind(str_keys,str_l_seqUsed),2)) ' good sequences']);
            disp(num2str(round(10*onset.seqDur)/10));
    
            % Record Keys
            for nbKeys = 1:length(keys_as_sequence_element)
                logoriginal{end+1}{1} = num2str(timePressed(nbKeys) - timeStartExperience );
                logoriginal{end}{2} = 'rep';
                logoriginal{end}{3} = num2str(keys_as_sequence_element(nbKeys));
                logoriginal{end}{4} = num2str(keys_source_keyboard_value(nbKeys));
            end
        else
            break
        end
        % display red cross for 1 second
        [quit, ~, ~] = displayCross(param.keyboard, window, red_cross_duration, ...
                                            0, 0, 'red', 100, red_cross_duration, true, l_seqUsed);
        Screen('TextSize',window, param.textSize);
        if size(strfind(str_keys,str_l_seqUsed),2) == param.nbSeqPerMiniBlock
            subject_has_completed_introNb_sequences = true;
            DrawFormattedText(window,'You got it right!','center','center',gold);
            Screen('Flip', window);
            pause(1)
            sound(audio_signal{index_sound}, frequency{index_sound});
            pause(3)
        else
            DrawFormattedText(window,'Let s try again','center',100,gold);
            DrawFormattedText(window, '+', 'center', 'center', white);
            Screen('Flip', window);
            pause(3)
        end
    end
    % jittered rest
    pause(randi(param.JitterRangeBetweenMiniBlocks))
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
