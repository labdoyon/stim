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

% Testing which sequences have already been performed
sessionNumber = param.sessions(1);
for i=1:length(param.sessions)
    j = param.sessions(i);
    sessionName = strcat('sesssionN', num2str(j));
    task = ['Task - ', sessionName];
    output_file_name = [param.outputDir, param.sujet,'_', ...
        task,'_', '*' ,'.mat'];
    
    % <files> will contain in a structure element all the files from
    % previous run if there has been any
    files = dir(output_file_name);
    files = {files.name};
    if ~isempty(files) && i < length(param.sessions) % the task of the session being tested has been performed
        sessionNumber = param.sessions(i+1);
    else
        break
    end
end