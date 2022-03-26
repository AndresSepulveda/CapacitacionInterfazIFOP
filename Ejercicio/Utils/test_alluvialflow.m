function test_alluvialflow(datain)
%% read data

%filename = datain;
%keyboard
%formato = '%f %f %f';

%n       = 1;% fila en la que comienzan los datos
%row_str = n - 1;% header lines

%data = fopen(filename);
%D    = textscan(data, formato, 'HeaderLines', row_str, 'Delimiter', '');
%fclose(data);


%data = [D{1} D{2}];
%etiquetas = [D{3}];

%datain=load('sankey_noauto.txt');
%datain=load(filename);

data = [datain(:,1) datain(:,2)];
etiquetas = datain(:,3);

%% 

% origen
clear left_labels
for i = unique(data(:,1))'
%    lg_labels{i} =  strcat(string(i), ' : ', string(etiquetas(i))); % labels para leyenda
    left_labels{i} =  strcat(string(i));% labels para figura
end

[aux,idx]=unique(data(:,1));

for i=1:length(aux)
     lg_labels{i} =  strcat(string(i), ' : ', string(etiquetas(idx(i))));
end

% destino
clear right_labels
for i = unique(data(:,2))'
    right_labels{i} =  strcat(string(i));% labels para figura
end
%right_labels=left_labels;  % Problems in sites with 100% self return

% matriz de valores origen-destino
clear auxdata
for i = unique(data(:, 1))'% filas izquierda
    for j = unique(data(:, 2))'% columnas derecha
        aux1 = data(:, 1);
        aux2 = data(:, 2);
        
        auxdata(i, j) = length(find(aux1 == i & aux2 == j));
    end
end

% porcentaje de cada etiqueta
clear auxper
for i = unique(data(:, 1))'% filas izquierda
    aux1 = data(:, 1);
    auxper{1}(i) =  round(length(find(aux1 == i))./length(aux1)*100);
end
for i = unique(data(:, 2))'% filas izquierda
    aux1 = data(:, 2);
    auxper{2}(i) =  round(length(find(aux1 == i))./length(aux1)*100);
end

% zonas al norte arriba
left_labels  = fliplr(left_labels);
lg_labels    = fliplr(lg_labels);
right_labels = fliplr(right_labels);

auxper{1} = fliplr(auxper{1});
auxper{2} = fliplr(auxper{2});

auxdata = flipud(auxdata);
auxdata = fliplr(auxdata);

data = auxdata;

%% figura

tname = '';% title name
borde = 100;% borde barra del texto en la figura

set(0,'defaultfigurecolor',[1 1 1])
H = figure('units', 'centimeters', 'Position', [5, 5, 30, 25],'visible','off');
ax = axes;
box off

alluvialflow(data, auxper, lg_labels, left_labels, right_labels, tname, borde);

% settings
ax.Position(3) = ax.Position(3)*0.8;

%ax.Legend.Title.String = 'Puntos';
%%%ax.Legend.Title.String = ['N = ', num2str(length(etiquetas))];
%%%lgpos = ax.Legend.Position;

%%%ax.Legend.Position(1) = lgpos(1) + lgpos(2)*0.4;


