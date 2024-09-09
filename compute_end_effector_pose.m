% basic setup
close all
configuration;

% read the csv files
opts = detectImportOptions(csv_file_path{5}, 'Delimiter', ',');
data_USM2 = readtable(csv_file_path{5}, opts);
opts = detectImportOptions(csv_file_path{6}, 'Delimiter', ',');
data_USM4 = readtable(csv_file_path{6}, opts);
opts = detectImportOptions(csv_file_path{7}, 'Delimiter', ',');
data_endoscope = readtable(csv_file_path{7}, opts);
data_end_effector_2d_left = readtable(".\dataset\CollectedData_thomas_left.csv");
data_end_effector_2d_right = readtable(".\dataset\CollectedData_thomas_right.csv");
disp('Successfully read the files');

frame_indices = data_USM2.Var1;

% Compute the hand eye transformation matrix
% 1. compute the end effect pose in camera frame 
left_video_points = [[data_end_effector_2d_left.individual1_x, data_end_effector_2d_left.individual1_y];[data_end_effector_2d_left.individual2_x, data_end_effector_2d_left.individual2_y]];
right_video_points = [[data_end_effector_2d_right.individual1_x, data_end_effector_2d_right.individual1_y];[data_end_effector_2d_right.individual2_x, data_end_effector_2d_right.individual2_y]];
disparity = left_video_points(:,1) - right_video_points(:,1);
left_video_points = [left_video_points, disparity, ones(size(disparity, 1), 1)];
point3D = Q * left_video_points';
point3D = point3D ./ point3D(4, :);
point3D = point3D(1:3, :)';

% 2. Extract the end effect pose in endoscope frame
point_endo_USM2_ee = [];
point_endo_USM4_ee = [];
num = 0;
for index = 1:size(data_USM2.EndoscopePosition, 1)-num
    trans_endo_USM2_ee = str2num(data_USM2.EndoscopePosition{index});
    point_endo_USM2_ee = [point_endo_USM2_ee; trans_endo_USM2_ee(1:3)];  
    trans_endo_USM4_ee = str2num(data_USM4.EndoscopePosition{index});
    point_endo_USM4_ee = [point_endo_USM4_ee; trans_endo_USM4_ee(1:3)];
end
point3D = [point3D(1: size(point3D, 1)/2-num, :); point3D(size(point3D, 1)/2+1: size(point3D, 1)-num, :)];
endo =  [point_endo_USM2_ee; point_endo_USM4_ee];

% 3. registration to compute the hand eye transformation by Procrustes point registration
X = point3D;
Y = [point_endo_USM4_ee; point_endo_USM2_ee];
[d, Z, transform] = procrustes(point3D, [point_endo_USM2_ee; point_endo_USM4_ee], 'reflection', false, 'scaling', false);
hand_eye_transformation = [[transform.T, transform.c(1,:)']; [0, 0, 0, 1]]

% Project points to camera frame
projected_points_USM2 = projectPoints(point_endo_USM2_ee, hand_eye_transformation, projection_left);
projected_points_USM4 = projectPoints(point_endo_USM4_ee, hand_eye_transformation, projection_left);

% Read the video file
video_reader = VideoReader('.\dataset\EndoscopeImageMemory_0_ToolMotion_rect.avi');

% Create the video writer
filename = 'davinci_projection.mp4';
if exist(filename, 'file') == 2
    delete(filename);
end
v = VideoWriter(filename, 'MPEG-4');
v.FrameRate = frame_rate;
open(v);

% Process frames
num_frames = min(video_reader.NumFrames, length(frame_indices));

figure('Visible', 'off');  % Create a figure but don't display it
for i = 1:num_frames
    % Get the current frame index
    current_frame = frame_indices(i);
    
    % Read the specific frame from the video
    video_reader.CurrentTime = (current_frame - 1) / video_reader.FrameRate;
    video_frame = readFrame(video_reader);
    
    % Plot the projected points on the video frame
    imshow(video_frame);
    hold on;
    
    % Debug: Print point coordinates
    disp(['Frame ', num2str(current_frame), ':']);
    disp(['USM2: ', num2str(projected_points_USM2(i, 1)), ', ', num2str(projected_points_USM2(i, 2))]);
    disp(['USM4: ', num2str(projected_points_USM4(i, 1)), ', ', num2str(projected_points_USM4(i, 2))]);
    
    % Check if points are within frame bounds
    frame_size = size(video_frame);
    if all(projected_points_USM2(i, :) > 0 & projected_points_USM2(i, :) < [frame_size(2), frame_size(1)])
        plot(projected_points_USM2(i, 1), projected_points_USM2(i, 2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
        text(projected_points_USM2(i, 1), projected_points_USM2(i, 2), 'USM2', 'Color', 'red', 'FontSize', 12);
    else
        disp('USM2 point out of bounds');
    end
    
    if all(projected_points_USM4(i, :) > 0 & projected_points_USM4(i, :) < [frame_size(2), frame_size(1)])
        plot(projected_points_USM4(i, 1), projected_points_USM4(i, 2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
        text(projected_points_USM4(i, 1), projected_points_USM4(i, 2), 'USM4', 'Color', 'blue', 'FontSize', 12);
    else
        disp('USM4 point out of bounds');
    end
    
    title(['Frame: ', num2str(current_frame)]);
    hold off;
    
    % Capture the frame and write to video
    frame = getframe(gca);
    writeVideo(v, frame);
    
    % Display progress
    if mod(i, 100) == 0
        disp(['Processed ' num2str(i) ' frames out of ' num2str(num_frames)]);
    end
end

% Close the video writer
close(v);

% Show the video details
disp(['Video generation completed.']);
disp(['Video duration: ' num2str(num_frames/frame_rate, '%.2f') ' seconds']);
disp(['Frame rate: ' num2str(frame_rate) ' fps']);
disp(['Total frames: ' num2str(num_frames)]);
function projected_points = projectPoints(points3D, transformation, projection_matrix)
    % Convert 3D points to homogeneous coordinates
    points3D_homogeneous = [points3D, ones(size(points3D, 1), 1)]';
    
    % Transform points to camera frame
    points_camera = transformation * points3D_homogeneous;
    
    % Project 3D points to 2D using the projection matrix
    points_2d_homogeneous = projection_matrix * points_camera;
    
    % Perform perspective division
    points_2d = points_2d_homogeneous(1:2, :) ./ points_2d_homogeneous(3, :);
    
    % Transpose to get Nx2 matrix
    projected_points = points_2d';
end
