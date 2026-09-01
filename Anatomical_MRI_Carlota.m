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
    
    MRI_signal=niftiread([file_names(scan).folder '/' file_names(scan).name]);
    
    Image_thres=mean(single(MRI_signal(:)))+3*std(single(MRI_signal(:)));
      
    figure('Color','k','Name',file_names(scan).name)
    colormap(jet)

    [X_size, Y_size, Z_size]=size(MRI_signal);

    max_resolution=max([X_size, Y_size, Z_size]);

    MRI_signal=imresize3(MRI_signal,[max_resolution max_resolution max_resolution],'Method','linear');
    
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


