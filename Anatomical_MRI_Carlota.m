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
plane_names={'sag','cor','ax'};

% Colormap: set the name here instead of using the Colormap Editor
% (e.g. 'jet','parula','hot','gray','turbo','bone','copper')
colormap_name='jet';

%%
n_scans=length(file_names);

for scan=1:n_scans
    
    [MRI_signal, voxel_size]=Load_Align_Anatomical_Volume([file_names(scan).folder '/' file_names(scan).name]);

    Image_thres=mean(single(MRI_signal(:)))+3*std(single(MRI_signal(:)));

    figure('Color','k','Name',file_names(scan).name)
    colormap(colormap_name)

    % Slice numbers stay the original (aligned but un-resampled) voxel
    % indices for this plane; only the extracted 2D image is resized,
    % to correct in-plane anisotropy for display
    n_slices=size(MRI_signal,Choose_plane);
    slices=1:ceil(n_slices/n_collumns/n_rows):n_slices;

    for s=1:length(slices)

        subplot_tight(n_rows,n_collumns,s,0.001)

        slice_img=Extract_Anatomical_Slice(MRI_signal, voxel_size, Choose_plane, slices(s));

        imagesc(slice_img,[0 Image_thres]);

        axis image
        %axis equal
        axis xy
        axis off

        title(['s=' num2str(slices(s))],'color','w')
    end
    
    scan_base_name=regexprep(file_names(scan).name,'\.nii(\.gz)?$','');
    output_name=[scan_base_name '_' plane_names{Choose_plane} '.jpeg'];
    print(gcf,[general_path '/Anatomical_MRI_Images/' output_name],'-djpeg','-r600');
end


