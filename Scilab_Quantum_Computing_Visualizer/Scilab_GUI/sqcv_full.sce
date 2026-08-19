// Scilab Quantum Computing Visualizer (SQCV) 
// Load with: exec('sqcv_full.sce', -1);
// Then run:  run_all_tests();   SQCV_start();

// SECTION 1: quantum/state_init.sci

function psi = init_state(n)
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


// SECTION 2: gates/gate_matrices.sci

function M = gate_I(),   M = eye(2,2); endfunction
function M = gate_X(),   M = [0 1;1 0]; endfunction
function M = gate_Y(),   M = [0 -%i; %i 0]; endfunction
function M = gate_Z(),   M = [1 0;0 -1]; endfunction
function M = gate_H(),   M = (1/sqrt(2))*[1 1;1 -1]; endfunction
function M = gate_S(),   M = [1 0;0 %i]; endfunction
function M = gate_Sdg(), M = [1 0;0 -%i]; endfunction
function M = gate_T(),   M = [1 0;0 exp(%i*%pi/4)]; endfunction
function M = gate_Tdg(), M = [1 0;0 exp(-%i*%pi/4)]; endfunction
function M = gate_RX(theta), M = [cos(theta/2) -%i*sin(theta/2); -%i*sin(theta/2) cos(theta/2)]; endfunction
function M = gate_RY(theta), M = [cos(theta/2) -sin(theta/2); sin(theta/2) cos(theta/2)]; endfunction
function M = gate_RZ(theta), M = [exp(-%i*theta/2) 0; 0 exp(%i*theta/2)]; endfunction
function M = gate_P(phi),    M = [1 0;0 exp(%i*phi)]; endfunction

function M = gate_matrix_by_name(name, theta)
    select name
    case "I"   then M = gate_I();
    case "X"   then M = gate_X();
    case "Y"   then M = gate_Y();
    case "Z"   then M = gate_Z();
    case "H"   then M = gate_H();
    case "S"   then M = gate_S();
    case "Sdg" then M = gate_Sdg();
    case "T"   then M = gate_T();
    case "Tdg" then M = gate_Tdg();
    case "RX"  then M = gate_RX(theta);
    case "RY"  then M = gate_RY(theta);
    case "RZ"  then M = gate_RZ(theta);
    case "P"   then M = gate_P(theta);
    else error("Unknown single-qubit gate: "+name);
    end
endfunction


// SECTION 3: quantum/tensor_product.sci + apply_gate.sci

function U = expand_single_qubit_gate(gate, target, n)
    U = 1;
    for k = 1:n
        if k == target then
            U = kron(U, gate);
        else
            U = kron(U, eye(2,2));
        end
    end
endfunction

function psi_out = apply_single_gate(psi, gate, target, n)
    U = expand_single_qubit_gate(gate, target, n);
    psi_out = U*psi;
endfunction


// SECTION 4: quantum/apply_controlled_gate.sci

function U = expand_controlled_gate(gate, control, target, n)
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


// SECTION 5: quantum/measurement.sci

function probs = get_probabilities(psi)
    probs = real(psi .* conj(psi));
    // Renormalize to avoid floating-point drift
    s = sum(probs);
    if s > 1e-12 then
        probs = probs / s;
    end
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
    // Build CDF once for efficiency
    cdf = cumsum(probs);
    cdf(dim) = 1;  // Ensure last entry is exactly 1
    for s = 1:shots
        r = rand();
        outcome = dim - 1;
        for idx = 0:dim-1
            if r <= cdf(idx+1) then outcome = idx; break; end
        end
        counts(outcome+1) = counts(outcome+1) + 1;
    end
endfunction


// SECTION 6: quantum/density_matrix.sci + partial_trace.sci

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


// SECTION 7: quantum/bloch_coordinates.sci

function [x,y,z] = bloch_from_rho(rho)
    Xg=[0 1;1 0]; Yg=[0 -%i;%i 0]; Zg=[1 0;0 -1];
    x = real(trace(rho*Xg));
    y = real(trace(rho*Yg));
    z = real(trace(rho*Zg));
endfunction

function [x,y,z] = bloch_from_amplitudes(alpha, beta)
    x = 2*real(conj(alpha)*beta);
    y = 2*imag(conj(alpha)*beta);
    z = abs(alpha)^2 - abs(beta)^2;
endfunction


// SECTION 8: gui/circuit_gui.sci (circuit data model + execution)

function g = make_gate(gtype, q1, q2, q3, theta, col)
    g = tlist(["gate","type","q1","q2","q3","theta","col"], ..
               gtype, q1, q2, q3, theta, col);
endfunction

function res = members(a,b)
    res = %f*ones(1,size(a,2));
    for i=1:size(a,2)
        res(i) = or(a(i)==b);
    end
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

function circuit = add_gate(circuit, gtype, q1, q2, q3, theta)
    if q2==0 & q3==0 then qu=[q1]; elseif q3==0 then qu=[q1 q2]; else qu=[q1 q2 q3]; end
    col = next_col(circuit, qu);
    g = make_gate(gtype, q1, q2, q3, theta, col);
    circuit($+1) = g;
endfunction

