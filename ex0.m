% GAWPS - Graphical Analysis for Well Placement Strategy
% Model SPE10 (30,65,:) and (48,100,:)

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

clear
close all
clc

%% Read and Process of Synthetic Model

coord = [30,65; 48,100];

[G, gw, rock, indw] = resmodel(coord, 'SPE10');

%% Petrophysics Methods 

% Winland Plot

wp = winland(rock.poro, rock.perm, indw);

% Classical Lorenz Plot

[lp.F, lp.Lc] = classiclorenz(G, rock.perm, indw);

% Stratigraphic Modified Lorenz Plot

[smlp.S, smlp.F] = stratigraphiclorenz(G, rock.poro, rock.perm, indw);

% Modified Lorenz Plot

[ssp.df, ssp.indi] = derivativesmlp(G, smlp.S, smlp.F, indw, 10);

[mlp.S, mlp.F, mlp.FUS, mlp.categ] = modifiedlorenz(smlp.S, smlp.F, gw, ...
    ssp.indi);

% Normalized Cumulative Flow Capacity

ncfc = flowcapacity(G, rock.perm, indw);

% Normalized RQI

nrqi = normalizedrqi(G, rock.poro, rock.perm, indw);

% Histogram and Normal Probability Plot

fzi = normalprobability(rock.poro, rock.perm, indw);

% Log-Normal Permeability Distribution

[dp.Ks, dp.P, dp.Vk] = dykstraparsons(rock.perm, indw);