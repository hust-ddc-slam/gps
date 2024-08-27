function [ timestamps,PositionMatrix, HeadingVecor] =loadGpsData(gps_cleaned_filename,trajectoryfilename)

    inputFile = gps_cleaned_filename;

    fid = fopen(inputFile, 'r');
    if fid == -1
        error('无法打开文件 %s', inputFile);
    end

    % 初始化变量
    gpsData = [];
    groupSize = 4;

    while ~feof(fid)
    line = fgetl(fid);
    tokens = strsplit(line, ',');
    timestamp = str2double(tokens{1});%字符串转double
    type = tokens{2}(2:end);  % $在第一位，从第二位开始取去掉$，
    data = tokens(3:end);
    
    gpsData = [gpsData; {timestamp, type, data}];%嵌套
    end
    fclose(fid);

% GPRMC:推荐定位信息
% GNVTG：地磁航行和地速信息
% GPGGA：GPS定位信息，包括海拔高度，经度，纬度
%GPHDT:航向角

    % 提取每组的GPGGA和GNHDT数据
    numGroups = floor(size(gpsData, 1) / groupSize);
    %每组定位信息包含GPRMC、GNVTG、GPGGA、GPHDT四组数据，numGroups代表定位信息数，向下取整是因为最后一组数据可能不完整
    Positions = zeros(numGroups, 3);  % 经纬度和高度
    Heading = zeros(numGroups, 1);   % 航向角
    timestamps = zeros(numGroups, 1);

    for i = 1:numGroups
        for j = 1:groupSize
            idx = (i-1) * groupSize + j;
            type = gpsData{idx, 2};
            data = gpsData{idx, 3};
            time = gpsData{idx, 1};
        
            if strcmp(type, 'GPGGA')
                lat_str = data{2};%纬度数据
                lat_deg = str2double(lat_str(1:2));%前两位表示度
                lat_min = str2double(lat_str(3:end));%后面表示分
                lat = lat_deg + lat_min / 60;%折合为度
                lon_str = data{4};%经度数据
                lon_deg = str2double(lon_str(1:3));%前三位表示度
                lon_min = str2double(lon_str(4:end));%后面表示分
                lon = lon_deg + lon_min / 60;%折合为度
                alt = str2double(data{9});%海拔数据
                Positions(i, :) = [lat, lon, alt];%[纬度，经度，海拔]
                timestamps(i,:) = time;
                Heading(i,:) = 0;
            %elseif strcmp(type, 'GPHDT')
                %heading = 0;%str2double(data{1});                                                                                                                                                                                                                                                                          Heading(i) = heading;
            end
        end
    end
    initialPosition = mean(Positions(1:40, :));%mean:求均值作为参考点的位置信息和航行角
    initialHeading = mean(Heading(1:40));

    % 初始化ENU坐标系的轨迹数据
    %PositionMatrix = zeros(numGroups, 3);

    %PositionMatrix(1,:) = [0,0,0];
    %HeadingVecor(1,:) = initialHeading;
    timestamps = timestamps(1:end);

    % 转换到ENU坐标系
    for i = 1:numGroups
        [x, y, z] = geodetic2enu(Positions(i, 1), Positions(i, 2), Positions(i, 3), ...
                                 initialPosition(1), initialPosition(2), initialPosition(3), ...
                                 wgs84Ellipsoid);
        PositionMatrix(i, :) = [x, y, z];
        HeadingVecor(i,:) = Heading(i);
    end

end