function csvBasedRightCameraVideoLabelingTool()
% 全局變量
global video currentFrame csvData allLabels frameIndices currentFrameIndex;
global standardWidth standardHeight ax panel frameEdit;

% 設置標準尺寸
standardWidth = 1280;
standardHeight = 720;

% 讀取視頻
[fileName, pathName] = uigetfile({'*.mp4;*.avi','Video Files (*.mp4,*.avi)'}, 'Select Right Camera Video');
videoPath = fullfile(pathName, fileName);
video = VideoReader(videoPath);

% 讀取CSV文件
[csvFileName, csvPathName] = uigetfile({'*.csv','CSV Files (*.csv)'}, 'Select CSV File');
csvPath = fullfile(csvPathName, csvFileName);
csvData = readtable(csvPath);

% 創建保存標記幀的文件夾
if ~exist('./label_frame', 'dir')
    mkdir('./label_frame');
end

% 獲取CSV中的幀索引
frameIndices = cellfun(@(x) str2double(x(4:7)), csvData.index) + 1;
currentFrameIndex = 1;
currentFrame = frameIndices(currentFrameIndex);

% 創建主窗口
fig = figure('Name', 'Improved Right Camera Video Labeling Tool', 'NumberTitle', 'off', ...
    'Position', [100 100 standardWidth standardHeight], ...
    'ResizeFcn', @resizeCallback);

% 創建視頻顯示區域
ax = axes('Parent', fig, 'Position', [0, 0.1, 1, 0.9]);

% 創建控制面板
panel = uipanel('Parent', fig, 'Position', [0, 0, 1, 0.1], 'Units', 'normalized');

% 創建按鈕和控件
uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Previous Frame', 'Callback', @previousFrame, 'Units', 'normalized', 'Position', [0.05, 0.1, 0.2, 0.8]);
uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Next Frame', 'Callback', @nextFrame, 'Units', 'normalized', 'Position', [0.3, 0.1, 0.2, 0.8]);
uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Manual Label', 'Callback', @manualLabel, 'Units', 'normalized', 'Position', [0.55, 0.1, 0.2, 0.8]);
uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Clear Labels', 'Callback', @clearLabels, 'Units', 'normalized', 'Position', [0.8, 0.1, 0.15, 0.8]);

% 創建輸入框
uicontrol('Parent', panel, 'Style', 'text', 'String', 'Frame:', 'Units', 'normalized', 'Position', [0.05, 0.6, 0.1, 0.3]);
frameEdit = uicontrol('Parent', panel, 'Style', 'edit', 'Callback', @goToFrame, 'Units', 'normalized', 'Position', [0.15, 0.6, 0.1, 0.3]);

