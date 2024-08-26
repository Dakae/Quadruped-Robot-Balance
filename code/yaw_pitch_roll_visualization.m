function cube_rotation_visualization()
    % 초기 설정
    figure('Position', [100, 100, 800, 600]);
    
    % 초기 각도 값
    yaw = 0;    % Yaw (Z축 회전)
    pitch = 0;  % Pitch (Y축 회전)
    roll = 0;   % Roll (X축 회전)
    
    % 3D 정육면체 시각화
    hAxes = axes('Position', [0.3, 0.3, 0.6, 0.6]);
    plot3DCube(yaw, pitch, roll, hAxes);
    
    % Yaw 슬라이더
    uicontrol('Style', 'text', 'Position', [50, 400, 100, 20], 'String', 'Yaw');
    hYawSlider = uicontrol('Style', 'slider', 'Min', -180, 'Max', 180, ...
        'Value', yaw, 'Position', [50, 370, 200, 20]);
    addlistener(hYawSlider, 'ContinuousValueChange', ...
        @(src, event) updateYaw(src, event, hAxes, pitch, roll));
    
    % Pitch 슬라이더
    uicontrol('Style', 'text', 'Position', [50, 300, 100, 20], 'String', 'Pitch');
    hPitchSlider = uicontrol('Style', 'slider', 'Min', -90, 'Max', 90, ...
        'Value', pitch, 'Position', [50, 270, 200, 20]);
    addlistener(hPitchSlider, 'ContinuousValueChange', ...
        @(src, event) updatePitch(src, event, hAxes, yaw, roll));
    
    % Roll 슬라이더
    uicontrol('Style', 'text', 'Position', [50, 200, 100, 20], 'String', 'Roll');
    hRollSlider = uicontrol('Style', 'slider', 'Min', -180, 'Max', 180, ...
        'Value', roll, 'Position', [50, 170, 200, 20]);
    addlistener(hRollSlider, 'ContinuousValueChange', ...
        @(src, event) updateRoll(src, event, hAxes, yaw, pitch));

    % 0으로 초기화하는 버튼 추가
    uicontrol('Style', 'pushbutton', 'String', 'Reset', ...
        'Position', [50, 100, 100, 40], ...
        'Callback', @(src, event) resetToZero(hYawSlider, hPitchSlider, hRollSlider, hAxes));
    
    % 각도 업데이트 함수들
    function updateYaw(src, ~, hAxes, pitch, roll)
        yaw = get(src, 'Value');
        plot3DCube(yaw, pitch, roll, hAxes);
    end

    function updatePitch(src, ~, hAxes, yaw, roll)
        pitch = get(src, 'Value');
        plot3DCube(yaw, pitch, roll, hAxes);
    end

    function updateRoll(src, ~, hAxes, yaw, pitch)
        roll = get(src, 'Value');
        plot3DCube(yaw, pitch, roll, hAxes);
    end

    % 초기화 버튼의 콜백 함수
    function resetToZero(hYawSlider, hPitchSlider, hRollSlider, hAxes)
        % 각도를 0으로 초기화
        set(hYawSlider, 'Value', 0);
        set(hPitchSlider, 'Value', 0);
        set(hRollSlider, 'Value', 0);
        % 정육면체도 초기 상태로 돌아가도록 업데이트
        plot3DCube(0, 0, 0, hAxes);
    end
end

function plot3DCube(yaw, pitch, roll, hAxes)
    % 기본 정육면체 꼭짓점 좌표
    vertices = [-1 -1 -1;
                -1 -1  1;
                -1  1  1;
                -1  1 -1;
                 1 -1 -1;
                 1 -1  1;
                 1  1  1;
                 1  1 -1];
             
    % 정육면체 면 구성
    faces = [1 2 3 4;
             5 6 7 8;
             1 2 6 5;
             2 3 7 6;
             3 4 8 7;
             4 1 5 8];
         
    % 회전 행렬 계산
    Rx = [1 0 0; 0 cosd(roll) -sind(roll); 0 sind(roll) cosd(roll)];
    Ry = [cosd(pitch) 0 sind(pitch); 0 1 0; -sind(pitch) 0 cosd(pitch)];
    Rz = [cosd(yaw) -sind(yaw) 0; sind(yaw) cosd(yaw) 0; 0 0 1];
    R = Rz * Ry * Rx;

    % 꼭짓점 회전 적용
    rotatedVertices = (R * vertices')';
    
    % 정육면체 그리기
    axes(hAxes);
    cla(hAxes);
    patch('Vertices', rotatedVertices, 'Faces', faces, ...
          'FaceColor', 'cyan', 'FaceAlpha', 0.8);
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    grid on;
    axis equal;
    xlim([-2, 2]);
    ylim([-2, 2]);
    zlim([-2, 2]);
    view(3);
    title(sprintf('Yaw: %.1f, Pitch: %.1f, Roll: %.1f', yaw, pitch, roll));
end