function psi_out = apply_one_gate(psi, g, n)
    select g.type
    case "MEASURE" then psi_out = psi;
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
    else
        eqn = g.type+"(q"+string(g.q1-1)+")";
        if g.theta<>0 then eqn = eqn + " theta="+string(g.theta); end
    end
endfunction


// SECTION 9: visualization/draw_circuit.sci

function clear_axes(ax)
   
    while size(ax.children,1) > 0
        delete(ax.children(1));
    end
endfunction

function draw_circuit(ax, circuit, n, highlight_idx)
    sca(ax); clear_axes(ax);
    maxcol = 1;
    for k=1:size(circuit), maxcol = max(maxcol, circuit(k).col); end
    W = max(maxcol+2, 4); H = n+1;
    ax.data_bounds = [-0.2 -0.5; W+1 H+0.5];
    ax.tight_limits = "on";
    ax.axes_visible = ["off","off","off"];
    ax.margins = [0.02 0.02 0.06 0.02];
    // Draw qubit wires
    for q=1:n
        y = H-q;
        xsegs([0.5; W+0.5], [y; y]);
        e = gce(); e.segs_color = color("black"); e.thickness = 1;
        xstring(0.0, y-0.15, "q"+string(q-1));
        e2 = gce(); e2.font_size = 3;
    end
    ax.title.text = "Circuit Diagram";
    ax.title.font_size = 3;
    // Draw gates
    for k=1:size(circuit)
        g = circuit(k);
        x  = g.col+1;
        hl = (k == highlight_idx);
        select g.type
        case "CNOT" then
            y1=H-g.q1; y2=H-g.q2;
            xsegs([x;x],[y1;y2]);
            xfarc(x-0.12,y1+0.12,0.24,0.24,0,360*64);
            xarc(x-0.18,y2+0.18,0.36,0.36,0,360*64);
        case "CZ" then
            y1=H-g.q1; y2=H-g.q2;
            xsegs([x;x],[y1;y2]);
            xfarc(x-0.12,y1+0.12,0.24,0.24,0,360*64);
            xfarc(x-0.12,y2+0.12,0.24,0.24,0,360*64);
        case "SWAP" then
            y1=H-g.q1; y2=H-g.q2;
            xsegs([x;x],[y1;y2]);
            xstring(x-0.1,y1-0.1,"X"); xstring(x-0.1,y2-0.1,"X");
        case "TOFFOLI" then
            y1=H-g.q1; y2=H-g.q2; y3=H-g.q3;
            xsegs([x;x],[min([y1 y2 y3]);max([y1 y2 y3])]);
            xfarc(x-0.12,y1+0.12,0.24,0.24,0,360*64);
            xfarc(x-0.12,y2+0.12,0.24,0.24,0,360*64);
            xarc(x-0.18,y3+0.18,0.36,0.36,0,360*64);
        case "FREDKIN" then
            y1=H-g.q1; y2=H-g.q2; y3=H-g.q3;
            xsegs([x;x],[min([y1 y2 y3]);max([y1 y2 y3])]);
            xfarc(x-0.12,y1+0.12,0.24,0.24,0,360*64);
            xstring(x-0.1,y2-0.1,"X"); xstring(x-0.1,y3-0.1,"X");
        else
            y = H-g.q1;
            if hl then
                xrect(x-0.35,y+0.35,0.70,0.70);
                e = gce(); e.foreground = color("blue"); e.thickness = 2;
            end
            xrect(x-0.3,y+0.3,0.6,0.6);
            e = gce(); e.background = color("white"); e.fill_mode = "on";
            xstring(x-0.18,y-0.08,g.type);
            e2 = gce(); e2.font_size = 3;
        end
    end
endfunction


// SECTION 10: visualization/draw_state_vector.sci + draw_probability.sci

function draw_state_table(mensaje_handle, psi, n)
    dim = 2^n;
    hdr = "BASIS  AMPLITUDE          PROB   PHASE(deg)";
    txt = hdr;
    for idx=0:dim-1
        a = psi(idx+1);
        p = real(a*conj(a));
        if abs(a) > 1e-9 then
            ph = atan(imag(a), real(a)) * 180 / %pi;
            phs = msprintf("%.1f", ph);
        else
            phs = "-";
        end
        re_str = msprintf("%7.4f", real(a));
        im_str = msprintf("%7.4f", abs(imag(a)));
        if imag(a) >= 0 then
            amp_str = re_str + "+" + im_str + "i";
        else
            amp_str = re_str + "-" + im_str + "i";
        end
        prob_str = msprintf("%.4f", p);
        line = basis_label(idx,n) + "  " + amp_str + "  " + prob_str + "  " + phs;
        txt = [txt; line];
    end
    set(mensaje_handle, "string", txt);
endfunction


function draw_probability_bars(ax, psi, n)
    sca(ax);
    clear_axes(ax);
    probs = get_probabilities(psi);
    dim = 2^n;

    // Build labels as a string column vector
    labels = "";
    for idx=0:dim-1
        if idx==0 then
            labels = basis_label(idx, n);
        else
            labels = [labels; basis_label(idx, n)];
        end
    end

    locs = (1:dim)';  // Column vector

    bar(locs', probs');


    ax.x_ticks = tlist(["ticks","locations","labels"], locs, labels);
    ax.title.text = "Probabilities";
    // Ensure all bars and labels are visible with proper margins
    ax.data_bounds = [0.5, 0; dim+0.5, 1.05];
    ax.tight_limits = "on";
    ax.margins = [0.12 0.15 0.12 0.1];
    ax.font_size = 2;
