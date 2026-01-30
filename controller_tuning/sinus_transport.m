function y = sinus_transport(t)
    A = 20;         
    f = 0.1;           
    omega = 2*pi*f;  
    delay = 1;       
    
    if t < delay
        y = A * sin(0);  
    else
        y = A * sin(omega * (t - delay));
    end

end
