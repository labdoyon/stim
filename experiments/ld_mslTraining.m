function [returnCode] = ld_mslTraining(param, phase_number, test)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = ld_mslTraining(param)
%%
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
% Thibault Vlieghe 2022/08/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3; test=false; end


% INIT
% CREATION OF THE WINDOW
window = createWindow(param);

% loading param
durNoResponse = param.durNoResponse;
if ~test
    nbBlocks = param.nbMiniBlocks(phase_number) * 2;  % * 2 because there are two sequences
    maxNbBlocksSameSeq = param.maxNbMiniBlocksSameSeq;
    nbSeqPerBlock = param.nbSeqPerMiniBlock;
else
    nbBlocks = param.nbTestBlocks * 2;  % * 2 because there are two sequences
    maxNbBlocksSameSeq = param.maxNbTestBlocksSameSeq;
    nbSeqPerBlock = param.nbSeqPerTestBlock;
end
both_hands_keyboard_key_to_task_element = param.both_hands_keyboard_key_to_task_element;

white = param.white;

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
Screen('TextSize',window, param.textSize);
gold = [255,215,0,255];

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

% Generate mini blocks
sequence_a_or_b = [];
while length(sequence_a_or_b) < nbBlocks
    if length(sequence_a_or_b) < nbBlocks - 6  % 6 is purely arbitrary
        tmp_sequence_a_or_b = vertcat(ones(3,1), 2*ones(3,1));
    else
        number_mini_blocks = fix(abs(length(sequence_a_or_b) - nbBlocks) / 2);
        tmp_sequence_a_or_b = vertcat(ones(number_mini_blocks,1), ...
            2*ones(number_mini_blocks,1));
    end
    % randomize order
    tmp_sequence_a_or_b = tmp_sequence_a_or_b(randperm(numel(tmp_sequence_a_or_b)));
    % verify no uninterrupted sequence of the same 
    attempt_sequence_a_or_b = vertcat(sequence_a_or_b, tmp_sequence_a_or_b);
    longest_uninterrupted_sequence_len = max(diff(find([1,diff(attempt_sequence_a_or_b'),1])));
    if longest_uninterrupted_sequence_len <= maxNbBlocksSameSeq
        sequence_a_or_b = attempt_sequence_a_or_b;
    end
end

DrawFormattedText(window,'PERFORM THE SEQUENCE AS FAST','center',100,gold);
DrawFormattedText(window,'AND ACCURATE AS POSSIBLE','center',200,gold);
DrawFormattedText(window,'... The task will begin momentarily ...','center',500,gold); %%

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


% Display cross
[quit, keysPressed, timePressed] = displayCross(param.keyboard, window,param.durRest,0,0,'red',100);

if quit
    Screen('CloseAll')
    return
end

% TASK
for i = 1:numel(sequence_a_or_b)
     %%% PRELOAD
    if sequence_a_or_b(i) == 1
        l_seqUsed = param.seqA;
        LeftOrRightHand = param.HandSoundSequenceAssociation.seqA.hand;
        tmp_sound = param.HandSoundSequenceAssociation.seqA.sound;
    elseif sequence_a_or_b(i) == 2
        l_seqUsed = param.seqB;
        LeftOrRightHand = param.HandSoundSequenceAssociation.seqB.hand;
        tmp_sound = param.HandSoundSequenceAssociation.seqB.sound;
    end

    index_sound = find(strcmp(param.sounds, tmp_sound));
    
    if strcmp(LeftOrRightHand, 'left_hand')
        param.keyboard_key_to_task_element = param.left_hand_keyboard_key_to_task_element;
    elseif strcmp(LeftOrRightHand, 'right_hand')
        param.keyboard_key_to_task_element = param.right_hand_keyboard_key_to_task_element;
    end

    subject_has_picked_correct_sound = false;

    while ~quit && ~subject_has_picked_correct_sound
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
    
        % Show both hands
        left_image_hand = imread([param.rawDir 'stimuli' filesep 'left-hand_with-numbers.png']); % Left Hand
        right_image_hand = imread([param.rawDir 'stimuli' filesep 'right-hand_with-numbers.png']); % Right Hand
        texture_left_hand = Screen('MakeTexture', window, left_image_hand);
        texture_right_hand = Screen('MakeTexture', window, right_image_hand);
        Screen('DrawTexture',window,texture_left_hand,[],[20 20 size(left_image_hand,2) size(left_image_hand,1)]);
        Screen('DrawTexture',window,texture_right_hand,[],[20 20 size(right_image_hand,2) size(right_image_hand,1)]);
        DrawFormattedText(window, '+', 'center', 'center', white);
        Screen('Flip', window);
        
        hand_chosen = 'unset';
        left_hand_key = 0;
        right_hand_key = 0;
        [quit, key, timePressed] = displayCross(param.keyboard, window,durNoResponse,1,0,'white',100, durNoResponse);
        if quit
            Screen('CloseAll')
            break
        end
        strDecoded = ld_convertKeyCode(key, param.keyboard);
        key = ld_convertOneKey(strDecoded);
        try
            key_task_value = both_hands_keyboard_key_to_task_element(key);
        catch ME
            switch ME.identifier
                case 'MATLAB:Containers:Map:NoKey'
                    key = 0;
                otherwise
                    ME.identifier
                    rethrow(ME)
            end
        end
        disp("key_task_value")
        disp(key_task_value)
        if key_task_value == 1 % index
            try
                left_hand_key = param.left_hand_keyboard_key_to_task_element(key);
            catch ME
                switch ME.identifier
                    case 'MATLAB:Containers:Map:NoKey'
                        left_hand_key = 0;
                    otherwise
                        ME.identifier
                        rethrow(ME)
                end
            end
            if left_hand_key == 1
                hand_chosen = 'left_hand';
            end
            try
                right_hand_key = param.right_hand_keyboard_key_to_task_element(key);
            catch ME
                switch ME.identifier
                    case 'MATLAB:Containers:Map:NoKey'
                        right_hand_key = 0;
                    otherwise
                        ME.identifier
                        rethrow(ME)
                end
            end
            if right_hand_key == 1
                hand_chosen = 'right_hand';
            end
        end
        if strcmp(LeftOrRightHand, hand_chosen)
            subject_has_picked_correct_sound = true;
            break;
        end
    end

    if quit
        Screen('CloseAll')
        break
    end
    
    % Testing number of good sequences entered
    logoriginal{length(logoriginal)+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{length(logoriginal)}{2} = param.task;

    [quit, keysPressed, timePressed] = displayCross(...
        param.keyboard, window,...
        0, nbSeqPerBlock*length(l_seqUsed),...
        0,'green',100, param.durNoResponse, true, l_seqUsed);

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

    if size(strfind(str_keys,str_l_seqUsed),2) == nbSeqPerBlock && ~test
        sound(audio_signal{index_sound}, frequency{index_sound});
    end

    if quit
        Screen('CloseAll')
        break
    end

    % display red cross
    if ~test && ~quit
        jittered_rest_duration = randi(param.JitterRangeBetweenMiniBlocks);
        [quit, ~, ~] = displayCross(param.keyboard, window, jittered_rest_duration, ...
                                            0, 0, 'red', 100, jittered_rest_duration);
    elseif ~quit
        [quit, keysPressed, timePressed] = displayCross(param.keyboard, window,param.durRest,0,0,'red',100);
    end

    if quit
        Screen('CloseAll')
        break
    end

end

% Display cross
if ~quit
    [quit, keysPressed, timePressed] = displayCross(param.keyboard, window,param.durRest,0,0,'red',100);
end

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

