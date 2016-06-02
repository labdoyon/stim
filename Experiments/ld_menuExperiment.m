function ld_menuExperiment(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CoRe Project
% Output: subject.mat (lines of cell) + block duration and variance
%
%----------------------------------------------
% Vo An Nguyen  2010/10/06, Universite de Montreal
% Arnaud Bore 2012/10/05, CRIUGM - arnaud.bore@gmail.com
% Arnaud Bore 2012/11/09 Switch to new psychotoolbox 3
% Arnaud Bore 2014/10/31 CoRe Project
% Arnaud Bore 2016/05/27 Stim Project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameters
if nargin < 1
    run('en_parameters');
    
    sujet=inputdlg('Code sujet:');   % prompt to enter the subject name
    if isempty(sujet)
        return;
    end
    param.sujet = sujet{1};
end

param.title = 'stim';

% Menu
nextMenu = 1;
while nextMenu
    
    choice = menu('Language','Francais','English','Quit');
    switch choice
        case 1
            param.language = 1;
        case 2
            param.language = 2; 
        case 3
            break;
    end
    ld_menuCond(param)
end

clear;
