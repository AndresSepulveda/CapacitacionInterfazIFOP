more off
warning off
close all
clear all
win_start
tic
%

%file_amerb='PuntosCosta_AV.txt';
%file_amerb='Hab_Rocoso_Coquimbo.txt';
file_amerb='PuntosCostaAncud.txt';

skip = 10;
radius = 2000;  % 2km for Coq/Ancud, 7km for AV

disp('Leer Sitios')
amers=load(file_amerb);

a_lat=amers(1:skip:end,2);
a_lon=amers(1:skip:end,1);

tabla=[];
quienconquien=[];

disp('Leer Datos')
tic

for ifile=1:13
    
%    file_prefix=['Inicial_1-10_Ancud_720_M',num2str(ifile),'_Lapa'];
    file_prefix=['Uniforme_1-10_Coquimbo_720_M',num2str(ifile),'_Lapa'];
%    file_prefix=['Uniforme_1-10_AV_720_M',num2str(ifile),'_Lapa'];


for ii=1:size(file_prefix,1)
num_lat_lon=[];

filename=file_prefix(ii,:);
nc=load([filename,'.txt']);

if ifile < 10
 prefix=['M0',num2str(ifile),'_',file_prefix(ii,:)];
else
 prefix=['M',num2str(ifile),'_',file_prefix(ii,:)];
end
% age_seconds              (traj,time)
% land_binary_mask
% lat
% lon
% z
% status
% time(time)

lonini=nc(:,3);
latini=nc(:,4);
lonend=nc(:,7);
latend=nc(:,8);
status=nc(:,9);
 
particulas_od=zeros(size(a_lat,1),size(a_lat,1));
not_stranded =zeros(4,size(a_lat,1));

l0=0; % Active
m0=0; % Missing_data
n0=0; % Retired
o0=0; % None

inicial_final=[];

for i=1:size(latini,1)  % Trayectorias

   aux_amers=zeros(length(a_lat),1);

   dista_ini=haversine(a_lat,a_lon,latini(i),lonini(i));
   dista_end=haversine(a_lat,a_lon,latend(i),lonend(i));

   if (min(dista_ini) < radius) && (min(dista_end) < radius)

   coord_ini=find(dista_ini == min(dista_ini));
   coord_end=find(dista_end == min(dista_end));
   end_status=status(i);
   
   if (end_status == 0)
      l0 = l0 +1;
      try
         particulas_od(coord_ini(1),coord_end(1))=particulas_od(coord_ini(1),coord_end(1))+1;
%         aux_inicial_final=[ini_lon,ini_lat,end_lon,end_lat,end_status];
%         inicial_final=[inicial_final; aux_inicial_final];
      catch
      end
      not_stranded(1,coord_ini(1)) = not_stranded(1,coord_ini(1))+1;
   end
   if (end_status == 1)
      aux_nll=[coord_ini(1),a_lat(coord_ini(1)),a_lon(coord_ini(1))];
      num_lat_lon=[num_lat_lon;aux_nll];
      try
         particulas_od(coord_ini(1),coord_end(1))=particulas_od(coord_ini(1),coord_end(1))+1;
%		 aux_inicial_final=["2000-05-30", "00:00:00", ini_lon,ini_lat,"2000-05-30", "00:00:00", end_lon,end_lat,end_status];
%         aux_inicial_final=[ini_lon,ini_lat,end_lon,end_lat,end_status];
%         inicial_final=[inicial_final; aux_inicial_final];
      catch
      end
      not_stranded(2,coord_ini(1)) = not_stranded(2,coord_ini(1))+1;
      m0=m0+1;
   end
   if (end_status == 2)
      n0 = n0 +1;
      not_stranded(3,coord_ini(1)) = not_stranded(3,coord_ini(1))+1;
   end
   if (end_status == 3)
      o0 = o0 +1;
      not_stranded(4,coord_ini(1)) = not_stranded(4,coord_ini(1))+1;
   end
end  % Radius
end  % Traj

disp('Totales')

prefix;

% l0  % Active
% m0  % Missing
% n0  % Retired
% o0  % none

tot=l0+m0+n0+o0;
%sum(sum(particulas_od))

aux_tabla=[ size(latini,1), l0,m0,n0,o0,tot,sum(sum(particulas_od))];

tabla=[tabla; aux_tabla];

normalized_particulas_od=particulas_od;

