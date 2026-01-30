filename = "data/characteristic_filtered.csv";
filename2 = "data/characteristic.csv";

data = readmatrix(filename);
data2 = readmatrix(filename2);

CCR = data(:,1);
RPM = data(:,2);

CCR2 = data2(:,1);
RPM2 = data2(:,2);




figure
plot(CCR2, RPM2, 'LineWidth',1)
hold on
plot(CCR,RPM,'LineWidth',1)

grid on
xlabel("CCR")
ylabel("RPM")
legend("raw","smoothed")
title("DC motor characteristics")
