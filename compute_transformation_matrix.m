function T = compute_transformation_matrix(alpha, a, theta, d)
    alpha = deg2rad(alpha);
    theta = deg2rad(theta);
    T = [cos(theta), -sin(theta), 0, a;
         sin(theta)*cos(alpha), cos(theta)*cos(alpha), -sin(alpha), -sin(alpha)*d;
         sin(theta)*sin(alpha), cos(theta)*sin(alpha), cos(alpha), cos(alpha)*d;
         0, 0, 0, 1];
end
