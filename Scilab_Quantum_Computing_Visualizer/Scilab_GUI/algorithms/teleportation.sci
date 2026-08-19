// FILE: algorithms/teleportation.sci  (3 qubits: q0=payload, q1,q2=Bell pair)

function run_teleportation_demo(theta_in, phi_in)
    n = 3;
    psi = init_state(n);
    // prepare q0 in cos(theta/2)|0> + e^i phi sin(theta/2)|1>
    psi = apply_single_gate(psi, gate_RY(theta_in), 1, n);
    psi = apply_single_gate(psi, gate_RZ(phi_in), 1, n);
    // Bell pair on q1,q2
    psi = apply_single_gate(psi, gate_H(), 2, n);
    psi = apply_controlled_gate(psi, gate_X(), 2, 3, n);
    // Alice: CNOT(q0,q1), H(q0)
    psi = apply_controlled_gate(psi, gate_X(), 1, 2, n);
    psi = apply_single_gate(psi, gate_H(), 1, n);
    // Measure q0,q1
    probs = get_probabilities(psi);
    r = rand(); cum=0; dim=8; outcome=7;
    for idx=0:dim-1
        cum=cum+probs(idx+1);
        if r<=cum then outcome=idx; break; end
    end
    bits = dec2bin_bits(outcome,n);
    m0 = bits(1); m1 = bits(2);
    psi_collapsed = zeros(dim,1); psi_collapsed(outcome+1)=1;
    psi_collapsed = psi_collapsed / norm(psi_collapsed);
    // Bob applies correction: X if m1==1, Z if m0==1
    if m1==1 then psi_collapsed = apply_single_gate(psi_collapsed, gate_X(), 3, n); end
    if m0==1 then psi_collapsed = apply_single_gate(psi_collapsed, gate_Z(), 3, n); end
    rho_bob = partial_trace_keep_one(psi_collapsed, 3, n);
    [x,y,z] = bloch_from_rho(rho_bob);
    mprintf("Teleportation: measured (m0,m1)=(%d,%d)\n",m0,m1);
    mprintf("Bob's qubit Bloch vector: (%.3f,%.3f,%.3f)\n",x,y,z);
    [x0,y0,z0] = bloch_from_amplitudes(cos(theta_in/2), exp(%i*phi_in)*sin(theta_in/2));
    mprintf("Original input Bloch vector: (%.3f,%.3f,%.3f)  (should match)\n",x0,y0,z0);
endfunction