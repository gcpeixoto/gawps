function fzi = normalprobability(poro, perm, ind)
% Calculates the histogram and normal probability plot of the well.
% The flow zone indicator (FZI) is is a index based on pore throat,
% tortuosity, and effective area based on texture properties, sedimentation
% model, pore geometry, and digenesis effects.
% The histogram and normal probability plot are methods for characterizing
% a well in a hydrocarbon reservoir. 
% 
% SYNOPSIS:
%     fzi = normalprobability(rock.poro, rock.perm, ind)
% 
% PARAMETERS:
%     rock.poro - The porosity of the reservoir.
%     rock.perm - The permeability of the reservoir.
%     ind       - The well indices.
% 
% RETURNS:
%     fzi - Array containing the FZI of the well.
%     
% SEE ALSO:
%     resmodel, winland, classiclorenz, stratigraphiclorenz,
%     derivativesmlp, modifiedlorenz, flowcapacity, normalizedrqi,
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

[lay, len] = size(ind); % Number of Wells and Layers

rqi = 0.0314*sqrt(perm(ind)./poro(ind));
phi_z = poro(ind)./(1 - poro(ind));
fzi = rqi./phi_z;

%% Plots

str = [];

for i = 1:len

    formatSpec = "W%d";
    aux = compose(formatSpec, i);
    str = [str; aux];
    
end

for i = 1:len
    
    figure
    histogram(log(fzi(:,i)), ceil(2*(lay^(1/3))), 'Normalization', 'probability')
    % title('Histogram Analysis')
    title(str(i))
    xlabel('log(FZI)')
    ylabel('Frequency')
    grid
    
end

for i = 1:len
    
    figure
    n = normplot(fzi(:,i));
    % title('Normal Probabilty Plot')
    title(str(i))
    xlabel('FZI')
    ylabel('Cumulative Probability')
    set(n(1,1), 'Marker', 's', ...
        'LineStyle', '-', ...
        'Color', 'k', ...
        'MarkerFaceColor', 'w')
    delete(n(2:3,1))
end