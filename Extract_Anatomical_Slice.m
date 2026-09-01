function slice_img = Extract_Anatomical_Slice(MRI_signal, voxel_size, plane, slice_number)
%EXTRACT_ANATOMICAL_SLICE Get one 2D slice, resized to correct in-plane anisotropy
%   plane: 1=sag, 2=cor, 3=ax. slice_number is the original voxel index
%   along that axis of the aligned (un-resampled) volume, as returned by
%   LOAD_ALIGN_ANATOMICAL_VOLUME.

if plane==1
    slice_img=squeeze(MRI_signal(slice_number,:,:))';
elseif plane==2
    slice_img=squeeze(MRI_signal(:,slice_number,:))';
elseif plane==3
    slice_img=squeeze(MRI_signal(:,:,slice_number))';
else
    error('plane must be 1 (sag), 2 (cor) or 3 (ax)');
end

% slice_img rows follow other_dims(2), columns follow other_dims(1)
other_dims=setdiff([1 2 3],plane);
row_pixel_size=voxel_size(other_dims(2));
col_pixel_size=voxel_size(other_dims(1));
target_pixel_size=min(row_pixel_size,col_pixel_size);

new_img_size=round(size(slice_img).*[row_pixel_size col_pixel_size]/target_pixel_size);
slice_img=imresize(slice_img,new_img_size,'bilinear');

end
