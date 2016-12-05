%%
% Parameters for stim
%

currentOS = lower(system_dependent('getos'));

%% Keys = a b c d %%
param = struct(...
    'rawDir', HOME, ... 
    'outputDir', [HOME, 'output', filesep], ...      % output directory to save data (onset and .mat)
    'seqA',     [1 4 2 3 1], ...                     % sequence A to execute
    'nbBlocksDayOne',            10, ...             % number of blocs during task
    'nbBlocksDayTwo',            8, ...              % number of blocs during task
    'waitMax',                   2, ...             % Max wait GoNoGo
    'ratioNoGo',                0.1, ...            % Ratio of noGo
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