% the source of the joint value
csv_file_path = {
    ".\dataset\part0009\DVST_XI_ToolMotion_USM1.csv", % the original dVlogger data
    ".\dataset\part0009\DVST_XI_ToolMotion_USM2.csv",
    ".\dataset\part0009\DVST_XI_ToolMotion_USM3.csv",
    ".\dataset\part0009\DVST_XI_ToolMotion_USM4.csv",
    ".\dataset\part0009\labelled_DVST_XI_ToolMotion_USM2.csv", % the data for compute the hand-eye transformation
    ".\dataset\part0009\labelled_DVST_XI_ToolMotion_USM4.csv",
    ".\dataset\part0009\labelled_DVST_XI_ToolMotion_USM1.csv",
    ".\dataset\part0009\CollectedData_thomas_left.csv", % the left video labelled point data
    ".\dataset\part0009\CollectedData_thomas_right.csv" % the right video labelled point data
};

file_path_0006 = {
    ".\dataset\part0006\DVST_XI_part0006_LND_USM0.csv",
    ".\dataset\part0006\DVST_XI_part0006_LND_USM1.csv",
    ".\dataset\part0006\DVST_XI_part0006_LND_USM2.csv",
    ".\dataset\part0006\DVST_XI_part0006_LND_USM3.csv",
    ".\dataset\part0006\EndoscopeImageMemory_0_part0006_LND_Rect.avi",
    ".\dataset\part0006\EndoscopeImageMemory_1_part0006_LND_Rect.avi"
};

file_path_0007 = {
    ".\dataset\part0007\DVST_XI_part0007_ALL_USM0.csv",
    ".\dataset\part0007\DVST_XI_part0007_ALL_USM1.csv",
    ".\dataset\part0007\DVST_XI_part0007_ALL_USM2.csv",
    ".\dataset\part0007\DVST_XI_part0007_ALL_USM3.csv",
    ".\dataset\part0007\EndoscopeImageMemory_0_part0007_ALL_Rect.avi",
    ".\dataset\part0007\EndoscopeImageMemory_1_part0007_ALL_Rect.avi"
};

file_path_0008 = {
    ".\dataset\part0008\DVST_XI_part0008_ALL_USM0.csv",
    ".\dataset\part0008\DVST_XI_part0008_ALL_USM1.csv",
    ".\dataset\part0008\DVST_XI_part0008_ALL_USM2.csv",
    ".\dataset\part0008\DVST_XI_part0008_ALL_USM3.csv",
    ".\dataset\part0008\EndoscopeImageMemory_0_part0008_ALL_Rect.avi",
    ".\dataset\part0008\EndoscopeImageMemory_1_part0008_ALL_Rect.avi"
};

% coupling matrix
coupling_matrix = [
    -1.56323325            0           0           0;
              0   1.01857984           0           0;
              0 -0.830634273 0.608862987 0.608862987;
              0            0 -1.21772597  1.21772597
];

% the endoscope intrinsic matrix
projection_left =  [ 8.2572909006503187e+02, 0.0, 3.8724927520751953e+02, 0;
                    0.0, 8.2572909006503187e+02, 3.4791796493530273e+02, 0;
                    0.0, 0.0, 1, 0.0 ];

projection_right = [ 8.2572909006503187e+02, 0.0, 3.8724927520751953e+02, -3.5752213173627606;
                    0.0, 8.2572909006503187e+02, 3.4791796493530273e+02, 0;
                    0.0, 0.0, 1, 0.0 ];

% the endoscope Q matrix for reconstruct the 3d point in endoscope frame
Q = [ 1.0, 0.0, 0.0, -3.8724927520751953e+02;
    0.0, 1.0, 0.0, -3.4791796493530273e+02;
    0.0, 0.0, 0.0, 8.2572909006503187e+02;
    0.0, 0.0, 2.3095887408562604e+02, 0.0 ];

% hand-eye transformation
hand_eye_transformation = [
   -0.9994   -0.0262   -0.0229    0.0295
    0.0316   -0.9593   -0.2805    0.0206
   -0.0146   -0.2810    0.9596    0.0151
         0         0         0    1.0000
];

% the recording video fps
frame_rate = 30;

% container for storing the reprojection point
reprojection_USM2 = [];
reprojection_USM4 = [];