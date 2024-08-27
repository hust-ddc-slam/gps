clc;clear;close all;

folderpath = "E:\SLAM\8.26 dataset\data_row";%原始数据存放路径
dir = dir(folderpath);%获取原始数据文件夹下所有文件的信息
data_folder = fileparts("E:\SLAM\8.26 dataset\data_row");%获取原始数据文件夹的父文件夹路径
gps_raw_folder = folderpath + "\";%原始数据文件夹名
gps_clean_folder = data_folder + "\data_clean2";%整理后数据文件夹名
gps_trace_folder = data_folder + "\data_trace2";%轨迹数据文件夹名
j = 1;

%如果不存在整理后数据文件夹和轨迹数据文件夹则创建
if ~exist(gps_clean_folder,"file")
   mkdir(gps_clean_folder);
end
if ~exist(gps_trace_folder,"file")
   mkdir(gps_trace_folder);
end


for i = 3:(length(dir))%遍历原始数据夹下的文件
    if ~contains(dir(i).name,".txt")%找到GPS数据文件
        continue
    end
    gps_raw_filename = gps_raw_folder+dir(i).name;%原始数据文件名
    gps_clean_filename = gps_clean_folder+"\gpsclean_"+dir(i).name;%整理后数据文件名
    gps_trace_filename = gps_trace_folder+"\gpstrace_"+dir(i).name;%轨迹数据文件名
    
    %整理原始数据文件为正确格式
    func_ProcessGPS(gps_raw_filename, gps_clean_filename);
    %注释错误行
    modify_gps(gps_clean_filename)
    %读取文件获取经纬度、海拔、角度信息
    [timestamps,PositionMatrix, HeadingVecor] =loadGpsData(gps_clean_filename);
    %整理为FAST_LIO算法可用数据格式（8*n）
    save_gps_trajectory(timestamps,PositionMatrix, HeadingVecor,gps_trace_filename);
    
    %绘制三维轨迹图
    figure(j);
    scatter3(PositionMatrix(:,1), PositionMatrix(:,2),PositionMatrix(:,3), 'filled'); % 使用散点图显示渐变色
    xlabel('X (meters)');
    ylabel('Y (meters)');
    title(dir(i).name,'3D Trajectory with Gradient Color (showing time)');
    j = j + 1; 
end