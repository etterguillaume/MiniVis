function varargout = MiniVis(varargin)
% MINIVIS MATLAB code for MiniVis.fig
%      MINIVIS, by itself, creates a new MINIVIS or raises the existing
%      singleton*.
%
%      H = MINIVIS returns the handle to a new MINIVIS or the handle to
%      the existing singleton*.
%
%      MINIVIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MINIVIS.M with the given input arguments.
%
%      MINIVIS('Property','Value',...) creates a new MINIVIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MiniVis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MiniVis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MiniVis

% Last Modified by GUIDE v2.5 25-Mar-2019 14:25:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MiniVis_OpeningFcn, ...
                   'gui_OutputFcn',  @MiniVis_OutputFcn, ...
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


% --- Executes just before MiniVis is made visible.
function MiniVis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Choose default command line output for MiniVis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MiniVis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MiniVis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in zoom_in.
function zoom_in_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_in (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plot_min = round((handles.first_frame + handles.plot_min)/2);
handles.plot_max = round((handles.plot_max + handles.last_frame)/2);
set(handles.trace_display, 'XLim', [handles.ms.time(handles.plot_min)/1000 handles.ms.time(handles.plot_max)/1000]);
guidata(hObject,handles)

% --- Executes on button press in zoom_out.
function zoom_out_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plot_min = round((handles.plot_min + 1)/2);
handles.plot_max = round((handles.ms.numFrames + handles.plot_max)/2);
set(handles.trace_display, 'XLim', [handles.ms.time(handles.plot_min)/1000 handles.ms.time(handles.plot_max)/1000]);
guidata(hObject,handles)

% --- Executes on button press in load_data.
function load_data_Callback(hObject, eventdata, handles)
workingDir=uigetdir; % Prompts the user to select the directory containing Neuralynx data

% Error checking
while isempty(workingDir);
    errordlg('Please select a directory containing data')
    workingDir=uigetdir;
end

set(handles.status, 'String', ['Importing ' workingDir '......']);

%% Find and open ms.mat
load([workingDir '/ms.mat']);
load([workingDir '/behav.mat']);

%% (Re)-Create video objects
aviFiles = dir([workingDir filesep '*.avi']);
for i=1:ms.numFiles
    ms.vidObj{i} = VideoReader([workingDir filesep 'msCam' num2str(i) '.avi']);
end
for i=1:behav.numFiles
    behav.vidObj{i} = VideoReader([workingDir filesep 'behavCam' num2str(i) '.avi']);
end

set(handles.status, 'String', ['Successfully imported ' workingDir ]);

%% Find corresponding calcium/behavior frames
for frame_i = 1:length(ms.time)
    handles.behav_frame_at_calcium_time(frame_i) = unique(dsearchn(behav.time,ms.time(frame_i)));
end

%% Pass variables into handles
handles.ms=ms;
handles.behav=behav;

handles.pause = 0;
handles.is_loop = 0;
handles.ms_gamma = 1;
handles.behav_gamma = 1;
handles.is_dFF = 0;

handles.current_mstime = 0;
handles.current_mstimestr = datestr(seconds(handles.current_mstime/1000),'HH:MM:SS:FFF');

set(handles.timestamp_dsp, 'String', handles.current_mstimestr);


guidata(hObject,handles)
set(handles.cell_display_popup,'String',1:handles.ms.numNeurons);
%% Instantiate displays
handles.preprocessed = 0;
%% Plotting trace and playback bar
% Default values
handles.first_frame = 150;
handles.last_frame = 300;
handles.current_cell = 1;

handles.plot_min = 1;
handles.plot_max = ms.numFrames;
handles.max_current_trace = max(ms.RawTraces(:,handles.current_cell));

set(handles.cell_number_dsp, 'String', num2str(handles.current_cell));

handles.current_frame = handles.first_frame;

handles.trace_plot = plot(handles.ms.time/1000,ms.RawTraces(:,handles.current_cell),'color', [1 1 1], 'Parent', handles.trace_display);
set(handles.trace_display, 'color', [0.15 0.15 0.15]);
hold on
clip_block.Vertices = [handles.ms.time(handles.first_frame)/1000 0; handles.ms.time(handles.first_frame)/1000 handles.max_current_trace; handles.ms.time(handles.last_frame)/1000 handles.max_current_trace; handles.ms.time(handles.last_frame)/1000 0];
clip_block.Faces = [1 2 3 4];
clip_block.FaceColor = [0.6 0 0];
clip_block.FaceAlpha = 0.15;
handles.clip_block = patch(clip_block, 'Parent', handles.trace_display);
handles.playback_line = line([handles.ms.time(handles.first_frame)/1000 handles.ms.time(handles.first_frame)/1000], [0 handles.max_current_trace], 'color', 'b', 'Parent', handles.trace_display);
hold off

%% Get information about experiment
set(handles.experiment_name, 'String', ms.Experiment);
set(handles.ds_factor, 'String', ['Downsampling: ' num2str(ms.ds) 'x']);

handles.ms_fps = 1/mode(diff(ms.time/1000));
handles.behav_fps = 1/mode(diff(behav.time/1000));

handles.ms_duration = ms.numFrames/handles.ms_fps;

set(handles.experiment_duration, 'String', ['Duration: ' num2str(handles.ms_duration) ' s']);
set(handles.ms_fps_display, 'String', ['Miniscope: ' num2str(handles.ms_fps) ' fps']);
set(handles.behav_fps_display, 'String', ['Behavior: ' num2str(handles.behav_fps) ' fps']);

frameNum = 1;
vidNum = ms.vidNum(frameNum);
vidFrameNum = ms.frameNum(frameNum);

% Get first frame
ms_frame = ms.vidObj{vidNum}.read(vidFrameNum);
behav_frame = behav.vidObj{vidNum}.read(vidFrameNum);

set(handles.ms_display,'Units','pixels');
axes(handles.ms_display);
set(handles.ms_display, 'xlimmode','manual',...
           'ylimmode','manual',...
           'zlimmode','manual',...
           'climmode','manual',...
           'alimmode','manual');
handles.ms_image = image(ms_frame, 'Parent', handles.ms_display);
handles.cm_viridis = viridis(256);
colormap(handles.ms_display,handles.cm_viridis);
set(handles.ms_display,'Units','normalized');
daspect([1 1 1])

set(handles.behav_display,'Units','pixels');
axes(handles.behav_display);
set(handles.behav_display, 'xlimmode','manual',...
           'ylimmode','manual',...
           'zlimmode','manual',...
           'climmode','manual',...
           'alimmode','manual');
handles.behav_image = imshow(behav_frame, 'Parent', handles.behav_display);
set(handles.behav_display,'Units','normalized');
daspect([1 1 1])
set(gcf,'doublebuffer','off');

%% Cell display
bounding_box = regionprops(ms.SFPs(:,:,handles.current_cell)>0,'BoundingBox');
bounding_box = bounding_box.BoundingBox;
if ms.ds ~= 1
bounding_box = bounding_box*ms.ds;
end

handles.bounding_box = bounding_box;
handles.bbox_rect_obj = rectangle('Position', handles.bounding_box, 'EdgeColor', 'r', 'Parent', handles.ms_display);

cell_image = imcrop(ms_frame,handles.bounding_box);
handles.cell_image = image(cell_image, 'Parent', handles.cell_display);
colormap(handles.cell_display,handles.cm_viridis);

drawnow;
guidata(hObject,handles)

%% Calculating background for dF/F plotting
for frameNum=1:ceil(0.005*ms.numFrames):ms.numFrames
    vidNum = ms.vidNum(frameNum);
    vidFrameNum = ms.frameNum(frameNum);
    if frameNum == 1
    frame = ms.vidObj{vidNum}.read(vidFrameNum);
    else
    frame(:,:,end+1) = ms.vidObj{vidNum}.read(vidFrameNum);
    end
    set(handles.status, 'String', ['Calculating background..... ' num2str(ceil(frameNum/ms.numFrames*100)) '% done']);
end

handles.ms_background = min(frame,[],3);

set(handles.status, 'String', 'Ready ');

guidata(hObject,handles)

% hObject    handle to load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in export_video.
function export_video_Callback(hObject, eventdata, handles)
% hObject    handle to export_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in exit_btn.
function exit_btn_Callback(hObject, eventdata, handles)
% hObject    handle to exit_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = questdlg('Are you sure you want to quit?', ...
	'MiniVis', ...
	'Yes, I am done with this','No I am loving it','No I am enjoying this');
switch answer
    case 'Yes, I am done with this'
        close all
    case 'No I am enjoying this'
end

% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = msgbox({'Welcome to MiniVis, a visualization tool for miniscope data. Here is a list of keyboard shortcuts:'...
                'Press "a" or "left" to move left'...
                'Press "d" or "right" to move right'...
                'Press "w" or "up" to zoom in'...
                'Press "s" or "down" to zoom out'...
                'Press "r" to reset the view'...
            'Copyright Guillaume Etter © 2019'...
            'Sylvain Williams Lab & McGill University'...
            'Distributed under GNU open source licence'}, 'Instructions');
set(h,'Color', [0.5 0.5 0.5]);


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in play_video.
function play_video_Callback(hObject, eventdata, handles)
% hObject    handle to play_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Pre-processing in RAM
handles.pause = 0;
numFrames2Play = num2str(abs(handles.last_frame-handles.first_frame+1));
if handles.preprocessed ~= 1
    for frameNum=handles.first_frame:handles.last_frame
    set(handles.status, 'String', ['Pre-processing '  num2str(frameNum-handles.first_frame+1) '/' numFrames2Play ' frames.....']);
    msvidNum = handles.ms.vidNum(frameNum);
    msvidFrameNum = handles.ms.frameNum(frameNum);
    handles.ms_frame{frameNum} = handles.ms.vidObj{msvidNum}.read(msvidFrameNum);

    %% Image processing
    if handles.is_dFF
    handles.ms_frame{frameNum} = handles.ms_frame{frameNum} - handles.ms_background;
    end

    if handles.ms_gamma ~= 1
    handles.ms_frame{frameNum} = imadjust(handles.ms_frame{frameNum},[],[],handles.ms_gamma);
    end

    behavvidNum = handles.behav.vidNum(handles.behav_frame_at_calcium_time(frameNum));
    behavvidFrameNum = handles.behav.frameNum(handles.behav_frame_at_calcium_time(frameNum));
    handles.behav_frame{frameNum} = handles.behav.vidObj{behavvidNum}.read(behavvidFrameNum);
    handles.cell_frame{frameNum} = imcrop(handles.ms_frame{frameNum},handles.bounding_box);
    end
end

handles.preprocessed = 1;
set(handles.clip_block, 'FaceColor', [0 0.6 0]);

%% Play the video clip
for frameNum=handles.first_frame:handles.last_frame
set(handles.status, 'String', ['Playing: '  num2str(frameNum-handles.first_frame+1) '/' numFrames2Play ' frames']);
axes(handles.ms_display);
set(handles.ms_image, 'CData', handles.ms_frame{frameNum});

axes(handles.behav_display);
set(handles.behav_image, 'CData', handles.behav_frame{frameNum});

axes(handles.cell_display);
set(handles.cell_image, 'CData', handles.cell_frame{frameNum});

%% Update the trace plot
set(handles.playback_line,'XData', [handles.ms.time(frameNum)/1000 handles.ms.time(frameNum)/1000]);
handles.current_frame = frameNum;

%% Update time display
handles.current_mstime = handles.ms.time(frameNum);
handles.current_mstimestr = datestr(seconds(handles.current_mstime/1000),'HH:MM:SS:FFF');
set(handles.timestamp_dsp, 'String', handles.current_mstimestr);
guidata(hObject, handles);
end


% --- Executes on button press in pause_video.
function pause_video_Callback(hObject, eventdata, handles)
% hObject    handle to pause_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pause = 1;
guidata(hObject, handles);


% --- Executes on button press in yalp_video.
function yalp_video_Callback(hObject, eventdata, handles)
% hObject    handle to yalp_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in cell_list.
function cell_list_Callback(hObject, eventdata, handles)
% hObject    handle to cell_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cell_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cell_list


% --- Executes during object creation, after setting all properties.
function cell_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cell_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cell_display_popup.
function cell_display_popup_Callback(hObject, eventdata, handles)
% hObject    handle to cell_display_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cell_display_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cell_display_popup
handles.current_cell = get(handles.cell_display_popup,'Value');
handles.max_current_trace = max(handles.ms.RawTraces(:,handles.current_cell));
set(handles.cell_number_dsp, 'String', num2str(handles.current_cell));
set(handles.trace_plot, 'YData', handles.ms.RawTraces(:,handles.current_cell));

%% Refresh ms_display
msvidNum = handles.ms.vidNum(handles.current_frame);
msvidFrameNum = handles.ms.frameNum(handles.current_frame);
ms_frame = handles.ms.vidObj{msvidNum}.read(msvidFrameNum);

set(handles.ms_image, 'CData', ms_frame);
guidata(hObject,handles)

%% Refresh cell display
bounding_box = regionprops(handles.ms.SFPs(:,:,handles.current_cell)>0,'BoundingBox');
bounding_box = bounding_box.BoundingBox;
if handles.ms.ds ~= 1
bounding_box = bounding_box*handles.ms.ds;
end

handles.bounding_box = bounding_box;
set(handles.bbox_rect_obj,'Position', handles.bounding_box);

cell_image = imcrop(ms_frame,handles.bounding_box);
set(handles.cell_image, 'CData', cell_image);

drawnow;
handles.preprocessed = 0;
set(handles.clip_block, 'FaceColor', [0.6 0 0]);
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function cell_display_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cell_display_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'BackgroundColor',[0.15 0.15 0.15]);

