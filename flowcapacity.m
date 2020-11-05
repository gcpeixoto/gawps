function F = flowcapacity(G, perm, ind)
% Calculates the normalized cumulative flow capacity of the well.
% The normalized cumulative flow capacity is a method for characterizing
% a well in a hydrocarbon reservoir, based on the stratigraphic modified
% Lorenz plot. 
% 
% SYNOPSIS:
%     ncfc = flowcapacity(G, rock.perm, ind)
% 
% PARAMETERS:
%     G         - The struct containing the grid data.
%     rock.perm - The permeability of the reservoir.
%     ind       - The well indeces.
% 
% RETURNS:
%     ncfc - Array containing the normalized cumulative flow capacity of
%            the well.
%     
% SEE ALSO:
%     resmodel, winland, classiclorenz, stratigraphiclorenz,
%     derivativesmlp, modifiedlorenz, normalizedrqi, normalprobability,
%     dykstraparsons.

%{
UFPB - Federal University of Paraiba
LAMEP - Petroleum Engineering Modelling Laboratory

Dr. Gustavo Charles Peixoto de Oliveira
Thiago Ney Evaristo Rodrigues

This file is part of the tool GAWPS.

GAWPS is a set of codes for simulating wells using graphical methods for
characterizing oil reservoirs, based on MRST (MATLAB Reservoir Simulation
Toolbox).
%}

[~, len] = size(ind); % Number of Wells

h = G.faces.centroids(G.cells.faces(G.cells.faces(:,2)==6,1),3) - ...
    G.faces.centroids(G.cells.faces(G.cells.faces(:,2)==5,1),3);
h = h(ind); % Thickness

permcumsum = cumsum(perm(ind).*h);
F = permcumsum./max(permcumsum); % Normalized Cumulative Flow Capacity

H = G.cells.centroids(:,3);
H = H(ind); % Depth

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
% title('Normalized Cumulative Flow Capacity')
legend(str, 'Location', 'southeast')
xlabel('Depth [m]')
ylabel('Flow Capacity')
xlim([min(H, [], 'all') max(H, [], 'all')])
grid