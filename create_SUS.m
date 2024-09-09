% 创建 SUS 子系统函数
function sus = create_SUS()
    inch2m = 25.4/1000;
    sus = rigidBodyTree('DataFormat', 'column');
    
    % SUS 链接 1: 移动关节 (Prismatic)
    body1 = rigidBody('SUS_1');
    joint1 = rigidBodyJoint('SUS_joint1', 'prismatic');
    setFixedTransform(joint1, compute_transformation_matrix(0.0, 0.0*inch2m, 90.0, 75.50579*inch2m));
    joint1.JointAxis = [0 0 1];
    body1.Joint = joint1;
    addBody(sus, body1, 'base');
    
    % SUS 链接 2: 旋转关节 (Revolute)
    body2 = rigidBody('SUS_2');
    joint2 = rigidBodyJoint('SUS_joint2', 'revolute');
    setFixedTransform(joint2, compute_transformation_matrix(0.0, 0.0*inch2m, 0.0, 0.0*inch2m));
    joint2.JointAxis = [0 0 1];
    body2.Joint = joint2;
    addBody(sus, body2, 'SUS_1');
    
    % SUS 链接 3: 移动关节 (Prismatic)
    body3 = rigidBody('SUS_3');
    joint3 = rigidBodyJoint('SUS_joint3', 'prismatic');
    setFixedTransform(joint3, compute_transformation_matrix(90.0, 0.0*inch2m, 0.0, 41.0*inch2m));
    joint3.JointAxis = [1 0 0];
    body3.Joint = joint3;
    addBody(sus, body3, 'SUS_2');
    
    % SUS 链接 4: 旋转关节 (Revolute)
    body4 = rigidBody('SUS_4');
    joint4 = rigidBodyJoint('SUS_joint4', 'revolute');
    setFixedTransform(joint4, compute_transformation_matrix(-90.0, 0.0*inch2m, 90.0, -2.85579*inch2m));
    joint4.JointAxis = [1 0 0];
    body4.Joint = joint4;
    addBody(sus, body4, 'SUS_3');
end