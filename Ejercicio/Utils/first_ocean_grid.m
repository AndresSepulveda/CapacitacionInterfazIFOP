%% Posicion grilla mas cercana a la costa 

% el script podria fallar si hay un lago en tierra, no revisé que pasa en 
% ese caso

% la linea de frontera se hace buscando el vecino mas cercano del ultimo
% punto encontrado, en el caso de este ejemplo parto con latitud que esta
% mas al sur. Hay que fijarse en el dominio y que esta grilla inicial sea 
% un extremo, si no es posible, se puede probar con la latitud mas al 
% norte, longitud más al oeste o longitud más al este.   

close all
clear all;clc
win_start

%nfile='.\CROCO_FILES\IFOP_Ancud\croco_grd.nc.2';% nombre del archivo
nfile='.\CROCO_FILES\IFOP_Coq\croco_grd.nc';% nombre del archivo
%nfile='.\CROCO_FILES\IFOP_Coq\croco_grd.nc.1';% nombre del archivo

lat=ncread(nfile,'lat_psi');% latitud 2D
lon=ncread(nfile,'lon_psi');% longitud 2D

lati=double(lat(1,:))';% latitud 1D
loni=double(lon(:,1));% longitud 1D

mask=ncread(nfile,'mask_psi');% mask valores 0/1

% busco grillas cerca de la linea de costa
olon=[];
olat=[];

% por lonngitud
for i=1:size(lon,1)
    aux=mask(i,:);
    olon=[olon lon(i,[strfind(aux,[1 0])+1])];
    olat=[olat lat(i,[strfind(aux,[1 0])+1])];    
    
    olon=[olon lon(i,[strfind(aux,[0 1])+1])];
    olat=[olat lat(i,[strfind(aux,[0 1])+1])];    
end

% por latitud
for i=1:size(lon,2)
    aux=mask(:,i);
    olon=[olon lon([strfind(aux',[1 0])+1],i)'];
    olat=[olat lat([strfind(aux',[1 0])+1],i)'];    
    
    olon=[olon lon([strfind(aux',[0 1])+1],i)'];
    olat=[olat lat([strfind(aux',[0 1])+1],i)'];    
end

% quito grillas repetidas
grids=[olon' olat'];
ugrids=unique(grids,'rows');

% ordeno las grillas para crear una linea
data=[ugrids];
dist=pdist2(data,data);

N = size(data,1);
result = NaN(1,N);

% *hay que seleccionar uno de los 4 de abajo:

aux=min(data(:,2));% estoy ordenando la linea a partir de la latitud mas al sur!!!
aux2= find(data(:,2)==aux);

% aux=max(data(:,2));% estoy ordenando la linea a partir de la latitud mas al norte!!!
% aux2= find(data(:,2)==aux);

% aux=min(data(:,1));% estoy ordenando la linea a partir de la longitud mas al oeste!!! 
% aux2= find(data(:,1)==aux);

% aux=max(data(:,1));% estoy ordenando la linea a partir de la longitud mas al este!!!
% aux2= find(data(:,1)==aux);

result(1)=aux2(1);

for ii=2:N
    dist(:,result(ii-1))=Inf;
    [~, closest_idx]=min(dist(result(ii-1),:));
    result(ii)=closest_idx;
end

ugg=[];
for i=1:length(result)
ugg(i,:)=ugrids(result(i),:);
end

indx=find(ugg(:,1) < -69);

lon_grillasmascercanas=ugg(indx,1);
lat_grillasmascercanas=ugg(indx,2);

lonlats = [(floor(100*ugg(indx,1)))/100 (floor(100*ugg(indx,2)))/100];

dlmwrite('PuntosCosta.txt',lonlats,'precision','%.3f','delimiter',' ')
%save -ascii PuntosCosta.txt lonlats

% figura
figure
subplot(1,2,1)
m_proj('lambert','long',[min(loni) max(loni)],'lat',[min(lati) max(lati)]);
m_pcolor(loni,lati,mask')
hold on
m_grid('linest',':','tickdir','out');

subplot(1,2,2)
m_proj('lambert','long',[min(loni) max(loni)],'lat',[min(lati) max(lati)]);
m_pcolor(loni,lati,mask')
hold on
m_grid('linest',':','tickdir','out');
m_plot(lon_grillasmascercanas,lat_grillasmascercanas,'rs','markerfacecolor','r','markersize',4)
