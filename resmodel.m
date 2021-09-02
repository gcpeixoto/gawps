function [G, gw, rock, indw] = resmodel(coord, reserv)
% Processes the reservoir model, returning the data of petrophysical
% properties, grid, and indices of the well under study.
% 
% SYNOPSIS:
%     [G, gw, rock, indw] = resmodel(coord, reserv)
% 
% PARAMETERS:
%     coord  - coordinates of the wells under study.
%     reserv - name of the reservoir model. The current available options are: 
%              'SPE10', 'UNISIM1D', 'UNISIM2D', 'Egg', and 'Norne'. 
% 
% RETURNS:
%     G    - struct containing the grid data.
%     gw   - struct containing the well grid data.
%     rock - struct containing the petrophysical properties of the
%            reservoir.
%     indw - array containing the indices of the well under study.
%     
% SEE ALSO:
%     winland, classiclorenz, stratigraphiclorenz, derivativesmlp,
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

%% Read and Process

reserv = string(reserv);

% Reservoir Model

if all(reserv == 'SPE10')
    
    f = fullfile('..', 'GAWPS', 'Models', 'SPE10', {'G-SPE10.mat'; 'rock-SPE10.mat'});

    load(f{1}, 'G');
    load(f{2}, 'rock');

    aux = rock.poro == 0;
    aux2 = rock.poro ~= 0;
    rock.poro(aux) = min(rock.poro(aux2));
    
    rock.perm = convertTo(rock.perm,milli*darcy); % m^2 to mD
    rock.perm = geomean(rock.perm,2);
    
elseif all(reserv == 'UNISIM1D')
    
    f = fullfile('..', 'GAWPS', 'Models', 'UNISIM-I-D', 'UNISIM_I_D_ECLIPSE.DATA');

    grdecl = readGRDECL(f);
    G = processGRDECL(grdecl);
    G = computeGeometry(G);
    clc

    % Actives Properties

    active = grdecl.ACTNUM == 1;

    rock.poro = grdecl.PORO (active);

    KX = grdecl.PERMX (active);
    KY = grdecl.PERMY (active);
    KZ = grdecl.PERMZ (active);

    rock.perm = [KX, KY, KZ];
    rock.perm = geomean(rock.perm, 2);  % [mD]

elseif all(reserv == 'UNISIM2D')

    f = fullfile('..', 'GAWPS', 'Models', 'UNISIM-II-D', 'UNISIM_II_D_ECLIPSE.DATA');

    grdecl = readGRDECL(f);
    G = processGRDECL(grdecl);
    G = computeGeometry(G);

    active = grdecl.ACTNUM == 1;

    rock.poro = grdecl.PORO (active);

    KX = grdecl.PERMX (active);
    KY = grdecl.PERMY (active);
    KZ = grdecl.PERMZ (active);

    rock.perm = [KX, KY, KZ];
    rock.perm = geomean(rock.perm, 2);  % [mD]
    
elseif all(reserv == 'Egg')
    
    mrstModule add deckformat

    f = fullfile('..', 'GAWPS', 'Models', 'EGG', 'Egg_Model_ECL.DATA');

    % Reading the input deck

    deck = readEclipseDeck(f);      
    deck = convertDeckUnits(deck);  % Convert to MRST units (SI)

    % Reading grid structure

    G = initEclipseGrid(deck); 
    G = computeGeometry(G);

    % Reading rock properties

    rock = initEclipseRock(deck);
    rock = compressRock(rock, G.cells.indexMap);

    rock.perm = convertTo(rock.perm,milli*darcy); % m^2 to mD
    rock.perm = geomean(rock.perm,2);
    
elseif all(reserv == 'Norne')
    
    f = fullfile('..', 'GAWPS', 'Models', 'Norne', {'G-NORNE.mat'; ...
             'rock-NORNE.mat'; 'grdecl-NORNE.mat'});

    load(f{1}, 'G');
    load(f{2}, 'rock');
    G = computeGeometry(G);

    rock.perm = convertTo(rock.perm,milli*darcy); % m^2 to mD
    rock.perm = geomean(rock.perm,2);
    
else
    
    error('The reservoir name is incorrect.')
    
end

%% Reservoir Mapping

[len, ~] = size(coord);

[ijk{1:3}] = ind2sub(G.cartDims, G.cells.indexMap(:));
ijk = [ijk{:}];

indw = [];
W = [];
gw = [];

for i = 1:len

    [I,J,K] = meshgrid(coord(i,1), coord(i,2), 1:G.cartDims(3));
    aux = find(ismember(ijk, [I(:), J(:), K(:)], 'rows'));
    indw = [indw aux];
    
    W = [W; addWell([], G, rock, aux)];
    gw = [gw; extractSubgrid(G, aux)];

end

for i = 1:len

    formatSpec = "W%d";
    str = compose(formatSpec, i);
    W(i).name = char(str);
    
end

%% Plots

figure
plotCellData(G, rock.poro, 'EdgeColor', 'none')
for i = 1:len
    
    plotWell(G, W(i,:), 'height', 60)
    
end
axis off
if all(reserv == 'SPE10')
    
    axis tight
    
end
colorbar
view(3)

figure
plotCellData(G, rock.perm, 'EdgeColor', 'none')
for i = 1:len
    
    plotWell(G, W(i,:), 'height', 60)
    
end
axis off
if all(reserv == 'SPE10')
    
    axis tight
    
end
colorbar
view(3)
