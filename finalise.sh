#!/usr/bin/env sh
# Commit changes and push, then add metadata to note how changes were made 

module load nco
module load git

set -x
set -e

git commit -am "update"
git push

cp topog_new_deseas_partialcell_mindepth_masked_fixnonadvective.nc topog.nc
ncatted -O -h -a history,global,a,c," | Created on $(date) using https://github.com/COSIMA/make_025deg_topo/tree/$(git rev-parse --short HEAD)" topog.nc
ncatted -O -h -a history,global,a,c," | Updated on $(date) using https://github.com/COSIMA/make_025deg_topo/tree/$(git rev-parse --short HEAD)" ocean_mask.nc
ncatted -O -h -a history,global,a,c," | Created on $(date) using https://github.com/COSIMA/make_025deg_topo/tree/$(git rev-parse --short HEAD)" kmt.nc
ncatted -O -h -a history,global,a,c," | Updated on $(date) using https://github.com/COSIMA/make_025deg_topo/tree/$(git rev-parse --short HEAD)" ocean_vgrid.nc
