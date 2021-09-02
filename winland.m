function wp = winland(poro, perm, ind)
% Calculates the Winland plot of the well.
% The Winland plot is a method for characterizing wells in a hydrocarbon
% reservoir and carryin out rock typing.
% 
% SYNOPSIS:
%     wp = winland(rock.poro, rock.perm, ind)
% 
% PARAMETERS:
%     rock.poro - porosity field.
%     rock.perm - permeability field.
%     ind       - well indices.
% 
% RETURNS:
%     wp - array containing data from the winland plot.
%     
% SEE ALSO:
%     classiclorenz, stratigraphiclorenz, modifiedlorenz, flowcapacity,
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

% Radius size calculation

wp.r35 = 10.^(0.732 + 0.588*log10(perm(ind)*(10^-3)) - ...
    0.864*log10(poro(ind)));

% Classification

for i = 1:len

    wp.mega{i} = find(wp.r35(:,i) > 10);
    wp.macro{i} = find(wp.r35(:,i) <= 10 & wp.r35(:,i) > 2.5);
    wp.meso{i} = find(wp.r35(:,i) <= 2.5 & wp.r35(:,i) > 0.5);
    wp.micro{i} = find(wp.r35(:,i) <= 0.5 & wp.r35(:,i) > 0.2);
    wp.nano{i} = find(wp.r35(:,i) <= 0.2);

end

% Isoradius Lines

wp_poro = 0:0.001:0.45;
k_iso100 = 1000*exp((250*log(10)*((108*log(wp_poro))/(125*log(10)) ...
    + log(10)/log(10) - 183/250))/147);
k_iso25 = 1000*exp((250*log(10)*((108*log(wp_poro))/(125*log(10)) ...
    + log(2.5)/log(10) - 183/250))/147);
k_iso05 = 1000*exp((250*log(10)*((108*log(wp_poro))/(125*log(10)) ...
    + log(0.5)/log(10) - 183/250))/147);
k_iso02 = 1000*exp((250*log(10)*((108*log(wp_poro))/(125*log(10)) ...
    + log(0.2)/log(10) - 183/250))/147);

%% Plot

str = [];

for i = 1:len

    formatSpec = "W%d";
    aux = compose(formatSpec, i);
    str = [str; aux];
    
end

str2 = {'R_{35} = 10 \mum'; 'R_{35} = 2.5 \mum'; 'R_{35} = 0.5 \mum'; ...
    'R_{35} = 0.2 \mum'};
str2 = convertCharsToStrings(str2);
str = [str; str2];

clear str2

figure
for i = 1:len
    
    sly = semilogy(poro(ind(:,i)), perm(ind(:,i)), 's');
    set(sly, 'MarkerFaceColor', sly.Color)
    hold on
    
end
semilogy(wp_poro,k_iso100, wp_poro,k_iso25, wp_poro,k_iso05, wp_poro,k_iso02)
% title('Winland Plot')
xlabel('Porosity')
ylabel('Permeability [mD]')
legend(str, 'Location', 'southeast')
grid
