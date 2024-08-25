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
    while ~feof(fid)
        line = fgetl(fid);
        % 跳过空行
        if isempty(line)
            continue;
        end
    
        % 分割时间戳和GPS数据
        tokens = strsplit(line, ',');
        timeStamp = tokens{1};
        gpsData = strjoin(tokens(2:end), ',');
    
        % 检查是否以$开头
        if startsWith(gpsData, '$')
            % 如果当前有未完成的句子，先写入输出文件
            if ~isempty(currentSentence)
                fprintf(fid_out, '%s,%s\n', currentTimeStamp, currentSentence);
            end
            % 更新当前句子和时间戳
            currentTimeStamp = timeStamp;
            currentSentence = gpsData;
        else
            % 否则，继续拼接当前句子
            currentSentence = strcat(currentSentence, gpsData);
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
