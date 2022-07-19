function savefile_HandSoundSequenceAssociation(param, HandSoundSequenceAssociation)

i_name = 1;
output_file_name = [param.outputDir, param.subject,'_',param.task,'_' , num2str(i_name) ,'.mat'];
while exist(output_file_name,'file')
    i_name = i_name+1;
    output_file_name = [param.outputDir, param.subject,'_',param.task,'_' , num2str(i_name) ,'.mat'];
end

save(output_file_name, 'HandSoundSequenceAssociation');