% --- Executes on button press in reset_plot.
function reset_plot_Callback(hObject, eventdata, handles)
% hObject    handle to reset_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plot_min = 1;
handles.plot_max = handles.ms.numFrames;
set(handles.trace_display, 'XLim', [handles.ms.time(handles.plot_min)/1000 handles.ms.time(handles.plot_max)/1000]);
handles.preprocessed = 0;
set(handles.clip_block, 'FaceColor', [0.6 0 0]);
guidata(hObject,handles)

% --- Executes on button press in loop_button.
function loop_button_Callback(hObject, eventdata, handles)
% hObject    handle to loop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.is_loop = get(hObject,'Value');
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of loop_button


% --- Executes on button press in goto_lastframe.
function goto_lastframe_Callback(hObject, eventdata, handles)
% hObject    handle to goto_lastframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in goto_firstframe.
function goto_firstframe_Callback(hObject, eventdata, handles)
% hObject    handle to goto_firstframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in select_clip_btn.
function select_clip_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_clip_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x, ~, button] = ginput(2);
x = dsearchn(handles.ms.time/1000,x);

% Setting the x axes to the user selection
handles.first_frame = min(x);
handles.last_frame = max(x);
handles.preprocessed = 0;
set(handles.clip_block, 'FaceColor', [0.6 0 0]);
set(handles.clip_block, 'Vertices', [handles.ms.time(handles.first_frame)/1000 0; handles.ms.time(handles.first_frame)/1000 handles.max_current_trace; handles.ms.time(handles.last_frame)/1000 handles.max_current_trace; handles.ms.time(handles.last_frame)/1000 0]);
set(handles.playback_line, 'XData',[handles.ms.time(handles.first_frame)/1000 handles.ms.time(handles.first_frame)/1000]);
guidata(hObject, handles);  % updating handles structure

