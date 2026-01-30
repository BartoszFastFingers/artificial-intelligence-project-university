function y = zaklocenia_gauss_delayed(t)
sigma = 20;
delay = 1;
Ts = 0.001;           
persistent last_t last_y

if isempty(last_t)
    last_t = -inf;
    last_y = 0;
end

if t < delay
    y = 0;
elseif t - last_t >= Ts
    last_y = sigma * randn();
    last_t = t;
    y = last_y;
else
    y = last_y;
end

end

