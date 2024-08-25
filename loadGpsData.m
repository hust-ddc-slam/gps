function [ timestamps,PositionMatrix, HeadingVecor] =loadGpsData(gps_cleaned_filename)

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
    timestamp = str2double(tokens{1});
    type = tokens{2}(2:end);  % 去掉$
    data = tokens(3:end);
    
    gpsData = [gpsData; {timestamp, type, data}];
    end
    fclose(fid);

    % 提取每组的GPGGA和GNHDT数据
    numGroups = floor(size(gpsData, 1) / groupSize);
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
                lat_str = data{2};
                lat_deg = str2double(lat_str(1:2));
                lat_min = str2double(lat_str(3:end));
                lat = lat_deg + lat_min / 60;
                lon_str = data{4};
                lon_deg = str2double(lon_str(1:3));
                lon_min = str2double(lon_str(4:end));
                lon = lon_deg + lon_min / 60;
                alt = str2double(data{9});
                Positions(i, :) = [lat, lon, alt];
                timestamps(i,:) = time;
                Heading(i,:) = 0;
            %elseif strcmp(type, 'GPHDT')
                %heading = 0;%str2double(data{1});                                                                                                                                                                                                                                                                          Heading(i) = heading;
            end
        end
    end
    initialPosition = mean(Positions(1:40, :));
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