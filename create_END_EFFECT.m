function end_effect = create_END_EFFECT(name)
    if ~contains(name, 'endoscope')
        end_effect = create_end_effect(name);
    else
        end_effect = create_endoscope(name);
    end
end
function end_effect = create_end_effect(name)
    end_effect = rigidBodyTree("DataFormat", "column");

    body1 = rigidBody([name '_body1']);
    body1Joint = rigidBodyJoint([name '_joint1'], "revolute");
    setFixedTransform(body1Joint, compute_transformation_matrix(0, 0, 0, 0.467));
    body1Joint.JointAxis = [0, 0, 1];
    body1.Joint = body1Joint;
    addBody(end_effect, body1, "base");

    body2 = rigidBody([name '_body2']);
    body2Joint = rigidBodyJoint([name '_joint2'], "revolute");
    setFixedTransform(body2Joint, compute_transformation_matrix(-90, 0, -90, 0));
    body2Joint.JointAxis = [0, 0, 1];
    body2.Joint = body2Joint;
    addBody(end_effect, body2, [name '_body1']);

    body3 = rigidBody([name '_body3']);
    body3Joint = rigidBodyJoint([name '_joint3'], "revolute");
    setFixedTransform(body3Joint, compute_transformation_matrix(-90, 0.0091, -90, 0));
    body3Joint.JointAxis = [0, 0, 1];
    body3.Joint = body3Joint;
    addBody(end_effect, body3, [name '_body2']);

    body4 = rigidBody([name '_body4']);
    body4Joint = rigidBodyJoint([name '_joint4'], "fixed");
    setFixedTransform(body4Joint, compute_transformation_matrix(-90, 0, 0, 0.01));
    body4.Joint = body4Joint;
    addBody(end_effect, body4, [name '_body3']);
end

function end_effect = create_endoscope(name)
    end_effect = rigidBodyTree("DataFormat", "column");

    body1 = rigidBody([name '_body1']);
    body1Joint = rigidBodyJoint([name '_joint1'], "revolute");
    setFixedTransform(body1Joint, compute_transformation_matrix(0, 0, 0, 0.3829));
    body1Joint.JointAxis = [0, 0, 1];
    body1.Joint = body1Joint;
    addBody(end_effect, body1, "base");

    body2 = rigidBody([name '_body2']);
    body2Joint = rigidBodyJoint([name '_joint2'], "fixed");
    setFixedTransform(body2Joint, compute_transformation_matrix(-90, 0, -90, 0));
    body2.Joint = body2Joint;
    addBody(end_effect, body2, [name '_body1']);

    body3 = rigidBody([name '_body3']);
    body3Joint = rigidBodyJoint([name '_joint3'], "fixed");
    setFixedTransform(body3Joint, compute_transformation_matrix(-90, 0, -90, 0));
    body3.Joint = body3Joint;
    addBody(end_effect, body3, [name '_body2']);

    body4 = rigidBody([name '_body4']);
    body4Joint = rigidBodyJoint([name '_joint4'], "fixed");
    setFixedTransform(body4Joint, compute_transformation_matrix(-90, 0, 0, 0));
    body4.Joint = body4Joint;
    addBody(end_effect, body4, [name '_body3']);
end

