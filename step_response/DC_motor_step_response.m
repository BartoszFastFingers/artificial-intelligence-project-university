clear;
clc;
s = serialport("/dev/ttyACM1",115200);
configureTerminator(s,"LF");
flush(s);

sample_time_ms = 5;
observation_time_ms = 3000;


time = [];
RPM = [];

samples = observation_time_ms /sample_time_ms;


while length(time) < samples
    line = strtrim(readline(s));
    C = sscanf(line, '%d ms: %f RPM');
    if numel(C) == 2
        time(end+1) = C(1);
        RPM(end+1) = abs(C(2));
end
end

clear s  

data = [time(:) RPM(:)];

fid = fopen("data/step_response_filtered.csv","w");
fprintf(fid,"time,rpm\n");
fprintf(fid,"%f,%f\n", data');
fclose(fid);

figure
plot(time,RPM)
grid on
xlabel("Time [ms]")
ylabel("RPM")
