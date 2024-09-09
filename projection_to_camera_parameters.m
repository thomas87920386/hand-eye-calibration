function [intrinsic, rotation, translation] = projection_to_camera_parameters(P)

    if size(P, 2) == 12
        P = reshape(P, 4, 3)';
    end
    
    % Check if P is 3x4
    assert(all(size(P) == [3, 4]), '投影矩陣應為 3x4 的形狀');
    
    % Extract the left 3x3 submatrix (M)
    M = P(:, 1:3);
    
    % Perform RQ decomposition
    [R, Q] = rq(M);
    R_true = Q * diag([1, 1, -1]);
    
    % Calculate intrinsic matrix
    intrinsic = R;

    % Ensure the diagonal elements are positive
    D = diag(sign(diag(intrinsic)));
    intrinsic = intrinsic * D;
    Q = D * Q;

    % Normalize intrinsic matrix
    intrinsic = intrinsic / intrinsic(3,3);

    % Calculate rotation matrix
    rotation = R_true;

    % Calculate translation vector
    translation = inv(intrinsic) * P(:, 4);
end

function [R, Q] = rq(M)
    [Q, R] = qr(flipud(M)');
    R = flipud(R');
    R = fliplr(R);
    Q = Q';
    Q = flipud(Q);
end