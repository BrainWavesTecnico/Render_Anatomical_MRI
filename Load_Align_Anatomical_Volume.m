function [MRI_signal, voxel_size, nii_info] = Load_Align_Anatomical_Volume(file_path)
%LOAD_ALIGN_ANATOMICAL_VOLUME Load a NIfTI volume aligned to canonical axes
%   Aligns array dimensions to dim1=sag(L-R), dim2=cor(A-P), dim3=ax(S-I)
%   using the header's affine transform, so different scans (e.g. axial
%   T2 vs sagittal T1) are indexed the same way regardless of how each
%   was originally acquired/stored.

nii_info=niftiinfo(file_path);
MRI_signal=niftiread(nii_info);

R=nii_info.Transform.T(1:3,1:3);
[~, voxel_axis_for_world]=max(abs(R),[],1);
world_axis_sign=sign(R(sub2ind(size(R), voxel_axis_for_world, 1:3)));

MRI_signal=permute(MRI_signal, voxel_axis_for_world);
voxel_size=nii_info.PixelDimensions(voxel_axis_for_world);

for d=1:3
    if world_axis_sign(d)<0
        MRI_signal=flip(MRI_signal,d);
    end
end

end
