clear;
clc;
filename = "data/step_response.csv";
filename2 = "data/step_response_filtered.csv"
data = readmatrix(filename);
data2 = readmatrix(filename2)

time_ms = data(:,1);
%RPM = data(:,2);
RPM_filtered = data2(:,2);


figure

hold on
%plot(time_ms,RPM,'LineWidth',2)
plot(time_ms,RPM_filtered,'LineWidth',2)
grid on
xlabel("ms")
ylabel("RPM")
legend("raw","smoothed")
title("DC motor characteristics")
