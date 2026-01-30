function y = zaklocenia_random_delayed(t)

szum_amplituda = 50;  
delay = 1;            

if t < delay
    y = 0;
else
    y = szum_amplituda * (2*randi([0,1]) - 1);
end

end