endfunction


// SECTION 11: visualization/draw_bloch_sphere.sci  (2D projection)


function draw_bloch_sphere(ax, bx, by, bz, label)
    sca(ax); clear_axes(ax);

    //  Outer circle (unit sphere outline) 
    t = linspace(0, 2*%pi, 100);
    plot2d(cos(t), sin(t), style=color("gray"));

    // Inner ellipse (equator, perspective) 
    plot2d(cos(t), 0.3*sin(t), style=color(200,200,200));

    //  Axes lines 
    xsegs([-1.15; 1.15], [0; 0]);   // X axis (horizontal)
    xsegs([0; 0], [-1.15; 1.15]);   // Z axis (vertical)

    //  Axis labels 
    xstring(1.18, -0.05, "X");
    xstring(-1.35, -0.05, "-X");
    xstring(-0.12, 1.18, "|0>");
    xstring(-0.12, -1.35, "|1>");


    xstring(0.08, -0.15, "Y-in");

    //  State vector arrow (projected onto XZ plane) 
    // We project: horizontal = bx, vertical = bz  (by goes into screen)
    if (abs(bx)+abs(by)+abs(bz)) > 1e-6 then
        // Draw arrow line from origin to (bx, bz)
        xsegs([0; bx], [0; bz]);
        e = gce(); e.segs_color = color("red"); e.thickness = 3;
        
        xfarc(bx-0.06, bz+0.06, 0.12, 0.12, 0, 360*64);
        e2 = gce(); e2.background = color("red");

       
        if abs(by) > 0.01 then
            ydir = "(Y="+msprintf("%.2f",by)+")";
            xstring(bx+0.08, bz+0.08, ydir);
        end
    end

    // --- Axes cosmetics ---
    ax.data_bounds = [-1.5 -1.5; 1.5 1.5];
    ax.tight_limits = "on";
    ax.isoview = "on";
    ax.axes_visible = ["off","off","off"];
    ax.title.text = "Bloch: " + label;
    ax.title.font_size = 3;
    ax.margins = [0.05 0.05 0.1 0.05];
endfunction


// SECTION 12: algorithms/bell_state.sci

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


// SECTION 13: algorithms/deutsch_jozsa.sci

function circuit = build_dj_circuit(func_type)
    circuit = list();
    circuit = add_gate(circuit,"X",2,0,0,0);
    circuit = add_gate(circuit,"H",1,0,0,0);
    circuit = add_gate(circuit,"H",2,0,0,0);
    if func_type=="balanced" then
        circuit = add_gate(circuit,"CNOT",1,2,0,0);
    elseif func_type=="constant1" then
        circuit = add_gate(circuit,"X",2,0,0,0);
    end
    circuit = add_gate(circuit,"H",1,0,0,0);
endfunction

function run_dj_demo(func_type)
    n=2;
    circuit = build_dj_circuit(func_type);
    psi = run_circuit(circuit,n);
    probs = get_probabilities(psi);
    p_q0_is_0 = probs(1)+probs(2);
    mprintf("Deutsch-Jozsa (%s): P(q0=0)=%.2f\n",func_type,p_q0_is_0);
    if p_q0_is_0 > 0.99 then
        mprintf("=> function is CONSTANT\n");
    else
        mprintf("=> function is BALANCED\n");
    end
endfunction


// SECTION 14: algorithms/grover.sci


