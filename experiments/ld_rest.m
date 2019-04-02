function ld_rest(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = en_verification(param)
%
% Verifying if correct button is pressed for each finger
%
% param:            structure containing parameters (see parameters.m)
% returnCode:       error returned
%
%
% Vo An Nguyen 2009/03/26
% Arnaud Bore 2012/10/05, CRIUGM - arnaud.bore@gmail.com
% Arnaud Boré 2012/08/11 switch toolbox psychotoolbox 3.0
% EG March 9, 2015     
% Arnaud Boré 2016/27/05
% Arnaud Boré 2016/07/09 - Modification displayCross
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INIT
% CREATION OF THE WINDOW
window = createWindow(param);
success = 0;
while success == 0
    %     Display quit, key, time
    [~, ~, ~] = displayCross(param.keyboard, window, ...
                                                param.durRest, 0, 0, 'white', 100);
    success = 1;
end

Screen('CloseAll');