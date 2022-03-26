function sankey_diagram(filename,puntos,prefix,skip)

%
% filename es el archivo con la matriz de conectividad potencial
% puntos es el archivo con el listado de las AMERB
%
particulas_od=load(filename);

total_particles=sum(sum(particulas_od));
totpart=[num2str(total_particles), ' particulas'];
disp(totpart)

tot_calc=total_particles;

amerb =load(puntos);

a_lat=amerb(1:skip:end,2);
a_lon=amerb(1:skip:end,1);

skip2=1;   % Places
skip3=1;   % Particles

disp('Start Sankey')
    sankey=[];
    m=1;
    n=1;
    for i=1:skip2:size(particulas_od,1)
        for j=1:skip2:size(particulas_od,1)
            if particulas_od(i,j) > 0
                for k=1:skip3:particulas_od(i,j)
                    sankey(m,1)=i;
                    sankey(m,2)=j;
                    sankey(m,3)=a_lat(i);
                    m=m+1;
                    perce=round((m/tot_calc)*100);
                    if (mod(perce,10) == 0)
                        avance=[num2str(perce),' %'];
                        disp(avance)
                    end    
                end
            end
        end
    end    
    
    san_file=[prefix,'_Sankey_',num2str(m),'_particulas'];
    fname=[san_file, '.txt'];
    save(fname,'sankey','-ascii')

    f = figure('visible','off');
    test_alluvialflow(sankey);
    print('-dpng',[san_file,'.png'])
   
    %
    %  No autocorrelation. Avoid particles that return to the same AMERB
    %
    sankey_noauto=sankey;
    indx_s=find(sankey_noauto(:,1) == sankey_noauto(:,2));
    sankey_noauto(indx_s,:)=[];
    aux_totnon=size(sankey_noauto,1);

    san_noa_file=[prefix,'_Sankey_NOA_',num2str(aux_totnon),'_particulas'];
    fname=[san_noa_file, '.txt'];
    save(fname,'sankey','-ascii')
    
    f = figure('visible','off');
    test_alluvialflow(sankey_noauto);
    print('-dpng',[san_noa_file,'.png'])

    whos sankey sankey_noauto
    
    disp(totpart)
    totnon=[num2str(aux_totnon),' particulas noauto'];
    disp(totnon)
        
