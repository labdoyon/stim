%%
% Parameters for stim
%

currentOS = lower(system_dependent('getos'));

%% Keys = a b c d %%
param = struct(...
    'rawDir',           HOME, ... 
    'outputDir',        [HOME, 'output', filesep], ...      % output directory to save data (onset and .mat)
    'LeftOrRightHand',  1,...                   % 1 = Left Hand, 2 = Right Hand
    'seqA',             [2 4 1 3 4 2 3 1], ...        % sequence A to execute
    'seqB',             [2 1 4 3 2 3 4 1], ...        % sequence B to execute
    'nbBlocks',         2, ...                  % number of blocs during task
    'nbBlocksDayOne',   10, ...                 % number of blocs during task
    'nbBlocksDayTwo',   8, ...                  % number of blocs during task
    'nbKeys',           20, ...                 % number of keys during task
    'IntroNbSeq',       1, ...                  % nb of sequences for pre-training    
    'durRest',          20,...                  % Duration of the Rest period
    'language',         1, ...                  % 1 = french (default); 2 = english
    'fullscreen',       0, ...                  % 0: subwindow, 1: whole desktop => see createWindow.m for modifications
    'numMonitor',       0, ...                  % 0: 1 monitor, 1: two monitors
    'flipMonitor',      0, ...                  % 0: don't flip, 1: flip monitor
    'os',               currentOS ...
);

param.keyboard = KbName('KeyNames');

param.hands = {'left_hand'; 'right_hand'};
param.sounds = {'sound1'; 'sound2'};

if strfind(currentOS,'microsoft')
    LoadPsychHID
    empties = cellfun('isempty',param.keyboard);
    param.keyboard(empties) = {'zzzzz'};
end