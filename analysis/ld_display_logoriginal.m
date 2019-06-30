function [logoriginalFigure,logoriginal_explicit] = ld_display_logoriginal(logoriginal)
%This function plots the entries of logoriginal, output of stim motor task,
%for manual review of the raw data. It also returns logoriginal_explicit, a
%rearranged version of logoriginal much easier to review from the workspace
%
%   On the x-axis is the position of the event in logoriginal, its index.
%   On the y axis is the time stamp of the event, the recorded time when it
%   happened
%   The point shape (dot, triangle, star,...) indicates what is the event

%   Thibault Vlieghe, 2019/06/05, Montreal Neurological institute
%   thibault.vlieghe@mcgill.ca

%#ok<*NASGU>
%#ok<*AGROW>

%% logoriginal_explicit computation
logoriginal_explicit = cell(length(logoriginal),3);
for i = 1:length(logoriginal)
    logoriginal_explicit{i,1} = logoriginal{i}{1};
    logoriginal_explicit{i,2} = logoriginal{i}{2};
    if length(logoriginal{i}) > 2
        logoriginal_explicit{i,3} = logoriginal{i}{3};
    end
end

%% Displaying the raw data

% logoriginal's 2nd element (logoriginal{i}{2}) indicates what event is
% being recorded in the (i-th) entry
% Possible events include:

% regular entries
% <name of the task>    always the first entry
% 'START'           signals the start of the motor task
% 'Rest'            signals the start of a resting phase between
%                   blocks
% 'Practice'        the start of a block
% 'rep'             which means a key was pressed and recorded
% 'STOP'            Task completed without issues

% Problem-indicating entries
% 'STOP MANUALLY'   the task was manually interrupted by pressing escape or
%                   any key set for this purposer
% 'CRASH'           the task crashed
% unknown entries

key = []; key_x = []; key_time = [];
rest = []; rest_x = [];
practice = []; practice_x = [];

unknownEntries = []; unknownEntries_x = [];

for i = 1:length(logoriginal) % Read through logoriginal entries
    
    % Regular entries
    if strcmp(logoriginal{i}{2}, 'rep') % Key press
        key(end+1) = str2double(logoriginal{i}{3});
        key_time(end+1) = str2double(logoriginal{1,i}(1));
        key_x(end+1) = i;
        
    elseif strcmp(logoriginal{i}{2},'Rest') % Start of a rest phase
        rest(end+1) = str2double(logoriginal{1,i}(1));
        rest_x(end+1) = i;
        
    elseif strcmp(logoriginal{i}{2},'Practice') % Start of a task block
        practice(end+1) = str2double(logoriginal{1,i}(1));
        practice_x(end+1) = i;
    
    elseif strcmp(logoriginal{i}{2},'START') % Start of the task
        start = str2double(logoriginal{1,i}(1));
        start_x = i;
        
    elseif strcmp(logoriginal{i}{2},'STOP') % End of the task
        stop = str2double(logoriginal{1,i}(1));
        stop_x = i;
    
    % Problem-indicating entries
    elseif strcmp(logoriginal{i}{2},'STOP MANUALLY') % Task was interrupted
        stopManually = str2double(logoriginal{1,i}(1));
        stopManually_x = i;
        
    elseif strcmp(logoriginal{i}{2},'CRASH') % Task crashed
        crash = str2double(logoriginal{1,i}(1));
        crash_x = i;
        
    else % Unknown entry
        if i == 1;  taskName = logoriginal{i}{2};
        else
            unknownEntries(end+1) = str2double(logoriginal{1,i}(1));
            unknownEntries_x(end+1) = i;
        end
        
    end
end

%% Plot results

logoriginalFigure = figure;
xlabel('logoriginal entry number')
ylabel('time (s)')
if exist('taskName','var'); title(taskName);end
labels = {'keys','Resting period start','Practice block start'};

% Plot key presses as blue dots . or blue line with circles markers
if length(key_x)<20;plot_options='b-o';else;plot_options = 'b.';end
plot(key_x,key_time,plot_options)
hold on
    % Plot rest period starts as yellow left pointing triangles
    % Plot practice block starts as yellow right pointing triangles
    plot(rest_x,rest,'c<'); plot(practice_x,practice,'c>')
    % plot start as green upward-pointing triangle
    if exist('start','var')
        plot(start_x,start,'g^'); labels{end+1} = 'start';
    end
    % plot stop as green downward-pointing triangle. If it exists!
    if exist('stop','var')
        plot(stop_x,stop,'gv'); labels{end+1} = 'stop';
    end
    
    % If crashes, plot as red x
    if exist('stopManually','var')
        plot(stopManually_x,stopManually,'rx'); labels{end+1} = 'Manual stop: Tak interrupted';
    end
    if exist('crash','var')
        plot(crash_x,crash,'rx'); labels{end+1} = 'Task crashed';
    end
    % if unknown entries, plot as magenta *
    if ~isempty(unknownEntries)
        plot(unknownEntries_x,unknownEntries,'m*'); labels{end+1} = 'unknown entries';
    end
hold off

legend(labels)


% logoriginalFigure.Position(3) = logoriginalFigure.Position(3)*1.8; % to
% resize the figure so it's 1.8 wider

% subplot(1,2,1); plot(timeStamp,plot_options)
% subplot(1,2,2); bar(key)