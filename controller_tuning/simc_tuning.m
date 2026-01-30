load('data/fitted_model2.mat');
params = coeffvalues(fittedmodel);
names  = coeffnames(fittedmodel);
K  = params(1);
T  = params(2)/6500;
t0 = params(3)/1000;

fprintf('K = %.2f\nT = %.2f\nt0 = %.2f\n', K, T, t0);
tau_c_values = linspace(t0, t0*5, 8);
results = zeros(length(tau_c_values), 3);
s = tf('s');
G = K/(T*s + 1)*exp(-t0*s);

figure('Name', 'Odpowiedzi skokowe regulatorów PI', 'Position', [100 100 900 600]);
hold on;
colors = lines(length(tau_c_values));
legend_entries = cell(1, length(tau_c_values));
dt = 0.001; 
t_sim = 0:dt:2;

for i = 1:length(tau_c_values)
    tau_c = tau_c_values(i);
    Kp = T/(K*(tau_c + t0));
    Ti = min(T, 4*(tau_c + t0));
    C = Kp*(1 + 1/(Ti*s));
    sys_cl = feedback(C*G, 1);
    
    sys_cl_d = c2d(sys_cl, dt, 'tustin');
    [y, t_out] = step(sys_cl_d, t_sim);
    
    if any(isnan(y)) || max(abs(y)) > 5
        results(i,:) = [NaN NaN NaN];
        legend_entries{i} = sprintf('τ_c = %.4f (niestabilny)', tau_c);
        continue;
    end
    
    plot(t_out, y, 'Color', colors(i,:), 'LineWidth', 1.5);
    legend_entries{i} = sprintf('τ_c = %.4f s', tau_c);
    info = stepinfo(y, t_out, dcgain(sys_cl));
    results(i,:) = [info.SettlingTime, info.Overshoot, info.RiseTime];
end

xlabel('Czas [s]', 'FontSize', 12);
ylabel('Odpowiedź y(t)', 'FontSize', 12);
title(sprintf('Odpowiedzi skokowe układu zamkniętego dla różnych τ_c (krok %.3f s)', dt), 'FontSize', 14);
legend(legend_entries, 'Location', 'best', 'FontSize', 9);
grid on;
yline(1, '--k', 'Wartość zadana', 'LineWidth', 1);
xlim([0 2]);
hold off;

tau_c_col = tau_c_values';
SettlingTime_col = results(:,1);
Overshoot_col = results(:,2);
RiseTime_col = results(:,3);
Tab = table(tau_c_col, SettlingTime_col, Overshoot_col, RiseTime_col);
Tab.Properties.VariableNames = {'Tau_c','Czas_ustalania_s','Przeregulowanie_pct','Czas_narastania_s'};
disp(Tab);

disp(table((1:length(tau_c_values))', tau_c_values', 'VariableNames', {'Index','Tau_c'}))
idx = input('Wybierz numer wiersza Tau_c: ');
tau_c = tau_c_values(idx);

Kp = T / (K * (tau_c + t0));
Ti = min(T, 4*(tau_c + t0));
Td = 0;

assignin('base', 'Kp', Kp);
assignin('base', 'Ti', Ti);
assignin('base', 'Td', Td);

fprintf('\nWybrana wartość Tau_c = %.4f\n', tau_c);
fprintf('Parametry regulatora:\nKp = %.4f\nTi = %.4f\nTd = %.4f\n', Kp, Ti, Td);

figure('Name', 'Wybrana odpowiedź skokowa', 'Position', [100 100 800 500]);
C_sel = Kp*(1 + 1/(Ti*s));
sys_cl_sel = feedback(C_sel*G, 1);
sys_cl_sel_d = c2d(sys_cl_sel, dt, 'tustin'); 
[y_sel, t_sel] = step(sys_cl_sel_d, t_sim);
plot(t_sel, y_sel, 'b', 'LineWidth', 2);
xlabel('Czas [s]', 'FontSize', 12);
ylabel('Odpowiedź y(t)', 'FontSize', 12);
title(sprintf('Odpowiedź skokowa dla τ_c = %.4f s (krok %.3f s)', tau_c, dt), 'FontSize', 14);
grid on;
yline(1, '--r', 'Wartość zadana', 'LineWidth', 1);
xlim([0 2]);

run('export_scripts/export_data_simu.m');

state_models;

