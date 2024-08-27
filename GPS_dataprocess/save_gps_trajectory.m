function save_gps_trajectory(timestamps,PositionMatrix, HeadingVecor,trajectoryfilename)
    for i = 1:length(HeadingVecor)
        Quaternion(i,:) = [0,0,0,1];
    end
    T = table(timestamps, PositionMatrix(:, 1),PositionMatrix(:, 2),PositionMatrix(:, 3),Quaternion(:,4),Quaternion(:,1),Quaternion(:,2),Quaternion(:,3),...
        'VariableNames', {'$$$t', 'x', 'y','z','qx','qy','qz','qw'});  
    writetable(T, trajectoryfilename, 'Delimiter', ' ');
end