function nrqi = normalizedrqi(G, poro, perm, ind)
% Calculates the normalized cumulative RQI.
% The rock quality index (RQI) is simply the empirical relationship that
% link porosity and permeability of a medium.
% The normalized cumulative RQI is a method for characterizing a well in a
% hydrocarbon reservoir.
% 
% SYNOPSIS:
%     nrqi = normalizedrqi(G, rock.poro, rock.perm, ind)
% 
% PARAMETERS:
%     G         - The struct containing the grid data.
%     rock.poro - The porosity of the reservoir.
%     rock.perm - The permeability of the reservoir.
%     ind       - The well indices.
% 
% RETURNS:
%     nrqi - Array containing the normalized cumulative RQI of the well.
%     
% SEE ALSO:
%     resmodel, winland, classiclorenz, stratigraphiclorenz,
%     derivativesmlp, modifiedlorenz, flowcapacity, normalprobability,
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

rqi = 0.0314*sqrt(perm(ind)./poro(ind)); % RQI
rqicumsum = cumsum(rqi,'reverse');
nrqi = rqicumsum./max(rqicumsum); % Normalized RQI

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
    
    pl = plot(nrqi(:,i), H(:,i), '-s');
    set(pl, 'MarkerFaceColor', pl.Color)
    hold on

end
% title('Normalized Cumulative RQI')
legend(str, 'Location', 'southeast')
xlabel('RQI')
ylabel('Depth [m]')
ylim([min(H, [], 'all') max(H, [], 'all')])
set(gca,'Ydir','reverse')
grid