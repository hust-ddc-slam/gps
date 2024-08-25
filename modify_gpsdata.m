% 打开文件
clear;clc;
filename = "D:\UV\data\0823data\data_clean\2.txt";
fid = fopen(filename, 'r');
if fid == -1
    error('无法打开文件 %s', filename);
end

% 读取文件内容
fileContent = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
fclose(fid);
lines = fileContent{1};

% 删除前两行
lines(1:3) = [];

[timestamps,PositionMatrix, HeadingVecor] =loadGpsData(filename);

% 处理文件内容
for i = 1:length(lines)
    line = lines{i};
    
    % 检查是否存在第一个逗号之后不是指定开头的行
    if contains(line, ',')
        parts = strsplit(line, ',');
        if ~ismember(parts{2}, {'$GNVTG', '$GPGGA', '$GPRMC', '$GNHDT', '$GPHDT'})
            lines{i} = ['&&&', line];
        end
    end
end

for i = 1:length(HeadingVecor)
    if PositionMatrix(i,3)>2 || isnan(PositionMatrix(i,1)) || isnan(PositionMatrix(i,2)) || isnan(PositionMatrix(i,3))
        lines{i*4+3} = ['&&&', lines{i*4+3}];
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

