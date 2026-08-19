// FILE: quantum/density_matrix.sci 

function rho = state_to_density(psi)
    rho = psi*psi';
endfunction

function bf = insert_bit(bits_other, pos, val, n)
    bf = zeros(1,n); j = 1;
    for k = 1:n
        if k == pos then
            bf(k) = val;
        else
            bf(k) = bits_other(j); j = j+1;
        end
    end
endfunction

function rho_r = partial_trace_keep_one(psi, keep, n)
    rho = state_to_density(psi);
    rho_r = zeros(2,2);
    otherdim = 2^(n-1);
    for a = 0:1
        for b = 0:1
            s = 0;
            for m = 0:otherdim-1
                ob = dec2bin_bits(m, n-1);
                br = insert_bit(ob, keep, a, n);
                bc = insert_bit(ob, keep, b, n);
                ir = bits2dec(br); ic = bits2dec(bc);
                s = s + rho(ir+1, ic+1);
            end
            rho_r(a+1,b+1) = s;
        end
    end
endfunction

function p = purity(rho)
    p = real(trace(rho*rho));
endfunction