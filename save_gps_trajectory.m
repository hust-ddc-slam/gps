function save_gps_trajectory(timestamps,PositionMatrix, HeadingVecor,trajectoryfilename)
    for i = 1:length(HeadingVecor)
        Quaternion(i,:) = [1,0,0,0];
    end
    T = table(timestamps, PositionMatrix(:, 1),PositionMatrix(:, 2),PositionMatrix(:, 3),Quaternion(:,2),Quaternion(:,3),Quaternion(:,4),Quaternion(:,1),...
        'VariableNames', {'t', 'x', 'y','z','qx','qy','qz','qw'});  
    writetable(T, trajectoryfilename, 'Delimiter', ' ', 'WriteVariableNames', false);

    figure(1);
    scatter3(PositionMatrix(:,1), PositionMatrix(:,2),PositionMatrix(:,3), 'filled'); % 使用散点图显示渐变色
    xlabel('X (meters)');
    ylabel('Y (meters)');
    title('3D Trajectory');
end