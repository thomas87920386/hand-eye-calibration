% basic setup
close all
clear

% Read the video file
video_reader = VideoReader("C:\Users\tmas0\Desktop\da Vinci Xi\reprojection_video_left_0008.mp4");

% Determine the number of frames to process
num_frames = video_reader.NumFrames;

% Create a folder to store the images
output_folder = 'output_reprojection_left_frames_0008';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Process frames
for index = 1:300
    % Read a frame from the video
    video_frame = readFrame(video_reader);
    
    % Save the frame as an image
    filename = sprintf('%s/frame_%04d.png', output_folder, index);
    imwrite(video_frame, filename);
end

disp('All frames have been saved as images.');