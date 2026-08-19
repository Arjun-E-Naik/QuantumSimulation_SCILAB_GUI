// FILE: algorithms/bell_state.sci

function circuit = build_bell_circuit()
    circuit = list();
    circuit = add_gate(circuit,"H",1,0,0,0);
    circuit = add_gate(circuit,"CNOT",1,2,0,0);
endfunction

function run_bell_demo()
    n = 2;
    circuit = build_bell_circuit();
    psi = run_circuit(circuit, n);
    mprintf("BELL STATE  |Phi+> = (|00>+|11>)/sqrt(2)\n");
    probs = get_probabilities(psi);
    mprintf("P(00)=%.2f P(01)=%.2f P(10)=%.2f P(11)=%.2f\n", ..
        probs(1),probs(2),probs(3),probs(4));
    rho0 = partial_trace_keep_one(psi,1,n);
    rho1 = partial_trace_keep_one(psi,2,n);
    mprintf("Purity(q0)=%.3f  Purity(q1)=%.3f (1=pure,0.5=max mixed)\n", ..
        purity(rho0), purity(rho1));
    mprintf("Explanation: measuring q0 fully determines q1 (perfect correlation).\n");
endfunction