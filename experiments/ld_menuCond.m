function ld_menuCond(param)
%MENU_D_ONE Summary of this function goes here
%   Detailed explanation goes here
%
%
% Vo An Nguyen 2010/10/07
% Arnaud Bore 2012/10/05, CRIUGM - arnaud.bore@gmail.com
% Arnaud Bore 2014/10/31 
% EG March 9, 2015     
% Arnaud Bore 2016/06/02
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global D_EXPERIMENT;
    nextMenu = 1;
    
    while nextMenu
        choice = menu(...
                       strcat('Menu - ', D_EXPERIMENT),...
                       'Step 1: Adjust sounds volumes',...
                       'Step 2: Checking keyboard',...
                       'Step 3: Sequence Familiarization', ...
                       'Step 4: Association of the sequences and sound',...
                       'Task',...
                       'Quit'...
                       );
        sessionName = D_EXPERIMENT;
        switch choice
            case 1
                param.task = ['Step-1_sound-volume-adjustment', sessionName];
                ld_adjustVolume(param);
            case 2
                param.task = ['Verification - ', sessionName];
                ld_verification(param);
            case 3
                param.task = ['Phase 1 - ', sessionName];
                ld_intro(param);
            case 4
                param.task = ['Phase 2 - ', sessionName];
                ld_sound_sequence_association(param);
            case 5
                param.task = ['Task - ', sessionName];
                ld_task(param);
            case 6
                break;
        end
    end
