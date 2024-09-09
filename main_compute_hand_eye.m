% basic setup
clear;
close all
configuration;

% create the visualization model and extract the rotation/prismatic joint
% value
daVinci = build_da_Vinci_function();
config = homeConfiguration(daVinci);
showdetails(daVinci)

% read the csv file
opts = detectImportOptions(csv_file_path{5}, 'Delimiter', ',');
data_USM2 = readtable(csv_file_path{5}, opts);
opts = detectImportOptions(csv_file_path{6}, 'Delimiter', ',');
data_USM4 = readtable(csv_file_path{6}, opts);
opts = detectImportOptions(csv_file_path{7}, 'Delimiter', ',');
data_endoscope = readtable(csv_file_path{7}, opts);
data_end_effector_2d_left = readtable(csv_file_path{8});
data_end_effector_2d_right = readtable(csv_file_path{9});
disp('Successfully read the files');

% Create the axis and graph for the visualization robot model
kinematic_simulation = figure('Name', 'Da Vinci XI kinematic simulation');
kinematic_simulation_ax = axes('Parent', kinematic_simulation, 'View', [45, 45], 'GridLineStyle', '-', 'NextPlot', 'add', 'Title', 'da Vinci Xi Model Trajectory');
kinematic_simulation_ax = show(daVinci, config, 'Parent', kinematic_simulation_ax, 'PreservePlot', false);
axis(kinematic_simulation_ax, 'equal');
xlabel(kinematic_simulation_ax, 'X'); ylabel(kinematic_simulation_ax, 'Y'); zlabel(kinematic_simulation_ax, 'Z');

% Create the axis and graph for the simulation the trajectory projection in
% the 2D endoscope frame
endoscope_view = figure('Name', 'Endoscope View');
endoscope_view_ax = axes('Parent', endoscope_view, 'YDir', 'reverse', 'NextPlot', 'add', 'Title', 'Endoscope View');
axis(endoscope_view_ax, [0 1280 0 720]);
xlabel('X (0-1280 pixel)');
ylabel('Y (0-720 pixel)');

% Create the axis and graph for showing the camera pose in base frame
show_camera_pose_3d = figure('Name', 'Camera pose');
show_camera_pose_3d_ax = axes('Parent', show_camera_pose_3d, NextPlot='add', Title='Camera Pose');
view(3)
grid on

% create the container for end effector 3d trajectory based on world frame
trajectory_line_USM2 = plot3(kinematic_simulation_ax, nan, nan, nan, 'Color', [0 0.4470 0.7410], 'LineWidth', 2);
trajectory_line_USM4 = plot3(kinematic_simulation_ax, nan, nan, nan, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2);

% create the more obvious label for the end effector
scatter_USM2 = scatter3(kinematic_simulation_ax, nan, nan, nan, 100, [0 0.4470 0.7410], 'filled');
scatter_USM4 = scatter3(kinematic_simulation_ax, nan, nan, nan, 100, [0.8500 0.3250 0.0980], 'filled');

% initialization
trajectory_USM2 = [];
trajectory_USM4 = [];

% create the USM2 and USM4 body frame
frame_USM2 = create_end_effector_frame(kinematic_simulation_ax, 'USM2');
frame_USM4 = create_end_effector_frame(kinematic_simulation_ax, 'USM4');

% transform joint value array to structure
[config_struct, joint_map] = array_to_struct_config(daVinci, config);

% Compute the hand eye transformation matrix
% 1. compute the end effect pose in cemera frame 
left_video_points = [[data_end_effector_2d_left.individual1_x, data_end_effector_2d_left.individual1_y];[data_end_effector_2d_left.individual2_x, data_end_effector_2d_left.individual2_y]];
right_video_points = [[data_end_effector_2d_right.individual1_x, data_end_effector_2d_right.individual1_y];[data_end_effector_2d_right.individual2_x, data_end_effector_2d_right.individual2_y]];
disparity = left_video_points(:,1) - right_video_points(:,1);
left_video_points = [left_video_points, disparity, ones(size(disparity, 1), 1)];
point3D = Q * left_video_points';
point3D = point3D ./ point3D(4, :);
point3D = point3D(1:3, :)';
point3D_USM2 = point3D(1: size(point3D, 1)/2, :);
size(point3D_USM2, 1)
point3D_USM4 = point3D(size(point3D, 1)/2+1: size(point3D, 1), :);
size(point3D_USM4, 1)
% 2. Extract the end effect pose in enscope frame
point_endo_USM2_ee = [];
point_endo_USM4_ee = [];
num = 0;
for index = 1:size(data_USM2.EndoscopePosition, 1)-num
    trans_endo_USM2_ee = str2num(data_USM2.EndoscopePosition{index});
    point_endo_USM2_ee = [point_endo_USM2_ee; trans_endo_USM2_ee(1:3)];  
    trans_endo_USM4_ee = str2num(data_USM4.EndoscopePosition{index});
    point_endo_USM4_ee = [point_endo_USM4_ee; trans_endo_USM4_ee(1:3)];
