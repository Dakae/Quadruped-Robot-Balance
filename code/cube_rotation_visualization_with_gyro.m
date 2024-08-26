function cube_rotation_visualization_with_gyro()
    % 초기 설정
    figure('Position', [100, 100, 800, 600]);
    
    % 초기 각도 값
    yaw = 0;    % Yaw (Z축 회전)
    pitch = 0;  % Pitch (Y축 회전)
    roll = 0;   % Roll (X축 회전)
    
    % 3D 정육면체 시각화
    hAxes = axes('Position', [0.3, 0.3, 0.6, 0.6]);
    plot3DCube(yaw, pitch, roll, hAxes);
    
    % Yaw 슬라이더 (고정)
    uicontrol('Style', 'text', 'Position', [50, 400, 100, 20], 'String', 'Yaw');
    hYawSlider = uicontrol('Style', 'slider', 'Min', -180, 'Max', 180, ...
        'Value', yaw, 'Position', [50, 370, 200, 20]);
    addlistener(hYawSlider, 'ContinuousValueChange', ...
        @(src, event) updateYaw(src, event, hAxes, pitch, roll));
    
    % 시리얼 포트 설정 (자이로 데이터를 읽기 위함)
    s = serialport("COM6", 38400, "Timeout", 5); % Timeout을 5초로 설정
    
    % 데이터 읽기 및 업데이트 루프
    while ishandle(hAxes)  % Figure가 열려있는 동안 루프 실행
        if s.NumBytesAvailable > 0 % 수신된 데이터가 있을 때만 읽기
            gyroData = readline(s); % 데이터 읽기
            dataArray = str2double(split(strtrim(gyroData), ',')); % 문자열 다듬기 및 분리

            if length(dataArray) == 2 && all(~isnan(dataArray)) % 올바른 데이터인지 확인
                pitch = dataArray(1);
                roll = dataArray(2);
                plot3DCube(yaw, pitch, roll, hAxes);
            end
        end
        pause(0.1); % 업데이트 주기
    end
    
    % 각도 업데이트 함수
    function updateYaw(src, ~, hAxes, pitch, roll)
        yaw = get(src, 'Value');
        plot3DCube(yaw, pitch, roll, hAxes);
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
