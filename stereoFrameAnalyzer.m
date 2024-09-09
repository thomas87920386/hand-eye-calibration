function stereoFrameAnalyzer()
    % Main figure
    f = figure('Name', 'Stereo Frame Analyzer', 'Position', [100, 100, 800, 600], ...
               'KeyPressFcn', @keyPressCallback);

    % UI controls
    uicontrol('Style', 'pushbutton', 'String', 'Load Videos', ...
        'Position', [20, 560, 100, 30], 'Callback', @loadVideos);
    uicontrol('Style', 'pushbutton', 'String', 'Save Frame', ...
        'Position', [130, 560, 100, 30], 'Callback', @saveFrame);
    txtFrame = uicontrol('Style', 'text', 'String', 'Frame: 0/0', ...
        'Position', [240, 560, 100, 30]);

    % Axes for frame display
    ax = axes('Parent', f, 'Position', [0.1, 0.1, 0.8, 0.7]);

    % Global variables
    global leftVideo rightVideo currentFrame totalFrames;
    leftVideo = [];
    rightVideo = [];
    currentFrame = 1;
    totalFrames = 0;

    % Functions
    function loadVideos(~, ~)
        % Load left video
        [leftFilename, leftPathname] = uigetfile('*.mp4', 'Select Left Video');
        if leftFilename == 0
            return;
        end
        leftVideo = VideoReader(fullfile(leftPathname, leftFilename));
        
        % Load right video
        [rightFilename, rightPathname] = uigetfile('*.mp4', 'Select Right Video');
        if rightFilename == 0
            return;
        end
        rightVideo = VideoReader(fullfile(rightPathname, rightFilename));
        
        % Check if videos have the same number of frames
        if leftVideo.NumFrames ~= rightVideo.NumFrames
            errordlg('Videos must have the same number of frames!');
            return;
        end
        
        % Set total frames and reset current frame
        totalFrames = leftVideo.NumFrames;
        currentFrame = 1;
        
        % Update display
        updateDisplay();
    end

    function saveFrame(~, ~)
        if isempty(leftVideo) || isempty(rightVideo)
            errordlg('Please load videos first.');
            return;
        end

        % Create directories if they don't exist
        if ~exist('left_frames', 'dir')
            mkdir('left_frames');
        end
        if ~exist('right_frames', 'dir')
            mkdir('right_frames');
        end

        % Read and save left frame (original)
        leftFrame = read(leftVideo, currentFrame);
        imwrite(leftFrame, sprintf('left_frames/left_%04d.png', currentFrame));

        % Read and save right frame (original)
        rightFrame = read(rightVideo, currentFrame);
        imwrite(rightFrame, sprintf('right_frames/right_%04d.png', currentFrame));

        msgbox('Original frames saved successfully!');
    end

    function keyPressCallback(~, eventdata)
        switch eventdata.Key
            case 'leftarrow'
                if currentFrame > 1
                    currentFrame = currentFrame - 1;
                    updateDisplay();
                end
            case 'rightarrow'
                if currentFrame < totalFrames
                    currentFrame = currentFrame + 1;
                    updateDisplay();
                end
        end
    end

    function updateDisplay()
        if ~isempty(leftVideo) && ~isempty(rightVideo)
            % Read current frames
            leftFrame = read(leftVideo, currentFrame);
            rightFrame = read(rightVideo, currentFrame);
            
            % Create anaglyph
            anaglyph = stereoAnaglyph(leftFrame, rightFrame);
            
            % Display anaglyph
            imshow(anaglyph, 'Parent', ax);
            set(txtFrame, 'String', sprintf('Frame: %d/%d', currentFrame, totalFrames));
        end
    end
end