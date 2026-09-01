%%%%%
%
%  Plot and save a single anatomical MRI slice, chosen by scan name,
%  plane and slice number.
%
%%%%%%%%%%%

general_path='/Users/user/Documents/Research/CSF-MIND';
addpath(genpath(general_path))

scan_name='t1_mprage';   % substring identifying the scan file
plane_name='sag';        % 'sag', 'cor' or 'ax'
slice_number=100;        % original voxel index along that axis

%%
plane_names={'sag','cor','ax'};
plane=find(strcmpi(plane_name,plane_names));
if isempty(plane)
    error('plane_name must be one of ''sag'', ''cor'' or ''ax''');
end

file_names = dir(fullfile(general_path, ['/**/*' scan_name '*.nii*']));
if isempty(file_names)
    error('No file found matching scan_name "%s"', scan_name);
elseif numel(file_names)>1
    warning('%d files match scan_name "%s"; using the first one: %s', ...
        numel(file_names), scan_name, file_names(1).name);
end
file_names=file_names(1);

[MRI_signal, voxel_size]=Load_Align_Anatomical_Volume([file_names.folder '/' file_names.name]);

n_slices=size(MRI_signal,plane);
if slice_number<1 || slice_number>n_slices
    error('slice_number must be between 1 and %d for plane "%s"', n_slices, plane_name);
end

Image_thres=mean(single(MRI_signal(:)))+3*std(single(MRI_signal(:)));

slice_img=Extract_Anatomical_Slice(MRI_signal, voxel_size, plane, slice_number);

figure('Color','k','Name',file_names.name)
colormap(jet)
imagesc(slice_img,[0 Image_thres]);
axis image
axis xy
axis off

scan_base_name=regexprep(file_names.name,'\.nii(\.gz)?$','');
output_name=sprintf('%s_%s_slice%d.jpeg', scan_base_name, plane_name, slice_number);
print(gcf,[general_path '/Anatomical_MRI_Images/' output_name],'-djpeg','-r600');
