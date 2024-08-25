clear; clc;
%func_ProcessGPS("D:\UV\data\0823data\data\606.2264.txt", "D:\UV\data\0823data\data_clean\2.txt");
[timestamps,PositionMatrix, HeadingVecor] =loadGpsData("D:\UV\data\0823data\data_clean\2.txt");
save_gps_trajectory(timestamps,PositionMatrix, HeadingVecor,"D:\UV\data\0823data\data_clean\2_trac.txt");
%[timestamps,PositionMatrix, HeadingVecor] =loadGpsData("F:\2024.8.21-dataset\data_clean\2 _o.txt","F:\2024.8.21-dataset\data_clean\2_trac.txt");
% 创建一个table  

% 保存table为txt文件  

% figure(2);
% plot(HeadingVecor);

%for i = 1:length(HeadingVecor)
    %if isnan(HeadingVecor(i,1))
        %i*4-2
    %elseif PositionMatrix(i,3)>2
        %i*4-2
    %end
%end

 %绘制二维轨迹图
%figure(1);
%scatter3(PositionMatrix(:,1), PositionMatrix(:,2),PositionMatrix(:,3), 'filled'); % 使用散点图显示渐变色
%xlabel('X (meters)');
%ylabel('Y (meters)');
%title('3D Trajectory with Gradient Color (showing time)');