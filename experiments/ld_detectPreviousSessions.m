function sessionNumber = ld_detectPreviousSessions(param)
% Detects previous sessions ran (if any) for a particular subject
%   returns 0 if no sessions have been ran for current subject
%   It is also possible output files are not stored in the current output
%   folder
%
%   if previous sessions have been ran and stored in 'stim/output' , it
%   returns the number of the last session ran
%
%   Thibault VLIEGHE, 2019/04/04

% to reconstruct the file(s) name(s)
if param.LeftOrRightHand == 1
    LeftOrRightHand = 'leftHand';
elseif param.LeftOrRightHand == 2
    LeftOrRightHand = 'rightHand';
end

sessionNumber = 1; % if the first session has not been performed

% Testing which sequences have already been performed
for i=1:param.numberOfSessions
    
    sessionName = strcat('sesssionN', num2str(i));
    task = ['Task - ', sessionName];
    output_file_name = [param.outputDir, param.sujet,'_', ...
        LeftOrRightHand,'_', task,'_', '*' ,'.mat'];
    
    % <files> will contain in a structure element all the files from
    % previous run if there has been any
    files = dir(output_file_name);
    files = {files.name};
    if ~isempty(files) % the task of the session being tested has been performed
        sessionNumber=i+1;
    else
        break
    end
end