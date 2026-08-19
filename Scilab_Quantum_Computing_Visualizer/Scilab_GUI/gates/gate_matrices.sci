// FILE: gates/gate_matrices.sci

function M = gate_I(),   M = eye(2,2); endfunction
function M = gate_X(),   M = [0 1;1 0]; endfunction
function M = gate_Y(),   M = [0 -%i; %i 0]; endfunction
function M = gate_Z(),   M = [1 0;0 -1]; endfunction
function M = gate_H(),   M = (1/sqrt(2))*[1 1;1 -1]; endfunction
function M = gate_S(),   M = [1 0;0 %i]; endfunction
function M = gate_Sdg(), M = [1 0;0 -%i]; endfunction
function M = gate_T(),   M = [1 0;0 exp(%i*%pi/4)]; endfunction
function M = gate_Tdg(), M = [1 0;0 exp(-%i*%pi/4)]; endfunction
function M = gate_RX(theta), M = [cos(theta/2) -%i*sin(theta/2); -%i*sin(theta/2) cos(theta/2)]; endfunction
function M = gate_RY(theta), M = [cos(theta/2) -sin(theta/2); sin(theta/2) cos(theta/2)]; endfunction
function M = gate_RZ(theta), M = [exp(-%i*theta/2) 0; 0 exp(%i*theta/2)]; endfunction
function M = gate_P(phi),    M = [1 0;0 exp(%i*phi)]; endfunction

function M = gate_matrix_by_name(name, theta)
    select name
    case "I"   then M = gate_I();
    case "X"   then M = gate_X();
    case "Y"   then M = gate_Y();
    case "Z"   then M = gate_Z();
    case "H"   then M = gate_H();
    case "S"   then M = gate_S();
    case "Sdg" then M = gate_Sdg();
    case "T"   then M = gate_T();
    case "Tdg" then M = gate_Tdg();
    case "RX"  then M = gate_RX(theta);
    case "RY"  then M = gate_RY(theta);
    case "RZ"  then M = gate_RZ(theta);
    case "P"   then M = gate_P(theta);
    else error("Unknown single-qubit gate: "+name);
    end
endfunction