// FILE: quantum/state_init.sci

function psi = init_state(n)
    // |00...0>, q0 = MSB
    dim = 2^n;
    psi = zeros(dim,1);
    psi(1) = 1;
endfunction

function bits = dec2bin_bits(idx, n)
 
    bits = zeros(1,n);
    val = idx;
    for k = n:-1:1
        bits(k) = modulo(val,2);
        val = floor(val/2);
    end
endfunction

function idx = bits2dec(bits)
    n = size(bits,2);
    idx = 0;
    for k = 1:n
        idx = idx + bits(k)*2^(n-k);
    end
endfunction

function s = basis_label(idx,n)
    b = dec2bin_bits(idx,n);
    s = "";
    for k=1:n
        s = s + string(b(k));
    end
    s = "|" + s + ">";
endfunction