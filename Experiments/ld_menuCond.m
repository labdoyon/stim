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
                       'Rest', ...  
                       'Verification',...
                       'Intro',...
                       'Task',...
                       'Quit'...
                       );
        sessionName = D_EXPERIMENT;
        switch choice
            case 1
                ld_rest(param);
            case 2           
                param.task = ['Verification - ', sessionName];
                ld_verification(param);        
            case 3
                param.task = ['Intro - ', sessionName];
                ld_intro(param);
            case 4
                param.task = ['Task - ', sessionName];
                if strcmp(D_EXPERIMENT, 'Condition_C')
                    ld_taskMultipleSequences(param);
                else
                    ld_task(param);
                end
            case 5
                break;
        end
    end