% 初始化
allLabels = table('Size', [0, 5], 'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'Frame', 'Individual1_x', 'Individual1_y', 'Individual2_x', 'Individual2_y'});
updateFrame();

% 更新幀
    function updateFrame()
        if ~isvalid(ax)
            ax = axes('Parent', gcf, 'Position', [0, 0.1, 1, 0.9]);
        end
        if currentFrame > 0 && currentFrame <= video.NumFrames
            frame = read(video, currentFrame);
            frame = imresize(frame, [standardHeight, standardWidth]);
            imshow(frame, 'Parent', ax);
            title(ax, sprintf('Frame: %d', currentFrame));
            set(frameEdit, 'String', num2str(currentFrame));

            drawGuidelines();

            % 顯示當前幀的標記（如果有）
            frameIndex = find(allLabels.Frame == currentFrame);
            if ~isempty(frameIndex)
                hold(ax, 'on');
                plot(ax, allLabels.Individual1_x(frameIndex), allLabels.Individual1_y(frameIndex), 'ro', 'MarkerSize', 10);
                plot(ax, allLabels.Individual2_x(frameIndex), allLabels.Individual2_y(frameIndex), 'bo', 'MarkerSize', 10);
                hold(ax, 'off');
            end
        else
            cla(ax);
            title(ax, 'Invalid Frame');
        end
    end

% 繪製參考橫線
    function drawGuidelines()
        hold(ax, 'on');
        y1 = csvData.individual1_y(currentFrameIndex);
        y2 = csvData.individual2_y(currentFrameIndex);

        plot(ax, [1, standardWidth], [y1, y1], 'r--', 'LineWidth', 2);
        text(ax, 10, y1, 'Individual 1', 'Color', 'r', 'VerticalAlignment', 'bottom');

        plot(ax, [1, standardWidth], [y2, y2], 'b--', 'LineWidth', 2);
        text(ax, 10, y2, 'Individual 2', 'Color', 'b', 'VerticalAlignment', 'bottom');
        hold(ax, 'off');
    end

% 上一幀
    function previousFrame(~, ~)
        if currentFrameIndex > 1
            currentFrameIndex = currentFrameIndex - 1;
            currentFrame = frameIndices(currentFrameIndex);
            updateFrame();
        end
    end

% 下一幀
    function nextFrame(~, ~)
        if currentFrameIndex < length(frameIndices)
            currentFrameIndex = currentFrameIndex + 1;
            currentFrame = frameIndices(currentFrameIndex);
            updateFrame();
        end
    end

% 跳轉到指定幀
    function goToFrame(hObject, ~)
        frame = str2double(get(hObject, 'String'));
        index = find(frameIndices == frame);
        if ~isempty(index)
            currentFrameIndex = index;
            currentFrame = frame;
            updateFrame();
        else
            warndlg('Invalid frame number or frame not in CSV');
        end
    end

    function manualLabel(~, ~)
        frame = read(video, currentFrame);
        frame = imresize(frame, [standardHeight, standardWidth]);
        imshow(frame, 'Parent', ax);
        drawGuidelines();

        hold(ax, 'on');
        y1 = csvData.individual1_y(currentFrameIndex);
        y2 = csvData.individual2_y(currentFrameIndex);

        title(ax, 'Click to label Individual 1 (x-coordinate only)');
        [x1, ~] = ginput(1);
        plot(ax, x1, y1, 'ro', 'MarkerSize', 10);

        title(ax, 'Click to label Individual 2 (x-coordinate only)');
        [x2, ~] = ginput(1);
        plot(ax, x2, y2, 'bo', 'MarkerSize', 10);

        hold(ax, 'off');
        title(ax, sprintf('Frame: %d - Labeled', currentFrame));

        newRow = table(currentFrame, x1, y1, x2, y2, ...
            'VariableNames', {'Frame', 'Individual1_x', 'Individual1_y', 'Individual2_x', 'Individual2_y'});

        existingIndex = find(allLabels.Frame == currentFrame);
        if isempty(existingIndex)
            allLabels = [allLabels; newRow];
        else
            allLabels(existingIndex, :) = newRow;
        end

        % 儲存標記後的幀圖像
        saveLabeledFrame(frame, x1, y1, x2, y2);

        disp(['Manually labeled frame ', num2str(currentFrame)]);
    end

    % 儲存標記後的幀圖像（無白框）
    function saveLabeledFrame(frame, x1, y1, x2, y2)
        % 创建一个不可见的图形
        fig = figure('Visible', 'off');
        
        % 创建轴并设置其位置以填充整个图形
        ax = axes('Position', [0 0 1 1]);
        
        % 显示图像
        imshow(frame, 'Parent', ax);
        hold on;

        % 繪製參考線
        plot([1, standardWidth], [y1, y1], 'r--', 'LineWidth', 2);
        plot([1, standardWidth], [y2, y2], 'b--', 'LineWidth', 2);

        % 繪製標記點
        plot(x1, y1, 'ro', 'MarkerSize', 10);
        plot(x2, y2, 'bo', 'MarkerSize', 10);

        % 添加文本
        text(x1, y1-20, 'Individual 1', 'Color', 'r', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
        text(x2, y2+20, 'Individual 2', 'Color', 'b', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center');
        
        hold off;

        % 设置图形大小
        set(fig, 'PaperUnits', 'inches');
        set(fig, 'PaperSize', [standardWidth standardHeight]/100);
        set(fig, 'PaperPosition', [0 0 standardWidth standardHeight]/100);

        % 保存图像
        print(fig, sprintf('./label_frame/frame_%04d.png', currentFrame), '-dpng', '-r100');
        
        % 关闭图形
        close(fig);
    end


% 清除標記
    function clearLabels(~, ~)
        frameIndex = find(allLabels.Frame == currentFrame);
        if ~isempty(frameIndex)
            allLabels(frameIndex, :) = [];
            updateFrame();
            disp(['Cleared labels for frame ', num2str(currentFrame)]);
        else
            warndlg('No labels to clear for this frame');
        end
    end

% 視窗大小變化回調函數
    function resizeCallback(~, ~)
        if isvalid(ax) && isvalid(panel)
            set(ax, 'Position', [0, 0.1, 1, 0.9]);
            set(panel, 'Position', [0, 0, 1, 0.1]);
            updateFrame();
        end
    end

% 程序結束時保存所有標記
    function closeFigure(~, ~)
        if ~isempty(allLabels)
            writetable(allLabels, 'right_camera_labels.csv');
            disp('Saved all labels to right_camera_labels.csv');
        end
        delete(gcf);
    end

    function scaledCoord = scaleCoordinate(coord, originalSize, newSize)
        scaledCoord = (coord / originalSize) * newSize;
    end

set(fig, 'CloseRequestFcn', @closeFigure);
updateFrame();
end