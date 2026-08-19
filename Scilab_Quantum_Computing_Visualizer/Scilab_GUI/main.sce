
// FILE: main.sce  -- entry point, GUI, callbacks

global G_n G_circuit G_psi G_fig G_ax_circuit G_ax_prob G_ax_bloch
global G_txt_state G_selected_gate G_pending_ctrl G_step_idx

function SQCV_start()
    global G_n G_circuit G_psi G_fig G_ax_circuit G_ax_prob G_ax_bloch
    global G_txt_state G_selected_gate G_pending_ctrl G_step_idx

    G_n = 2;
    G_circuit = list();
    G_psi = init_state(G_n);
    G_selected_gate = "";
    G_pending_ctrl = [];
    G_step_idx = 0;

    G_fig = figure("figure_name","Scilab Quantum Computing Visualizer (SQCV)", ..
                    "position",[50 50 1150 700],"background",8);

    // Toolbar
    uicontrol(G_fig,"style","pushbutton","string","New Circuit","position",[10 660 90 25],"callback","cb_new_circuit()");
    uicontrol(G_fig,"style","pushbutton","string","Reset","position",[105 660 70 25],"callback","cb_reset()");
    uicontrol(G_fig,"style","pushbutton","string","Run","position",[180 660 60 25],"callback","cb_run()");
    uicontrol(G_fig,"style","pushbutton","string","Step","position",[245 660 60 25],"callback","cb_step()");
    uicontrol(G_fig,"style","pushbutton","string","Clear","position",[310 660 60 25],"callback","cb_clear()");
    uicontrol(G_fig,"style","pushbutton","string","Measure 1","position",[375 660 80 25],"callback","cb_measure1()");
    uicontrol(G_fig,"style","pushbutton","string","Measure 1000","position",[460 660 100 25],"callback","cb_measure1000()");
    uicontrol(G_fig,"style","text","string","Qubits:","position",[570 660 45 25]);
    uicontrol(G_fig,"style","popupmenu","string","1|2|3|4|5|6|7|8","value",2, ..
              "position",[615 660 50 25],"callback","cb_set_qubits()","tag","qspin");

    //  Left sidebar: gate palette 
    gates1 = ["H";"X";"Y";"Z";"S";"Sdg";"T";"Tdg"];
    for k=1:size(gates1,1)
        uicontrol(G_fig,"style","pushbutton","string",gates1(k), ..
            "position",[10 620-25*(k-1) 60 22], ..
            "callback","cb_select_gate("""+gates1(k)+""")");
    end
    uicontrol(G_fig,"style","pushbutton","string","RX","position",[10 420 60 22],"callback","cb_select_rot(""RX"")");
    uicontrol(G_fig,"style","pushbutton","string","RY","position",[10 395 60 22],"callback","cb_select_rot(""RY"")");
    uicontrol(G_fig,"style","pushbutton","string","RZ","position",[10 370 60 22],"callback","cb_select_rot(""RZ"")");
    uicontrol(G_fig,"style","pushbutton","string","CNOT","position",[10 335 60 22],"callback","cb_select_gate(""CNOT"")");
    uicontrol(G_fig,"style","pushbutton","string","CZ","position",[10 310 60 22],"callback","cb_select_gate(""CZ"")");
    uicontrol(G_fig,"style","pushbutton","string","SWAP","position",[10 285 60 22],"callback","cb_select_gate(""SWAP"")");
    uicontrol(G_fig,"style","pushbutton","string","TOFFOLI","position",[10 250 60 22],"callback","cb_select_gate(""TOFFOLI"")");
    uicontrol(G_fig,"style","pushbutton","string","FREDKIN","position",[10 225 60 22],"callback","cb_select_gate(""FREDKIN"")");

    uicontrol(G_fig,"style","pushbutton","string","Bell Demo","position",[10 180 90 25],"callback","cb_bell_demo()");
    uicontrol(G_fig,"style","pushbutton","string","Grover Demo","position",[10 150 90 25],"callback","cb_grover_demo()");
    uicontrol(G_fig,"style","pushbutton","string","DJ Demo","position",[10 120 90 25],"callback","cb_dj_demo()");
    uicontrol(G_fig,"style","pushbutton","string","Teleport Demo","position",[10 90 90 25],"callback","cb_teleport_demo()");

    //  Center: circuit axes 
    G_ax_circuit = newaxes();
    G_ax_circuit.axes_bounds = [0.13 0.55 0.55 0.4];

    //  Right: probability bar chart 
    G_ax_prob = newaxes();
    G_ax_prob.axes_bounds = [0.70 0.55 0.28 0.4];

    //  Bottom: Bloch sphere 
    G_ax_bloch = newaxes();
    G_ax_bloch.axes_bounds = [0.13 0.08 0.28 0.4];

    // State table text 
    G_txt_state = uicontrol(G_fig,"style","listbox","string","", ..
        "position",[560 300 570 250]);

    refresh_all();
endfunction

// callbacks
function cb_new_circuit()
    global G_circuit G_psi G_n G_step_idx
    G_circuit = list(); G_psi = init_state(G_n); G_step_idx=0;
    refresh_all();
endfunction

function cb_reset()
    global G_psi G_n G_step_idx
    G_psi = init_state(G_n); G_step_idx = 0;
    refresh_all();
endfunction

function cb_clear()
    cb_new_circuit();
endfunction

function cb_set_qubits()
    global G_n G_circuit G_psi G_step_idx
    h = findobj("tag","qspin");
    G_n = h.value;
    G_circuit = list(); G_psi = init_state(G_n); G_step_idx = 0;
    refresh_all();
endfunction

function cb_select_gate(gname)
    global G_selected_gate G_pending_ctrl
    G_selected_gate = gname;
    G_pending_ctrl = [];
    ask_and_place(gname, 0);
endfunction

function cb_select_rot(gname)
    theta = x_dialog("Enter rotation angle theta (radians):","%pi/2");
    theta = evstr(theta);
    ask_and_place(gname, theta);
endfunction

function ask_and_place(gname, theta)
    global G_n G_circuit
    select gname
    case {"CNOT","CZ","SWAP"} then
        qc = x_dialog("Control/first qubit index (0-based):","0");
        qt = x_dialog("Target/second qubit index (0-based):","1");
        qc = evstr(qc)+1; qt = evstr(qt)+1;
        if qc<1|qc>G_n|qt<1|qt>G_n|qc==qt then
            messagebox("Invalid qubit indices.","Error","error"); return;
        end
        G_circuit = add_gate(G_circuit, gname, qc, qt, 0, 0);
    case {"TOFFOLI"} then
        c1=evstr(x_dialog("Control 1 (0-based):","0"))+1;
        c2=evstr(x_dialog("Control 2 (0-based):","1"))+1;
        t=evstr(x_dialog("Target (0-based):","2"))+1;
        if c1<1|c1>G_n|c2<1|c2>G_n|t<1|t>G_n|c1==c2|c1==t|c2==t then
            messagebox("Invalid qubit indices.","Error","error"); return;
        end
        G_circuit = add_gate(G_circuit,"TOFFOLI",c1,c2,t,0);
    case {"FREDKIN"} then
        c=evstr(x_dialog("Control (0-based):","0"))+1;
        t1=evstr(x_dialog("Target 1 (0-based):","1"))+1;
        t2=evstr(x_dialog("Target 2 (0-based):","2"))+1;
        if c<1|c>G_n|t1<1|t1>G_n|t2<1|t2>G_n|c==t1|c==t2|t1==t2 then
            messagebox("Invalid qubit indices.","Error","error"); return;
        end
        G_circuit = add_gate(G_circuit,"FREDKIN",c,t1,t2,0);
    else
        q = evstr(x_dialog("Qubit index (0-based):","0"))+1;
        if q<1|q>G_n then
            messagebox("Invalid qubit index.","Error","error"); return;
        end
        G_circuit = add_gate(G_circuit, gname, q, 0, 0, theta);
    end
    refresh_all();
endfunction

function cb_run()
    global G_circuit G_n G_psi
    G_psi = run_circuit(G_circuit, G_n);
    refresh_all();
endfunction

function cb_step()
    global G_circuit G_n G_psi G_step_idx
    if G_step_idx >= size(G_circuit) then
        messagebox("Circuit complete.","Info","info"); return;
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
    messagebox("Measured: "+basis_label(outcome,G_n),"Measurement","info");
    G_psi = psic;
    refresh_all();
endfunction

function cb_measure1000()
    global G_psi G_n G_ax_prob
    counts = measure_many(G_psi, G_n, 1000);
    sca(G_ax_prob); cla();
    bar(1:2^G_n, counts/1000);
    G_ax_prob.title.text = "1000-shot measurement histogram";
endfunction

function cb_bell_demo()
    global G_n G_circuit G_psi
    G_n = 2; G_circuit = build_bell_circuit();
    G_psi = run_circuit(G_circuit, G_n);
    run_bell_demo();
    refresh_all();
endfunction

function cb_grover_demo()
    run_grover_demo();
endfunction

function cb_dj_demo()
    run_dj_demo("balanced");
    run_dj_demo("constant0");
endfunction

function cb_teleport_demo()
    run_teleportation_demo(%pi/3, %pi/5);
endfunction

// refresh / render 
function refresh_all(highlight)
    global G_circuit G_n G_psi G_ax_circuit G_ax_prob G_ax_bloch G_txt_state
    if ~exists("highlight") then highlight = 0; end
    draw_circuit(G_ax_circuit, G_circuit, G_n, highlight);
    draw_state_table(G_txt_state, G_psi, G_n);
    draw_probability_bars(G_ax_prob, G_psi, G_n);
    rho0 = partial_trace_keep_one(G_psi, 1, G_n);
    [x,y,z] = bloch_from_rho(rho0);
    draw_bloch_sphere(G_ax_bloch, x, y, z, "q0");
endfunction