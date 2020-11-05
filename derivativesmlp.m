function [df, indi] = derivativesmlp(G, S, F, ind, numb)
% Plot the derivative stratigraphic modified Lorenz plot and the clustering
% map of the well. The derivative modified Lorenz plot and depth-wise speed
% unit clustering are method to assist in the identification of hydraulic
% flow units.
% 
% SYNOPSIS:
%     [df, indi] = derivativesmlp(G, S, F, ind, numb) use the
%     classification of the authors of the flow units.
%
%     [df, indi] = derivativesmlp(G, S, F, ind, numb, intv) use the
%     classification of the flow units of the your choice.  
% 
% PARAMETERS:
%     G     - The struct containing the grid data.
%     S     - Array containing the storage capacity of the well
%             (respecting the stratigraphic sequence). 
%     F     - Array containing the flow capacity of the well (respecting
%             the stratigraphic sequence).
%     ind   - The well indices.
%     numb  - Number of partitions.
%     intv  - Intervals for flow units classification (ex.: [0.1, 0.5, 1]).
% 
% RETURNS:
%     df   - Array containing the slopes obtained.
%     indi - The inflection points of the plot. 
%     
% SEE ALSO:
%     resmodel, winland, classiclorenz, stratigraphiclorenz,
%     modifiedlorenz, flowcapacity, normalizedrqi, normalprobability,
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

[~, len] = size(S); % Number of Wells

% Properties

dx = [];
dy = [];

for i = 1:len
    
    aux1 = gradient(S(:,i));
    aux2 = gradient(F(:,i));
    dx = [dx aux1];
    dy = [dy aux2];

end

df = dy./dx;
df = df(2:end,:);

H = G.cells.centroids(:,3);
H = H(ind); % Depth

clear aux1 aux2 i dx dy

% Clustering

[B,I] = sort(df, 'descend');
idx = [];

j = 1:(length(H) - 1);
k = 1:length(df);
indi = [];

for i = 1:len
    
    [aux, ~] = kmeans([k(:),df(:,i)], numb, 'Start', [I(1:numb,i), B(1:numb,i)]);
    aux2 = find(aux(j) ~= aux(j+1));
    
    if length(aux2) ~= (numb - 1)
        
        error('This well has a clustering problem.')
        
    end
    
    idx = [idx, aux];
    indi = [indi, aux2];

end

indi = indi + 1;

clear B I i j aux aux2 h

%% Average Values

% Indices

indt = [ones(1, len); indi];
indt = [indt; ones(1,len)*length(S(:,1))];

% Average Values

dfmean_fu = zeros(numb,len);

for j = 1:len
    
    for i = 1:numb
        
        dfmean_fu(i,j) = mean(df(indt(i,j):(indt(i+1,j)-1),j));
        
    end
    
end

indt(1,:) = 0;

C = zeros(numb, len);
C = num2cell(C);

dindt = diff(indt);

for j = 1:len
    
    for i = 1:numb
        
        C{i,j} = zeros(dindt(i,j),1) + dfmean_fu(i,j);
        
    end
    
end

dfmean_cells = cell2mat(C);
dfmean_cells = dfmean_cells(2:end,:);

i = 1:(numb - 2);

I = zeros(numb, len);

for j = 1:len
    
    aux = mean([indi(i,j), indi(i+1,j)-1], 2);
    I(2:(end-1),j) = aux;
    I(1,j) = mean([1, indi(1,j)-1]);
    I(end,j) = mean([indi(end,j), length(H)]);
    
end

aux1 = floor(I);
aux2 = ceil(I);

hmean = [];
dfmean = [];

for j = 1:len
    
    aux3 = H(aux1(:,j),j);
    aux4 = H(aux2(:,j),j);
    aux5 = dfmean_cells(aux1(:,j),j);
    aux6 = dfmean_cells(aux2(:,j),j);
    
    hmean = [hmean, mean([aux3, aux4], 2)];
    dfmean = [dfmean, mean([aux5, aux6], 2)];
    
end

clear aux1 aux2 aux3 aux4 aux5 aux6 aux C dindt i j dfmean_cells dfmean_fu

%% Plots

str1 = [];

for i = 1:len

    formatSpec = "W%d";
    aux = compose(formatSpec, i);
    str1 = [str1; aux];
    
end

str2 = [];

for i = 1:numb

    formatSpec = "$R^{(%d)}$";
    aux = compose(formatSpec, i);
    str2 = [str2; aux];
    
end

figure
for i = 1:len

    stairs(H(:,i), df(:,i));
    hold on
    
end
% title('Derivative Stratigraphic Modified Lorenz Plot')
legend(str1, 'Location', 'northeast')
xlim([min(H, [], 'all'), max(H, [], 'all')])
xlabel('Depth [m]')
ylabel('RPS')
grid

str2 = [str2; 'Average'];

for i = 1:len
    
    figure
    gscatter(H(:,i), df(:,i), idx(:,i))
    hold on
    s = stem(hmean(:,i), dfmean(:,i), 'sk');
    set(s, 'MarkerFaceColor', 'k')
    title(str1(i))
    legend(str2, 'Interpreter', 'latex', 'Location', 'northeast')
    xlabel('Depth [m]')
    ylabel('RPS')
    xlim([min(H(:,i), [], 'all'), max(H(:,i), [], 'all')])
    grid
    
end