% --- Executes on button press in ms_increase_gamma.
function ms_increase_gamma_Callback(hObject, eventdata, handles)
% hObject    handle to ms_increase_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get the ms frame
if handles.ms_gamma < 1.95
msvidNum = handles.ms.vidNum(handles.current_frame);
msvidFrameNum = handles.ms.frameNum(handles.current_frame);
ms_frame = handles.ms.vidObj{msvidNum}.read(msvidFrameNum);

handles.ms_gamma = handles.ms_gamma + 0.1;
ms_frame = imadjust(ms_frame,[],[],handles.ms_gamma);
set(handles.ms_image, 'CData', ms_frame);
set(handles.ms_gamma_value, 'String', ['Gamma: ' num2str(handles.ms_gamma)]);
handles.preprocessed = 0;
set(handles.clip_block, 'FaceColor', [0.6 0 0]);
guidata(hObject, handles);
end

% --- Executes on button press in ms_decrease_gamma.
function ms_decrease_gamma_Callback(hObject, eventdata, handles)
% hObject    handle to ms_decrease_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.ms_gamma > 0.05
msvidNum = handles.ms.vidNum(handles.current_frame);
msvidFrameNum = handles.ms.frameNum(handles.current_frame);
ms_frame = handles.ms.vidObj{msvidNum}.read(msvidFrameNum);

