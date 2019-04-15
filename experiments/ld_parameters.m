%%
% Parameters for stim
%

currentOS = lower(system_dependent('getos'));

%% Keys = a b c d %%
param = struct(...
    'rawDir',               HOME, ... 
    'outputDir',            [HOME, 'output', filesep], ...  % output directory to save data (onset and .mat)
    'LeftOrRightHand',      1,...                           % 1 = Left Hand, 2 = Right Hand
    'flipKeys',             0,...                           % 0 = don't flip, 1 = flip keys for left Hand,
    ...                                                     % 2 = flip keys for Right Hand, 3 =both
    ...                                                     % (1 becomes 4, 2 becomes 3 and vice versa)
    'sessions',             [ 1  ;2 ;3.1 ;3.2 ;3.3 ;3.4],...% sessions to be performed
    'sessionBlocksNumber',  [ 16 ;4 ;4   ;4   ;4   ;4  ],...% number of Blocks for each session
    'sessionNumber',        1,...                           % number of sequence being performed
    'seqA',                 [4 1 3 2 4], ...                % sequence A to execute
    'seqB',                 [4 2 3 1 4], ...                % sequence B to execute
    'nbKeys',               60, ...                         % number of keys during task
    'IntroNbSeq',           3, ...                          % nb of sequences for pre-training    
    'durRest',              20,...                          % Duration of the Rest period
    'language',             1, ...                          % 1 = french (default); 2 = english
    'fullscreen',           0, ...                          % 0: subwindow, 1: whole desktop => see createWindow.m for modifications
    'numMonitor',           0, ...                          % 0: 1 monitor, 1: two monitors
    'flipMonitor',          0, ...                          % 0: don't flip, 1: flip monitor
    'os',                   currentOS ...
);

param.keyboard = KbName('KeyNames');

if strfind(currentOS,'microsoft')
    LoadPsychHID
    empties = cellfun('isempty',param.keyboard);
    param.keyboard(empties) = {'zzzzz'};
end