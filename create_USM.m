function usm = create_USM(name)
    switch name
        case 'USM1'
            usm = createOuterUSM('USM1');
        case 'USM2'
            usm = createInnerUSM('USM2');
        case 'USM3'
            usm = createInnerUSM('USM3');
        case 'USM4'
            usm = createOuterUSM('USM4');
    end
end

function usm = createInnerUSM(name)
    usm = rigidBodyTree('DataFormat', 'column');
    inch2m = 25.4/1000;

    % Tornado link
    tornado = rigidBody([name '_OT']);
    tornadoJoint = rigidBodyJoint([name '_OT_joint'], 'revolute');
    setFixedTransform(tornadoJoint, compute_transformation_matrix(45.0, 0.0, 90.0, -33.0470*inch2m));
    tornadoJoint.JointAxis = [0 0 1];
    tornado.Joint = tornadoJoint;
    addBody(usm, tornado, 'base');
    
    % USM link 1
    body1 = rigidBody([name '_1']);
    joint1 = rigidBodyJoint([name '_joint1'], 'revolute');
    setFixedTransform(joint1, compute_transformation_matrix(15.0, 0.0, 0.0, 11.96628*inch2m));
    joint1.JointAxis = [0 0 1];
    body1.Joint = joint1;
    addBody(usm, body1, [name '_OT']);
    
    % USM link 2
    body2 = rigidBody([name '_2']);
    joint2 = rigidBodyJoint([name '_joint2'], 'revolute');
    setFixedTransform(joint2, compute_transformation_matrix(-87.20, -1.07596*inch2m, -28.030, -0.58455*inch2m));
    joint2.JointAxis = [0 0 1];
    body2.Joint = joint2;
    addBody(usm, body2, [name '_1']);
    
    % USM link 3
    body3 = rigidBody([name '_3']);
    joint3 = rigidBodyJoint([name '_joint3'], 'revolute');
    setFixedTransform(joint3, compute_transformation_matrix(0.0, 10.0*inch2m, 112.8860, 0.0));
    joint3.JointAxis = [0 0 1];
    body3.Joint = joint3;
    addBody(usm, body3, [name '_2']);
    
    % USM link 4
    body4 = rigidBody([name '_4']);
    joint4 = rigidBodyJoint([name '_joint4'], 'revolute');
    setFixedTransform(joint4, compute_transformation_matrix(0.0, 12.0*inch2m, 5.1440, 0.0));
    joint4.JointAxis = [0 0 1];
    body4.Joint = joint4;
    addBody(usm, body4, [name '_3']);
    
    % USM link 5
    body5 = rigidBody([name '_5']);
    joint5 = rigidBodyJoint([name '_joint5'], 'prismatic');
    setFixedTransform(joint5, compute_transformation_matrix(-90.0, 4.69966*inch2m, 0.0, -13.30303*inch2m));
    joint5.JointAxis = [0 0 1];
    body5.Joint = joint5;
    addBody(usm, body5, [name '_4']);
end

% 创建内侧 USM (USM2, USM3) 子系统函数
function usm = createOuterUSM(name)
    inch2m = 25.4/1000;
    usm = rigidBodyTree('DataFormat', 'column');
    
    % Tornado link
    tornado = rigidBody([name '_OT']);
    tornadoJoint = rigidBodyJoint([name '_OT_joint'], 'revolute');
    setFixedTransform(tornadoJoint, compute_transformation_matrix(62.0, 0.0, 90.0, -31.84792*inch2m));
    tornadoJoint.JointAxis = [0 0 1];
    tornado.Joint = tornadoJoint;
    addBody(usm, tornado, 'base');
    
    % USM link 1
    body1 = rigidBody([name '_1']);
    joint1 = rigidBodyJoint([name '_joint1'], 'revolute');
    setFixedTransform(joint1, compute_transformation_matrix(15.0, 0.0, 0.0, 11.96628*inch2m));
    joint1.JointAxis = [0 0 1];
    body1.Joint = joint1;
    addBody(usm, body1, [name '_OT']);

    % USM link 2
    body2 = rigidBody([name '_2']);
    joint2 = rigidBodyJoint([name '_joint2'], 'revolute');
    setFixedTransform(joint2, compute_transformation_matrix(-87.20, -1.07596*inch2m, -28.030, -0.58455*inch2m));
    joint2.JointAxis = [0 0 1];
    body2.Joint = joint2;
    addBody(usm, body2, [name '_1']);

    % USM link 3
    body3 = rigidBody([name '_3']);
    joint3 = rigidBodyJoint([name '_joint3'], 'revolute');
    setFixedTransform(joint3, compute_transformation_matrix(0.0, 10.0*inch2m, 112.8860, 0.0));
    joint3.JointAxis = [0 0 1];
    body3.Joint = joint3;
    addBody(usm, body3, [name '_2']);

    % USM link 4
    body4 = rigidBody([name '_4']);
    joint4 = rigidBodyJoint([name '_joint4'], 'revolute');
    setFixedTransform(joint4, compute_transformation_matrix(0.0, 12.0*inch2m, 5.1440, 0.0));
    joint4.JointAxis = [0 0 1];
    body4.Joint = joint4;
    addBody(usm, body4, [name '_3']);

    % USM link 5
    body5 = rigidBody([name '_5']);
    joint5 = rigidBodyJoint([name '_joint5'], 'prismatic');
    setFixedTransform(joint5, compute_transformation_matrix(-90.0, 4.69966*inch2m, 0.0, -13.30303*inch2m));
    joint5.JointAxis = [0 0 1];
    body5.Joint = joint5;
    addBody(usm, body5, [name '_4']);
end