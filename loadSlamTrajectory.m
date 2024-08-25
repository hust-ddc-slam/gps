
function [timestamp, trajectory_pos, trajectory_q] = loadSlamTrajectory(input_file)

	fileID = fopen(input_file, 'r');
	if(fileID==-1)
		fprintf("Error. Cannot open trajectory file: %s", input_file);
	end
	
	data = textscan(fileID, '%f %f %f %f %f %f %f %f', 'HeaderLines', 1);
	fclose(fileID);
	
	timestamp = data{1};
	x = data{2};
	y = data{3};
	z = data{4};
	qx = data{5};
	qy = data{6};
	qz = data{7};
	qw = data{8};
	
	trajectory_pos = [x, y, z];
	trajectory_q = [qw,qx,qy,qz];
end

