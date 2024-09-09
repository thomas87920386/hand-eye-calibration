# hand-eye-calibration
The Matlab script for hand-eye calibration

First, you need to download all the scripts in this repository into a folder, which will be the project folder. Subsequently, check the "configuration.m", it will show the needed folder, file or data for the project.

1. main_compute_hand_eye.m:
The script is used to compute the hand-eye transformation and can compute the mean error between the reprojection point and ground truth.

2. main_create_label_video.m:
Can label the video by the coordinates computed by the reprojected point.

3. main_endoscopePosition_visualization.m:
The script can plot the point with the coordinates, which is the translation part in the "EndoscopePosition" column, to the video.

4. main_save_all_frames.m:
The script can extract all the frames from the video into the folder. It is only helpful to write the thesis.

5. main_label_right_video.m:
According to the point coordinates in the CSV file, recording the left video labelled point, to draw the horizontal line in the right video frame, which is needed to be labelled and fixed the Y coordinate of the labelled point coordinates in the right frame.

Step 1:
Select the right video you want to label.
![image](https://github.com/user-attachments/assets/80b2b2ba-3f92-4e83-ade3-b5463b157b7e)

Step 2:
Select the CSV file recording the left video labelled point coordinates.
![image](https://github.com/user-attachments/assets/0d6b1a8d-9bbf-49be-aa63-82730729a134)

Step 3:
After choosing both the files needed, you will see the screen like this:
![image](https://github.com/user-attachments/assets/d1631b74-07d6-405b-978d-b773d260e4ff)

Step 4:
Click the manual label button.
![image](https://github.com/user-attachments/assets/fa2c45a6-2722-44e3-bd22-d0a364e3d6e3)

Step 5:
After pressing the button, the support crosshair can help you label the feature, and click the left mouse button label.
![image](https://github.com/user-attachments/assets/3dcca288-4230-430d-b64c-3816d5188e03)

Step 6:
The result after labelling the feature.
![image](https://github.com/user-attachments/assets/e4888b9e-0caf-43da-b5e1-a4dfd3ad8b5d)

Step 7:
After labelling this frame, press the "Next Frame" button directly and continue steps 4 to 7 until all the frames you want to label are done.
![image](https://github.com/user-attachments/assets/d531b07a-fafb-47a3-a85b-0328959d4f1a)

Step 8:
When you finish the labelling work, close the window directly. Do not press anything.
![image](https://github.com/user-attachments/assets/036f3a62-acfe-4596-b0cd-a9dd4170f20b)
And can see which frame you have labelled in the MatLab command line.
![image](https://github.com/user-attachments/assets/01fff6dd-461c-4822-b254-a47b9a8e1912)

Step 9:
Find the "right_camera_labels.csv" in the project folder. It will record all the points you label.
![image](https://github.com/user-attachments/assets/0228dea7-0a30-49f2-af09-c61a75b55784)







