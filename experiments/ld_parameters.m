%%
% Parameters for stim
%

currentOS = lower(system_dependent('getos'));

%% Keys = a b c d %%
param = struct(...
    'rawDir', HOME, ... 
    'outputDir',          [HOME, 'output', filesep], ...      % output directory to save data (onset and .mat)
    'seqA',     [1 4 2 3 1], ...                    % sequence A to execute
    'seqB',     [1 2 3 4 1], ...                    % sequence B to execute
    'nbBlocks',                  16, ...                     % default number of blocks
    'nbBlocksDayOne',            10, ...                  % number of blocs during task 1
    'nbBlocksDayTwo',            8, ...                  % number of blocs during task 2
    'nbKeys',              60, ...                  % number of keys during task
    'IntroNbSeq',           3, ...                  % nb of sequences for pre-training    
    'durRest',             25,...                   %  Duration of the Rest period
    'language',             1, ...                  % 1 = french (default); 2 = english
    'fullscreen',           1, ...                  % 0: subwindow, 1: whole desktop => see createWindow.m for modifications
    'numMonitor',           1, ...                  % 1: two monitors, 0: 1 monitor
    'flipMonitor',          0, ...           
    'os',                   currentOS ...
);

param.keyboard = KbName('KeyNames');

if strfind(currentOS,'microsoft')
    LoadPsychHID
    empties = cellfun('isempty',param.keyboard);
    param.keyboard(empties) = {'zzzzz'};
end