handles.ms_gamma = handles.ms_gamma - 0.1;
ms_frame = imadjust(ms_frame,[],[],handles.ms_gamma);
set(handles.ms_image, 'CData', ms_frame);
set(handles.ms_gamma_value, 'String', ['Gamma: ' num2str(handles.ms_gamma)]);
handles.preprocessed = 0;
set(handles.clip_block, 'FaceColor', [0.6 0 0]);
guidata(hObject, handles);
end

% --- Executes on button press in behav_increase_gamma.
function behav_increase_gamma_Callback(hObject, eventdata, handles)
% hObject    handle to behav_increase_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
behav_frame = get(handles.behav_image, 'CData');
handles.behav_gain = handles.behav_gain + 0.1;
guidata(hObject, handles);
set(handles.behav_image, 'CData', behav_frame * handles.behav_gain);
handles.preprocessed = 0;
set(handles.clip_block, 'FaceColor', [0.6 0 0]);
guidata(hObject, handles);

% --- Executes on button press in behav_decrease_gamma.
function behav_decrease_gamma_Callback(hObject, eventdata, handles)
% hObject    handle to behav_decrease_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
behav_frame = get(handles.behav_image, 'CData');
handles.behav_gain = handles.behav_gain - 0.1;
set(handles.behav_image, 'CData', behav_frame * handles.behav_gain);
handles.preprocessed = 0;
set(handles.clip_block, 'FaceColor', [0.6 0 0]);
guidata(hObject, handles);

