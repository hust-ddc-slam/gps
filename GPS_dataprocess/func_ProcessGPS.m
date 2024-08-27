function func_ProcessGPS(gps_raw_filename, gps_cleaned_filename)

    inputFile = gps_raw_filename;
    outputFile = gps_cleaned_filename;



    % 打开输入文件
    fid = fopen(inputFile, 'r');
    if fid == -1
        error('无法打开文件 %s', inputFile);
    end

    % 打开输出文件
    fid_out = fopen(outputFile, 'w');
    if fid_out == -1
        error('无法创建文件 %s', outputFile);
    end

    % 初始化变量
    currentSentence = '';
    currentTimeStamp = '';

    % 逐行读取文件内容
    while ~feof(fid)%feof()：如果读到文件末尾返回1，否则返回0    
        line = fgetl(fid);%fgetl，读取一行文本
        % 跳过空行
        if isempty(line)%isempty：如果内容为空返回1
            continue;
        end
    
        % 分割时间戳和GPS数据
        tokens = strsplit(line, ',');%strsplit（待分割的字符串，分割界定符号），结果返回一个数组
        timeStamp = tokens{1};%这个是时间
        gpsData = strjoin(tokens(2:end), ',');%strjoin（待串联的字符串，链接符号），这个是GPS数据

        % 检查是否以$开头
        if startsWith(gpsData, '$')%startsWith(待检测字符串，检测符号):如果字符串以检测符合开头返回1，否则0，不区分大小写
            % 如果当前有未完成的句子，先写入输出文件
            if ~isempty(currentSentence)%作用是检测到的第一串以$开头的GPS数据不写，因为可能不完整
                fprintf(fid_out, '%s,%s\n', currentTimeStamp, currentSentence);%'%s':输出为字符串，'\n':空行
            end
            % 更新当前句子和时间戳
            currentTimeStamp = timeStamp;
            currentSentence = gpsData;
        else
            % 否则，继续拼接当前句子
            currentSentence = strcat(currentSentence, gpsData);%strcat：串联字符串，无间隔
        end
    end

    % 写入最后一个句子
    if ~isempty(currentSentence)
        fprintf(fid_out, '%s,%s\n', currentTimeStamp, currentSentence);
    end

    % 关闭文件
    fclose(fid);
    fclose(fid_out);

end
