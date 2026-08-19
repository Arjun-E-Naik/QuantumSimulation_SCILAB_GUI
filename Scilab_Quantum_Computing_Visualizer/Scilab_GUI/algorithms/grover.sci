// FILE: algorithms/grover.sci  (2-qubit, target |11>)

function psi = grover_2qubit(target_idx)
    n = 2;
    psi = init_state(n);
    psi = apply_single_gate(psi, gate_H(), 1, n);
    psi = apply_single_gate(psi, gate_H(), 2, n);
    // Oracle: flip sign of target
    Uf = eye(4,4); Uf(target_idx+1,target_idx+1) = -1;
    psi = Uf*psi;
    // Diffusion operator: 2|s><s| - I, |s> = H|00>
    s = (1/2)*ones(4,1);
    Udiff = 2*(s*s') - eye(4,4);
    psi = Udiff*psi;
endfunction

function run_grover_demo()
    n=2;
    target = 3; // |11>
    psi0 = init_state(n);
    psi0 = apply_single_gate(psi0,gate_H(),1,n);
    psi0 = apply_single_gate(psi0,gate_H(),2,n);
    mprintf("Before amplification: uniform 25%% each\n");
    psi = grover_2qubit(target);
    probs = get_probabilities(psi);
    mprintf("After 1 Grover iteration: P(00)=%.2f P(01)=%.2f P(10)=%.2f P(11)=%.2f\n", ..
        probs(1),probs(2),probs(3),probs(4));
    mprintf("Target |11> is now the dominant outcome.\n");
endfunction