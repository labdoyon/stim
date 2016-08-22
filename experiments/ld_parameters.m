%%
% Parameters for stim
%

currentOS = lower(system_dependent('getos'));
currentKeyboard = zeros(1,256);

if strfind(currentOS, 'microsoft')
    currentKeyboard = KbName('KeyNamesWindows');
elseif strfind(currentOS, 'linux')
    currentKeyboard = KbName('KeyNamesLinux');
elseif strfind(currentOS, 'osx')
    currentKeyboard = KbName('KeyNamesOSX');
else
    disp('This program wont work correctly because it was not able to detect OS')
end

param.keyboard = currentKeyboard;

%% Keys = a b c d %%
param = struct(...
    'rawDir', HOME, ... 
    'outputDir',          [HOME, 'output', filesep], ...      % output directory to save data (onset and .mat)
    'seqA',     [4 1 3 2 4], ...                    % sequence A to execute
    'seqB',     [1 4 2 3 1], ...                    % sequence B to execute
    'seqC', [1 1 1 1 1], ...                        % sequence C to execute
    'seqD', [4 4 4 4 4], ...                        % sequence D to execute
    'listSequences' , 'seqC seqD ', ...             % List for multiple sequences Task
    'sequencesOrderMethod', 0, ...                  % 0: alternate between sequences, 1: random Sequences Order, 2 use sequencesOrder
    'sequencesOrder', [1 2 1 2 1 2 1 2 1 2], ...    % Order of sequences used for multipleTask need to be equal to nbBlocks
    'instructionDuration',  4, ...                  % Instruction duration
    'nbBlocks',            10, ...                  % number of blocs during task
    'nbKeys',              60, ...                  % number of keys during task
    'IntroNbSeq',           3, ...                  % nb of sequences for pre-training    
    'durRest',             25,...                   %  Duration of the Rest period
    'language',             1, ...                  % 1 = french (default); 2 = english
    'fullscreen',           1, ...                  % 0: subwindow, 1: whole desktop => see createWindow.m for modifications
    'numMonitor',           1, ...                  % 1: two monitors, 0: 1 monitor
    'flipMonitor',          0, ...           
    'os',                   currentOS ...
);