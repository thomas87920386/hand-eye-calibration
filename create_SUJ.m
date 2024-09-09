function suj = create_SUJ(name)
    switch name
        case "SUJ1"
            suj = createSUJ1();
        case "SUJ2"
            suj = createSUJ23('SUJ2');
        case "SUJ3"
            suj = createSUJ23('SUJ3');
        case "SUJ4"
            suj = createSUJ4();
    end
end

% 创建 SUJ1 子系统函数
function suj1 = createSUJ1()
    inch2m = 25.4/1000;
    suj1 = rigidBodyTree('DataFormat', 'column');
    
    % SUJ1 dummy 链接
    dummy = rigidBody('SUJ1_dummy');
    dummyJoint = rigidBodyJoint('SUJ1_dummy_joint', 'fixed');
    setFixedTransform(dummyJoint, compute_transformation_matrix(0.0, 0.0*inch2m, 90.0, 0.0*inch2m));
    dummy.Joint = dummyJoint;
    addBody(suj1, dummy, 'base');
    
    % SUJ1 链接 1: 旋转关节 (Revolute)
    body1 = rigidBody('SUJ1_1');
    joint1 = rigidBodyJoint('SUJ1_joint1', 'revolute');
    setFixedTransform(joint1, compute_transformation_matrix(0.0, 6.6250*inch2m, 55.0, 0.0*inch2m));
    joint1.JointAxis = [0 0 1];
    body1.Joint = joint1;
    addBody(suj1, body1, 'SUJ1_dummy');
    
    % SUJ1 链接 2: 移动关节 (Prismatic)
    body2 = rigidBody('SUJ1_2');
    joint2 = rigidBodyJoint('SUJ1_joint2', 'prismatic');
    setFixedTransform(joint2, compute_transformation_matrix(90.0, -0.7980*inch2m, 0.0, 25.1230*inch2m));
    joint2.JointAxis = [0 0 1];
    body2.Joint = joint2;
    addBody(suj1, body2, 'SUJ1_1');
    
    % SUJ1 链接 3: 移动关节 (Prismatic)
    body3 = rigidBody('SUJ1_3');
    joint3 = rigidBodyJoint('SUJ1_joint3', 'prismatic');
    setFixedTransform(joint3, compute_transformation_matrix(-90.0, 0.0*inch2m, 0.0, -10.58027*inch2m));
    joint3.JointAxis = [0 0 1];
    body3.Joint = joint3;
    addBody(suj1, body3, 'SUJ1_2');
    
    % SUJ1 链接 4: 旋转关节 (Revolute)
    body4 = rigidBody('SUJ1_4');
    joint4 = rigidBodyJoint('SUJ1_joint4', 'revolute');
    setFixedTransform(joint4, compute_transformation_matrix(0.0, 0.0*inch2m, 0.0, -14.77827*inch2m));
    joint4.JointAxis = [0 0 1];
    body4.Joint = joint4;
    addBody(suj1, body4, 'SUJ1_3');
end

