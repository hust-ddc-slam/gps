
function [R] = calcAignGravity(rosbag_name, imu_topic);
	
	bag = rosbag(rosbag_name);
	imu_topic = select(bag, 'Topic', imu_topic);
	imu_msgs = readMessages(imu_topic, 'DataFormat', 'struct');
	
	
	% Extract IMU data
	T = 2; % Define the time duration T in seconds
	imu_time = cellfun(@(msg) double(msg.Header.Stamp.Sec) + double(msg.Header.Stamp.Nsec)*1e-9, imu_msgs);
	imu_indices = find(imu_time <= imu_time(1) + T);		% first 2s data
	% time_debug = imu_time - imu_time(1);
	
	% Extract acceleration data for the first T seconds
	accel_x = cellfun(@(msg) msg.LinearAcceleration.X, imu_msgs(imu_indices));
	accel_y = cellfun(@(msg) msg.LinearAcceleration.Y, imu_msgs(imu_indices));
	accel_z = cellfun(@(msg) msg.LinearAcceleration.Z, imu_msgs(imu_indices));
	acc = [accel_x, accel_y, accel_z];
	
	% Step 3: Compute the gravity direction in the world frame
	avg_accel = [mean(accel_x), mean(accel_y), mean(accel_z)];
	gravity_world = avg_accel / norm(avg_accel);
	
	% Compute the rotation matrix from IMU frame to world frame
	z_world = [0 0 1]; % Gravity direction in the world frame
	v = cross(gravity_world, z_world);
	s = norm(v);
	c = dot(gravity_world, z_world);
	v_skew = [ 0    -v(3)  v(2);
           	v(3)  0    -v(1);
          	-v(2)  v(1)  0];
	R = eye(3) + v_skew + v_skew^2 * ((1 - c) / s^2);
	
	% aligned_R = R*avg_accel';		% should be zero.
	% fprintf("    -> Aligned gravity is: ");
	% aligned_R'

end

