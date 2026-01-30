simc_tuning;
Ki = Kp*Ti;
Kd = 0;
ts = 5;
[Kp, Ki, Kd] = generate_pid('PID', Kp, Ki, Kd, ts);

srcDest = '../../motor_pid_controller/Components/Src';
cFiles = dir('*.c');
csvFiles = dir('*.csv');
for i = 1:length(cFiles)
    movefile(cFiles(i).name, fullfile(srcDest, cFiles(i).name));
end
for i = 1:length(csvFiles)
    movefile(csvFiles(i).name, fullfile(srcDest, csvFiles(i).name));
end

incDest = '../../motor_pid_controller/Components/Inc';
hFiles = dir('*.h');
for i = 1:length(hFiles)
    movefile(hFiles(i).name, fullfile(incDest, hFiles(i).name));
end