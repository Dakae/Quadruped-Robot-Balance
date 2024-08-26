function quadruped_balance_simulation_with_gyro()
    % 초기 각도 값 설정
    global slope_x slope_y  % X축과 Y축 회전 각도를 전역 변수로 선언
    slope_x = 0;  % X축 회전 각도 (Pitch)를 0으로 초기화
    slope_y = 0;  % Y축 회전 각도 (Roll)를 0으로 초기화
    
    % 초기 설정 - 그래픽 창 생성
    figure('Position', [100, 100, 800, 600]);  % 새로운 그래픽 창을 열고, 창의 위치와 크기를 설정
    
    % 3D 로봇 시각화
    hAxes = axes('Position', [0.3, 0.3, 0.6, 0.6]);  % 그래픽 창 내에서 3D 플롯을 표시할 축을 생성
    plotQuadruped(hAxes);  % 초기 로봇과 바닥을 시각화하는 함수 호출

    % 시리얼 포트 설정 (자이로 데이터를 읽기 위함)
    s = serialport("COM6", 38400, "Timeout", 5); % Timeout을 5초로 설정
    
    % 데이터 읽기 및 업데이트 루프
    while ishandle(hAxes)  % Figure가 열려있는 동안 루프 실행
        if s.NumBytesAvailable > 0 % 수신된 데이터가 있을 때만 읽기
            gyroData = readline(s); % 데이터 읽기
            dataArray = str2double(split(strtrim(gyroData), ',')); % 문자열 다듬기 및 분리

            if length(dataArray) == 2 && all(~isnan(dataArray)) % 올바른 데이터인지 확인
                slope_x = dataArray(1);  % pitch 값을 slope_x로 설정
                slope_y = dataArray(2);  % roll 값을 slope_y로 설정
                plotQuadruped(hAxes);  % 로봇 기울기 업데이트
            end
        end
        pause(0.1); % 업데이트 주기
    end
end

function plotQuadruped(hAxes)
    global slope_x slope_y
    
    % 로봇 몸체 위치 및 크기 정의
    body_length = 2;
    body_width = 1;
    body_height = 0.5;
    body_z = 1;  % 몸체의 고정된 높이 (z축)

    % 로봇 다리 위치 (몸체 모서리 좌표)
    legs = [-body_length/2, -body_width/2;
             body_length/2, -body_width/2;
            -body_length/2,  body_width/2;
             body_length/2,  body_width/2];
         
    % 기울어진 바닥 생성
    [X, Y] = meshgrid(linspace(-2, 2, 10), linspace(-2, 2, 10));
    Z = tand(slope_x) * X + tand(slope_y) * Y;
    
    % 각 다리 끝점이 바닥에 닿는 위치의 높이 계산
    leg_heights = zeros(4, 1);  % 각 다리의 바닥과 닿는 지점의 높이를 저장할 배열 초기화
    for i = 1:4
        leg_heights(i) = interp2(X, Y, Z, legs(i, 1), legs(i, 2), 'linear');
    end
    
    % 시각화 설정
    axes(hAxes);  % 시각화할 축 설정
    cla(hAxes);  % 현재 축의 내용 지우기
    hold on;  % 여러 객체를 동시에 그리기 위해 hold on
    
    % 바닥 시각화
    surf(X, Y, Z, 'FaceAlpha', 0.5, 'EdgeColor', 'none');  % 반투명 바닥을 그리며, 선 없이 면만 표시
    
    % 로봇 몸체 시각화
    plot3(legs(:, 1), legs(:, 2), body_z * ones(4, 1), ...
        'ko-', 'MarkerSize', 10, 'LineWidth', 2);  % 몸체의 네 모서리를 연결한 선을 3D 공간에 시각화
    
    % 각 다리마다 두 개의 선을 그리는 루프
    for i = 1:4
        % 각 다리의 길이 계산
        li = abs(body_z - leg_heights(i));  % i번째 다리의 길이 li 계산

        % 세타i 계산
        thetai = asin(li / 2);  % i번째 다리의 길이로 세타i 계산

        % 첫 번째 선 (legi_line1) 그리기
        start_point = [legs(i, 1), legs(i, 2), body_z];  % i번째 다리의 시작점 좌표
        end_point_x1 = start_point(1) + cos(-thetai);  % X축 방향의 끝점 계산
        end_point_z1 = start_point(3) + sin(-thetai);  % Z축 방향의 끝점 계산

        plot3([start_point(1), end_point_x1], ...
              [start_point(2), start_point(2)], ...  % Y좌표는 동일한 평면에 위치
              [start_point(3), end_point_z1], 'r-', 'LineWidth', 2);  % 빨간색 선으로 표시
        
        % 두 번째 선 (legi_line2) 그리기
        end_point_x2 = end_point_x1 + cos(thetai - pi);  % 첫 번째 선의 끝점에서 thetai - 180도 방향
        end_point_z2 = end_point_z1 + sin(thetai - pi);  % 첫 번째 선의 끝점에서 thetai - 180도 방향

        plot3([end_point_x1, end_point_x2], ...
              [start_point(2), start_point(2)], ...  % Y좌표는 동일한 평면에 위치
              [end_point_z1, end_point_z2], 'b-', 'LineWidth', 2);  % 파란색 선으로 표시
    end
    
    % 축 설정
    xlabel('X');  % X축 레이블
    ylabel('Y');  % Y축 레이블
    zlabel('Z');  % Z축 레이블
    grid on;  % 그리드 표시
    axis equal;  % 축의 비율을 동일하게 유지
    xlim([-2, 2]);  % X축 범위 설정
    ylim([-2, 2]);  % Y축 범위 설정
    zlim([-1, 2]);  % Z축 범위 설정
    view(3);  % 3D 뷰 모드로 설정
    title(sprintf('Slope X: %.1f°, Slope Y: %.1f°', slope_x, slope_y));  % 현재 기울기를 제목으로 표시
    hold off;  % 더 이상 그래프에 추가하지 않도록 hold off
end
