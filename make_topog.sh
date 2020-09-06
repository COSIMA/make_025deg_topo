#!/usr/bin/env sh
#PBS -P v45
#PBS -q normal
#PBS -l walltime=10:00:00,mem=4GB
#PBS -l wd
#PBS -lstorage=scratch/v45+gdata/hh5
module load netcdf
module load nco
module use /g/data/hh5/public/modules
module load conda/analysis3

set -x
set -e

# ocean_mask.nc sets the land mask in kmt.nc and topography

cp -L --preserve=timestamps /g/data/ik11/inputs/access-om2/input_20200530/mom_025deg/ocean_mask.nc ocean_mask_original.nc
cp -L --preserve=timestamps /g/data/ik11/inputs/access-om2/input_20200530/mom_025deg/ocean_hgrid.nc .
cp -L --preserve=timestamps /g/data/ik11/inputs/access-om2/input_20200530/mom_025deg/ocean_vgrid.nc .
cp -L --preserve=timestamps /g/data/ik11/inputs/access-om2/input_20200530/mom_025deg/ocean_mosaic.nc .
cp -L --preserve=timestamps /g/data/ik11/inputs/access-om2/input_20200530/mom_025deg/grid_spec.nc .
ln -sf grid_spec.nc mosaic.nc
ln -sf /g/data/hh5/tmp/cosima/bathymetry/gebco.nc gebco_2014_rot.nc

cd topogtools
./build.sh
cd -

./topogtools/editTopo.py --overwrite --nogui --apply ocean_mask_edits.txt --output ocean_mask.nc ocean_mask_original.nc mask  # see https://github.com/COSIMA/access-om2/issues/210
./topogtools/float_vgrid  # this overwrites ocean_vgrid.nc
# ./topogtools/gen_topo  # generates topog_new.nc; takes about 2 hours at 0.25 deg, so must be run via qsub of this script
./topogtools/editTopo.py --overwrite --nogui --apply topog_edits.txt --output topog_new_edited.nc topog_new.nc
./topogtools/deseas topog_new_edited.nc topog_new_edited_deseas.nc  # remove seas
cp topog_new_edited_deseas.nc topog_new_edited_deseas_partialcell.nc
./topogtools/do_partial_cells topog_new_edited_deseas_partialcell.nc 1.0 0.2  # this overwrites its input, so we make copy in prev line
./topogtools/min_max_depth topog_new_edited_deseas_partialcell.nc topog_new_edited_deseas_partialcell_mindepth.nc 4  # can produce non-advective cells
./topogtools/apply_mask.py topog_new_edited_deseas_partialcell_mindepth.nc ocean_mask.nc topog_new_edited_deseas_partialcell_mindepth_masked.nc  # applies ocean_mask.nc
./topogtools/fix_nonadvective_mosaic topog_new_edited_deseas_partialcell_mindepth_masked.nc topog_new_edited_deseas_partialcell_mindepth_masked_fixnonadvective.nc  # automatically fix non-advective cells
./topogtools/check_nonadvective_mosaic topog_new_edited_deseas_partialcell_mindepth_masked_fixnonadvective.nc
cp topog_new_edited_deseas_partialcell_mindepth_masked_fixnonadvective.nc topog.nc
ncrename -O -v mask,kmt ocean_mask.nc kmt.nc  # make CICE mask kmt.nc from ocean_mask.nc
