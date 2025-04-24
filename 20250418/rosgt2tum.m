clc;clear;close all;

%输入rosbag存放文件路径和方法名称
folderpath = "/home/larry/data/3dof_street_0423/";
gt_output_path = "/home/larry/data/3dof_street_0423/gt/";
% methodname = "cticp";     % methodname is useless for gt-generation.

dir = dir(folderpath);%获取原始数据文件夹下所有文件的信息
raw_folder = folderpath + "/";%原始数据文件夹名

for i = 3:(length(dir))%遍历原始数据夹下的文件
    if ~contains(dir(i).name,".bag")    
        continue
    end
    [~, seq, ~] = fileparts(dir(i).name);       % extract the sequence name without extension
    
    % seq = "04-novib-2";       % test one sequence.
    rospose = [];                       % clear the trajectory every time.

    bag_filename = seq + ".bag";
    bag_filename = folderpath + bag_filename;

    fprintf("--> Processing rosbag: %s \n", bag_filename);

    bag = rosbag(bag_filename);
    msgs = select(bag,"Topic", '/gps_node/gps_traj');
    traj = readMessages(msgs,'DataFormat','struct');
    for j = 1:length(traj)
        traj{j}.Header.Stamp.Sec
        timestamps = double(traj{j}.Header.Stamp.Sec) + double(traj{j}.Header.Stamp.Nsec)*1e-9;
        rospose(j,:) = [timestamps,traj{j}.Pose.Position.X,traj{j}.Pose.Position.Y,traj{j}.Pose.Position.Z];
    end
    
    gt_filename = "gt_" + seq + ".txt";
    gt_filename = gt_output_path + gt_filename;
    fileID = fopen(gt_filename, 'w');
    for k = 1:length(rospose)
    fprintf(fileID, '%.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f\n', ...
        rospose(k,1),rospose(k,2), rospose(k,3), rospose(k,4), 0, 0, 0, 1);
    end

    fclose(fileID);             % close the file everytime.
    fprintf("<-- Saved gt to file: %s \n", gt_filename);

end
