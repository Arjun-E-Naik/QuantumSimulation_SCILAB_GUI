// ============================================================
// FILE: visualization/draw_bloch_sphere.sci
// ============================================================
function clear_axes(ax)
    // Scilab has no cla() - manually delete all children of the axes
    while size(ax.children,1) > 0
        delete(ax.children(1));
    end
endfunction

function draw_bloch_sphere(ax, x, y, z, label)
    sca(ax); clear_axes(ax);
    param3d1  // (declared so Scilab loads 3D toolbox if needed)
    [X,Y,Z] = create_sphere_mesh(20);
    plot3d1(X,Y,Z,alpha=45,theta=30,flag=[0 1 0]);
    // axes lines
    param3d([-1 1],[0 0],[0 0]);
    param3d([0 0],[-1 1],[0 0]);
    param3d([0 0],[0 0],[-1 1]);
    // state arrow
    param3d([0 x],[0 y],[0 z]);
    xstring(0,0,"|0> north / |1> south / "+label);
endfunction

function [X,Y,Z] = create_sphere_mesh(res)
    theta = linspace(0,%pi,res);
    phi = linspace(0,2*%pi,res);
    X = zeros(res,res); Y=X; Z=X;
    for i=1:res
        for j=1:res
            X(i,j) = sin(theta(i))*cos(phi(j));
            Y(i,j) = sin(theta(i))*sin(phi(j));
            Z(i,j) = cos(theta(i));
        end
    end
endfunction