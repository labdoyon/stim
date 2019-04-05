function lastSessionRan = ld_detectPreviousSessions(param)
% Detects previous sessions ran (if any) for a particular subject
%   returns 0 if no sessions have been ran for current subject
%   It is also possible output files are not stored in the current output
%   folder
%
%   if previous sessions have been ran and stored in 'stim/output' , it
%   returns the number of the last session ran
%
%   Thibault VLIEGHE, 2019/04/04

global HOME;

lastSessionRan=0;

i_name = 1;

if param.LeftOrRightHand == 1
    LeftOrRightHand = 'leftHand';
elseif param.LeftOrRightHand == 2
    LeftOrRightHand = 'rightHand';
end

% Testing which sequences have already been performed
for i=1:param.numberOfSequences
    
    sessionName = strcat('sesssionN', num2str(i));
    task = ['Task - ', sessionName];
    output_file_name = [param.outputDir, param.sujet,'_', ...
        LeftOrRightHand,'_', task,'_', num2str(i_name) ,'.mat'];
    
    if exist(output_file_name,'file') % the task of the sequence being tested has been performed
        lastSessionRan=i;
    else
        break
    end
end