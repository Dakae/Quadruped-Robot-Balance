function quadruped_balance_simulation()
    % 초기 각도 값 설정
    global slope_x slope_y  % X축과 Y축 회전 각도를 전역 변수로 선언
    slope_x = 0;  % X축 회전 각도 (Pitch)를 0으로 초기화
    slope_y = 0;  % Y축 회전 각도 (Roll)를 0으로 초기화
    
    % 초기 설정 - 그래픽 창 생성
    figure('Position', [100, 100, 800, 600]);  % 새로운 그래픽 창을 열고, 창의 위치와 크기를 설정
    
    % 3D 로봇 시각화
    hAxes = axes('Position', [0.3, 0.3, 0.6, 0.6]);  % 그래픽 창 내에서 3D 플롯을 표시할 축을 생성
    plotQuadruped(hAxes);  % 초기 로봇과 바닥을 시각화하는 함수 호출
    
    % X축 기울기 슬라이더 생성
    uicontrol('Style', 'text', 'Position', [50, 400, 100, 20], 'String', 'Slope X');  % 'Slope X' 라벨 생성
    hSlopeXSlider = uicontrol('Style', 'slider', 'Min', -20, 'Max', 20, ...
        'Value', slope_x, 'Position', [50, 370, 200, 20]);  % X축 기울기를 조정하는 슬라이더 생성
    addlistener(hSlopeXSlider, 'ContinuousValueChange', ...
        @(src, event) updateSlopeX(src, hAxes));  % 슬라이더가 변경될 때 호출되는 리스너 설정
    
    % Y축 기울기 슬라이더 생성
    uicontrol('Style', 'text', 'Position', [50, 300, 100, 20], 'String', 'Slope Y');  % 'Slope Y' 라벨 생성
    hSlopeYSlider = uicontrol('Style', 'slider', 'Min', -20, 'Max', 20, ...
        'Value', slope_y, 'Position', [50, 270, 200, 20]);  % Y축 기울기를 조정하는 슬라이더 생성
    addlistener(hSlopeYSlider, 'ContinuousValueChange', ...
        @(src, event) updateSlopeY(src, hAxes));  % 슬라이더가 변경될 때 호출되는 리스너 설정
end

function updateSlopeX(src, hAxes)
    % X축 기울기 슬라이더가 변경될 때 호출되는 함수
    global slope_x  % 전역 변수 slope_x 사용
    slope_x = get(src, 'Value');  % 슬라이더의 현재 값을 slope_x에 저장
    plotQuadruped(hAxes);  % 업데이트된 slope_x 값을 반영하여 로봇을 다시 시각화
end

function updateSlopeY(src, hAxes)
    % Y축 기울기 슬라이더가 변경될 때 호출되는 함수
    global slope_y  % 전역 변수 slope_y 사용
    slope_y = get(src, 'Value');  % 슬라이더의 현재 값을 slope_y에 저장
    plotQuadruped(hAxes);  % 업데이트된 slope_y 값을 반영하여 로봇을 다시 시각화
end

function plotQuadruped(hAxes)
    global slope_x slope_y
    
    % 로봇 몸체 위치 및 크기 정의
    body_length = 2;
    body_width = 1;
    body_height = 0.5;
    body_z = 1;  % 몸체의 고정된 높이 (z축)

    % 로봇 첫 번째 다리 위치 (몸체 모서리 좌표)
    leg1 = [-body_length/2, -body_width/2];
         
    % 기울어진 바닥 생성
    [X, Y] = meshgrid(linspace(-2, 2, 10), linspace(-2, 2, 10));
    Z = tand(slope_x) * X + tand(slope_y) * Y;
    
    % 첫 번째 다리 끝점이 바닥에 닿는 위치의 높이 계산
    leg1_height = interp2(X, Y, Z, leg1(1), leg1(2), 'linear');
    
    % 첫 번째 다리의 길이 계산
    l1 = abs(body_z - leg1_height);  % 첫 번째 다리의 길이 l1 계산

    % 세타1 계산
    theta1 = asin(l1 / 2);  % 첫 번째 다리의 길이로 세타1 계산

    % 결과 출력
    fprintf('첫 번째 다리의 길이 l1: %.4f\n', l1);
    fprintf('세타1 (rad): %.4f\n', theta1);
    fprintf('세타1 (deg): %.4f\n', rad2deg(theta1));  % 각도를 도(degree)로 변환하여 출력
    
    % 시각화 설정
    axes(hAxes);  % 시각화할 축 설정
    cla(hAxes);  % 현재 축의 내용 지우기
    hold on;  % 여러 객체를 동시에 그리기 위해 hold on
    
    % 바닥 시각화
    surf(X, Y, Z, 'FaceAlpha', 0.5, 'EdgeColor', 'none');  % 반투명 바닥을 그리며, 선 없이 면만 표시
    
    % 로봇 몸체 시각화
    plot3(leg1(1), leg1(2), body_z, 'ko-', 'MarkerSize', 10, 'LineWidth', 2);  % 몸체의 첫 번째 모서리를 표시
    
    % 첫 번째 선 (leg1_line1) 그리기
    start_point = [leg1(1), leg1(2), body_z];  % 첫 번째 다리의 시작점 좌표
    end_point_x1 = start_point(1) + cos(-theta1);  % X축 방향의 끝점 계산
    end_point_z1 = start_point(3) + sin(-theta1);  % Z축 방향의 끝점 계산

    plot3([start_point(1), end_point_x1], ...
          [start_point(2), start_point(2)], ...  % Y좌표는 동일한 평면에 위치
          [start_point(3), end_point_z1], 'r-', 'LineWidth', 2);  % 빨간색 선으로 표시
    
    % 두 번째 선 (leg1_line2) 그리기
    end_point_x2 = end_point_x1 + cos(theta1 - pi);  % 첫 번째 선의 끝점에서 theta1 - 180도 방향
    end_point_z2 = end_point_z1 + sin(theta1 - pi);  % 첫 번째 선의 끝점에서 theta1 - 180도 방향

    plot3([end_point_x1, end_point_x2], ...
          [start_point(2), start_point(2)], ...  % Y좌표는 동일한 평면에 위치
          [end_point_z1, end_point_z2], 'b-', 'LineWidth', 2);  % 파란색 선으로 표시
    
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
