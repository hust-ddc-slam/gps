clc;clear;close all;

%输入rosbag存放文件路径和方法名称
folderpath = "F:\test";
methodname = "cticp";

dir = dir(folderpath);%获取原始数据文件夹下所有文件的信息
raw_folder = folderpath + "\";%原始数据文件夹名

for i = 3:(length(dir))%遍历原始数据夹下的文件
    if ~contains(dir(i).name,".bag")    
        continue
    end
    dataname = dir(i).name;
    datapath = raw_folder + dataname;
    savename = "gt_"+methodname;
    savepath = raw_folder + savename + num2str(i-2)+".txt";
    bag = rosbag(datapath);
    msgs = select(bag,"Topic", '/gps_node/gps_traj');
    traj = readMessages(msgs,'DataFormat','struct');
    for j = 1:length(traj)
        timestamps = double(traj{j}.Header.Stamp.Sec) + double(traj{j}.Header.Stamp.Nsec)*1e-9;
        rospose(j,:) = [timestamps,traj{j}.Pose.Position.X,traj{j}.Pose.Position.Y,traj{j}.Pose.Position.Z];
    end

    fileID = fopen(savepath, 'w');

    for k = 1:length(rospose)
    fprintf(fileID, '%.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f\n', ...
        rospose(k,1),rospose(k,2), rospose(k,3), rospose(k,4), 0, 0, 0, 1);
    end
end