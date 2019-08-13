function [RawDataPlot, KeyPressesPlot, logoriginal_explicit] = ld_display_logoriginal(logoriginal,param)
%This function plots the entries of logoriginal, output of stim motor task,
%for review of the raw data. It also returns logoriginal_explicit, a
%rearranged version of logoriginal much easier to review in a spreadhseet.
%Addtionally, it proposes to visualize key presses throughout the task, as
%well as correct and incorrect sequences
% Usage: [RawDataPlot, KeyPressesPlot, logoriginal_explicit] = ld_display_logoriginal(logoriginal,param)
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

%% Check and assign variables
% if nargin == 0; error('please enter logoriginal as an input'); end
% if ~iscell(varargin{1}) || size(varargin{1},1)~=1
%         error('First input should be logoriginal. logoriginal should be a 1*nbEntries cell')
% end
% logoriginal = varargin{1}; sequence_exist = false;
% if nargin > 1; sequence = varargin{2}; sequence_exist = true; end
if isfield(param,'sequence')
    sequence = param.sequence; sequence_exist = true;
elseif isfield(param,'seqA')
    sequence = param.seqA; sequence_exist = true;
else
    sequence_exist = false;
end

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
        % record the actual key pressed on the keyboard
        keys(end+1) = str2double(logoriginal{i}{3});
        % record key time stamp and index
        key_times(end+1) = timeStamp; keys_indexes(end+1) = i;
        % record the block the key belongs to
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
    
    elseif strcmp(logoriginal{i}{2},'START') % Start of the task, happens once
        start = timeStamp;
        start_x = i;
        
    elseif strcmp(logoriginal{i}{2},'STOP') % End of the task
        stop = timeStamp;
        stop_x = i;
        
    %%%% Problem-indicating entries
    elseif strcmp(logoriginal{i}{2},'STOP MANUALLY') % Task was manually interrupted
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

RawDataPlot = figure(1);
if exist('taskName','var'); title(taskName);end
labels = {'keys','Resting period start','Practice block start'};

% Plot key presses as blue dots . or blue line with circles markers o if
% too few entries
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
        plot(stopManually_x,stopManually,'rx'); labels{end+1} = 'Manual stop: Task interrupted';
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

if currentBlock ~= length(practice_time)
    warning('Two measures of the number of blocks don''t match!')
end
numberOfBlocks = currentBlock;

%% Detection of valid and invalid sequences (provided sequence was provided)

if sequence_exist
    lenSeq = length(sequence);
    % counting the number of good sequences
    numberCorrectSequences = zeros(1,numberOfBlocks);

    % find the position of 3 in the sequence
    key3position = find(sequence == 3);

    % Range of positions to be checked around the 3, no need to check the 3, it is checked already
    RangeToCheck = 1-key3position:lenSeq-key3position ;
    RangeToCheck(RangeToCheck==0)=[];
    % keys_correct: 1 if the key belongs to a correctly executed sequence, 0 otherwise
    keys_correct = zeros(size(keys));

    for blockNumber = 1:numberOfBlocks
        % subset of keys belonging to this particular block
        keys_i = keys(keys_block==blockNumber);
        % Positions of this subset of keys in the keys array
        keys_i_position = find(keys_block==blockNumber,1,'first'); 
        nbKeys = length(keys_i); % number of keys
        Loc3 = find(keys_i == 3); % locations of 3s in this subset
        for ii = 1:length(Loc3)
            if Loc3(ii) <= nbKeys - (lenSeq - key3position) && (Loc3(ii) >= key3position)
                if keys_i(Loc3(ii) + RangeToCheck) == sequence(key3position + RangeToCheck)
                    numberCorrectSequences(blockNumber) = numberCorrectSequences(blockNumber) + 1;
                    % mark keys identified as correct
                    keys_correct(keys_i_position-1 + Loc3(ii) + [RangeToCheck 0]) = 1;
                    % make certain keys already belonging to a correct
                    % sequence are not used to validate another sequence
                    keys_i(Loc3(ii) + RangeToCheck) = zeros(size(RangeToCheck));
                end
            end
        end
    end
end
%% Key Presses plot

colormap = [[1 0 0] % red
            [0 0 1] % blue
            [1 1 0] % yellow
            [0 1 0] % green
        ];


% We convert keys_correct to a format displayable by barh so keys belonging
% to a correct sequence are below a green bar and others below a red bar
correct_session(1,1) = keys_correct(1);
% We will call "session" either a continuous uninterrupted set of correct
% keys, or a continuous uninterrupted set of incorrect keys
session_length(1,1) = 1; currentBlock = 1; index = 1;

for i = 2:length(keys_correct)
    if keys_block(i) == currentBlock % staying in the same Block
        if keys_correct(i) == correct_session(currentBlock,index) % staying in the same session
            session_length(currentBlock,index) = session_length(currentBlock,index) + 1;
        else % new session
            index = index + 1;
            correct_session(currentBlock,index) = keys_correct(i);
            session_length(currentBlock,index) = 1;
        end
    else % new block (which implies new session as well)
        currentBlock = currentBlock + 1; index = 1;
        correct_session(currentBlock,index) = keys_correct(i);
        session_length(currentBlock,index) = 1;
    end
end

KeyPressesPlot = figure(2);

if numberOfBlocks<10
    start = 1; stop = numberOfBlocks;
else
    warning("this file contains many blocks (>10)")
    warning("All blocks should not be displayed at once for readability")
    disp('Which range of blocks would you like to be displayed?')
    disp(['Blocks range from 1 to ',num2str(numberOfBlocks)])
    start = input('start: first block of the range (please enter a valid integer)\n');
    stop = input('stop: last block of the range (please enter a valid integer)\n');
end
numToBeDisplayed = stop - start +1;

for i = start:stop
    figure(2); subplot(numToBeDisplayed,1,i-start+1)
    keys_i = keys(keys_block == i);
    nbKeys = length(keys_i);
    b = bar(keys_i,'FaceColor','flat');
    for j = 1:4
        j_elements_positions = find(keys_i==j); num_elements = length(j_elements_positions);
        b.CData(j_elements_positions,:) = repmat(colormap(j,:),num_elements,1);
    end
    if sequence_exist
        temp = [.5 session_length(i,:)]; % we adjust the position of the plot with a dummy bar
        hold on; b2 = barh([5 10],[temp; 1:length(temp)],...
        'stacked','BarWidth',0.3,'FaceColor','flat'); hold off
        % We suppress display of the dummy bar
        b2(1).CData = [1 1 1]; b2(1).EdgeColor = [1 1 1];
        for j = 2:length(b2)
            if correct_session(i,j-1); b2(j).CData = [0 1 0];
            else; b2(j).CData = [1 0 0]; end
        end
        temps_axis = axis; axis([.5 nbKeys+0.5 0 5])
    end
end

end
