function y = polynomial_transport(t)
    a = 0.002;   
    b = 0;    
    c = 0.1;    
    d = 10;     
    delay = 1; 

    if t < delay
        y = 0;
    else
        x = t - delay;
        y = a*x^3 + b*x^2 + c*x + d;
    end
end