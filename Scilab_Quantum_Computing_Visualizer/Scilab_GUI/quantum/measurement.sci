// FILE: quantum/measurement.sci

function probs = get_probabilities(psi)
    probs = abs(psi).^2;
endfunction

function [outcome, psi_collapsed] = measure_state(psi, n)
    probs = get_probabilities(psi);
    r = rand();
    dim = 2^n;
    cumP = 0; outcome = dim-1;
    for idx = 0:dim-1
        cumP = cumP + probs(idx+1);
        if r <= cumP then outcome = idx; break; end
    end
    psi_collapsed = zeros(dim,1);
    psi_collapsed(outcome+1) = 1;
endfunction

function counts = measure_many(psi, n, shots)
    dim = 2^n;
    counts = zeros(1,dim);
    probs = get_probabilities(psi);
    for s = 1:shots
        r = rand(); cumP = 0; outcome = dim-1;
        for idx = 0:dim-1
            cumP = cumP + probs(idx+1);
            if r <= cumP then outcome = idx; break; end
        end
        counts(outcome+1) = counts(outcome+1) + 1;
    end
endfunction