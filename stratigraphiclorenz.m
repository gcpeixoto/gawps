function [S, F] = stratigraphiclorenz(G, poro, perm, ind)
% Plots the stratigraphic modified Lorenz plot of the well.
% The stratigraphic modified Lorenz plot is a method for characterizing
% wells in a hydrocarbon reservoir and identifying hydraulic flow units.
% 
% SYNOPSIS:
%     [S, F] = stratigraphiclorenz(G, rock.poro, rock.perm, ind)
% 
% PARAMETERS:
%     G         - struct containing the grid data.
%     rock.poro - porosity of the reservoir.
%     rock.perm - permeability of the reservoir.
%     ind       - well indices.
% 
% RETURNS:
%     S - array containing the storage capacity of the well.
%     F - array containing the flow capacity of the well.
%     
% SEE ALSO:
%     winland, classiclorenz, modifiedlorenz, flowcapacity,
%     slopestairplot, normalizedrqi, normalprobability, resmodel.

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

porocumsum = cumsum(poro(ind).*H);
S = porocumsum./max(porocumsum);
S = [zeros(1, len); S]; % Storage Capacity

permcumsum = cumsum(perm(ind).*H);
F = permcumsum./max(permcumsum);
F = [zeros(1, len); F]; % Flow Capacity 

%% Plot

str = [];

for i = 1:len

    formatSpec = "W%d";
    aux = compose(formatSpec, i);
    str = [str; aux];
    
end

figure
for i = 1:len

    pl = plot(S(:,i), F(:,i), '-s');
    set(pl, 'MarkerFaceColor', pl.Color)
    hold on
    
end
legend(str, 'Location', 'southeast')
% title('Stratigraphic Modified Lorenz Plot')
xlabel('Storage Capacity')
ylabel('Flow Capacity')
grid
