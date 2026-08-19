// FILE: algorithms/deutsch_jozsa.sci  (2-qubit: 1 input + 1 ancilla)

function circuit = build_dj_circuit(func_type)
    // func_type: "constant0","constant1","balanced"
    circuit = list();
    circuit = add_gate(circuit,"X",2,0,0,0);   // ancilla -> |1>
    circuit = add_gate(circuit,"H",1,0,0,0);
    circuit = add_gate(circuit,"H",2,0,0,0);
    select func_type
    case "balanced" then
        circuit = add_gate(circuit,"CNOT",1,2,0,0); // oracle: f(x)=x
    case "constant1" then
        circuit = add_gate(circuit,"X",2,0,0,0);
    else
        // constant0: identity oracle, do nothing
    end
    circuit = add_gate(circuit,"H",1,0,0,0);
endfunction

function run_dj_demo(func_type)
    n=2;
    circuit = build_dj_circuit(func_type);
    psi = run_circuit(circuit,n);
    probs = get_probabilities(psi);
    p_q0_is_0 = probs(1)+probs(2); // |00>,|01>
    mprintf("Deutsch-Jozsa (%s): P(q0=0)=%.2f\n",func_type,p_q0_is_0);
    if p_q0_is_0 > 0.99 then
        mprintf("=> function is CONSTANT\n");
    else
        mprintf("=> function is BALANCED\n");
    end
endfunction