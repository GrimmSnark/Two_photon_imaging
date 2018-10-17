function stitchCOImages(folder)

% folder = 'D:\Data\Histology\CO Staining\gCamp6s_M4\S2\';
images2Stitch = dir([folder '\*tif' ]);

intializeMIJ;
for i = 1:length(images2Stitch)
MIJ.run('Bio-Formats Importer', ['open=[' images2Stitch(i).folder '\' images2Stitch(i).name '] color_mode=Composite view=Hyperstack stack_order=XYCZT']);

pause(0.5);

MIJ.setRoi([0 0  5752 5752 ; 0 3600 3600 0],2);
MIJ.run("Crop");

if i ==2
    MIJ.run('Pairwise stitching', ['first_image=' images2Stitch(1).name ' second_image=' images2Stitch(2).name ' fusion_method=[Linear Blending] fused_image=fused_1.tif check_peaks=19 compute_overlap subpixel_accuracy x=0.0000 y=0.0000 registration_channel_image_1=[Average all channels] registration_channel_image_2=[Average all channels]']);
    MIJ.selectWindow(images2Stitch(1).name);
    MIJ.run('Close');
    MIJ.selectWindow(images2Stitch(2).name);
    MIJ.run('Close');
elseif i>2
    MIJ.run('Pairwise stitching', ['first_image=fused_' num2str(i-2) '.tif' ' second_image=' images2Stitch(i).name ' fusion_method=[Linear Blending] fused_image=fused_' num2str(i-1) '.tif check_peaks=19 compute_overlap subpixel_accuracy x=0.0000 y=0.0000 registration_channel_image_1=[Average all channels] registration_channel_image_2=[Average all channels]']); 
    MIJ.selectWindow(images2Stitch(i).name);
    MIJ.run('Close'); 
    MIJ.selectWindow(['fused_' num2str(i-2) '.tif']);
    MIJ.run('Close'); 
end
end

MIJ.run('Save', ['Tiff..., path=[' folder 'Fused.tif]']);
MIJ.run('Close'); 

