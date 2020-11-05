function [Ks, P, Vk] = dykstraparsons(perm, ind)
% Calculates the log-normal permeability distribution plot of the well.
% The log-normal permeability distribution plot is a method for
% characterizing a well in a hydrocarbon reservoir and identification of
% the level of heterogeneity. 
% 
% SYNOPSIS:
%     [Ks, P, Vk] = dykstraparsons(perm, ind)
% 
% PARAMETERS:
%     rock.perm - The permeability of the reservoir.
%     ind       - The well indices.
% 
% RETURNS:
%     Ks - Array containing the sample permeability.
%     P  - Array containing the log-normal permeability distribution.
%     Vk - The Dykstra-Parsons coefficient.
%     
% SEE ALSO:
%     resmodel, winland, classiclorenz, stratigraphiclorenz,
%     derivativesmlp, modifiedlorenz, flowcapacity, normalizedrqi,
%     normalprobability.

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

[lay, len] = size(ind);

Ks = sort(perm(ind), 'descend'); % Sample Permeability
P = linspace(0,(lay-1)*100/lay, lay)';

i = 1:(lay-1);
I = find((Ks(i) - Ks(i+1)) == 0) + 1;
for j = 1:length(I)

    P(I(j)) = P(I(j)-1);
    
end

for i = 1:len

    Vk(i) = 1 - exp(-sqrt(log(mean(Ks(:,i))/harmmean(Ks(:,i)))));
    
end

%% Plot

str = [];

for i = 1:len

    formatSpec = "W%d";
    aux = compose(formatSpec, i);
    str = [str; aux];
    
end

figure
for i = 1:len
    
    sly = semilogy(P, Ks(:,i), '-s');
    set(sly, 'MarkerFaceColor', sly.Color)
    hold on

end
legend(str)
% title('Log-Normal Permeability Distribution')
xlabel('Portion of Total Sample Having Higher Permeability')
ylabel('Permeability [mD]')
grid