% 创建 SUJ2/3 子系统函数
function suj = createSUJ23(name)
    inch2m = 25.4/1000;
    suj = rigidBodyTree('DataFormat', 'column');
    
    % SUJ dummy 链接
    dummy = rigidBody([name '_dummy']);
    dummyJoint = rigidBodyJoint([name '_dummy_joint'], 'fixed');
    if strcmp(name, 'SUJ2')
        setFixedTransform(dummyJoint, compute_transformation_matrix(0.0, 0.0*inch2m, 30.0, 0.0*inch2m));
    else % SUJ3
        setFixedTransform(dummyJoint, compute_transformation_matrix(0.0, 0.0*inch2m, -30.0, 0.0*inch2m));
    end
    dummy.Joint = dummyJoint;
    addBody(suj, dummy, 'base');
    
    % SUJ 链接 1: 旋转关节 (Revolute)
    body1 = rigidBody([name '_1']);
    joint1 = rigidBodyJoint([name '_joint1'], 'revolute');
    if strcmp(name, 'SUJ2')
        setFixedTransform(joint1, compute_transformation_matrix(0.0, 6.625*inch2m, 92.50, 0.0*inch2m));
    else % SUJ3
        setFixedTransform(joint1, compute_transformation_matrix(0.0, 6.625*inch2m, 87.50, 0.0*inch2m));
    end
    joint1.JointAxis = [0 0 1];
    body1.Joint = joint1;
    addBody(suj, body1, [name '_dummy']);
    
    % SUJ 链接 2: 移动关节 (Prismatic)
    body2 = rigidBody([name '_2']);
    joint2 = rigidBodyJoint([name '_joint2'], 'prismatic');
    setFixedTransform(joint2, compute_transformation_matrix(90.0, -5.280*inch2m, 0.0, 17.7210*inch2m));
    joint2.JointAxis = [0 0 1];
    body2.Joint = joint2;
    addBody(suj, body2, [name '_1']);
    
    % SUJ 链接 3: 移动关节 (Prismatic)
    body3 = rigidBody([name '_3']);
    joint3 = rigidBodyJoint([name '_joint3'], 'prismatic');
    setFixedTransform(joint3, compute_transformation_matrix(-90.0, 0.0*inch2m, 0.0, -10.58056*inch2m));
    joint3.JointAxis = [0 0 1];
    body3.Joint = joint3;
    addBody(suj, body3, [name '_2']);
    
    % SUJ 链接 4: 旋转关节 (Revolute)
    body4 = rigidBody([name '_4']);
    joint4 = rigidBodyJoint([name '_joint4'], 'revolute');
    setFixedTransform(joint4, compute_transformation_matrix(0.0, 0.0*inch2m, 0.0, -6.34690*inch2m));
    joint4.JointAxis = [0 0 1];
    body4.Joint = joint4;
    addBody(suj, body4, [name '_3']);
end

% 创建 SUJ4 子系统函数
function suj4 = createSUJ4()
    inch2m = 25.4/1000;
    suj4 = rigidBodyTree('DataFormat', 'column');
    
    % SUJ4 dummy 链接
    dummy = rigidBody('SUJ4_dummy');
    dummyJoint = rigidBodyJoint('SUJ4_dummy_joint', 'fixed');
    setFixedTransform(dummyJoint, compute_transformation_matrix(0.0, 0.0*inch2m, -90.0, 0.0*inch2m));
    dummy.Joint = dummyJoint;
    addBody(suj4, dummy, 'base');
    
    % SUJ4 链接 1: 旋转关节 (Revolute)
    body1 = rigidBody('SUJ4_1');
    joint1 = rigidBodyJoint('SUJ4_joint1', 'revolute');
    setFixedTransform(joint1, compute_transformation_matrix(0.0, 6.6250*inch2m, 126.0, 0.0*inch2m));
    joint1.JointAxis = [0 0 1];
    body1.Joint = joint1;
    addBody(suj4, body1, 'SUJ4_dummy');
    
    % SUJ4 链接 2: 移动关节 (Prismatic)
    body2 = rigidBody('SUJ4_2');
    joint2 = rigidBodyJoint('SUJ4_joint2', 'prismatic');
    setFixedTransform(joint2, compute_transformation_matrix(90.0, -7.9790*inch2m, 0.0, 23.4220*inch2m));
    joint2.JointAxis = [0 0 1];
    body2.Joint = joint2;
    addBody(suj4, body2, 'SUJ4_1');
    
    % SUJ4 链接 3: 移动关节 (Prismatic)
    body3 = rigidBody('SUJ4_3');
    joint3 = rigidBodyJoint('SUJ4_joint3', 'prismatic');
    setFixedTransform(joint3, compute_transformation_matrix(-90.0, 0.0*inch2m, 0.0, -10.58027*inch2m));
    joint3.JointAxis = [0 0 1];
    body3.Joint = joint3;
    addBody(suj4, body3, 'SUJ4_2');
    
    % SUJ4 链接 4: 旋转关节 (Revolute)
    body4 = rigidBody('SUJ4_4');
    joint4 = rigidBodyJoint('SUJ4_joint4', 'revolute');
    setFixedTransform(joint4, compute_transformation_matrix(0.0, 0.0*inch2m, 0.0, -14.77827*inch2m));
    joint4.JointAxis = [0 0 1];
    body4.Joint = joint4;
    addBody(suj4, body4, 'SUJ4_3');
end
