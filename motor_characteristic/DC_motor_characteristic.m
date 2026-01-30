s = serialport("/dev/ttyACM1",115200);
configureTerminator(s,"LF");
flush(s);

CCR = [];
RPM = [];

while length(CCR) < 180
    try
        line = readline(s);
    catch
        break;
    end

    if isempty(line)
        continue; 
    end

    parts = split(line,":");
    if numel(parts)==2
        c = str2double(parts(1));
        r = str2double(parts(2));

        if ~isnan(c) && ~isnan(r)
            CCR(end+1) = c;
            RPM(end+1) = r;
        end
    end
end


