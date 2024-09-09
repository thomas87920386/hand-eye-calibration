function [projected_USM2, projected_USM4] = show_camera_view(ax, robot, config, trajectory_USM2, trajectory_USM4, davinci_bodies, projection_left, extrinsic_left1, extrinsic_left2, point3D)
    cla(ax);

    % create the figure for show the groudtrouth point coordinates and the
    % projection result
    evaluation_view = figure('Name', 'Evaluation View');
    evaluation_view_ax = axes('Parent', evaluation_view, 'YDir', 'reverse', 'GridLineStyle', '-', 'NextPlot', 'add', 'Title', 'Evaluation View');
    axis(evaluation_view_ax, [0 1280 0 720]);
    xlabel('X (0-1280 pixel)');
    ylabel('Y (0-720 pixel)');

    scatter(evaluation_view_ax, [point3D(1, 1), point3D(2, 1)], [point3D(1, 2), point3D(2, 2)], 50, [0 0.4470 0.7410], 'filled');
    text(point3D(1, 1), point3D(1, 2), 'USM2', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 12);
    text(point3D(2, 1), point3D(2, 2), 'USM4', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 12);

    % get the USM2 and USM4 end-effector transformation rest to the base
    % frame
    [pos_USM2, orient_USM2] = calculate_end_effector('USM2', robot, config);
    [pos_USM4, orient_USM4] = calculate_end_effector('USM4', robot, config);
    
    % project the USM2 and USM4 3D point in the base to the camera 3D frame
    projected_USM2 = project_point(pos_USM2', extrinsic_left1, projection_left);
    projected_USM4 = project_point(pos_USM4', extrinsic_left2, projection_left);

    % draw the end-effector position
    scatter(ax, projected_USM2(1), projected_USM2(2), 100, [0 0.4470 0.7410], 'filled');
    scatter(ax, projected_USM4(1), projected_USM4(2), 100, [0.8500 0.3250 0.0980], 'filled');
    scatter(evaluation_view_ax, [projected_USM2(1), projected_USM4(1)], [projected_USM2(2), projected_USM4(2)], 50, [0.8500 0.3250 0.0980], 'filled');
    text(projected_USM2(1), projected_USM2(2), 'USM2', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 12);
    text(projected_USM4(1), projected_USM4(2), 'USM4', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 12);
    
    % project the trajectory
    if ~isempty(trajectory_USM2)
        projected_traj_USM2 = project_point(trajectory_USM2, extrinsic_left1, projection_left);
        plot(ax, projected_traj_USM2(:,1), projected_traj_USM2(:,2), 'Color', [0 0.4470 0.7410], 'LineWidth', 2);
    else
        disp("nothing to plot trajectory_USM2")
    end
    if ~isempty(trajectory_USM4)
        projected_traj_USM4 = project_point(trajectory_USM4, extrinsic_left2, projection_left);
        plot(ax, projected_traj_USM4(:,1), projected_traj_USM4(:,2), 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2);
    else
        disp("nothing to plot trajectory_USM4")
    end
    
    % draw body_frame
    draw_projected_frame(ax, pos_USM2, orient_USM2, extrinsic_left1, projection_left, 'USM2');
    draw_projected_frame(ax, pos_USM4, orient_USM4, extrinsic_left2, projection_left, 'USM4');

    % draw da Vinci robotic links
    if nargin > 7 && ~isempty(davinci_bodies)
        projected_points_USM2 = [];
        projected_points_USM4 = [];
        projected_points_common = [];
        for i = 1:length(davinci_bodies)
            body_name = davinci_bodies{i};
            transform = getTransform(robot, config, body_name);
            position = transform(1:3, 4);
            orient = transform(1:3, 1:3);

            if contains(body_name, 'USM2')
                projected_pos = project_point(position', extrinsic_left1, projection_left);
                projected_points_USM2 = [projected_points_USM2; projected_pos];
                scatter(ax, projected_pos(1), projected_pos(2), 50, [0 0.4470 0.7410], 'filled');
            elseif contains(body_name, 'USM4')
                projected_pos = project_point(position', extrinsic_left2, projection_left);
                projected_points_USM4 = [projected_points_USM4; projected_pos];
                scatter(ax, projected_pos(1), projected_pos(2), 50, [0.8500 0.3250 0.0980], 'filled');
            else
                projected_points_common = [projected_points_common; projected_pos];
                scatter(ax, projected_pos(1), projected_pos(2), 50, 'black', 'filled');
            end
        end
        % Connect the USM2 point
        if ~isempty(projected_points_USM2)
            plot(ax, projected_points_USM2(:,1), projected_points_USM2(:,2), 'Color', 'black', 'LineWidth', 1.5);
        end
        
        % Connect the USM4 point
        if ~isempty(projected_points_USM4)
            plot(ax, projected_points_USM4(:,1), projected_points_USM4(:,2), 'Color', 'black', 'LineWidth', 1.5);
        end
        
        % Connect the others point
        if ~isempty(projected_points_common)
            plot(ax, projected_points_common(:,1), projected_points_common(:,2), 'k-', 'LineWidth', 1.5);
        end
    end
end

function draw_projected_frame(ax, position, orientation, extrinsic, projection, name)
    frame_points = [position, position + orientation(:,1), position + orientation(:,2), position + orientation(:,3)];
    projected_frame = project_point(frame_points', extrinsic, projection)';

    % draw the body frame
    plot(ax, [projected_frame(1,1) projected_frame(1,2)], [projected_frame(2,1) projected_frame(2,2)], 'r', 'LineWidth', 2);
    plot(ax, [projected_frame(1,1) projected_frame(1,3)], [projected_frame(2,1) projected_frame(2,3)], 'g', 'LineWidth', 2);
    plot(ax, [projected_frame(1,1) projected_frame(1,4)], [projected_frame(2,1) projected_frame(2,4)], 'b', 'LineWidth', 2);
    
    % add the label
    text(ax, projected_frame(1,1), projected_frame(2,1), name, 'Color', 'black', 'FontWeight', 'bold');
    text(ax, projected_frame(1,2), projected_frame(2,2), 'X', 'Color', 'red', 'FontWeight', 'bold');
    text(ax, projected_frame(1,3), projected_frame(2,3), 'Y', 'Color', 'green', 'FontWeight', 'bold');
    text(ax, projected_frame(1,4), projected_frame(2,4), 'Z', 'Color', 'blue', 'FontWeight', 'bold');
end

% get the transformation of the end-effector rest to the base frame
function [position, orientation] = calculate_end_effector(usm_name, robot, config)
    tool_frame = [usm_name '_END_EFFECT_body4'];
    T = getTransform(robot, config, tool_frame);
    position = T(1:3, 4);
    orientation = T(1:3, 1:3);
end

function projected_points = project_point(points3D, extrinsic, projection_matrix)
    % tranform to the homogeneous point
    if size(points3D, 2) == 3
        points3D = [points3D, ones(size(points3D, 1), 1)];
    end
    
    % transform the point to the camera 3D point
    points_camera = (extrinsic * points3D');
    
    % transform the point from the camera 3D frame to the 2D frame
    projected_homogeneous = (projection_matrix * points_camera)';
    
    % normalize
    projected_points = projected_homogeneous(:, 1:2) ./ projected_homogeneous(:, 3);
end