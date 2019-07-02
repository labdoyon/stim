function [RawDataPlot, KeyPressesPlot, logoriginal_explicit] = ld_display_logoriginal(varargin)
%This function plots the entries of logoriginal, output of stim motor task,
%for review of the raw data. It also returns logoriginal_explicit, a
%rearranged version of logoriginal much easier to review in a spreadhseet.
%Addtionally, it proposes to visualize key presses throughout the task, as
%well as correct and incorrect sequences (provided the sequence used during
%the task is provided)
% Usage: [RawDataPlot, KeyPressesPlot, logoriginal_explicit] = ld_display_logoriginal(logoriginal)
%        [RawDataPlot, KeyPressesPlot, logoriginal_explicit] = ld_display_logoriginal(logoriginal, sequence)
%
%   On the x-axis is the position of the event in logoriginal, its index.
%   On the y axis is the time stamp of the event, the recorded time when it
%   happened
%   The point shape (dot, triangle, star,...) indicates what is the event

%   Thibault Vlieghe, 2019/07/02, Montreal Neurological institute
%   thibault.vlieghe@mcgill.ca


%%  Suppress Warnings
%#ok<*NASGU>
%#ok<*AGROW>
%#ok<*FNDSB>

%% Define variables
if nargin == 0; error('please enter logoriginal as an input'); end
logoriginal = varargin{1};
if nargin > 1; sequence = varargin{2}; end

%% logoriginal_explicit computation

% This section computes logoriginal_explicit, a rearranged version of
% logoriginal much easier to review in a spreadhseet.

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

keys = []; keys_indexes = []; key_times = []; keys_block = [];
rest_time = []; rest_index = [];
practice_time = []; practice_index = [];

unknownEntries = []; unknownEntries_x = [];

currentBlock = 1;
valid_key = 0;
for i = 1:length(logoriginal) % Read through logoriginal entries
    
    timeStamp = str2double(logoriginal{1,i}(1));
    
    %%%% Regular entries
    if strcmp(logoriginal{i}{2}, 'rep') && valid_key == 1 % Key press during practice phase
        % the actual key pressed on the keyboard
        keys(end+1) = str2double(logoriginal{i}{3});
        % Key time stamp and index
        key_times(end+1) = timeStamp; keys_indexes(end+1) = i;
        % the block the key belongs to
        keys_block(end+1) = currentBlock;
        
    elseif strcmp(logoriginal{i}{2},'Rest') % Start of a rest phase
        rest_time(end+1) = timeStamp;
        rest_index(end+1) = i;
        % we enter a rest phase, sometimes keys are recorded during this
        % period, which is an error, such entries must be ignored
        valid_key = 0;
        
    elseif strcmp(logoriginal{i}{2},'Practice') % Start of a task block
        practice_time(end+1) = timeStamp;
        practice_index(end+1) = i;
        % If there hasn't been any keys entered yet, then this is the first
        % practice block, else, this indicates the start of a new block.
        if ~isempty(keys); currentBlock = currentBlock + 1; end
        % we enter a practice phase, keys recorded during this time are valid
        valid_key = 1;
    
    elseif strcmp(logoriginal{i}{2},'START') % Start of the task
        start = timeStamp;
        start_x = i;
        
    elseif strcmp(logoriginal{i}{2},'STOP') % End of the task
        stop = timeStamp;
        stop_x = i;
        
    %%%% Problem-indicating entries
    elseif strcmp(logoriginal{i}{2},'STOP MANUALLY') % Task was interrupted
        stopManually = timeStamp;
        stopManually_x = i;
        
    elseif strcmp(logoriginal{i}{2},'CRASH') % Task crashed
        crash = timeStamp;
        crash_x = i;
        
    else % Unknown entry
        if i == 1;  taskName = logoriginal{i}{2};
        elseif strcmp(logoriginal{i}{2}, 'rep') % do nothing, spurious keys
        else
            unknownEntries(end+1) = timeStamp;
            unknownEntries_x(end+1) = i;
        end
        
    end
end

%% Logoriginal plot

RawDataPlot = figure;
if exist('taskName','var'); title(taskName);end
labels = {'keys','Resting period start','Practice block start'};

% Plot key presses as blue dots . or blue line with circles markers
if length(keys_indexes)<20;plot_options='b-o';else;plot_options = 'b.';end
plot(keys_indexes,key_times,plot_options)
hold on
    % Plot rest period starts as yellow left pointing triangles
    % Plot practice block starts as yellow right pointing triangles
    plot(rest_index,rest_time,'c<'); plot(practice_index,practice_time,'c>')
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
    % if unknown entries, plot as magenta stars, *
    if ~isempty(unknownEntries)
        plot(unknownEntries_x,unknownEntries,'m*'); labels{end+1} = 'unknown entries';
    end
hold off

% Often there are not dots plotted in the upper left corner, thus, it is a
% better location for the legend
legend(labels,'Location','NorthWest')
xlabel('logoriginal index / entry number')
ylabel('time (s)')

%% Key Presses plot

if currentBlock ~= length(practice_time)
    warning('Two measures of the number of Block don''t match!')
end
numberOfBlocks = currentBlock;

colormap = [[1 0 0] % red
            [0 0 1] % blue
            [1 1 0] % yellow
            [0 1 0] % green
    ];

KeyPressesPlot = figure;
% for i = 1:numberOfBlocks
i = 15;
%     subplot(numberOfBlocks,1,i)
    blockKeys = keys(keys_block == i);
    b = bar(blockKeys,'FaceColor','flat');
    for j = 1:4
        j_elements_positions = find(blockKeys==j); num_elements = length(j_elements_positions);
        b.CData(j_elements_positions,:) = repmat(colormap(j,:),num_elements,1);
    end
    % b.CData
    % bar subplot
    % y = [1 2 3; 4 5 6];
    % ax1 = subplot(2,1,1);
    % bar(ax1,y)
    % 
    % ax2 = subplot(2,1,2); 
    % bar(ax2,y,'stacked')
% end


% logoriginalFigure.Position(3) = logoriginalFigure.Position(3)*1.8; % to
% resize the figure so it's 1.8 wider

% subplot(1,2,1); plot(timeStamp,plot_options)
% subplot(1,2,2); bar(key)