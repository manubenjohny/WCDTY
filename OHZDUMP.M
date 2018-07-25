function ohzdump

%%
%%	OHZDUMP.M	ASCII Dump of Sweep with concatentation
%%
%%
%%

global datafilepath datafilename;
global trace TBlock;

% Check that a file has been opened

datafile=[datafilepath datafilename];

if strcmp(datafilename,'0')
	errcall('OPEN A FILE FIRST');
	return;
end


%	FInfo:	Row 1: Handles for GUI


	FInfo = get(gcf,'UserData');			% Get UserData Matrix (handles for GUI and traces)

% Get Information for the current sweep

	HIDline = FInfo(2,2);
	TP = get(HIDline,'UserData');

	TPname = TP(1,:);	

	TPvect = TP(2,:); 	%TPVect = [rnum maxrun swpnum maxswp infoADRS NB ];
	rnum = TPvect(1);
	swpnum = TPvect(3);
	
	TBlock = TP(3,:);
	
	I = TBlock(20);
	
	trace = get(HIDline,'YData');
	time = get(HIDline,'XData');
	

% Determine what region to output (full range)

	disp(' ');
	disp(['Range:  ' num2str(time(1)) ' to ' num2str(time(length(time)))]);

	ti = [1 length(time)];

% Determine how many points to output (all points)

	disp(' ');
	disp(['Sampling I (usec):  ' num2str(I)]);
        disp(['Points per ms:      ' num2str(1000/I)]);

	x = [ti(1):ti(2)];
	data = [time(x);trace(x)];

% Open up file and write trace

	dumpfile = 'c:\pgp\ohz.txt';

	dumpfileID = fopen(dumpfile,'a');
	fprintf(dumpfileID, '%f\t%f\n',data);
	fclose(dumpfileID);

disp('Done.');