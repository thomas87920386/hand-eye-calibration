% basic setup
close all
configuration;

% create the visualization model and extract the rotation/prismatic joint value
daVinci = build_da_Vinci_function();
config = homeConfiguration(daVinci);
showdetails(daVinci)

% read the csv files
opts = detectImportOptions(file_path_0006{2}, 'Delimiter', ',');
data_USM2 = readtable(file_path_0006{2}, opts);
opts = detectImportOptions(file_path_0006{4}, 'Delimiter', ',');
data_USM4 = readtable(file_path_0006{4}, opts);
disp('Successfully read the files');

% Open the video file
video_path_left = file_path_0006{5};
v_in_left = VideoReader(video_path_left);
video_path_right = file_path_0006{6};
v_in_right = VideoReader(video_path_right);

% Create output video writer
output_filename_left = 'reprojection_video_left_0006.mp4';
v_out_left = VideoWriter(output_filename_left, 'MPEG-4');
v_out_left.FrameRate = v_in_left.FrameRate;
open(v_out_left);
output_filename_right = 'reprojection_video_right_0006.mp4';
v_out_right = VideoWriter(output_filename_right, 'MPEG-4');
v_out_right.FrameRate = v_in_right.FrameRate;
open(v_out_right);

% transform joint value array to structure
[config_struct, joint_map] = array_to_struct_config(daVinci, config);

% Determine the number of frames to process
num_frames = min([v_in_left.NumFrames, height(data_USM2), height(data_USM4)]);

for index = 1: num_frames
    % Read a frame from the input video
    frame_left = readFrame(v_in_left);
    frame_right = readFrame(v_in_right);

    % Update model configuration
    current_config = config_struct;

    % update the USM2 joint value
    joint_name_array = ["USM2_OT_joint", "USM2_joint1", "USM2_joint2", "USM2_joint3", "USM2_joint4", "USM2_joint5", "USM2_END_EFFECT_joint1", "USM2_END_EFFECT_joint2", "USM2_END_EFFECT_joint3"];
    psm_joint_values = str2num(data_USM2.JointValues{index});
    psm_joint_values(7:10) = coupling_matrix * psm_joint_values(7:10)';
    joint_values = psm_joint_values;
    current_config = update_model_config(current_config, joint_name_array, joint_values);

    % update the USM4 joint value
    joint_name_array = ["USM4_OT_joint", "USM4_joint1", "USM4_joint2", "USM4_joint3", "USM4_joint4", "USM4_joint5", "USM4_END_EFFECT_joint1", "USM4_END_EFFECT_joint2", "USM4_END_EFFECT_joint3"];
    psm_joint_values = str2num(data_USM4.JointValues{index});
    psm_joint_values(7:10) = coupling_matrix * psm_joint_values(7:10)';
    joint_values = psm_joint_values;
    current_config = update_model_config(current_config, joint_name_array, joint_values);

    % transfer the config with structure type to array type
    config_array = struct_to_array_config(current_config, joint_map);

    % compute the end effect pose in base frame
    [pos_USM2, orient_USM2] = calculate_end_effector('USM2', daVinci, config_array);
    [pos_USM4, orient_USM4] = calculate_end_effector('USM4', daVinci, config_array);
    
    T_endo_USM2_ee = array2matrix(data_USM2.EndoscopePosition{index});
    extrinsic_left1 = hand_eye_transformation * T_endo_USM2_ee * inv([[orient_USM2, pos_USM2];[0, 0, 0, 1]]);
    extrinsic_left1 = check_orthogonal(extrinsic_left1);

    T_endo_USM4_ee = array2matrix(data_USM4.EndoscopePosition{index}); 
    extrinsic_left2 = hand_eye_transformation * T_endo_USM4_ee * inv([[orient_USM4, pos_USM4];[0, 0, 0, 1]]);
    extrinsic_left2 = check_orthogonal(extrinsic_left2);

    pos_USM2_left = project_point(pos_USM2, extrinsic_left1.A, projection_left);
    pos_USM4_left = project_point(pos_USM4, extrinsic_left2.A, projection_left);

    pos_USM2_right = project_point(pos_USM2, extrinsic_left1.A, projection_right);
    pos_USM4_right = project_point(pos_USM4, extrinsic_left2.A, projection_right);

    % Draw points on the frame
    frame_left = insertMarker(frame_left, pos_USM2_left, 'Color', 'red', 'Size', 10);
    frame_left = insertMarker(frame_left, pos_USM4_left, 'Color', 'blue', 'Size', 10);
    frame_right = insertMarker(frame_right, pos_USM2_left, 'Color', 'red', 'Size', 10);
    frame_right = insertMarker(frame_right, pos_USM4_left, 'Color', 'blue', 'Size', 10);

    % Draw end-effector body frame into the video
    axis_length = 0.01;
    frame_left = draw_body_frame(frame_left, pos_USM2, orient_USM2(:, 1)*axis_length, orient_USM2(:, 2)*axis_length, orient_USM2(:, 3)*axis_length, extrinsic_left1.A, projection_left);
    frame_left = draw_body_frame(frame_left, pos_USM4, orient_USM4(:, 1)*axis_length, orient_USM4(:, 2)*axis_length, orient_USM4(:, 3)*axis_length, extrinsic_left2.A, projection_left);
    frame_right = draw_body_frame(frame_right, pos_USM2, orient_USM2(:, 1)*axis_length, orient_USM2(:, 2)*axis_length, orient_USM2(:, 3)*axis_length, extrinsic_left1.A, projection_right);
    frame_right = draw_body_frame(frame_right, pos_USM4, orient_USM4(:, 1)*axis_length, orient_USM4(:, 2)*axis_length, orient_USM4(:, 3)*axis_length, extrinsic_left2.A, projection_right);

    % Write the frame to the output video
    writeVideo(v_out_left, frame_left);
    writeVideo(v_out_right, frame_right);

    % the following code can extract the frame to be the PNG image
    % frame_filename = fullfile("C:\Users\tmas0\Desktop\Dissertation picture\output_labelled_frame", sprintf('frame_%04d.png', index));
    % imwrite(frame, frame_filename);

    % Display progress
    if mod(index, 100) == 0
        disp(['Processed frame ', num2str(index), ' of ', num2str(num_frames)]);
    end
