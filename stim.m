function varargout = stim(varargin)
% stim M-file for stim.fig
%      stim, by itself, creates a new stim or raises the existing
%      singleton*.
%
%      H = stim returns the handle to a new stim or the handle to
%      the existing singleton*.
%
%      stim('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in stim.M with the given input arguments.
%
%      stim('Property','Value',...) creates a new stim or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stim_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stim

% Last Modified by GUIDE v2.5 31-Oct-2014 09:36:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stim_OpeningFcn, ...
                   'gui_OutputFcn',  @stim_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before stim is made visible.
function stim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stim (see VARARGIN)

% Choose default command line output for stim
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stim wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global EXPERIMENT;
global HOME;
EXPERIMENT = 'stim Project';
HOME = which('stim');
HOME = HOME(1:length(HOME)-6);

% Create Output directory if it doesn't exists
outputDir = strcat(HOME,'output');
if ~exist(outputDir, 'dir')
    mkdir(outputDir) % create output dir
end

% add stimuli/ and experiments/ to the MATLAB path
addpath(strcat(HOME,'stimuli'))
addpath(strcat(HOME,'experiments'))

% --- TO RUN ONLY ONE DESIGN --- %
% --- should be removed if stim_ChooseDesign is used
% -----------------------------------------------------------------------
% design_desc = stim_ChooseDesign();%'IntR_1hand';
% Get parameters from paramters....m
run([HOME, 'experiments' filesep 'ld_parameters']);
% Set param to application data collection
% Is accessed in stim: param = getappdata(0,'...');
% Should be removed when done using rmappdata
setappdata(0,'param', param);
% -----------------------------------------------------------------------

setExperimentButton(handles);
pos = get(handles.uipanel_stim_Project, 'Position');
pos(2) = 2;
set(handles.uipanel_stim_Project, 'Position', pos);
set(handles.uipanel_stim_Project, 'Visible', 'On');

% --- Outputs from this function are returned to the command line.
function varargout = stim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%
%  Buttons 
%%%%%%%%%%%

% --- Executes on button press in buttonStart.
% function Start_experiment(D_EXPERIMENT,handles)
function Start_experiment(handles)
% Get param from application data collection
% Is defined in stim_ChooseDesign
% Should be removed when done using rmappdata
param = getappdata(0,'param');

param.numMonitor = get(handles.radiobuttonYesSecondMonitor, 'Value');
param.flipMonitor = get(handles.radiobuttonYesFlipMonitor, 'Value');

% Common parameters
param.outputDir = get(handles.editOutputDir, 'String');
param.fullscreen = get(handles.radiobuttonFullScreenYes, 'Value');

% Sequences
param.seqA = str2num(get(handles.editSeqA, 'String'));
param.seqB = str2num(get(handles.editSeqB, 'String'));

% Testing
param.nbBlocks = str2double(get(handles.editNbBlocks, 'String'));
param.nbKeys = str2double(get(handles.editNbKeys, 'String'));

% Rest
param.durRest = str2double(get(handles.editdurRest, 'String'));

% Intro
param.IntroNbSeq = str2double(get(handles.editIntroNbSeq, 'String'));

ld_menuExperiment(param)
param = rmfield(param,'start');
setappdata(0,'param', param);


% --- Executes on button press in buttonResults
function button_NextSession_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

param = getappdata(0,'param');
    param.start = 'yes';
setappdata(0,'param', param);

Start_experiment(handles)

% --- Executes on button press in buttonResults
function button_Session1_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global D_EXPERIMENT;
% D_EXPERIMENT = 'Condition_A';
% Start_experiment(D_EXPERIMENT,handles)
param = getappdata(0,'param');
    param.sessionNumber=1;
    param.start = 'yes';
setappdata(0,'param', param);

Start_experiment(handles)

% --- Executes on button press in buttonResults
function button_Session2_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global D_EXPERIMENT;
% D_EXPERIMENT = 'Condition_B';
% Start_experiment(D_EXPERIMENT,handles)
param = getappdata(0,'param');
    param.sessionNumber=2;
    param.start = 'yes';
setappdata(0,'param', param);

Start_experiment(handles)
        
% --- Executes on button press in buttonResults
function button_Session3_1_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global D_EXPERIMENT;
% D_EXPERIMENT = 'Condition_C';
% Start_experiment(D_EXPERIMENT,handles)
param = getappdata(0,'param');
    param.sessionNumber=3.1;
    param.start = 'yes';
setappdata(0,'param', param);

Start_experiment(handles)

% --- Executes on button press in buttonResults
function button_Session3_2_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global D_EXPERIMENT;
% D_EXPERIMENT = 'Condition_C';
% Start_experiment(D_EXPERIMENT,handles)
param = getappdata(0,'param');
    param.sessionNumber=3.2;
    param.start = 'yes';
setappdata(0,'param', param);

Start_experiment(handles)

% --- Executes on button press in buttonResults
function button_Session3_3_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global D_EXPERIMENT;
% D_EXPERIMENT = 'Condition_C';
% Start_experiment(D_EXPERIMENT,handles)
param = getappdata(0,'param');
    param.sessionNumber=3.3;
    param.start = 'yes';
setappdata(0,'param', param);

Start_experiment(handles)

% --- Executes on button press in buttonResults
function button_Session3_4_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global D_EXPERIMENT;
% D_EXPERIMENT = 'Condition_C';
% Start_experiment(D_EXPERIMENT,handles)
param = getappdata(0,'param');
    param.sessionNumber=3.4;
    param.start = 'yes';
setappdata(0,'param', param);

Start_experiment(handles)

% --- Executes on button press in buttonResults
function button_validate_subject_name(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

param = getappdata(0,'param');
param.sujet = get(handles.editSubject, 'String');
param.group = subjectCodeAnalysis(param.sujet);

if ~isempty(param.group)
    % a group has been specified
    
%     % we perform handChoice so we know which hand and sequence must be used
%     ld_handAndSequenceChoice(param);
%     param = getappdata(0,'param');

    % we look through the stim/output folder to detect any previous
    % sessions
    param.sessionNumber = ld_detectPreviousSessions(param);
else
    % no group has been specified
    disp('Warning: subject code has not been read correctly')
    disp('Are the last two chracters of subject name digits?')
end

set(handles.button_NextSession, 'String', strcat('Next Step: Session_',...
num2str(param.sessionNumber)));

setappdata(0,'param', param);

function buttonResults_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
param = getappdata(0,'param');
ld_runAnalysis(param.outputDir)

% --- Executes on button press in buttonQuit.
function buttonQuit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rmappdata(0, 'param');
clear;
close;

%%%%%%%%%%%%%%%%%%
%  Utilities
%%%%%%%%%%%%%%%%%%

function setExperimentButton(handles)

% Buttons and panel properties
set(handles.button_Session1, 'FontWeight', 'normal');
set(handles.button_Session2, 'FontWeight', 'normal');
set(handles.button_Session3_1, 'FontWeight', 'normal');
set(handles.button_Session3_2, 'FontWeight', 'normal');
set(handles.button_Session3_3, 'FontWeight', 'normal');
set(handles.button_Session3_4, 'FontWeight', 'normal');

set(handles.uipanel_stim_Project, 'Visible', 'off');

% Get param from application data collection
% Is defined in stim_ChooseDesign
% Should be removed when done using rmappdata
param = getappdata(0,'param');

set(handles.editNbBlocks, 'String', num2str(param.nbBlocks));
set(handles.editNbKeys, 'String', num2str(param.nbKeys));

set(handles.editSeqA, 'String', num2str(param.seqA));
set(handles.editSeqB, 'String', num2str(param.seqB));

set(handles.editdurRest, 'String', num2str(param.durRest));
set(handles.editIntroNbSeq, 'String', num2str(param.IntroNbSeq));

set(handles.editOutputDir, 'String', param.outputDir);

if param.fullscreen == 1
    set(handles.radiobuttonFullScreenYes, 'Value', 1);
else
    set(handles.radiobuttonFullScreenNo, 'Value', 1);
end

if param.numMonitor == 1
    set(handles.radiobuttonYesSecondMonitor, 'Value', 1);
else
    set(handles.radiobuttonNoSecondMonitor, 'Value', 1);
end

if param.flipMonitor == 1
    set(handles.radiobuttonYesFlipMonitor, 'Value', 1);
else
    set(handles.radiobuttonNoFlipMonitor, 'Value', 1);
end

function code = subjectCodeAnalysis(name)
code = str2num(name(end-1:end));