for j=1:size(a_lat,1)
   total_part=sum(normalized_particulas_od(j,:));
   if total_part==0
      normalized_particulas_od(j,:)= normalized_particulas_od(j,:)*0.0;
   else
      normalized_particulas_od(j,:)= (normalized_particulas_od(j,:)/total_part)*100;
   end
end
%
% Correccion de Daniel Brieva 22/03/2020
%

for jj=1:length(a_lat)
   auxqcq=[];
   aux_norm=normalized_particulas_od(jj,:);
   sort_norm=sort(aux_norm);
   bb=sum(normalized_particulas_od(jj,:));  % Must be 100
   auxqcq=[jj];
   for kk=length(a_lat):-1:length(a_lat)-2
      indx=find(aux_norm == sort_norm(kk));
      auxqcq=[auxqcq, indx(1), sort_norm(kk)];
   end
   quienconquien=[quienconquien; auxqcq];
end


toc
disp('Graficar') 
tic

f = figure('visible','off');
pcolor(normalized_particulas_od')
title([' Conectividad Normalizada'])
ylabel('Destino')
xlabel('Origen')
colormap(flipud(hot));
colorbar
print('-dpng',[prefix,'_MatrizConectiviadPotencial_Normalizada.png'])

f = figure('visible','off');
pcolor(particulas_od')
title([' Conectividad - # Particulas'])
ylabel('Destino')
xlabel('Origen')
colormap(flipud(hot));
colorbar
print('-dpng',[prefix,'_MatrizConectividadPotencial.png'])

f = figure('visible','off');
plotConfMat_as(fliplr(particulas_od)')
print('-dpng',[prefix,'_MatrizConectividadPotencial_valores.png'])

%f = figure('visible','off');
%aux_pod=particulas_od;
%%%indx=where(aux_pod > median(median(aux_pod)));   %% necesita Simulink
%indx=find(aux_pod > median(median(aux_pod)));
%aux_pod(indx)=median(median(aux_pod));
%pcolor(aux_pod')
%title(['Mitad inferior Conectividad - # Particulas'])
%ylabel('Destino')
%xlabel('Origen')
%colormap(flipud(hot));
%colorbar
%print('-dpng',[prefix,'_MatrizConectividadPotencial_lower50.png'])


f = figure('visible','off');
dia=diag(normalized_particulas_od);
hist(dia)
title([prefix,' - Autoreclutamiento'])
xlabel('Porcentaje')
ylabel('Numero de Sitios')
print('-dpng',[prefix,'_Histograma_Autoreclutamiento.png'])

toc

disp('Guardar Archivo') 
tic

filename=[prefix,'_Puntos_Inicial_Final.txt'];
dlmwrite(filename,inicial_final,'\t')

filename=[prefix,'_MatrizConectividadPotencial.txt'];
%
%  Save with format
%
fid = fopen(filename,'w+');
for i=1:size(particulas_od,1)
    for j=1:size(particulas_od,1)
        fprintf(fid,'%i ',particulas_od(i,j)');
    end
   fprintf(fid,'\n');
end
fclose(fid);
toc

end

aux_nll=sortrows(num_lat_lon,1);  %% NOT sort !
[~,indx,~]=unique(aux_nll(:,1),"first");
aux_nll=aux_nll(indx,:);

filename=[prefix,'_num_lat_lon.txt'];
fid = fopen(filename,'w+');
for i=1:size(aux_nll,1)
   fprintf(fid,'%i %.4f %.4f',aux_nll(i,:));
   fprintf(fid,'\n');
end
fclose(fid);

filename=[prefix,'_estadistica_particulas.txt'];
fid = fopen(filename,'w+');
for i=1:size(tabla,1)
   fprintf(fid,'%i %i %i %i %i %i %i',tabla(i,:));
   fprintf(fid,'\n');
end
fclose(fid);

filename=[prefix,'_tres_conexiones_particulas.txt'];  %%% changed to 10, where?
fid = fopen(filename,'w+');
for i=1:size(quienconquien,1)
   fprintf(fid,'%i %i %.1f %i %.1f %i %.1f',quienconquien(i,:));
   fprintf(fid,'\n');
end
fclose(fid);
toc

tic
%%keyboard
disp('Diagrama Sankey')
sankey_diagram([prefix,'_MatrizConectividadPotencial.txt'],file_amerb,prefix,skip)
toc
end % ifile
