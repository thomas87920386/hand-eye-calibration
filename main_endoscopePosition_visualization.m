% basic setup
close all
clear
configuration;

% read the csv files
opts = detectImportOptions(file_path_0008{1}, 'Delimiter', ',');
data_USM1 = readtable(file_path_0008{1}, opts);
opts = detectImportOptions(file_path_0008{2}, 'Delimiter', ',');
data_USM2 = readtable(file_path_0008{2}, opts);
opts = detectImportOptions(file_path_0008{3}, 'Delimiter', ',');
data_USM3 = readtable(file_path_0008{3}, opts);
opts = detectImportOptions(file_path_0008{4}, 'Delimiter', ',');
data_USM4 = readtable(file_path_0008{4}, opts);
disp('Successfully read the files');

% Read the video file
video_reader = VideoReader(file_path_0008{5});

% Create the video writer
filename = 'davinci_part0008.mp4';
if exist(filename, 'file') == 2
    delete(filename);
    disp(['Deleted existing file: ' filename]);
end

v = VideoWriter(filename, 'MPEG-4');
v.FrameRate = frame_rate;
open(v);

% Determine the number of frames to process
num_frames = min([height(data_USM1), height(data_USM2), height(data_USM3), height(data_USM4), video_reader.NumFrames]);

% Create a figure off-screen
endoscope_view = figure('Visible', 'off');
endoscope_view_ax = axes('Parent', endoscope_view, 'YDir', 'reverse', 'NextPlot', 'add');
axis(endoscope_view_ax, [0 1280*2 0 720*2]);

% Pre-create plot objects
h_image = image(zeros(video_reader.Height, video_reader.Width, 3), 'Parent', endoscope_view_ax);
h_USM1 = plot(endoscope_view_ax, NaN, NaN, 'r', 'MarkerSize', 15, 'Tag', 'USM1');
h_USM2 = plot(endoscope_view_ax, NaN, NaN, 'g', 'MarkerSize', 15, 'Tag', 'USM2');
h_USM3 = plot(endoscope_view_ax, NaN, NaN, 'b', 'MarkerSize', 15, 'Tag', 'USM3');
h_USM4 = plot(endoscope_view_ax, NaN, NaN, 'y', 'MarkerSize', 15, 'Tag', 'USM4');

t_USM1 = text(0, 0, 'USM1', 'Color', 'red', 'FontSize', 8, 'VerticalAlignment', 'bottom', 'Visible', 'off');
t_USM2 = text(0, 0, 'USM2', 'Color', 'green', 'FontSize', 8, 'VerticalAlignment', 'bottom', 'Visible', 'off');
t_USM3 = text(0, 0, 'USM3', 'Color', 'blue', 'FontSize', 8, 'VerticalAlignment', 'bottom', 'Visible', 'off');
t_USM4 = text(0, 0, 'USM4', 'Color', 'yellow', 'FontSize', 8, 'VerticalAlignment', 'bottom', 'Visible', 'off');

% Process frames
for index = 1:num_frames
    % Read a frame from the video
    video_frame = readFrame(video_reader);
    
    % Update the image data
    set(h_image, 'CData', video_frame);
    
    % Update EndoscopePosition data
    USM1_datapoint = str2num(data_USM1.EndoscopePosition{index})*10000;
    USM2_datapoint = str2num(data_USM2.EndoscopePosition{index})*10000;
    USM3_datapoint = str2num(data_USM3.EndoscopePosition{index})*10000;
    USM4_datapoint = str2num(data_USM4.EndoscopePosition{index})*10000;
    
    set(h_USM1, 'XData', USM1_datapoint(1), 'YData', USM1_datapoint(2));
    set(h_USM2, 'XData', USM2_datapoint(1), 'YData', USM2_datapoint(2));
    set(h_USM3, 'XData', USM3_datapoint(1), 'YData', USM3_datapoint(2));
    set(h_USM4, 'XData', USM4_datapoint(1), 'YData', USM4_datapoint(2));
    
    % Update label positions
    set(t_USM1, 'Position', [USM1_datapoint(1)+500, USM1_datapoint(2)+500, 0], 'Visible', 'on');
    set(t_USM2, 'Position', [USM2_datapoint(1)+500, USM2_datapoint(2)+500, 0], 'Visible', 'on');
    set(t_USM3, 'Position', [USM3_datapoint(1)+500, USM3_datapoint(2)+500, 0], 'Visible', 'on');
    set(t_USM4, 'Position', [USM4_datapoint(1)+500, USM4_datapoint(2)+500, 0], 'Visible', 'on');
    
    % Capture the frame and write to video
    frame = getframe(endoscope_view);
    writeVideo(v, frame);
    
    % Display progress
    if mod(index, 100) == 0
        disp(['Processed ' num2str(index) ' frames out of ' num2str(num_frames)]);
    end
end

% Close the video writer
close(v);

% Close the figure
close(endoscope_view);

% Show the video details
disp(['Video generation completed.']);
disp(['Video duration: ' num2str(num_frames/frame_rate, '%.2f') ' seconds']);
disp(['Frame rate: ' num2str(frame_rate) ' fps']);
disp(['Total frames: ' num2str(num_frames)]);