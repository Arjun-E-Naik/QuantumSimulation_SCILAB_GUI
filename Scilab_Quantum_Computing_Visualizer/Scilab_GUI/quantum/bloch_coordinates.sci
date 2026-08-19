// FILE: quantum/bloch_coordinates.sci

function [x,y,z] = bloch_from_rho(rho)
    X=[0 1;1 0]; Y=[0 -%i;%i 0]; Z=[1 0;0 -1];
    x = real(trace(rho*X));
    y = real(trace(rho*Y));
    z = real(trace(rho*Z));
endfunction

function [x,y,z] = bloch_from_amplitudes(alpha, beta)
    x = 2*real(conj(alpha)*beta);
    y = 2*imag(conj(alpha)*beta);
    z = abs(alpha)^2 - abs(beta)^2;
endfunction