// FILE: quantum/apply_controlled_gate.sci

function U = expand_controlled_gate(gate, control, target, n)
    // U = P0(control) ⊗ I...⊗I  +  P1(control) ⊗ ... gate on target ...
    P0 = [1 0;0 0];  P1 = [0 0;0 1];  I2 = eye(2,2);
    term0 = 1; term1 = 1;
    for k = 1:n
        if k == control then
            term0 = kron(term0, P0);
            term1 = kron(term1, P1);
        elseif k == target then
            term0 = kron(term0, I2);
            term1 = kron(term1, gate);
        else
            term0 = kron(term0, I2);
            term1 = kron(term1, I2);
        end
    end
    U = term0 + term1;
endfunction

function psi_out = apply_controlled_gate(psi, gate, control, target, n)
    if control == target then
        error("Control and target qubit cannot be the same.");
    end
    U = expand_controlled_gate(gate, control, target, n);
    psi_out = U*psi;
endfunction

function U = expand_swap_gate(q1, q2, n)
    dim = 2^n;
    U = zeros(dim,dim);
    for idx = 0:dim-1
        bits = dec2bin_bits(idx,n);
        nb = bits;
        tmp = nb(q1); nb(q1) = nb(q2); nb(q2) = tmp;
        nidx = bits2dec(nb);
        U(nidx+1, idx+1) = 1;
    end
endfunction

function psi_out = apply_swap_gate(psi, q1, q2, n)
    if q1==q2 then error("SWAP requires two distinct qubits."); end
    U = expand_swap_gate(q1,q2,n);
    psi_out = U*psi;
endfunction

function U = expand_toffoli_gate(c1, c2, target, n)
    dim = 2^n;
    U = zeros(dim,dim);
    P0=[1 0;0 0]; P1=[0 0;0 1]; X=[0 1;1 0]; I2=eye(2,2);
    for b1 = 0:1
        for b2 = 0:1
            term = 1;
            for k = 1:n
                if k==c1 then
                    if b1==0 then term=kron(term,P0); else term=kron(term,P1); end
                elseif k==c2 then
                    if b2==0 then term=kron(term,P0); else term=kron(term,P1); end
                elseif k==target then
                    if (b1==1 & b2==1) then term=kron(term,X); else term=kron(term,I2); end
                else
                    term = kron(term, I2);
                end
            end
            U = U + term;
        end
    end
endfunction

function psi_out = apply_toffoli_gate(psi, c1, c2, target, n)
    U = expand_toffoli_gate(c1,c2,target,n);
    psi_out = U*psi;
endfunction

function U = expand_fredkin_gate(control, t1, t2, n)
    dim = 2^n;
    U = zeros(dim,dim);
    for idx = 0:dim-1
        bits = dec2bin_bits(idx,n);
        if bits(control) == 1 then
            nb = bits;
            tmp = nb(t1); nb(t1)=nb(t2); nb(t2)=tmp;
            nidx = bits2dec(nb);
        else
            nidx = idx;
        end
        U(nidx+1, idx+1) = 1;
    end
endfunction

function psi_out = apply_fredkin_gate(psi, control, t1, t2, n)
    U = expand_fredkin_gate(control,t1,t2,n);
    psi_out = U*psi;
endfunction