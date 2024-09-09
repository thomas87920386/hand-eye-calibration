function transformation_matrix = check_orthogonal(transformation_matrix)
    % 提取旋轉矩陣
    rotation_matrix = transformation_matrix(1:3, 1:3);
    
    % 檢查正交性
    is_orthogonal = all(abs(rotation_matrix * rotation_matrix' - eye(3)) < 1e-10, 'all');
    
    % 檢查行列式是否為1（特殊正交群SO(3)的條件）
    is_special_orthogonal = abs(det(rotation_matrix) - 1) < 1e-10;
    
    if ~is_orthogonal || ~is_special_orthogonal
        % 使用SVD進行正交化
        [U, ~, V] = svd(rotation_matrix);
        rotation_matrix = U * V';
        
        % 確保行列式為1（處理反射情況）
        if det(rotation_matrix) < 0
            V(:, 3) = -V(:, 3);
            rotation_matrix = U * V';
        end
        
        % disp('Rotation matrix has been orthogonalized and ensured to be in SO(3).');
    end
    
    % 使用rigidtform3d創建新的變換矩陣
    transformation_matrix = rigidtform3d(rotation_matrix, transformation_matrix(1:3, 4));
end
