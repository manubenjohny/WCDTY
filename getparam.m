function y = getparam
% function y = showparam
% Program for extracting infoblock entries from Q data files
% 2/7/2000 by MGE

default_directory = 'c:\My Documents\data\ephys\b-series\';

filename = input(sprintf('Default directory is %s\nEnter file name or <RETURN>: ',default_directory),'s');

if isempty(filename),
	[datafilename,datafilepath] = uigetfile(strcat(default_directory,'*.*'),'Select Data File');
	datafile=[datafilepath datafilename];
else
   datafile = strcat('c:\My Documents\data\ephys\b-series\',filename);
end

if (sum(datafile)),
   fprintf('Opening %s...\n',datafile)
	datafileID = fopen(datafile,'rb');
   if datafileID == -1,
      y = -1;
      error('Getparam could not find your file!')
   end 
   [dirblock,count]=fread(datafileID,256,'short');
	maxrun=dirblock(1);

	rnumber = 1;
	while rnumber ~=0,
   
	rnumber = input('Enter run number (0 to quit): ');
   
   if rnumber ~= 0,
   	infoADRS = dirblock(rnumber*2+1);
		status = fseek(datafileID,512*infoADRS,-1);
		[infoblock,count]=fread(datafileID,128,'short');

		if infoblock(1) ~= 32100
   	   disp('Error reading infoblock');
   	   rnumber = 0;
		end

		fprintf('Cwc (pF)  = %3f\nRs (M0hm) = %3f\nGain = %3f\n\n',infoblock(46+1)/1000,infoblock(47+1)/100,infoblock(7+1)/10);

   	InfoblockIndex = 1;
   	while InfoblockIndex ~= 0,
			InfoblockIndex = input('Enter infoblock index for desired parameter (0 for new run): ');
   	   disp(sprintf('Parameter = %d\n',infoblock(InfoblockIndex+1)))
      end
   else
      fprintf('Bye\n\n');
   end
	end

	y=fclose(datafileID);
   
else
   y=-1;
	error('No filename specified!');
end
return;