 %
%   Andres Sepulveda (andres.sepulveda@gmail.com) 04/2021
%
more off
warning off
close all
clear all

%pkg load octcdf

disp('Leer Datos')
tic

%%file_prefix=['Erizo_Coquimbo_Uniforme_20000601_to_20001030'];   % 0  1  2  3
%%	plot_title='Erizo Coquimbo Uniforme';                   % active seeded_on_land missing_data retired
%%file_prefix=['Lapa_Coquimbo_Uniforme_20000801_to_20000910'];   % 0  1  2  3
%%	plot_title='Lapa Coquimbo Uniforme';                   % active seeded_on_land missing_data retired
%%file_prefix=['Loco_Coquimbo_Uniforme_20000601_to_20001030'];   % 0  1  2  3
%%	plot_title='Loco Coquimbo Uniforme';                   % active seeded_on_land missing_data retired
%%file_prefix=['Macha_Coquimbo_uniforme_20000601_to_20001030'];   % 0  1  2  3
%%	plot_title='Macha Coquimbo Uniforme';                   % active seeded_on_land missing_data retired



%     ANCUD 
%file_prefix=['Lapa_Ancud_Uniforme_20000801_to_20001210'];   % 0  1  2  3   %% skip=200
%	plot_title='Lapa Ancud Uniforme';                   % active seeded_on_land missing_data retired
%file_prefix=['Erizo_Ancud_Uniforme_20000901_to_20010330'];   % 0  1  2  3
%	plot_title='Erizo Ancud Uniforme';                   % active seeded_on_land missing_data retired
file_prefix=['Loco_Ancud_Uniforme_20000601_to_20000913'];   % 0  1  2  
	plot_title='Loco Ancud Uniforme';                   % active missing_data retired
file_prefix=['Loco_Ancud_Uniforme_20000601_to_20001030'];   % 0  1  2  
	plot_title='Loco Ancud Uniforme';                   % active missing_data retired




prefix=file_prefix(1,:)
nc=netcdf(['/data2/matlab/Trond/Output/',prefix,'.nc'],'r');
status_id1=nc{'status'}.flag_values
status_id2=nc{'status'}.flag_meanings

% age_seconds              (traj,time)
% land_binary_mask
% lat
% lon
% z
% status
% time(time)


rango = [13]; % 80 160 320 640] ; %  Lapa_Agosto_Coquimbo

r = 1;


for skip = rango

	cuenta = 0;
        all_to_r = [];

	disp([' '])
	disp([' *******************************' ])
	disp([' '])
	disp(['skip =  ',num2str(skip)])
	num_lat_lon=[];

%%        complete_lat=nc{'lat'}(:,:);
%%	size(complete_lat)

	lat=nc{'lat'}(1:skip:end,:);
	lon=nc{'lon'}(1:skip:end,:);
	status=nc{'status'}(1:skip:end,:);
	tiempo=nc{'time'}(:);

	disp(['Rangos trayectorias'])
	min(min(lat))
	max(max(lat(lat < 90)))
	min(min(lon))
	max(max(lon(lon < 180)))

%%        aux_conecta=1;
%%	indx_conecta=1:skip:size(complete_lat,1);

	toc
	disp('Extraer Maximo/Minimo')
	tic
 
	for i=1:size(lat,1)  % Trayectorias
	   aux_lat=lat(i,:);
	   aux_lat(aux_lat > 90)=[]; %Land particles, edges?
	   if size(aux_lat) >  0
		
	      ini_lat=aux_lat(1);
	      end_lat=aux_lat(end);
	%
	%  Longitud
	%
	      aux_lon=lon(i,:);
	      indx_lon=find(aux_lon > 180);
	      aux_lon(indx_lon)=[];
	      ini_lon=aux_lon(1); 
	      end_lon=aux_lon(end);
	%
	%  Status
	%
	      aux_status=status(i,:);  %  0 - Active 1 - Seeded_on_Land 2 - Missing_data 3 - Retired
	      aux_status(indx_lon)=[];
	      end_status=aux_status(end);
	%
	%   Tiempo
	%
	      aux_time=tiempo;
	      aux_time(indx_lon)=[];
	      ini_tiempo=aux_time(1);
	      end_tiempo=aux_time(end);
   
%%	      sel_part=indx_conecta(aux_conecta); 
%%	      aux_conecta = aux_conecta + 1;
             

%%	      aux_r = [sel_part ini_tiempo end_tiempo ini_lat ini_lon end_lat end_lon end_status];
	      aux_r = [ini_tiempo end_tiempo ini_lat ini_lon end_lat end_lon end_status];
	      all_to_r = [all_to_r; aux_r ];
              cuenta = cuenta + 1;
	   end % if
	end % trajectories

	whos  all_to_r

	outfile=[file_prefix,'_',num2str(skip),'.nc'];

	ncnew=netcdf(outfile,'c');

	ncnew('trajectory') = cuenta;

%%	ncnew{'sel_part'}  = ncdouble('trajectory');
%%	ncnew{'sel_part'}(:) = all_to_r(:,1);
	ncnew{'ini_time'}  = ncdouble('trajectory');
	ncnew{'ini_time'}(:) = all_to_r(:,1);
	ncnew{'end_time'}  = ncdouble('trajectory');
	ncnew{'end_time'}(:) = all_to_r(:,2);
	ncnew{'ini_lat'}  = ncdouble('trajectory');
	ncnew{'ini_lat'}(:) = all_to_r(:,3);
	ncnew{'ini_lon'}  = ncdouble('trajectory');
	ncnew{'ini_lon'}(:) = all_to_r(:,4);
	ncnew{'end_lat'}  = ncdouble('trajectory');
	ncnew{'end_lat'}(:) = all_to_r(:,5);
	ncnew{'end_lon'}  = ncdouble('trajectory');
	ncnew{'end_lon'}(:) = all_to_r(:,6);
	ncnew{'end_status'}  = ncdouble('trajectory');
	ncnew{'end_status'}(:) = all_to_r(:,7);
        close(ncnew)

end % skip


