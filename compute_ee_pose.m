% basic setup
close all
configuration;

% create the visualization model and extract the rotation/prismatic joint value
daVinci = build_da_Vinci_function();
config = homeConfiguration(daVinci);

% read the csv file
opts = detectImportOptions(csv_file_path{1}, 'Delimiter', ',');
data_USM1 = readtable(csv_file_path{1}, opts);
opts = detectImportOptions(csv_file_path{2}, 'Delimiter', ',');
data_USM2 = readtable(csv_file_path{2}, opts);
opts = detectImportOptions(csv_file_path{3}, 'Delimiter', ',');
data_USM3 = readtable(csv_file_path{3}, opts);
opts = detectImportOptions(csv_file_path{4}, 'Delimiter', ',');
data_USM4 = readtable(csv_file_path{4}, opts);

% transform joint value array to structure
[config_struct, joint_map] = array_to_struct_config(daVinci, config);

% Create tables to store T_USM1 to T_USM4 data
T_USM1_table = table('Size', [0, 1], 'VariableTypes', {'string'}, 'VariableNames', {'EE'});
T_USM2_table = table('Size', [0, 1], 'VariableTypes', {'string'}, 'VariableNames', {'EE'});
T_USM3_table = table('Size', [0, 1], 'VariableTypes', {'string'}, 'VariableNames', {'EE'});
T_USM4_table = table('Size', [0, 1], 'VariableTypes', {'string'}, 'VariableNames', {'EE'});

for index = 1:height(data_USM2)
    % 更新 + 初始化模型配置
    current_config = config_struct;

    % update the endoscope joint value
    joint_name_array = ["SUJ1_joint1", "SUJ1_joint2","SUJ1_joint3", "SUJ1_joint4", "USM1_OT_joint", "USM1_joint1", "USM1_joint2", "USM1_joint3", "USM1_joint4", "USM1_joint5", "USM1_endoscope_joint1"];
    suj_joint_values = str2num(data_USM1.SUJvalues{index});
    psm_joint_values = str2num(data_USM1.JointValues{index});
    joint_values = [suj_joint_values(1:4), psm_joint_values(1:7)];
    current_config = update_model_config(current_config, joint_name_array, joint_values);

    % update the USM2 joint value
    joint_name_array = ["SUJ2_joint1", "SUJ2_joint2","SUJ2_joint3", "SUJ2_joint4", "USM2_OT_joint", "USM2_joint1", "USM2_joint2", "USM2_joint3", "USM2_joint4", "USM2_joint5", "USM2_END_EFFECT_joint1", "USM2_END_EFFECT_joint2", "USM2_END_EFFECT_joint3"];
    suj_joint_values = str2num(data_USM2.SUJvalues{index});
    psm_joint_values = str2num(data_USM2.JointValues{index});
    psm_joint_values(7:10) = coupling_matrix * psm_joint_values(7:10)';
    joint_values = [suj_joint_values(1:4), psm_joint_values];
    current_config = update_model_config(current_config, joint_name_array, joint_values);

    % update the endoscope joint value
    joint_name_array = ["SUJ3_joint1", "SUJ3_joint2","SUJ3_joint3", "SUJ3_joint4", "USM3_OT_joint", "USM3_joint1", "USM3_joint2", "USM3_joint3", "USM3_joint4", "USM3_joint5", "USM3_endoscope_joint1"];
    suj_joint_values = str2num(data_USM3.SUJvalues{index});
    psm_joint_values = str2num(data_USM3.JointValues{index});
    joint_values = [suj_joint_values(1:4), psm_joint_values(1:7)];
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

    % compute the end effect pose in base frame
    T_USM1 = getTransform(daVinci, config_array, "USM1_endoscope_body4");
    T_USM2 = getTransform(daVinci, config_array, "USM2_END_EFFECT_body4");
    T_USM3 = getTransform(daVinci, config_array, "USM3_endoscope_body4");
    T_USM4 = getTransform(daVinci, config_array, "USM4_END_EFFECT_body4");

    % Convert T_USM1 to T_USM4 to strings and add to respective tables
    T_USM1_string = mat2str(T_USM1);
    T_USM2_string = mat2str(T_USM2);
    T_USM3_string = mat2str(T_USM3);
    T_USM4_string = mat2str(T_USM4);

    T_USM1_table = [T_USM1_table; {T_USM1_string}];
    T_USM2_table = [T_USM2_table; {T_USM2_string}];
    T_USM3_table = [T_USM3_table; {T_USM3_string}];
    T_USM4_table = [T_USM4_table; {T_USM4_string}];
end

% Display the T_USM tables
% disp('T_USM1 Table:');
% disp(T_USM1_table);
% disp('T_USM2 Table:');
% disp(T_USM2_table);
% disp('T_USM3 Table:');
% disp(T_USM3_table);
% disp('T_USM4 Table:');
% disp(T_USM4_table);

% Merge data_USM2 with T_USM2_table
merged_data = [data_USM1, T_USM1_table];
% Save the merged data to a new CSV file
writetable(merged_data, 'merged_USM1_data.csv');
% Merge data_USM2 with T_USM2_table
merged_data = [data_USM2, T_USM2_table];
% Save the merged data to a new CSV file
writetable(merged_data, 'merged_USM2_data.csv');
% Merge data_USM2 with T_USM2_table
merged_data = [data_USM3, T_USM3_table];
% Save the merged data to a new CSV file
writetable(merged_data, 'merged_USM3_data.csv');
% Merge data_USM2 with T_USM2_table
merged_data = [data_USM4, T_USM4_table];
% Save the merged data to a new CSV file
writetable(merged_data, 'merged_USM4_data.csv');

disp('Merged data has been saved to merged_USM2_data.csv');

function config_struct = update_model_config(config_struct, joint_name_array, joint_values)
    for i = 1:length(joint_name_array)
        joint_name = joint_name_array{i}(1:end);
        if isfield(config_struct, joint_name_array{i})
            config_struct.(joint_name) = joint_values(i);
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