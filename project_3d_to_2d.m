function point_2d = project_3d_to_2d(point_3d, P)
    % 將3D點轉換為齊次坐標
    point_3d_homogeneous = [point_3d; 1];
    
    % 使用投影矩陣進行變換
    point_2d_homogeneous = P * point_3d_homogeneous;
    
    % 將齊次坐標轉換回非齊次坐標
    point_2d = point_2d_homogeneous(1:2) ./ point_2d_homogeneous(3);
end