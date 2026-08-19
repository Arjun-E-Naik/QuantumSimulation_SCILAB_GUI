// FILE: quantum/tensor_product.sci 

function U = expand_single_qubit_gate(gate, target, n)
    U = 1;
    for k = 1:n
        if k == target then
            U = kron(U, gate);
        else
            U = kron(U, eye(2,2));
        end
    end
endfunction

function psi_out = apply_single_gate(psi, gate, target, n)
    U = expand_single_qubit_gate(gate, target, n);
    psi_out = U*psi;
endfunction