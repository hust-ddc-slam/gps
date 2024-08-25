clc;clear;close all;




%% file path
% test1
data_folder = "C:/Users/larrydong/Desktop/gps_process/data/test-0718/1/";
data_name = "2024-07-18-17-09-04";
gps_raw_filename = data_folder + data_name + ".raw-gps.txt";
gps_cleaned_filename = data_folder + data_name + ".gps-clean.txt";

% test2
data_folder = "C:/Users/larrydong/Desktop/gps_process/data/test-0718/2/";
data_name = "2024-07-18-17-13-26";
gps_raw_filename = data_folder + data_name + ".raw-gps.txt";
gps_cleaned_filename = data_folder + data_name + ".gps-clean.txt";


% test3
data_folder = "C:/Users/larrydong/Desktop/gps_process/data/test-0718/3/";
data_name = "2024-07-18-17-14-45";
gps_raw_filename = data_folder + data_name + ".raw-gps.txt";
gps_cleaned_filename = data_folder + data_name + ".gps-clean.txt";


bag_name = data_folder + data_name + ".bag";
slam_trajectory_raw_filename = data_folder + data_name + ".slam.txt";

% %% 传感器参数
 INIT_DURATION = 2;				% 用前2s数据用于各种初始化；
 IMU_FREQUENCY = 100;
 GPS_FREQUENCY = 5;
 INIT_IMU_CNT = INIT_DURATION * IMU_FREQUENCY;
 INIT_GPS_CNT = INIT_DURATION * GPS_FREQUENCY; 


%% Step 1. Process raw GPS
slam_trajectory_raw_filename = "D:\UV\data\0823data\data_clean\fastlio.txt";
gps_cleaned_filename = "D:\UV\data\0823data\data_clean\2.txt";
bag_name = "D:\UV\data\0823data\data\1970-01-01-08-10-22.bag";
trajectoryfilename = "D:\UV\data\0823data\data_clean\2_trajectory.txt";
% fprintf("--> Processing raw gps: %s \n", gps_raw_filename);
% func_ProcessGPS(gps_raw_filename, gps_cleaned_filename);


%% Step 2. Process GPS data and get ENU coordinate.

fprintf("-->Loading GPS file: %s \n", gps_cleaned_filename);
[gps_ts, gps_raw, gps_heading] = loadGpsData(gps_cleaned_filename);
skip_num = 10;
gps_ts = gps_ts(skip_num:end);
gps_raw = gps_raw(skip_num:end, :);
gps_heading = gps_heading(skip_num:end);
gps_raw(1:5,:)
gps_heading(1:5,:)

GPS_CNT = length(gps_ts);

gps_init_x = 0;
gps_init_y = 0;
gps_init_heading = mean(gps_heading(1:INIT_GPS_CNT))		% heading: 北N 到GPS的y
gps_heading = gps_heading - gps_init_heading;

theta = deg2rad(5.5);%(gps_init_heading);			% 夹角加上90°，从北->GPS的x
gps_init_R_enu2gps = [cos(theta), -sin(theta), 0; sin(theta), cos(theta), 0; 0,0,1];	% 绕z旋转矩阵