% --- Executes on button press in reset_ms_gamma.
function reset_ms_gamma_Callback(hObject, eventdata, handles)
% hObject    handle to reset_ms_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ms_gamma = 1;
msvidNum = handles.ms.vidNum(handles.current_frame);
msvidFrameNum = handles.ms.frameNum(handles.current_frame);
ms_frame = handles.ms.vidObj{msvidNum}.read(msvidFrameNum);

set(handles.ms_image, 'CData', ms_frame);
set(handles.ms_gamma_value, 'String', ['Gamma: ' num2str(handles.ms_gamma)]);
handles.preprocessed = 0;
set(handles.clip_block, 'FaceColor', [0.6 0 0]);
guidata(hObject, handles);

% --- Executes on button press in reset_behav_gamma.
function reset_behav_gamma_Callback(hObject, eventdata, handles)
% hObject    handle to reset_behav_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.behav_gain = 1;
behavvidNum = handles.behav.vidNum(handles.behav_frame_at_calcium_time(handles.current_frame));
behavvidFrameNum = handles.behav.frameNum(handles.behav_frame_at_calcium_time(handles.current_frame));
behav_frame = handles.behav.vidObj{behavvidNum}.read(behavvidFrameNum);
handles.preprocessed = 0;
set(handles.clip_block, 'FaceColor', [0.6 0 0]);
set(handles.behav_image, 'CData', behav_frame);
guidata(hObject, handles);

% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in dFF_check.
function dFF_check_Callback(hObject, eventdata, handles)
% hObject    handle to dFF_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dFF_check
handles.is_dFF = get(hObject,'Value');
handles.preprocessed = 0;
set(handles.clip_block, 'FaceColor', [0.6 0 0]);
guidata(hObject, handles);


% --- Executes on button press in plot_background.
function plot_background_Callback(hObject, eventdata, handles)
% hObject    handle to plot_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ms_background = handles.ms_background;
set(handles.ms_image, 'CData', ms_background);

% --- Executes on button press in plot_CN.
function plot_CN_Callback(hObject, eventdata, handles)
% hObject    handle to plot_CN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CN = handles.ms.CorrProj;
if handles.ms.ds ~= 1
   CN = imresize(CN,handles.ms.ds); 
end
CN = uint8((CN/max(CN(:)))*255);
set(handles.ms_image, 'CData', CN);

% --- Executes on button press in plot_PNR.
function plot_PNR_Callback(hObject, eventdata, handles)
% hObject    handle to plot_PNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PNR = handles.ms.PeakToNoiseProj;
if handles.ms.ds ~= 1
   PNR = imresize(PNR,handles.ms.ds); 
end
PNR = uint8((PNR/max(PNR(:)))*255);
set(handles.ms_image, 'CData', PNR);

% --- Executes on button press in plot_SFPs.
function plot_SFPs_Callback(hObject, eventdata, handles)
% hObject    handle to plot_SFPs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SFPs = max(handles.ms.SFPs,[],3);
if handles.ms.ds ~= 1
   SFPs = imresize(SFPs,handles.ms.ds); 
end
SFPs = uint8((SFPs/max(SFPs(:)))*255);
set(handles.ms_image, 'CData', SFPs);


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key
  case 'a' | '28'
      backward_Callback(hObject, eventdata, handles);
  case 'd' | '29'
      forward_Callback(hObject, eventdata, handles);
  case 'w' | '30'
      reduce_Callback(hObject, eventdata, handles);
  case 's' | '31'
      expand_Callback(hObject, eventdata, handles);
  case 'r'
      resetX_Callback(hObject, eventdata, handles);
  case 'z'
      decrease_gain1_Callback(hObject, eventdata, handles);
  case 'x'
      increase_gain1_Callback(hObject, eventdata, handles);
  case 'c'
      decrease_gain2_Callback(hObject, eventdata, handles);
  case 'v'
      increase_gain2_Callback(hObject, eventdata, handles);
  case 'm'
      marker_btn_Callback(hObject, eventdata, handles);
  case '1'
      rem_btn_Callback(hObject, eventdata, handles);
  case '2'
      sws_btn_Callback(hObject, eventdata, handles);
  case '3'
      wake_btn_Callback(hObject, eventdata, handles);
  case 'f'
      refresh_btn_Callback(hObject, eventdata, handles);
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider9_Callback(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider10_Callback(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider11_Callback(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
