// ============================================================
// FILE: visualization/draw_state_vector.sci  and draw_probability.sci
// ============================================================
function clear_axes(ax)
    // Scilab has no cla() - manually delete all children of the axes
    while size(ax.children,1) > 0
        delete(ax.children(1));
    end
endfunction


function draw_state_table(mensaje_handle, psi, n)
    dim = 2^n;
    txt = ["BASIS   AMPLITUDE            PROB     PHASE(deg)"];
    for idx=0:dim-1
        a = psi(idx+1);
        p = abs(a)^2;
        if abs(a) > 1e-9 then
            ph = atan(imag(a),real(a))*180/%pi;
            phs = string(ph);
        else
            phs = "-";
        end
        line = basis_label(idx,n)+"   "+string(real(a))+"+"+string(imag(a))+"i   "+string(p)+"   "+phs;
        txt($+1) = line;
    end
    set(mensaje_handle,"text",txt);
endfunction

function draw_probability_bars(ax, psi, n)
    sca(ax); clear_axes(ax);
    probs = get_probabilities(psi);
    dim = 2^n;
    labels = [];
    for idx=0:dim-1, labels($+1) = basis_label(idx,n); end
    bar(1:dim, probs);
    ax.x_ticks = tlist(["ticks","locations","labels"],1:dim,labels);
    ax.title.text = "Measurement Probabilities";
endfunction