end

% Close the video writer
close(v_out_left);
close(v_out_right);

disp('Video processing complete.');
disp(['Output saved as: ', output_filename_left]);
disp(['Output saved as: ', output_filename_right]);


function config_struct = update_model_config(config_struct, joint_name_array, joint_values)
    for i = 1:length(joint_name_array)
        joint_name = joint_name_array{i}(1:end);
        if isfield(config_struct, joint_name_array{i})
            config_struct.(joint_name) = joint_values(i);
            % disp(['Updated joint ', joint_name, ' to ', num2str(joint_values(i))]);
        else
            warning(['Joint ', joint_name, ' not found in config_struct']);
        end
    end
end

function [config_struct, joint_map] = array_to_struct_config(robot, config_array)
    config_struct = struct();
    joint_map = containers.Map('KeyType', 'char', 'ValueType', 'int32');
    joint_index = 1;
    
    for i = 1:length(robot.Bodies)
        body = robot.Bodies{i};
        joint_name = body.Joint.Name;
        
        if body.Joint.Type ~= "fixed"
            if joint_index <= length(config_array)
                config_struct.(joint_name) = config_array(joint_index);
                joint_map(joint_name) = joint_index;
                joint_index = joint_index + 1;
            else
                warning(['Not enough values in config_array for joint: ', joint_name]);
            end
        end
    end
end

function config_array = struct_to_array_config(config_struct, joint_map)
    config_array = zeros(length(joint_map), 1);
    
    for joint_name = keys(joint_map)
        index = joint_map(joint_name{1});
        config_array(index) = config_struct.(joint_name{1});
    end
end

function [position, orientation] = calculate_end_effector(usm_name, robot, config)
    tool_frame = [usm_name '_END_EFFECT_body4'];
    % tool_frame = [usm_name '_4'];
    T = getTransform(robot, config, tool_frame);
    position = T(1:3, 4);
    orientation = T(1:3, 1:3);
end

function projected_points = project_point(points3D, extrinsic, projection_matrix)
    % transform to the homogeneous coordinates
    if size(points3D, 1) == 3
        points3D = [points3D; ones(size(points3D, 2), 1)];
    end
    
    % transform the 3D point in base frame to the camera frame
    points_camera = (extrinsic * points3D);
    
    % transform the 3D point in 3D camera frame to the 2D frame
    projected_homogeneous = (projection_matrix * points_camera)';
    
    % normalize the homogeneous coordinates
    projected_points = projected_homogeneous(:, 1:2) ./ projected_homogeneous(:, 3);
end

function transformation = array2matrix(array)
    transformation = str2num(array);
    transformation = [[reshape(transformation(4:12), 3, 3)', transformation(1:3)']; [0, 0, 0, 1]];
end

function frame = draw_body_frame(frame, origin, x_axis, y_axis, z_axis, extrinsic, projection_matrix)
    % compute the projection of the body frame
    origin_2d = project_point(origin, extrinsic, projection_matrix);
    x_end_2d = project_point(origin + x_axis, extrinsic, projection_matrix);
    y_end_2d = project_point(origin + y_axis, extrinsic, projection_matrix);
    z_end_2d = project_point(origin + z_axis, extrinsic, projection_matrix);
    
    % draw the body frame
    frame = insertShape(frame, 'Line', [origin_2d, x_end_2d], 'ShapeColor', 'red', 'LineWidth', 2);
    frame = insertShape(frame, 'Line', [origin_2d, y_end_2d], 'ShapeColor', 'green', 'LineWidth', 2);
    frame = insertShape(frame, 'Line', [origin_2d, z_end_2d], 'ShapeColor', 'blue', 'LineWidth', 2);
    
    % add the label
    frame = insertText(frame, x_end_2d, 'X', 'FontColor', 'red', 'FontSize', 12);
    frame = insertText(frame, y_end_2d, 'Y', 'FontColor', 'green', 'FontSize', 12);
    frame = insertText(frame, z_end_2d, 'Z', 'FontColor', 'blue', 'FontSize', 12);
end