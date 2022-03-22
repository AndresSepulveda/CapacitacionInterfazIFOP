#!/usr/bin/env python

import sys

import os
from datetime import datetime, timedelta
import numpy as np
import glob

#from opendrift.readers import reader_basemap_landmask
from opendrift.readers import reader_ROMS_native
from opendrift.models.oceandrift import OceanDrift

o = OceanDrift(loglevel=0)  # Set loglevel to 0 for debug information

filename_nc = 'croco_avg_15m_AntofValpo.nc';

mosa_native = reader_ROMS_native.Reader('/data2/matlab/IFOP/Data/' + filename_nc)
mosa_native.interpolation='linearND'

o.add_reader([mosa_native])
start_date = mosa_native.start_time
end_date   = mosa_native.end_time

o.set_config('general:use_auto_landmask', False)

#
# Posicion inicial
#
st_lons = []
st_lats = []

for filename in glob.glob('PuntosCosta_AV.txt'):
#for filename in glob.glob('TresPuntos.txt'):
#for filename in glob.glob('UnPunto.txt'):
          print(filename)
          with open(filename, 'r') as f:
             lines = f.readlines()
          for line in lines:
                  line_split = line.split()
                  st_lons.append(float(line_split[0]))
                  st_lats.append(float(line_split[1]))
                  f.close()

#st_lons=st_lons[::9]
#st_lats=st_lats[::9]

#
# Strading
#
#o.set_config('general:coastline_action', 'stranding')  # Se quiedan pegadas a la costa (Oil)
o.set_config('general:coastline_action', 'previous') # Vuelve al punto inicial (PelagicEgg)

#
# Simulacion
# Puntos iniciales y finales
#
num_particles = 10000

mindep = -40
maxdep = -60

zd = np.random.rand(num_particles)
zd = zd*(maxdep - mindep) + mindep

for i in range(2,12):

   ini_date=start_date+timedelta(days=i*30)
   print(ini_date)
   all = np.empty((0,7))
   paso = 1

   for lat, lon in zip(st_lats, st_lons):
            print(lat)
            print(lon)
            o.seed_elements(lon=lon,
               lat=lat,
               radius=2500,
               number=num_particles,
               time=ini_date,
               z=zd)

            lons_start = o.elements_scheduled.lon
            lats_start = o.elements_scheduled.lat
            time_start = o.elements_scheduled_time

            o.run(end_time=ini_date+timedelta(days=90),
                time_step=timedelta(minutes=180),
                export_variables=['status','time'])

            index_of_first, index_of_last = o.index_of_activation_and_deactivation()
            lons = o.get_property('lon')[0]
            lats = o.get_property('lat')[0]
            status = o.get_property('status')[0]
            tiempo = o.get_time_array()[0]

            lons_end = lons[index_of_last, range(lons.shape[1])]
            lats_end = lats[index_of_last, range(lons.shape[1])]
            status_end = status[index_of_last, range(lons.shape[1])]
            time_end   = [tiempo[i] for i in index_of_last]

            uno = np.column_stack([time_start, lons_start, lats_start, time_end, lons_end, lats_end, status_end])
            all = np.append(all, uno, axis = 0)

            paso = paso + 1

            print(all.shape)
   filename=""
   auxfilename=['Uniforme_IF_Obyo_10000_M',  str(i), '.txt']
   for s in auxfilename:
      filename += s
   print(filename)
   np.savetxt(filename, all, fmt='%s %.4f %.4f %s %.4f %.4f %i')

