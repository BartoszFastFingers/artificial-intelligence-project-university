Q_values = [0.0001, 0.001, 0.01, 0.1, 1, 10];
R_values = [10, 50, 100, 500, 1000, 5000, 10000];

Ts = 0.001;
t_end = 10;
N = round(t_end / Ts);

szum_amplituda = 20;
sigma_pomiar = 50;
delay_steps = round(1 / Ts);

u = 200;

results = [];

for q_idx = 1:length(Q_values)
    for r_idx = 1:length(R_values)
        Q_test = eye(2) * Q_values(q_idx);
        R_test = R_values(r_idx);
        
        % Inicjalizacja
        x_hat = [0; 0];
        P_kal = eye(2);
        x_true = [0; 0];
        
        y_true_arr = zeros(N, 1);
        y_meas_arr = zeros(N, 1);
        y_est_arr = zeros(N, 1);
        
        for k = 1:N
            % Prawdziwy system
            x_true = A * x_true + B * u;
            y_true = C * x_true;
            
            % Zakłócenia (po delay)
            if k > delay_steps
                zakl_wal = szum_amplituda * (2*randi([0,1]) - 1);
                szum_pom = sigma_pomiar * randn();
            else
                zakl_wal = 0;
                szum_pom = 0;
            end
            
            y_meas = y_true + zakl_wal + szum_pom;
            
            % Filtr Kalmana
            x_pred = A * x_hat + B * u;
            P_pred = A * P_kal * A' + Q_test;
            K_kal = P_pred * C' / (C * P_pred * C' + R_test);
            x_hat = x_pred + K_kal * (y_meas - C * x_pred);
            P_kal = (eye(2) - K_kal * C) * P_pred;
            
            y_est = C * x_hat;
            
            y_true_arr(k) = y_true;
            y_meas_arr(k) = y_meas;
            y_est_arr(k) = y_est;
        end
        
        % Metryki (po ustaleniu)
        idx_start = delay_steps + 2000;
        
        % 1. Błąd śledzenia wartości prawdziwej
        MSE_true = mean((y_est_arr(idx_start:end) - y_true_arr(idx_start:end)).^2);
        
        % 2. Redukcja szumu (kluczowe!)
        std_meas = std(y_meas_arr(idx_start:end));
        std_est = std(y_est_arr(idx_start:end));
        std_true = std(y_true_arr(idx_start:end));  % powinno być ~0
        
        % Stosunek: ile razy estymata jest gładsza niż pomiar
        noise_reduction = std_est / std_meas;  % im mniejsze, tym lepsze wygładzanie
        
        % 3. Uchyb ustalony
        bias = abs(mean(y_est_arr(idx_start:end)) - mean(y_true_arr(idx_start:end)));
        
        results = [results; Q_values(q_idx), R_values(r_idx), MSE_true, noise_reduction, bias, std_est];
    end
end

%% Wyświetl wyniki
T_results = array2table(results, 'VariableNames', {'Q', 'R', 'MSE', 'NoiseReduction', 'Bias', 'StdEst'});

% Sortuj po redukcji szumu (najważniejsze)
T_sorted = sortrows(T_results, 'NoiseReduction');
disp('=== TOP 10 wg redukcji szumu (im mniejsze NoiseReduction, tym lepiej) ===');
disp(T_sorted(1:10, :));

%% Wybór: minimalna wariancja estymaty przy akceptowalnym biasie
% Filtruj: bias < 0.5 (akceptowalny uchyb)
good_idx = results(:,5) < 0.5;
if sum(good_idx) > 0
    filtered = results(good_idx, :);
    % Z tych wybierz najmniejszą wariancję estymaty
    [~, best_local] = min(filtered(:,6));
    best_result = filtered(best_local, :);
else
    % Jeśli żaden nie spełnia, wybierz najlepszy kompromis
    [~, best_local] = min(results(:,4));
    best_result = results(best_local, :);
end

fprintf('\n=== NAJLEPSZA KOMBINACJA ===\n');
fprintf('Q = %.4f\n', best_result(1));
fprintf('R = %.4f\n', best_result(2));
fprintf('MSE = %.4f\n', best_result(3));
fprintf('Noise Reduction = %.4f (im mniejsze tym lepiej)\n', best_result(4));
fprintf('Bias = %.4f\n', best_result(5));
fprintf('Std estymaty = %.4f\n', best_result(6));

%% Ustaw najlepsze wartości
Q = eye(2) * best_result(1);
R = best_result(2);
P = eye(2);

%% Wizualizacja najlepszego wyniku
fprintf('\n--- Test najlepszych parametrów ---\n');
Q_test = Q;
R_test = R;

x_hat = [0; 0];
P_kal = eye(2);
x_true = [0; 0];

y_true_arr = zeros(N, 1);
y_meas_arr = zeros(N, 1);
y_est_arr = zeros(N, 1);

for k = 1:N
    x_true = A * x_true + B * u;
    y_true = C * x_true;
    
    if k > delay_steps
        zakl_wal = szum_amplituda * (2*randi([0,1]) - 1);
        szum_pom = sigma_pomiar * randn();
    else
        zakl_wal = 0;
        szum_pom = 0;
    end
    
    y_meas = y_true + zakl_wal + szum_pom;
    
    x_pred = A * x_hat + B * u;
    P_pred = A * P_kal * A' + Q_test;
    K_kal = P_pred * C' / (C * P_pred * C' + R_test);
    x_hat = x_pred + K_kal * (y_meas - C * x_pred);
    P_kal = (eye(2) - K_kal * C) * P_pred;
    
    y_est = C * x_hat;
    
    y_true_arr(k) = y_true;
    y_meas_arr(k) = y_meas;
    y_est_arr(k) = y_est;
end

t = (1:N) * Ts;
figure('Name', 'Porównanie filtracji');
plot(t, y_meas_arr, 'b', 'DisplayName', 'Pomiar (z szumem)');
hold on;
plot(t, y_est_arr, 'r', 'LineWidth', 2, 'DisplayName', 'Estymata Kalmana');
plot(t, y_true_arr, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Wartość prawdziwa');
hold off;
legend('Location', 'best');
xlabel('Czas [s]');
ylabel('Wyjście');
title(sprintf('Q = %.4f, R = %.0f', best_result(1), best_result(2)));
grid on;
xlim([0.5 3]);  % zoom na obszar z zakłóceniami

fprintf('\nUstawiono Q i R w workspace.\n');