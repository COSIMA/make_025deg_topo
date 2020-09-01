# make_025deg_topo
Make 0.25 degree `topog.nc` MOM bathymetry file.

`./make_topog.sh` will generate topography and associated files. For 0.25deg resolution and higher this will require `qsub`.

When the output files are to your satisfaction, commit and push your changes and add the git commit hash as metadata in the output .nc files by running `finalise.sh`.

You can then copy them to `input_rc` using `copy_to_input_rc.sh`.
