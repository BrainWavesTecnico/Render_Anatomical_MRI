%function Anatomical_MRI

%%%%%
%
%  Choose the scan
%  Load the anatomical data and make plots.
%  Generate Figure
%
%  scripts by Joana Cabral, September 2026
%  joanabcabral@tecnico.ulisboa.pt
% 
%
%%%%%%%%%%%

general_path='/Users/user/Documents/Research/CSF-MIND';
addpath(genpath(general_path))
scan_name='t1_mprage';

% Find the fMRI scan in format .nii with these properties in the NIFTI folder
file_names = dir(fullfile(general_path, ['/**/*' scan_name '*.nii*']));

%%
n_rows=4;
n_collumns=8;


% Choose plane to plot  
Choose_plane=1; % %1--> sag,2--> cor, 3--> ax

%%
n_scans=length(file_names);

for scan=1:n_scans
    
    nii_info=niftiinfo([file_names(scan).folder '/' file_names(scan).name]);
    MRI_signal=niftiread(nii_info);

    Image_thres=mean(single(MRI_signal(:)))+3*std(single(MRI_signal(:)));

    figure('Color','k','Name',file_names(scan).name)
    colormap(jet)

    [X_size, Y_size, Z_size]=size(MRI_signal);
    voxel_size=nii_info.PixelDimensions(1:3);

    % Resample to isotropic voxels using the real voxel spacing (mm),
    % so slice counts reflect true anatomy instead of raw, possibly
    % anisotropic, voxel counts per axis
    iso_voxel_size=min(voxel_size);
    iso_size=round([X_size, Y_size, Z_size].*voxel_size/iso_voxel_size);

    MRI_signal=imresize3(MRI_signal,iso_size,'Method','linear');

    % Pad (not stretch) to a cube so every orientation has the same
    % number of slices to plot, without distorting the anatomy
    max_resolution=max(iso_size);
    pad_before=floor((max_resolution-iso_size)/2);
    pad_after=(max_resolution-iso_size)-pad_before;
    MRI_signal=padarray(MRI_signal,pad_before,0,'pre');
    MRI_signal=padarray(MRI_signal,pad_after,0,'post');

    n_slices=max_resolution;

    slices=1:ceil(n_slices/n_collumns/n_rows):n_slices;
    
    for s=1:length(slices)
        
        subplot_tight(n_rows,n_collumns,s,0.001)
        
        if Choose_plane==1
        
        imagesc(squeeze(MRI_signal(slices(s),:,:))',[0 Image_thres]);
        elseif Choose_plane==2
        imagesc(squeeze(MRI_signal(:,slices(s),:))',[0 Image_thres]);
        elseif Choose_plane==3
            imagesc(squeeze(MRI_signal(:,:,slices(s)))',[0 Image_thres]);
        end

        axis image
        %axis equal
        axis xy
        axis off
        
        title(['s=' num2str(slices(s))],'color','w')
    end
    
    saveas(gcf,[general_path '/Anatomical_MRI_Images/' file_names(scan).name '.jpeg']);
end


