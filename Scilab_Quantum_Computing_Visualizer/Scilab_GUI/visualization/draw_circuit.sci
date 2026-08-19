// ============================================================
// FILE: visualization/draw_circuit.sci
// ============================================================
function clear_axes(ax)
    // Scilab has no cla() - manually delete all children of the axes
    while size(ax.children,1) > 0
        delete(ax.children(1));
    end
endfunction


function draw_circuit(ax, circuit, n, highlight_idx)
    sca(ax); clear_axes(ax);
    maxcol = 1;
    for k=1:size(circuit), maxcol = max(maxcol, circuit(k).col); end
    W = maxcol+2; H = n+1;
    ax.data_bounds = [0 0; W+1 H+1];
    // qubit lines
    for q=1:n
        y = H-q;
        xset("color",1);
        plot2d([0.5 W+0.5],[y y],style=1,axesflag=0,rect=[0,0,W+1,H+1]);
        xstring(0,y+0.15,"q"+string(q-1));
    end
    // gates
    for k=1:size(circuit)
        g = circuit(k);
        x = g.col+1;
        col = 5; if k==highlight_idx then col=2; end
        select g.type
        case "CNOT" then
            y1=H-g.q1; y2=H-g.q2;
            plot2d([x x],[y1 y2],style=color("black"),axesflag=0);
            xfarc(x-0.12,y1+0.12,0.24,0.24,0,360*64); // control dot
            xarc(x-0.15,y2+0.15,0.3,0.3,0,360*64);    // target circle
        case "CZ" then
            y1=H-g.q1; y2=H-g.q2;
            plot2d([x x],[y1 y2],style=color("black"),axesflag=0);
            xfarc(x-0.12,y1+0.12,0.24,0.24,0,360*64);
            xfarc(x-0.12,y2+0.12,0.24,0.24,0,360*64);
        case "SWAP" then
            y1=H-g.q1; y2=H-g.q2;
            plot2d([x x],[y1 y2],style=color("black"),axesflag=0);
            xstring(x-0.1,y1,"x"); xstring(x-0.1,y2,"x");
        case "TOFFOLI" then
            y1=H-g.q1; y2=H-g.q2; y3=H-g.q3;
            plot2d([x x],[min([y1 y2 y3]) max([y1 y2 y3])],style=color("black"),axesflag=0);
            xfarc(x-0.12,y1+0.12,0.24,0.24,0,360*64);
            xfarc(x-0.12,y2+0.12,0.24,0.24,0,360*64);
            xarc(x-0.15,y3+0.15,0.3,0.3,0,360*64);
        else
            y = H-g.q1;
            rect = [x-0.3,y-0.3,0.6,0.6];
            xrect(rect(1),rect(2)+rect(4),rect(3),rect(4));
            xstring(x-0.15,y,g.type);
        end
    end
endfunction