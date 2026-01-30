% Krok próbkowania (dopasuj do Simulink)
Ts = 0.001;

% Model transmitancyjny z aproksymacją Padé
[num_pade, den_pade] = pade(t0, 1);
G_nom = tf(K, [T 1]);
G_del = G_nom * tf(num_pade, den_pade);

% Model ciągły w przestrzeni stanów
sys_c = ss(G_del);

% DYSKRETYZACJA - to jest klucz!
sys_d = c2d(sys_c, Ts, 'zoh');

% Macierze DYSKRETNE dla filtra Kalmana
A = sys_d.A;
B = sys_d.B;
C = sys_d.C;
D = sys_d.D;

% Sprawdzenie stabilności
fprintf('Wartości własne A (powinny być |λ| < 1):\n');
disp(eig(A))

% Parametry filtra Kalmana
R_Q_script;