gps_aligned = (gps_init_R_enu2gps * gps_raw')';
		
% 2.4 Plot GPS trajectory for debug;
figure("Name","GPS-Aligned");
plot3(gps_raw(:,1), gps_raw(:,2), gps_raw(:,3), 'r-'); hold on;
plot3(gps_aligned(:,1), gps_aligned(:,2), gps_aligned(:,3), 'g-'); 
legend(["gps-raw", "gps-aligned"]);
plot3(gps_raw(1,1), gps_raw(1,2), gps_raw(1,3), 'ro');
plot3(gps_aligned(1,1), gps_aligned(1,2), gps_aligned(1,3), 'go'); 

axis("equal");



%% Step 3. Align G for fastlio
% 3.1 Get some IMU data from rosbag;

fprintf("--> Align gravity. Loading imu from rosbag: %s\n", bag_name);
gravity_R = calcAlignGravity(bag_name, '/ouster/imu');

% 3.2 Extract all trajectory of fastlio;
[traj_ts, traj_pos_raw, traj_q_raw] = loadSlamTrajectory(slam_trajectory_raw_filename);
TRAJ_POS_CNT = length(traj_ts);
ROSBAG_T0 = traj_ts(1);

% 3.3 Align trajectory;
traj_pos_aligned = (gravity_R * traj_pos_raw')';
traj_rot_aligned = zeros(3,3,TRAJ_POS_CNT);
for i = 1:TRAJ_POS_CNT
	quat = traj_q_raw(i,:);
	rotm = quat2rotm(quat);
	traj_rot_aligned(:,:,i) = gravity_R*rotm;
end
traj_init_rot = traj_rot_aligned(:,:,1);
traj_init_pos = [0,0,0]';

% 3.4 Plot slam trajectory for debug
figure("Name", "SLAM-Traj-Aligned");
plot3(traj_pos_aligned(:,1), traj_pos_aligned(:,2), traj_pos_aligned(:,3), 'r-'); hold on;
plot3(traj_pos_aligned(1,1), traj_pos_aligned(1,2), traj_pos_aligned(1,3), 'ro'); 
plot3(traj_pos_raw(:,1), traj_pos_raw(:,2), traj_pos_raw(:,3), 'g-');
plot3(traj_pos_raw(1,1), traj_pos_raw(1,2), traj_pos_raw(1,3), 'go');
legend(["slam-aligned", "start", "slam-raw", "start"]);
axis("equal");

%% Step 4. Two sensor align

% 4.1 Timestamp align;
gps_ts = gps_ts - ROSBAG_T0;
gps_begin_index = sum(gps_ts<0);
gps_sync_pos = gps_aligned(gps_begin_index+1:end,:);	% 使用rosbag的时间戳（其实应该是fastlio的时间戳）和gps时间戳较大的，保留之后的。


% 4.2 extrinsics calibration. 
extrinsic_t_gps_imu = [0, 0, 0]';				% imu to gps
% extrinsic_t_gps_imu = [0.11, 0.30, 0.5]';				% imu to gps
angle = deg2rad(0.001);
extrinsic_R_gps_imu= [cos(angle), -sin(angle), 0; sin(angle), cos(angle), 0; 0,0,1];
extrinsic_T_gps_imu = [extrinsic_R_gps_imu, extrinsic_t_gps_imu; 0,0,0,1];
extrinsic_R_imu_gps = extrinsic_R_gps_imu';
extrinsic_t_imu_gps = -extrinsic_R_gps_imu' * extrinsic_t_gps_imu;
extrinsic_T_imu_gps = [extrinsic_R_imu_gps, extrinsic_t_imu_gps; 0,0,0,1];

pos_imu_in_gps = zeros(TRAJ_POS_CNT, 3);
for i = 1:TRAJ_POS_CNT
	R_imuInit_imuCurr = traj_rot_aligned(:,:,i);
	t_imuInit_imuCurr = traj_pos_aligned(i,:)';
	
	T_imuInit_imuCurr = [R_imuInit_imuCurr, t_imuInit_imuCurr; 0,0,0,1];
	T_imuInit_gpsCurr = T_imuInit_imuCurr * extrinsic_T_imu_gps;
	T_gpsInit_gpsCurr = extrinsic_T_gps_imu * T_imuInit_gpsCurr;
	pos_imu_in_gps(i,:) = T_gpsInit_gpsCurr(1:3, 4);
end



figure("Name", "compare");
plot3(traj_pos_aligned(:,1), traj_pos_aligned(:,2), traj_pos_aligned(:,3), 'k--'); hold on;
plot3(traj_pos_aligned(1,1), traj_pos_aligned(1,2), traj_pos_aligned(1,3), 'ko'); 
plot3(pos_imu_in_gps(:,1), pos_imu_in_gps(:,2), pos_imu_in_gps(:,3), 'g-'); 
plot3(pos_imu_in_gps(1,1), pos_imu_in_gps(1,2), pos_imu_in_gps(1,3), 'go');
plot3(gps_aligned(:,1), gps_aligned(:,2), gps_aligned(:,3), 'b-'); hold on;
plot3(gps_aligned(1,1), gps_aligned(1,2), gps_aligned(1,3), 'bo'); hold on;
legend(["slam-in-imu", "start", "slam-in-gps", "start", "gps-in-gps", "start"]);
axis("equal");

figure("Name", "gps_imu");
plot(traj_pos_aligned(:,1), traj_pos_aligned(:,2), 'k--'); hold on;
plot(traj_pos_aligned(1,1), traj_pos_aligned(1,2), 'ko'); 
plot(pos_imu_in_gps(:,1), pos_imu_in_gps(:,2), 'g-'); 
plot(pos_imu_in_gps(1,1), pos_imu_in_gps(1,2), 'go');
plot(gps_aligned(:,1), gps_aligned(:,2), 'b-'); hold on;
plot(gps_aligned(1,1), gps_aligned(1,2), 'bo'); hold on;
legend(["slam-in-imu", "start", "slam-in-gps", "start", "gps-in-gps", "start"]);
axis("equal");

