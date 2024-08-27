% 打开文件
clear;clc;
filename = "E:\SLAM\8.26 dataset\data_gps_clean\gps1.txt";
fid = fopen(filename, 'r');
if fid == -1
    error('无法打开文件 %s', filename);
end

% 读取文件内容
fileContent = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
fclose(fid);
lines = fileContent{1};

% 删除前两行
lines(1:2) = [];

[timestamps,PositionMatrix, HeadingVecor] =loadGpsData(filename);

% 处理文件内容
for i = 1:length(lines)
    line = lines{i};
    
    % 检查是否存在第一个逗号之后不是指定开头的行
    if contains(line, ',')
        parts = strsplit(line, ',');
        if ~ismember(parts{2}, {'$GNVTG', '$GPGGA', '$GPRMC', '$GNHDT', '$GPHDT'})
            %ismember（A,B）阵A中的数据是不是矩阵B中的成员，如果是返回1
            lines{i} = ['&&&', line];%注释掉异常数据
        end
    end
end
% 检查位置信息是否有误，如果x，y,z非数值，认为出错；z大于2也认为出错
for i = 1:length(HeadingVecor)
    if PositionMatrix(i,3)>2 || isnan(PositionMatrix(i,1)) || isnan(PositionMatrix(i,2)) || isnan(PositionMatrix(i,3))
        %isnan(A)，如果A为非数值返回1
        lines{i*4-1} = ['&&&', lines{i*4-1}];
    end
end

% 保存改动到原始文件
fid = fopen(filename, 'w');
if fid == -1
    error('无法打开文件 %s', filename);
end

for i = 1:length(lines)
    fprintf(fid, '%s\n', lines{i});
end

fclose(fid);