end
% 3. registration to compute the hand eye transformation by Procrustes point registration
X = [point3D_USM2; point3D_USM4];
Y = [point_endo_USM2_ee; point_endo_USM4_ee];
[d, Z, transform] = procrustes([point3D_USM2; point3D_USM4], [point_endo_USM2_ee; point_endo_USM4_ee], 'reflection', false, 'scaling', false);
hand_eye_transformation = [[transform.T, transform.c(1,:)']; [0, 0, 0, 1]]
d
RMS = sqrt(d^2 / size(point_endo_USM2_ee, 1))

figure
hold on
view(3)
plot3(X(:,1), X(:,2), X(:,3), 'x');
plot3(Y(:,1), Y(:,2), Y(:,3), 'o');
plot3(Z(:,1), Z(:,2), Z(:,3), 's');
legend('reconstruction', 'endoscopePosition', 'Transformed');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

for index = 1: 1%size(point3D_USM2, 1)
    % show the simulation progress
    index

    % update and initialization the model configuration
    current_config = config_struct;

    % update the endoscope joint value
    joint_name_array = ["SUJ3_joint1", "SUJ3_joint2","SUJ3_joint3", "SUJ3_joint4", "USM3_OT_joint", "USM3_joint1", "USM3_joint2", "USM3_joint3", "USM3_joint4", "USM3_joint5", "USM3_endoscope_joint1"];
    suj_joint_values = str2num(data_endoscope.SUJvalues{index});
    psm_joint_values = str2num(data_endoscope.JointValues{index});
    joint_values = [suj_joint_values(1:4), psm_joint_values(1:7)];
    current_config = update_model_config(current_config, joint_name_array, joint_values);

    % update the USM2 joint value
    joint_name_array = ["SUJ2_joint1", "SUJ2_joint2","SUJ2_joint3", "SUJ2_joint4", "USM2_OT_joint", "USM2_joint1", "USM2_joint2", "USM2_joint3", "USM2_joint4", "USM2_joint5", "USM2_END_EFFECT_joint1", "USM2_END_EFFECT_joint2", "USM2_END_EFFECT_joint3"];
    suj_joint_values = str2num(data_USM2.SUJvalues{index});
    psm_joint_values = str2num(data_USM2.JointValues{index});
    psm_joint_values(7:10) = coupling_matrix * psm_joint_values(7:10)';
    joint_values = [suj_joint_values(1:4), psm_joint_values];
    current_config = update_model_config(current_config, joint_name_array, joint_values);

    % update the USM4 joint value
    joint_name_array = ["SUJ4_joint1", "SUJ4_joint2","SUJ4_joint3", "SUJ4_joint4", "USM4_OT_joint", "USM4_joint1", "USM4_joint2", "USM4_joint3", "USM4_joint4", "USM4_joint5", "USM4_END_EFFECT_joint1", "USM4_END_EFFECT_joint2", "USM4_END_EFFECT_joint3"];
    suj_joint_values = str2num(data_USM4.SUJvalues{index});
    psm_joint_values = str2num(data_USM4.JointValues{index});
    psm_joint_values(7:10) = coupling_matrix * psm_joint_values(7:10)';
    joint_values = [suj_joint_values(1:4), psm_joint_values];
    current_config = update_model_config(current_config, joint_name_array, joint_values);

    % transfer the config with structure type to array type
    config_array = struct_to_array_config(current_config, joint_map);

    % update the visualization model 
    show(daVinci, config_array, 'Parent', kinematic_simulation_ax, 'PreservePlot', false, 'Frame', 'on');

    % compute the end effect pose in base frame
    [pos_USM2, orient_USM2] = calculate_end_effector('USM2', daVinci, config_array);
    [pos_USM4, orient_USM4] = calculate_end_effector('USM4', daVinci, config_array);

    % update the trajectory data
    trajectory_USM2 = [trajectory_USM2; pos_USM2'];
    trajectory_USM4 = [trajectory_USM4; pos_USM4'];

    % update trajectory visualization
    set(trajectory_line_USM2, 'XData', trajectory_USM2(:,1), 'YData', trajectory_USM2(:,2), 'ZData', trajectory_USM2(:,3));
    set(trajectory_line_USM4, 'XData', trajectory_USM4(:,1), 'YData', trajectory_USM4(:,2), 'ZData', trajectory_USM4(:,3));

    % update the end-effector pose
    set(scatter_USM2, 'XData', pos_USM2(1), 'YData', pos_USM2(2), 'ZData', pos_USM2(3));
    set(scatter_USM4, 'XData', pos_USM4(1), 'YData', pos_USM4(2), 'ZData', pos_USM4(3));

    % draw the end-effector body frame
    update_end_effector_frame(frame_USM2, pos_USM2, orient_USM2);
    update_end_effector_frame(frame_USM4, pos_USM4, orient_USM4);

    % Select the bodies that want to show at the camera 2D frame
    davinci_bodies = {'USM2_5', 'USM2_END_EFFECT_body1', 'USM2_END_EFFECT_body2', 'USM2_END_EFFECT_body3', 'USM2_END_EFFECT_body4', 'USM4_5', 'USM4_END_EFFECT_body1', 'USM4_END_EFFECT_body2', 'USM4_END_EFFECT_body3', 'USM4_END_EFFECT_body4'};
    
    % Compute the endoscope pose by USM2
    T_endo_USM2_ee = array2matrix(data_USM2.EndoscopePosition{index});
    extrinsic_left1 = hand_eye_transformation * T_endo_USM2_ee * inv([[orient_USM2, pos_USM2];[0, 0, 0, 1]]);
    extrinsic_left1 = check_orthogonal(extrinsic_left1);
    % use the extrinsic matrix show the camera place in the base frame
    plotCamera("AbsolutePose", extrinsic_left1, "Parent", show_camera_pose_3d_ax, "Color", "blue", "Label", "USM2", 'Size', 0.01);

    % Compute the endoscope pose by USM4
    T_endo_USM4_ee = array2matrix(data_USM4.EndoscopePosition{index}); 
    extrinsic_left2 = hand_eye_transformation * T_endo_USM4_ee * inv([[orient_USM4, pos_USM4];[0, 0, 0, 1]]);
    extrinsic_left2 = check_orthogonal(extrinsic_left2);
    % use the extrinsic matrix show the camera place in the base frame
    plotCamera("AbsolutePose", extrinsic_left2, "Parent", show_camera_pose_3d_ax, "Color", "red", "Label", "USM4", 'Size', 0.01);
    
    [re_2D_USM2, re_2D_USM4] = show_camera_view(endoscope_view_ax, daVinci, config_array, trajectory_USM2, trajectory_USM4, davinci_bodies, projection_left, extrinsic_left1.A, extrinsic_left2.A, [left_video_points(index, :); left_video_points(size(left_video_points, 1)/2 + index, :)]);
    reprojection_USM2 = [reprojection_USM2; re_2D_USM2];
    reprojection_USM4 = [reprojection_USM4; re_2D_USM4];

    drawnow;
    pause(1/frame_rate);
end

% Can statistic the reprojection error pixels in the X-axis and the Y-axis
% mean([reprojection_USM2; reprojection_USM4] - left_video_points(:, 1:2))

function config_struct = update_model_config(config_struct, joint_name_array, joint_values)
    for i = 1:length(joint_name_array)
        joint_name = joint_name_array{i}(1:end);
        if isfield(config_struct, joint_name_array{i})
            config_struct.(joint_name) = joint_values(i);
            disp(['Updated joint ', joint_name, ' to ', num2str(joint_values(i))]);
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
    T = getTransform(robot, config, tool_frame);
    position = T(1:3, 4);
    orientation = T(1:3, 1:3);
end

function frame = create_end_effector_frame(ax, name)
    frame.quiver_x = quiver3(ax, 0, 0, 0, 1, 0, 0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.3);
    frame.quiver_y = quiver3(ax, 0, 0, 0, 0, 1, 0, 'g', 'LineWidth', 2, 'MaxHeadSize', 0.3);
    frame.quiver_z = quiver3(ax, 0, 0, 0, 0, 0, 1, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.3);
    frame.text = text(ax, 0, 0, 0, name, 'FontSize', 10);
end

function update_end_effector_frame(frame, position, orientation_matrix)
    scale = 0.3; 
    axes = ['x', 'y', 'z'];
    for i = 1:3
        set(frame.(sprintf('quiver_%s', axes(i))), ...
            'XData', position(1), 'YData', position(2), 'ZData', position(3), ...
            'UData', orientation_matrix(1,i)*scale, ...
            'VData', orientation_matrix(2,i)*scale, ...
            'WData', orientation_matrix(3,i)*scale);
    end
    set(frame.text, 'Position', position' + [0, 0, scale]);
end

function transformation = array2matrix(array)
    transformation = str2num(array);
    transformation = [[reshape(transformation(4:12), 3, 3)', transformation(1:3)']; [0, 0, 0, 1]];
end