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

    % Align to a canonical axis order (dim1=sag/L-R, dim2=cor/A-P,
    % dim3=ax/S-I) using the header's affine transform, so array
    % dimensions map to the same anatomical direction for every file
    % regardless of how each scan (e.g. axial T2 vs sagittal T1) was
    % originally acquired/stored
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

    [X_size, Y_size, Z_size]=size(MRI_signal);

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
    
    scan_base_name=regexprep(file_names(scan).name,'\.nii(\.gz)?$','');
    print(gcf,[general_path '/Anatomical_MRI_Images/' scan_base_name '.jpeg'],'-djpeg','-r600');
end


