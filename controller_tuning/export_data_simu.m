%% EKSPORT DO PLIKÓW DLA SIMULINKA
% ================================

% 1. Parametry transmitancji G(s) = K/(T*s + 1)
% Dla bloku Transfer Fcn: Numerator = [K], Denominator = [T, 1]
save('transfer_fcn_params.mat', 'K', 'T');
fprintf('\n--- Eksport do Simulinka ---\n');
fprintf('Zapisano: transfer_fcn_params.mat\n');
fprintf('  Transfer Fcn: Numerator = [%.4f], Denominator = [%.4f, 1]\n', K, T);

% 2. Opóźnienie transportowe dla bloku Transport Delay
save('transport_delay_params.mat', 't0');
fprintf('Zapisano: transport_delay_params.mat\n');
fprintf('  Transport Delay: Time delay = %.4f s\n', t0);

% 3. Parametry regulatora PID dla bloku PID Controller
% W Simulinku PID Controller (parallel form): u = Kp*(e + 1/Ti*∫e + Td*de/dt)
% Lub w standardowej formie: P = Kp, I = Kp/Ti, D = Kp*Td
Ki = Kp / Ti;  % Współczynnik całkowania
Kd = Kp * Td;  % Współczynnik różniczkowania (= 0 dla PI)
save('pid_params.mat', 'Kp', 'Ti', 'Td', 'Ki', 'Kd');
fprintf('Zapisano: pid_params.mat\n');
fprintf('  PID Controller (Ideal/Parallel form):\n');
fprintf('    P = %.4f\n', Kp);
fprintf('    I = %.4f (lub Ti = %.4f)\n', Ki, Ti);
fprintf('    D = %.4f (lub Td = %.4f)\n', Kd, Td);

% 4. Eksport wszystkiego do jednego pliku (wygodne dla workspace)
Num_G = K;           % Licznik transmitancji
Den_G = [T, 1];      % Mianownik transmitancji
Delay = t0;          % Opóźnienie
P_gain = Kp;         % Wzmocnienie proporcjonalne
I_gain = Ki;         % Wzmocnienie całkujące
D_gain = Kd;         % Wzmocnienie różniczkujące
I_time = Ti;         % Czas całkowania
D_time = Td;         % Czas różniczkowania

save('simulink_all_params.mat', 'Num_G', 'Den_G', 'Delay', ...
     'P_gain', 'I_gain', 'D_gain', 'I_time', 'D_time', 'K', 'T', 't0');
fprintf('Zapisano: simulink_all_params.mat (wszystkie parametry)\n');

% 5. Eksport do plików tekstowych (alternatywa)
fid = fopen('simulink_params.txt', 'w');
fprintf(fid, 'PARAMETRY DLA SIMULINKA\n');
fprintf(fid, '=======================\n\n');
fprintf(fid, 'TRANSFER FCN (G(s) = K/(T*s + 1)):\n');
fprintf(fid, '  Numerator: [%.6f]\n', K);
fprintf(fid, '  Denominator: [%.6f, 1]\n\n', T);
fprintf(fid, 'TRANSPORT DELAY:\n');
fprintf(fid, '  Time delay: %.6f s\n\n', t0);
fprintf(fid, 'PID CONTROLLER (Parallel form):\n');
fprintf(fid, '  Kp (P): %.6f\n', Kp);
fprintf(fid, '  Ki (I): %.6f\n', Ki);
fprintf(fid, '  Kd (D): %.6f\n', Kd);
fprintf(fid, '  Ti: %.6f\n', Ti);
fprintf(fid, '  Td: %.6f\n', Td);
fclose(fid);
fprintf('Zapisano: simulink_params.txt\n');

fprintf('\n--- Instrukcja użycia w Simulinku ---\n');
fprintf('1. Wczytaj parametry: load(''simulink_all_params.mat'')\n');
fprintf('2. Transfer Fcn: Num=[Num_G], Den=Den_G\n');
fprintf('3. Transport Delay: Time delay = Delay\n');
fprintf('4. PID Controller: P=P_gain, I=I_gain, D=D_gain\n');
fprintf('   lub w formie idealnej: P=P_gain, I=I_time, D=D_time\n');