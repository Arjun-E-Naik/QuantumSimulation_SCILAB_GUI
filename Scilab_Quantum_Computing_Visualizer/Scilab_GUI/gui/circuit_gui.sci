// FILE: gui/circuit_gui.sci  

// A gate record is a tlist: gate('type','q1','q2','q3','theta','col')
// type: "H","X","Y","Z","S","Sdg","T","Tdg","RX","RY","RZ","P",
//       "CNOT","CZ","SWAP","TOFFOLI","FREDKIN","MEASURE"

function g = make_gate(gtype, q1, q2, q3, theta, col)
    g = tlist(["gate","type","q1","q2","q3","theta","col"], ..
               gtype, q1, q2, q3, theta, col);
endfunction

function nc = next_col(circuit, qubits_used)
    nc = 1;
    for k = 1:size(circuit)
        g = circuit(k);
        used = [g.q1 g.q2 g.q3];
        used = used(used>0);
        if or(members(used, qubits_used)) | or(members(qubits_used,used)) then
            nc = max(nc, g.col+1);
        end
    end
endfunction

function res = members(a,b)
    res = %f*ones(1,size(a,2));
    for i=1:size(a,2)
        res(i) = or(a(i)==b);
    end
endfunction

function circuit = add_gate(circuit, gtype, q1, q2, q3, theta)
    if q2==0 & q3==0 then qu=[q1]; elseif q3==0 then qu=[q1 q2]; else qu=[q1 q2 q3]; end
    col = next_col(circuit, qu);
    g = make_gate(gtype, q1, q2, q3, theta, col);
    circuit($+1) = g;
endfunction

function psi_out = apply_one_gate(psi, g, n)
    select g.type
    case "MEASURE" then psi_out = psi; // handled separately
    case "CNOT" then    psi_out = apply_controlled_gate(psi, gate_X(), g.q1, g.q2, n);
    case "CZ"   then    psi_out = apply_controlled_gate(psi, gate_Z(), g.q1, g.q2, n);
    case "SWAP" then    psi_out = apply_swap_gate(psi, g.q1, g.q2, n);
    case "TOFFOLI" then psi_out = apply_toffoli_gate(psi, g.q1, g.q2, g.q3, n);
    case "FREDKIN" then psi_out = apply_fredkin_gate(psi, g.q1, g.q2, g.q3, n);
    case "CRX" then psi_out = apply_controlled_gate(psi, gate_RX(g.theta), g.q1, g.q2, n);
    case "CRY" then psi_out = apply_controlled_gate(psi, gate_RY(g.theta), g.q1, g.q2, n);
    case "CRZ" then psi_out = apply_controlled_gate(psi, gate_RZ(g.theta), g.q1, g.q2, n);
    else
        M = gate_matrix_by_name(g.type, g.theta);
        psi_out = apply_single_gate(psi, M, g.q1, n);
    end
endfunction

function psi_final = run_circuit(circuit, n)
    psi_final = init_state(n);
    for k = 1:size(circuit)
        psi_final = apply_one_gate(psi_final, circuit(k), n);
    end
endfunction

function eqn = gate_equation_string(g)
    select g.type
    case "CNOT" then eqn = "CNOT(control=q"+string(g.q1-1)+", target=q"+string(g.q2-1)+")";
    case "CZ"   then eqn = "CZ(q"+string(g.q1-1)+",q"+string(g.q2-1)+")";
    case "SWAP" then eqn = "SWAP(q"+string(g.q1-1)+",q"+string(g.q2-1)+")";
    case "TOFFOLI" then eqn = "TOFFOLI(c1=q"+string(g.q1-1)+",c2=q"+string(g.q2-1)+",t=q"+string(g.q3-1)+")";
    case "FREDKIN" then eqn = "FREDKIN(c=q"+string(g.q1-1)+",t1=q"+string(g.q2-1)+",t2=q"+string(g.q3-1)+")";
    else eqn = g.type+"(q"+string(g.q1-1)+")";
        if g.theta<>0 then eqn = eqn + " theta="+string(g.theta); end
    end
endfunction