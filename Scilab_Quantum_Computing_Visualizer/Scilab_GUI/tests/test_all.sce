// FILE: tests/test_all.sce

function run_all_tests()
    tol = 1e-6; passed = 0; total = 0;

    function check(name, cond)
        total = total + 1;
        if cond then
            mprintf("[PASS] %s\n", name); passed = passed+1;
        else
            mprintf("[FAIL] %s\n", name);
        end
    endfunction

    n=1;
    psi0 = init_state(1);
    check("X|0>=|1>", norm(apply_single_gate(psi0,gate_X(),1,1)-[0;1])<tol);
    psi1=[0;1];
    check("X|1>=|0>", norm(apply_single_gate(psi1,gate_X(),1,1)-[1;0])<tol);
    check("H|0>=(|0>+|1>)/sqrt2", norm(apply_single_gate(psi0,gate_H(),1,1)-(1/sqrt(2))*[1;1])<tol);
    hh = apply_single_gate(apply_single_gate(psi0,gate_H(),1,1),gate_H(),1,1);
    check("H^2|0>=|0>", norm(hh-[1;0])<tol);
    check("Z|0>=|0>", norm(apply_single_gate(psi0,gate_Z(),1,1)-[1;0])<tol);
    check("Z|1>=-|1>", norm(apply_single_gate(psi1,gate_Z(),1,1)-[0;-1])<tol);

    n=2;
    b00=init_state(2);
    b10=[0;0;1;0];
    check("CNOT|00>=|00>", norm(apply_controlled_gate(b00,gate_X(),1,2,2)-b00)<tol);
    check("CNOT|10>=|11>", norm(apply_controlled_gate(b10,gate_X(),1,2,2)-[0;0;0;1])<tol);

    circuit = build_bell_circuit();
    psib = run_circuit(circuit,2);
    bell = (1/sqrt(2))*[1;0;0;1];
    check("Bell circuit = (|00>+|11>)/sqrt2", norm(psib-bell)<tol);
    probsb = get_probabilities(psib);
    check("Bell probs only 00/11", abs(probsb(2))<tol & abs(probsb(3))<tol);
    check("Probabilities sum to 1", abs(sum(probsb)-1)<tol);

    for k=1:5
        g = gate_H();
        v = rand(2,1)+%i*rand(2,1); v=v/norm(v);
        check("Norm preserved under H (trial "+string(k)+")", abs(norm(g*v)-1)<tol);
    end

    b01=[0;1;0;0];
    check("SWAP|01>=|10>", norm(apply_swap_gate(b01,1,2,2)-[0;0;1;0])<tol);

    n=3;
    t110 = zeros(8,1); t110(bits2dec([1 1 0])+1)=1;
    out = apply_toffoli_gate(t110,1,2,3,3);
    check("Toffoli|110>=|111>", norm(out - (zeros(8,1)+(1:8==8)'))<tol);

    check("Bloch |0> = (0,0,1)", and(abs([bloch_from_amplitudes(1,0)]-[0 0 1])<tol));
    check("Bloch |+> = (1,0,0)", and(abs([bloch_from_amplitudes(1/sqrt(2),1/sqrt(2))]-[1 0 0])<tol));

    mprintf("all tests passed.\n");
endfunction