// One Grover oracle + diffusion step for n qubits, 1 marked state
function psi = grover_iterate(psi, target_idx, n)
    dim = 2^n;
    // Phase oracle: flip amplitude of target state
    psi(target_idx+1) = -psi(target_idx+1);
    // Diffusion operator: 2|s><s| - I
    s = (1/sqrt(dim)) * ones(dim, 1);
    psi = 2*(s * (s'*psi)) - psi;
endfunction

// Returns optimal Grover iteration count for n qubits, 1 marked state
function iters = grover_optimal_iters(n)
    dim = 2^n;
    iters = max(1, round(%pi/4 * sqrt(dim)));
endfunction

// General Grover search: n qubits, marks target_idx
function psi = run_grover(n, target_idx)
    dim = 2^n;
    psi = init_state(n);
    // Hadamard on all qubits -> uniform superposition
    for q = 1:n
        psi = apply_single_gate(psi, gate_H(), q, n);
    end
    iters = grover_optimal_iters(n);
    for it = 1:iters
        psi = grover_iterate(psi, target_idx, n);
    end
endfunction

// Legacy 2-qubit wrapper kept for compatibility
function psi = grover_2qubit(target_idx)
    psi = run_grover(2, target_idx);
endfunction

function run_grover_demo()
    n = 2;
    target = 3;  // |11>
    dim = 2^n;
    mprintf("Grover Search: %d qubits, target |11> (index %d)\n", n, target);
    mprintf("Before: uniform %.2f%% each\n", 100/dim);
    psi = run_grover(n, target);
    probs = get_probabilities(psi);
    iters = grover_optimal_iters(n);
    mprintf("After %d Grover iteration(s):\n", iters);
    for idx = 0:dim-1
        mprintf("  P(%s)=%.4f\n", basis_label(idx,n), probs(idx+1));
    end
    mprintf("Target %s probability: %.4f\n", basis_label(target,n), probs(target+1));
endfunction


// SECTION 15: algorithms/teleportation.sci

function run_teleportation_demo(theta_in, phi_in)
    n = 3;
    psi = init_state(n);
    psi = apply_single_gate(psi, gate_RY(theta_in), 1, n);
    psi = apply_single_gate(psi, gate_RZ(phi_in), 1, n);
    psi = apply_single_gate(psi, gate_H(), 2, n);
    psi = apply_controlled_gate(psi, gate_X(), 2, 3, n);
    psi = apply_controlled_gate(psi, gate_X(), 1, 2, n);
    psi = apply_single_gate(psi, gate_H(), 1, n);
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
    if m1==1 then psi_collapsed = apply_single_gate(psi_collapsed, gate_X(), 3, n); end
    if m0==1 then psi_collapsed = apply_single_gate(psi_collapsed, gate_Z(), 3, n); end
    rho_bob = partial_trace_keep_one(psi_collapsed, 3, n);
    [x,y,z] = bloch_from_rho(rho_bob);
    mprintf("Teleportation: measured (m0,m1)=(%d,%d)\n",m0,m1);
    mprintf("Bob''s qubit Bloch vector: (%.3f,%.3f,%.3f)\n",x,y,z);
    [x0,y0,z0] = bloch_from_amplitudes(cos(theta_in/2), exp(%i*phi_in)*sin(theta_in/2));
    mprintf("Original input Bloch vector: (%.3f,%.3f,%.3f)  (should match)\n",x0,y0,z0);
endfunction


// SECTION 16: main.sce - GUI layout and callbacks

global G_n G_circuit G_psi G_fig G_ax_circuit G_ax_prob G_ax_bloch
global G_txt_state G_selected_gate G_pending_ctrl G_step_idx

function SQCV_start()
    global G_n G_circuit G_psi G_fig G_ax_circuit G_ax_prob G_ax_bloch
    global G_txt_state G_selected_gate G_pending_ctrl G_step_idx

    G_n             = 2;
    G_circuit       = list();
    G_psi           = init_state(G_n);
    G_selected_gate = "";
    G_pending_ctrl  = [];
    G_step_idx      = 0;

    
    figs = winsid();
    for fi = figs
        try
            if get(fi, "figure_name") == "SQCV - Quantum Circuit Simulator" then
                close(fi);
            end
        catch
        end
    end

    G_fig = figure("figure_name","SQCV - Quantum Circuit Simulator", ..
                    "position",[20 20 1350 720],"background",8);

    // TOP TOOLBAR (y=645 - safe distance below title bar) 
    tb_y = 645;
    uicontrol(G_fig,"style","pushbutton","string","New",      "position",[110 tb_y 55 28],"callback","cb_new_circuit()","fontsize",11);
    uicontrol(G_fig,"style","pushbutton","string","Run",      "position",[168 tb_y 55 28],"callback","cb_run()","fontsize",11,"foregroundcolor",[0 0.4 0]);
    uicontrol(G_fig,"style","pushbutton","string","Step",     "position",[226 tb_y 55 28],"callback","cb_step()","fontsize",11);
    uicontrol(G_fig,"style","pushbutton","string","Reset",    "position",[284 tb_y 55 28],"callback","cb_reset()","fontsize",11);
    uicontrol(G_fig,"style","pushbutton","string","Clear",    "position",[342 tb_y 55 28],"callback","cb_clear()","fontsize",11);
    uicontrol(G_fig,"style","pushbutton","string","Measure 1", "position",[410 tb_y 85 28],"callback","cb_measure1()","fontsize",11);
    uicontrol(G_fig,"style","pushbutton","string","Measure 1k","position",[498 tb_y 85 28],"callback","cb_measure1000()","fontsize",11);
    uicontrol(G_fig,"style","text","string","Qubits:","position",[600 tb_y+3 50 22],"fontsize",11);
    uicontrol(G_fig,"style","popupmenu","string","1|2|3|4|5|6","value",2, ..
              "position",[650 tb_y 50 28],"callback","cb_set_qubits()","tag","qspin","fontsize",11);

 
    lx = 5; bw = 100; bh = 21; gap = 1;
    py = 620;  // start below toolbar

    //  Single-qubit gates 
    uicontrol(G_fig,"style","text","string","1-Qubit Gates","position",[lx py bw 15],"fontsize",9,"horizontalalignment","center");
    gates1 = ["H";"X";"Y";"Z";"S";"Sdg";"T";"Tdg";"I"];
    for k=1:size(gates1,1)
        py = py - (bh+gap);
        uicontrol(G_fig,"style","pushbutton","string",gates1(k), ..
            "position",[lx py bw bh], ..
            "callback","cb_select_gate("""+gates1(k)+""")","fontsize",10);
    end

    //  Rotation gates 
    py = py - 14;
    uicontrol(G_fig,"style","text","string","Rotation","position",[lx py bw 15],"fontsize",9,"horizontalalignment","center");
    rots = ["RX";"RY";"RZ";"P"];
    for k=1:size(rots,1)
        py = py - (bh+gap);
        uicontrol(G_fig,"style","pushbutton","string",rots(k), ..
            "position",[lx py bw bh], ..
            "callback","cb_select_rot("""+rots(k)+""")","fontsize",10);
    end

    //  Multi-qubit gates 
    py = py - 14;
    uicontrol(G_fig,"style","text","string","Multi-Qubit","position",[lx py bw 15],"fontsize",9,"horizontalalignment","center");
    mgates = ["CNOT";"CZ";"SWAP";"TOFFOLI";"FREDKIN"];
    for k=1:size(mgates,1)
        py = py - (bh+gap);
        uicontrol(G_fig,"style","pushbutton","string",mgates(k), ..
            "position",[lx py bw bh], ..
            "callback","cb_select_gate("""+mgates(k)+""")","fontsize",10);
    end

    // -- Demo buttons --
    py = py - 14;
    uicontrol(G_fig,"style","text","string","Algorithms","position",[lx py bw 15],"fontsize",9,"horizontalalignment","center");
    py = py - (bh+gap);
    uicontrol(G_fig,"style","pushbutton","string","Bell State",    "position",[lx py bw bh],"callback","cb_bell_demo()","fontsize",10);
    py = py - (bh+gap);
    uicontrol(G_fig,"style","pushbutton","string","Grover",        "position",[lx py bw bh],"callback","cb_grover_demo()","fontsize",10);
    py = py - (bh+gap);
    uicontrol(G_fig,"style","pushbutton","string","Deutsch-Jozsa", "position",[lx py bw bh],"callback","cb_dj_demo()","fontsize",10);
    py = py - (bh+gap);
    uicontrol(G_fig,"style","pushbutton","string","Teleport",      "position",[lx py bw bh],"callback","cb_teleport_demo()","fontsize",10);

    
    //   TOP-LEFT:   Circuit diagram
    //   TOP-RIGHT:  Probability bars
    //   BOT-LEFT:   Bloch sphere (2D)
    //   BOT-RIGHT:  State vector table (listbox)

    G_ax_circuit = newaxes();
    G_ax_circuit.axes_bounds = [0.09 0.06 0.52 0.42];

    G_ax_prob = newaxes();
    G_ax_prob.axes_bounds = [0.64 0.06 0.34 0.42];

    G_ax_bloch = newaxes();
    G_ax_bloch.axes_bounds = [0.09 0.53 0.27 0.44];

    G_txt_state = uicontrol(G_fig,"style","listbox","string","", ..
        "position",[490 12 850 310],"fontname","Courier New","fontsize",10);

    refresh_all(0);
    mprintf("SQCV started. Place gates to auto-simulate. Use Run/Step for manual control.\n");
endfunction

function cb_new_circuit()
    global G_circuit G_psi G_n G_step_idx
    G_circuit  = list();
    G_psi      = init_state(G_n);
    G_step_idx = 0;
    refresh_all(0);
endfunction

function cb_reset()
    global G_psi G_n G_step_idx
    G_psi      = init_state(G_n);
    G_step_idx = 0;
    refresh_all(0);
endfunction

function cb_clear()
    cb_new_circuit();
endfunction

function cb_set_qubits()
    global G_n G_circuit G_psi G_step_idx
    h  = findobj("tag","qspin");
    G_n       = h.value;  
    G_circuit = list();
    G_psi     = init_state(G_n);
    G_step_idx = 0;
    refresh_all(0);
endfunction

function cb_select_gate(gname)
    global G_selected_gate G_pending_ctrl
    G_selected_gate = gname;
    G_pending_ctrl  = [];
    ask_and_place(gname, 0);
endfunction

function cb_select_rot(gname)
    ans_str = x_dialog("Enter rotation angle theta (radians):", "%pi/2");
    if ans_str == [] then return; end
    theta = evstr(ans_str);
    ask_and_place(gname, theta);
endfunction

function ask_and_place(gname, theta)
    global G_n G_circuit
    if gname=="CNOT" | gname=="CZ" | gname=="SWAP" | gname=="CRX" | gname=="CRY" | gname=="CRZ" then
        qc_s = x_dialog("Control/first qubit index (0-based, 0 to "+string(G_n-1)+"):", "0");
        if qc_s==[] then return; end
        qt_s = x_dialog("Target/second qubit index (0-based, 0 to "+string(G_n-1)+"):", "1");
        if qt_s==[] then return; end
        qc = evstr(qc_s)+1; qt = evstr(qt_s)+1;
        if qc<1 | qc>G_n | qt<1 | qt>G_n | qc==qt then
            messagebox("Invalid qubit indices. Must be 0 to "+string(G_n-1)+", distinct.","Error","error"); return;
        end
        G_circuit = add_gate(G_circuit, gname, qc, qt, 0, theta);
    elseif gname=="TOFFOLI" then
        if G_n < 3 then
            messagebox("TOFFOLI requires at least 3 qubits.","Error","error"); return;
        end
        c1_s = x_dialog("Control 1 (0-based):","0"); if c1_s==[] then return; end
        c2_s = x_dialog("Control 2 (0-based):","1"); if c2_s==[] then return; end
        t_s  = x_dialog("Target   (0-based):","2"); if t_s==[] then return; end
        c1=evstr(c1_s)+1; c2=evstr(c2_s)+1; t=evstr(t_s)+1;
        if c1<1|c1>G_n|c2<1|c2>G_n|t<1|t>G_n|c1==c2|c1==t|c2==t then
            messagebox("Invalid qubit indices.","Error","error"); return;
        end
        G_circuit = add_gate(G_circuit,"TOFFOLI",c1,c2,t,0);
    elseif gname=="FREDKIN" then
        if G_n < 3 then
            messagebox("FREDKIN requires at least 3 qubits.","Error","error"); return;
        end
        c_s  = x_dialog("Control  (0-based):","0"); if c_s==[] then return; end
        t1_s = x_dialog("Target 1 (0-based):","1"); if t1_s==[] then return; end
        t2_s = x_dialog("Target 2 (0-based):","2"); if t2_s==[] then return; end
        c=evstr(c_s)+1; t1=evstr(t1_s)+1; t2=evstr(t2_s)+1;
        if c<1|c>G_n|t1<1|t1>G_n|t2<1|t2>G_n|c==t1|c==t2|t1==t2 then
            messagebox("Invalid qubit indices.","Error","error"); return;
        end
        G_circuit = add_gate(G_circuit,"FREDKIN",c,t1,t2,0);
    else
        q_s = x_dialog("Qubit index (0-based, 0 to "+string(G_n-1)+"):","0");
        if q_s==[] then return; end
        q = evstr(q_s)+1;
        if q<1 | q>G_n then
            messagebox("Invalid qubit index. Must be 0 to "+string(G_n-1)+".","Error","error"); return;
        end
        G_circuit = add_gate(G_circuit, gname, q, 0, 0, theta);
    end
    refresh_all(0);
endfunction

function cb_run()
    global G_circuit G_n G_psi G_step_idx
    G_psi      = run_circuit(G_circuit, G_n);
    G_step_idx = size(G_circuit);
    refresh_all(0);
endfunction

function cb_step()
    global G_circuit G_n G_psi G_step_idx
    if G_step_idx >= size(G_circuit) then
        messagebox("Circuit complete. Press Reset State to start over.","Info","info"); return;
    end
    G_step_idx = G_step_idx + 1;
    g = G_circuit(G_step_idx);
    G_psi = apply_one_gate(G_psi, g, G_n);
    mprintf("Step %d: %s\n", G_step_idx, gate_equation_string(g));
    refresh_all(G_step_idx);
endfunction

function cb_measure1()
    global G_psi G_n
    [outcome, psic] = measure_state(G_psi, G_n);
    G_psi = psic;
    messagebox("Measured: "+basis_label(outcome,G_n),"Measurement Result","info");
    refresh_all(0);
endfunction

function cb_measure1000()
    global G_psi G_n G_ax_prob
    counts = measure_many(G_psi, G_n, 1000);
    dim    = 2^G_n;
    sca(G_ax_prob);
    clear_axes(G_ax_prob);
    locs = (1:dim)';
    bar(locs', counts/1000);
    // Build labels as column vector
    labels = "";
    for idx=0:dim-1
        if idx==0 then labels = basis_label(idx,G_n);
        else labels = [labels; basis_label(idx,G_n)]; end
    end
    G_ax_prob.x_ticks = tlist(["ticks","locations","labels"], locs, labels);
    G_ax_prob.title.text = "1000-shot Histogram";
    G_ax_prob.data_bounds = [0.5, 0; dim+0.5, max(counts/1000)*1.1+0.01];
    G_ax_prob.tight_limits = "on";
    G_ax_prob.margins = [0.12 0.15 0.12 0.1];
endfunction

function cb_bell_demo()
    global G_n G_circuit G_psi G_step_idx
    G_n       = 2;
    G_circuit = build_bell_circuit();
    G_step_idx = 0;
    h = findobj("tag","qspin");
    if h <> [] then set(h, "value", 2); end
    mprintf("\n=== BELL STATE DEMO ===\n");
    mprintf("Circuit: H(q0) -> CNOT(q0,q1)\n");
    mprintf("Creates entangled state |Phi+> = (|00>+|11>)/sqrt(2)\n");
    refresh_all(0);
    probs = get_probabilities(G_psi);
    mprintf("P(00)=%.4f  P(01)=%.4f  P(10)=%.4f  P(11)=%.4f\n", ..
        probs(1), probs(2), probs(3), probs(4));
    rho0 = partial_trace_keep_one(G_psi, 1, G_n);
    rho1 = partial_trace_keep_one(G_psi, 2, G_n);
    mprintf("Purity(q0)=%.3f  Purity(q1)=%.3f  (0.5 = maximally entangled)\n", ..
        purity(rho0), purity(rho1));
endfunction

function cb_grover_demo()
    global G_n G_circuit G_psi G_step_idx G_ax_circuit G_ax_prob G_ax_bloch G_txt_state
    // Ask user for number of qubits
    nq_s = x_dialog("Number of qubits for Grover (2 to 5):", "2");
    if nq_s == [] then return; end
    nq = evstr(nq_s);
    if nq < 2 | nq > 5 then
        messagebox("Qubits must be 2 to 5.","Error","error"); return;
    end
    dim = 2^nq;
 
    tgt_s = x_dialog("Target state index (0 to "+string(dim-1)+"):", string(dim-1));
    if tgt_s == [] then return; end
    tgt = evstr(tgt_s);
    if tgt < 0 | tgt >= dim then
        messagebox("Target must be 0 to "+string(dim-1)+".","Error","error"); return;
    end
    G_n = nq;
    h = findobj("tag","qspin");
    if h <> [] then set(h, "value", G_n); end
    
    G_circuit = list();
    for q = 1:G_n
        G_circuit = add_gate(G_circuit, "H", q, 0, 0, 0);
    end
    G_step_idx = 0;
  
    G_psi = run_grover(G_n, tgt);
    mprintf("\n=== GROVER SEARCH DEMO ===\n");
    iters = grover_optimal_iters(G_n);
    mprintf("%d qubits, target %s (index %d), %d iterations\n", ..
        G_n, basis_label(tgt, G_n), tgt, iters);
    probs = get_probabilities(G_psi);
    mprintf("Target probability: %.4f\n", probs(tgt+1));
   
    draw_circuit(G_ax_circuit, G_circuit, G_n, 0);
    draw_state_table(G_txt_state, G_psi, G_n);
    draw_probability_bars(G_ax_prob, G_psi, G_n);
    rho0 = partial_trace_keep_one(G_psi, 1, G_n);
    [bx,by,bz] = bloch_from_rho(rho0);
    draw_bloch_sphere(G_ax_bloch, bx, by, bz, "q0");
endfunction

function cb_dj_demo()
    global G_n G_circuit G_psi G_step_idx
 
    choices = ["balanced"; "constant0"; "constant1"];
    sel = x_choose(choices, "Choose Deutsch-Jozsa oracle type:");
    if sel == 0 then return; end
    ftype = choices(sel);
    G_n = 2;
    h = findobj("tag","qspin");
    if h <> [] then set(h, "value", 2); end
    G_circuit = build_dj_circuit(ftype);
    G_step_idx = 0;
    mprintf("\n=== DEUTSCH-JOZSA DEMO (%s) ===\n", ftype);
    mprintf("Circuit: X(q1) H(q0) H(q1)");
    if ftype == "balanced" then mprintf(" CNOT(q0,q1)"); end
    if ftype == "constant1" then mprintf(" X(q1)"); end
    mprintf(" H(q0)\n");
    refresh_all(0);
    probs = get_probabilities(G_psi);
    p_q0_is_0 = probs(1) + probs(2);
    if p_q0_is_0 > 0.99 then
        mprintf("Result: P(q0=0)=%.4f => CONSTANT function\n", p_q0_is_0);
    else
        mprintf("Result: P(q0=0)=%.4f => BALANCED function\n", p_q0_is_0);
    end
endfunction

function cb_teleport_demo()
    global G_n G_circuit G_psi G_step_idx
    G_n = 3;
    h = findobj("tag","qspin");
    if h <> [] then set(h, "value", 3); end
    // Build teleportation circuit
    G_circuit = list();
    // Prepare q0 in interesting state: RY(pi/3)
    G_circuit = add_gate(G_circuit, "RY", 1, 0, 0, %pi/3);
    // Create Bell pair on q1,q2
    G_circuit = add_gate(G_circuit, "H",  2, 0, 0, 0);
    G_circuit = add_gate(G_circuit, "CNOT", 2, 3, 0, 0);
    // Bell measurement
    G_circuit = add_gate(G_circuit, "CNOT", 1, 2, 0, 0);
    G_circuit = add_gate(G_circuit, "H",  1, 0, 0, 0);
    G_step_idx = 0;
    mprintf("\n=== QUANTUM TELEPORTATION DEMO ===\n");
    mprintf("Circuit: RY(pi/3) on q0, Bell pair on q1-q2, CNOT+H for measurement\n");
    mprintf("After measurement + classical corrections, q2 will have q0''s original state.\n");
    refresh_all(0);
    // Also run the full teleportation protocol with corrections
    run_teleportation_demo(%pi/3, 0);
endfunction


function refresh_all(highlight)
    global G_circuit G_n G_psi G_ax_circuit G_ax_prob G_ax_bloch G_txt_state
    if argn(2) < 1 then highlight = 0; end


    if size(G_circuit) > 0 then
        G_psi = run_circuit(G_circuit, G_n);
    else
        G_psi = init_state(G_n);
    end

    draw_circuit(G_ax_circuit, G_circuit, G_n, highlight);
    draw_state_table(G_txt_state, G_psi, G_n);
    draw_probability_bars(G_ax_prob, G_psi, G_n);
    if G_n >= 1 then
        rho0 = partial_trace_keep_one(G_psi, 1, G_n);
        [x,y,z] = bloch_from_rho(rho0);
        draw_bloch_sphere(G_ax_bloch, x, y, z, "q0");
    end
endfunction


// SECTION 17: tests/test_all.sce

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

    // --- Single-qubit gate tests ---
    psi0 = init_state(1);
    psi1 = [0;1];
    check("X|0>=|1>",          norm(apply_single_gate(psi0,gate_X(),1,1)-[0;1]) < tol);
    check("X|1>=|0>",          norm(apply_single_gate(psi1,gate_X(),1,1)-[1;0]) < tol);
    check("H|0>=(|0>+|1>)/sqrt2", norm(apply_single_gate(psi0,gate_H(),1,1)-(1/sqrt(2))*[1;1]) < tol);
    hh = apply_single_gate(apply_single_gate(psi0,gate_H(),1,1),gate_H(),1,1);
    check("H^2|0>=|0>",        norm(hh-[1;0]) < tol);
    check("Z|0>=|0>",          norm(apply_single_gate(psi0,gate_Z(),1,1)-[1;0]) < tol);
    check("Z|1>=-|1>",         norm(apply_single_gate(psi1,gate_Z(),1,1)-[0;-1]) < tol);
    check("S|0>=|0>",          norm(apply_single_gate(psi0,gate_S(),1,1)-[1;0]) < tol);
    check("S|1>=i|1>",         norm(apply_single_gate(psi1,gate_S(),1,1)-[0;%i]) < tol);
    check("Y|0>=i|1>",         norm(apply_single_gate(psi0,gate_Y(),1,1)-[0;%i]) < tol);

    // --- CNOT full truth table ---
    b00 = init_state(2);
    b10 = [0;0;1;0];
    b01 = [0;1;0;0];
    b11 = [0;0;0;1];
    check("CNOT|00>=|00>",     norm(apply_controlled_gate(b00,gate_X(),1,2,2)-b00) < tol);
    check("CNOT|10>=|11>",     norm(apply_controlled_gate(b10,gate_X(),1,2,2)-b11) < tol);
    check("CNOT|01>=|01>",     norm(apply_controlled_gate(b01,gate_X(),1,2,2)-b01) < tol);
    check("CNOT|11>=|10>",     norm(apply_controlled_gate(b11,gate_X(),1,2,2)-b10) < tol);

    // --- Bell state ---
    circuit = build_bell_circuit();
    psib    = run_circuit(circuit, 2);
    bell    = (1/sqrt(2))*[1;0;0;1];
    check("Bell circuit = (|00>+|11>)/sqrt2", norm(psib-bell) < tol);
    probsb  = get_probabilities(psib);
    check("Bell probs only 00/11",   abs(probsb(2)) < tol & abs(probsb(3)) < tol);
    check("Bell probs sum to 1",     abs(sum(probsb)-1) < tol);

    // --- Norm preservation ---
    for k=1:5
        v = rand(2,1)+%i*rand(2,1); v=v/norm(v);
        check("Norm preserved under H (trial "+string(k)+")", abs(norm(gate_H()*v)-1) < tol);
    end

    // --- SWAP ---
    check("SWAP|01>=|10>",     norm(apply_swap_gate(b01,1,2,2)-[0;0;1;0]) < tol);
    check("SWAP|10>=|01>",     norm(apply_swap_gate(b10,1,2,2)-b01) < tol);

    // --- Toffoli ---
    t110 = zeros(8,1); t110(bits2dec([1 1 0])+1) = 1;
    out  = apply_toffoli_gate(t110, 1, 2, 3, 3);
    expected = zeros(8,1); expected(8) = 1;
    check("Toffoli|110>=|111>", norm(out - expected) < tol);
    t100 = zeros(8,1); t100(bits2dec([1 0 0])+1) = 1;
    out2 = apply_toffoli_gate(t100, 1, 2, 3, 3);
    check("Toffoli|100>=|100> (no flip)", norm(out2 - t100) < tol);

    // --- Bloch sphere ---
    [bx,by,bz] = bloch_from_amplitudes(1, 0);
    check("Bloch |0> = (0,0,1)",  and(abs([bx by bz]-[0 0 1]) < tol));
    [bx,by,bz] = bloch_from_amplitudes(1/sqrt(2), 1/sqrt(2));
    check("Bloch |+> = (1,0,0)",  and(abs([bx by bz]-[1 0 0]) < tol));
    [bx,by,bz] = bloch_from_amplitudes(0, 1);
    check("Bloch |1> = (0,0,-1)", and(abs([bx by bz]-[0 0 -1]) < tol));

    // --- Partial trace purity ---
    psib2 = (1/sqrt(2))*[1;0;0;1];
    rho0  = partial_trace_keep_one(psib2, 1, 2);
    rho1  = partial_trace_keep_one(psib2, 2, 2);
    check("Bell purity(rho0)=0.5", abs(purity(rho0)-0.5) < tol);
    check("Bell purity(rho1)=0.5", abs(purity(rho1)-0.5) < tol);

    // --- Grover 2-qubit ---
    psi_g   = run_grover(2, 3);
    probs_g = get_probabilities(psi_g);
    check("Grover 2-qubit amplifies |11>", probs_g(4) > 0.95);

    // --- Deutsch-Jozsa ---
    circ_b = build_dj_circuit("balanced");
    psi_b  = run_circuit(circ_b, 2);
    prob_b = get_probabilities(psi_b);
    check("DJ balanced: P(q0=0) < 0.01",  (prob_b(1)+prob_b(2)) < 0.01);
    circ_c = build_dj_circuit("constant0");
    psi_c  = run_circuit(circ_c, 2);
    prob_c = get_probabilities(psi_c);
    check("DJ constant0: P(q0=0) > 0.99", (prob_c(1)+prob_c(2)) > 0.99);

    mprintf("\n%d / %d tests passed.\n", passed, total);
endfunction

mprintf("SQCV loaded.  Run: run_all_tests();  then  SQCV_start();\n");
