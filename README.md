# Render_Anatomical_MRI

MATLAB scripts to plot slices from anatomical MRI volumes (NIfTI, `.nii`/`.nii.gz`).

## Requirements

- MATLAB with the Image Processing Toolbox (`niftiread`, `niftiinfo`, `imresize`, `imresize3`).

## Scripts

### `Anatomical_MRI.m`

Plots a montage of evenly-spaced slices, in one chosen anatomical plane, for every scan
matching `scan_name` found under `general_path`. Saves one JPEG per scan at 600 DPI.

Edit the variables at the top before running:

- `general_path` — root folder to search for NIfTI files, and where `Anatomical_MRI_Images/`
  output subfolder is expected to exist.
- `scan_name` — substring used to match scan filenames (e.g. `'t1_mprage'`).
- `Choose_plane` — `1` (sagittal), `2` (coronal) or `3` (axial).
- `colormap_name` — any MATLAB colormap name (e.g. `'jet'`, `'parula'`, `'hot'`, `'gray'`).
  Set this instead of using the interactive Colormap Editor, which is unreliable.
- `n_rows` / `n_collumns` — montage grid size.

Each subplot is titled with the slice's original voxel index (`s=<n>`) along the chosen
axis, so it can be used to pick a slice number for `Plot_Single_Slice.m`.

### `Plot_Single_Slice.m`

Plots and saves a single slice, chosen by scan name, plane and slice number. Saves as
`<scan-filename>_<plane>_slice<n>.jpeg` at 600 DPI.

Edit the variables at the top before running:

- `general_path`, `scan_name`, `colormap_name` — same as above.
- `plane_name` — `'sag'`, `'cor'` or `'ax'`.
- `slice_number` — original voxel index along that axis (matches the numbers shown by
  `Anatomical_MRI.m`).

### Helper functions

- `Load_Align_Anatomical_Volume.m` — loads a NIfTI file and reorients it to a canonical
  axis order (dim1=sagittal/L-R, dim2=coronal/A-P, dim3=axial/S-I) using the header's
  affine transform, so array dimensions map to the same anatomical direction regardless
  of how each scan was originally acquired/stored (e.g. axial T2 vs. sagittal T1).
- `Extract_Anatomical_Slice.m` — extracts one 2D slice and resizes it (bicubic, 4x
  upsampled by default) to correct in-plane voxel anisotropy and smooth out visible
  voxel edges for display, without changing the slice's voxel index.
- `subplot_tight.m` — third-party helper for near-zero-margin subplot grids.

## Output

Both scripts save JPEGs at 600 DPI into `<general_path>/Anatomical_MRI_Images/`. Create
that subfolder before running if it doesn't already exist.
