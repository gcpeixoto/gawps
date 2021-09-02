function [F, Lc] = classiclorenz(G, perm, ind)
% Calculates the classic Lorenz plot of the well.
% The Lorenz plot identifies the level of heterogeneity over the well.
% 
% SYNOPSIS:
%     [F, Lc] = classiclorenz(G, rock.perm, ind)
% 
% PARAMETERS:
%     G         - struct containing the grid data.
%     rock.perm - permeability field.
%     ind       - well indices.
% 
% RETURNS:
%     F  - Array containing the flow capacity of the well.
%     Lc - Lorenz coefficient.
%     
% SEE ALSO:
%     resmodel, winland, stratigraphiclorenz, derivativesmlp,
%     modifiedlorenz, flowcapacity, normalizedrqi, normalprobability,
%     dykstraparsons.

%{
UFPB - Federal University of Paraiba
LAMEP - Petroleum Engineering Modelling Laboratory

Thiago Ney Evaristo Rodrigues
Dr. Gustavo Charles Peixoto de Oliveira

This file is part of the tool GAWPS.

GAWPS is a set of codes for simulating wells using graphical methods for
characterizing oil reservoirs, based on MRST (MATLAB Reservoir Simulation
Toolbox).
%}

[~, len] = size(ind); % Number of Wells

H = G.faces.centroids(G.cells.faces(G.cells.faces(:,2)==6,1),3) - ...
    G.faces.centroids(G.cells.faces(G.cells.faces(:,2)==5,1),3);
H = H(ind); % Thickness

permsort = perm(ind);

for i = 1:len
    
    [B,I] = sort(permsort(:,i), 'descend');
    permsort(:,i) = B;
    H(:,i) = H(I,i);
    
end

permcumsum = cumsum(permsort.*H);
F = permcumsum./max(permcumsum);
F = [zeros(1,len); F]; % Normalized Cumulative Flow Capacity

H = [zeros(1,len); H];
Hcumsum = cumsum(H);
H = Hcumsum./max(Hcumsum); % Normalized Cumulative Thickness

v = diff(H);

Lc = zeros(1,len); % Pre-allocation of the Lorenz Coefficient

for i = 1:len
    
    Lc(i) = 2*(sum((F(1:end-1,i)+F(2:end,i))/2.*v(:,i)) - 0.5);

end

dline = 0:0.1:1;

%% Plot

str = [];

for i = 1:len

    formatSpec = "W%d";
    aux = compose(formatSpec, i);
    str = [str; aux];
    
end

figure
for i = 1:len
    
    pl = plot(H(:,i), F(:,i), '-s');
    set(pl, 'MarkerFaceColor', pl.Color)
    hold on

end
legend(str, 'Location', 'southeast')
dpl = plot(dline, dline, 'k:');
set(get(get(dpl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
% title('Classic Lorenz Plot')
xlabel('Thickness')
ylabel('Flow Capacity')
grid
