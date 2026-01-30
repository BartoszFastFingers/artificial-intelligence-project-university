function y = sinus_transport(t)
% SINUS_TRANSPORT Generuje sinus o amplitudzie 0.7 i częstotliwości 5 Hz
% t - czas (wejście)
% y - wyjście (sygnał sinusoidalny)

A = 0.7;         % amplituda
f = 5;           % częstotliwość w Hz
omega = 2*pi*f;  % prędkość kątowa

y = A * sin(omega * t);

end
