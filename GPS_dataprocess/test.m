clear; clear
data_folder = "E:\SLAM\8.26 dataset";
data_name = "8.26-5.txt";
gps_raw_filename =  data_folder + "\data_row\"+data_name; %"E:\SLAM\8.26 dataset\data_row\8.26-2.txt";
gps_clean_filename = data_folder + "\data_clean\"+"gpsclean_"+data_name; %"E:\SLAM\8.26 dataset\data_clean\8.26-2.txt";
gps_trace_filename = data_folder + "\data_trace\"+"gpstrace_"+data_name; %"E:\SLAM\8.26 dataset\trace\gps1_trac.txt";
func_ProcessGPS(gps_raw_filename, gps_clean_filename);
modify_gps(gps_clean_filename)
[timestamps,PositionMatrix, HeadingVecor] =loadGpsData(gps_clean_filename);
save_gps_trajectory(timestamps,PositionMatrix, HeadingVecor,gps_trace_filename);
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
figure(1);
scatter3(PositionMatrix(:,1), PositionMatrix(:,2),PositionMatrix(:,3), 'filled'); % 使用散点图显示渐变色
xlabel('X (meters)');
ylabel('Y (meters)');
title('3D Trajectory with Gradient Color (showing time)');