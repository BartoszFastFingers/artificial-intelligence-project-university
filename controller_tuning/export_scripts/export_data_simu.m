%% EKSPORT DO PLIKÓW DLA SIMULINKA
save('transfer_fcn_params.mat', 'K', 'T');
fprintf('\n--- Eksport do Simulinka ---\n');
fprintf('Zapisano: transfer_fcn_params.mat\n');
fprintf('  Transfer Fcn: Numerator = [%.4f], Denominator = [%.4f, 1]\n', K, T);

save('transport_delay_params.mat', 't0');
fprintf('Zapisano: transport_delay_params.mat\n');
fprintf('  Transport Delay: Time delay = %.4f s\n', t0);


Ki = Kp / Ti;  
Kd = Kp * Td;  
save('pid_params.mat', 'Kp', 'Ti', 'Td', 'Ki', 'Kd');
fprintf('Zapisano: pid_params.mat\n');
fprintf('  PID Controller (Ideal/Parallel form):\n');
fprintf('    P = %.4f\n', Kp);
fprintf('    I = %.4f (lub Ti = %.4f)\n', Ki, Ti);
fprintf('    D = %.4f (lub Td = %.4f)\n', Kd, Td);

Num_G = K;           
Den_G = [T, 1];      
Delay = t0;          
P_gain = Kp;         
I_gain = Ki;         
D_gain = Kd;         
I_time = Ti;         
D_time = Td;         

save('simulink_all_params.mat', 'Num_G', 'Den_G', 'Delay', ...
     'P_gain', 'I_gain', 'D_gain', 'I_time', 'D_time', 'K', 'T', 't0');
fprintf('Zapisano: simulink_all_params.mat (wszystkie parametry)\n');

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
