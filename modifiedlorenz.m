function [S, F, FUS, categ] = modifiedlorenz(S, F, gw, indi, intv)
% Plot the modified Lorenz plot of the well.
% The modified Lorenz plot is a method for characterizing wells in a
% hydrocarbon reservoir. It sorts the hydraulic flow units based on the
% stratigraphic modified Lorenz plot.
% 
% SYNOPSIS:
%     [S, F, FUS, categ] = modifiedlorenz(S, F, gw, indi) use the
%     classification of the authors of the flow units.
%
%     [S, F, FUS, categ] = modifiedlorenz(S, F, gw, indi, intv) use the
%     classification of the flow units of the your choice. 
% 
% PARAMETERS:
%     S      - array containing the storage capacity of the well
%              (respecting the stratigraphic sequence). 
%     F      - array containing the flow capacity of the well (respecting
%              the stratigraphic sequence). 
%     gw     - struct containing the well grid data.
%     indi   - inflection points of the stratigraphic modified
%              Lorenz plot.
%     intv   - intervals for flow units classification (ex.: [0.1, 0.5, 1]).
% 
% RETURNS:
%     S      - array containing the storage capacity of the well (in order
%              of FUS). 
%     F      - array containing the flow capacity of the well (in order of
%              FUS). 
%     FUS    - structure containing the values of flow unit speed:
%
%              FUS.cells  - Array containing the flow unit speed of the
%                           well. 
%              FUS.fu     - Array containing the flow unit speed of the
%                           flow units
%              FUS.ind    - Array containing the indices of the flow units.
%
%     categ  - structure containing the classification of the flow unit:
%
%              categ.cells - Array containing the flow unit speed of the
%                            well. 
%              categ.fu    - Array containing the flow unit speed of the
%                            flow units. 
%     
% SEE ALSO:
%     resmodel, winland, classiclorenz, stratigraphiclorenz,
%     derivativesmlp, flowcapacity, normalizedrqi, normalprobability,
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

if nargin == 4
    
    intv = [0.1, 0.5, 1];
    
end

[numb, len] = size(indi);
numb = numb + 1;

% Indices

indt = [ones(1,len); indi];
indt = [indt; ones(1,len)*length(S)];

%% Flow Unit Speed

Si = [];
Fi = [];

for i = 1:len
    
    Si = [Si, S(indt(:,i),i)];
    Fi = [Fi, F(indt(:,i),i)];

end

deltaS = diff(Si);
deltaF = diff(Fi);

FUS.fu = deltaF./deltaS;

indt(1,:) = 0;

C = zeros(numb, len);
C = num2cell(C);

dindt = diff(indt);

for j = 1:len
    
    for i = 1:numb
        
        C{i,j} = zeros(dindt(i,j),1) + FUS.fu(i,j);
        
    end
    
end

FUS.cells = cell2mat(C);
FUS.cells = FUS.cells(2:end,:);

FUS.ind = [];
aux3 = [];
aux5 = [];

for i = 1:len

    [~,aux] = sortrows(FUS.fu(:,i),'descend');
    FUS.ind = [FUS.ind, aux];
    aux2 = deltaS(aux,i);
    aux3 = [aux3, aux2];
    aux4 = deltaF(aux,i);
    aux5 = [aux5, aux4];

end

deltaS = aux3;
deltaF = aux5;

S = cumsum([zeros(1,len); deltaS]);
F = cumsum([zeros(1,len); deltaF]);

clear aux aux2 aux3 aux4 aux5 deltaS deltaF

%% Classifications

categ.fu = FUS.fu;
categ.cells = FUS.cells;

aux1 = (FUS.fu < intv(1)); % Barriers
categ.fu(aux1) = 1;
aux2 = (FUS.cells < intv(1));
categ.cells(aux2) = 1;

aux3 = (FUS.fu >= intv(1) & FUS.fu < intv(2)); % Strong Baffles
categ.fu(aux3) = 2;
aux4 = (FUS.cells >= intv(1) & FUS.cells < intv(2));
categ.cells(aux4) = 2;

aux5 = (FUS.fu >= intv(2) & FUS.fu < intv(3)); % Weale Baffles
categ.fu(aux5) = 3;
aux6 = (FUS.cells >= intv(2) & FUS.cells < intv(3));
categ.cells(aux6) = 3;

aux7 = (FUS.fu >= intv(3)); % Speed Zones
categ.fu(aux7) = 4;
aux8 = (FUS.cells >= intv(3));
categ.cells(aux8) = 4;

%% Plots

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
% title('Modified Lorenz Plot')
legend(str, 'Location', 'southeast')
xlabel('Storage Capacity')
ylabel('Flow Capacity')
ylim([0,1])
grid

for i = 1:len

    figure
    plotCellData(gw(i), FUS.cells(:,i), 'EdgeAlpha', 0.5)
    title(str(i))
    % title('Flow Unit Speed')
    clb = colorbar;
    clb.Title.String = 'FUS';
    view(3)
    axis equal off
    
end

cmap = [1 0 0; 
        1 0.5 0.2;
        1 1 0.2;
        0 1 0];

for i = 1:len

    figure
    plotCellData(gw(i), categ.cells(:,i), 'EdgeColor', 'k','EdgeAlpha', 0.5)
    title(str(i))
    % title('Classifications')
    colormap(cmap)
    c = colorbar;
    c.Title.String = 'Classification';
    caxis([1 4])
    set(c, 'Ticks', [1.375 2.125 2.875 3.625], ...
           'TickLabels', {'B', 'SB', 'WB', 'NU'})
    % set(c, 'fontweight', 'bold')
    view(3)
    axis equal off
    
end
