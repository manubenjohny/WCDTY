function ascdump

%%
%%	ASCDUMP.M	ASCII Dump of Sweep with option to skip points
%%
%%
%%

global datafilepath datafilename HFmain;
global trace TBlock;

% Check that a file has been opened

datafile=[datafilepath datafilename];

if strcmp(datafilename,'0')
	errcall('OPEN A FILE FIRST');
	return;
end


%	FInfo:	Row 1: Handles for GUI


	FInfo = get(HFmain,'UserData');			% Get UserData Matrix (handles for GUI and traces)

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
	

% Determine what region to output

	disp(' ');
	disp(['Range:  ' num2str(time(1)) ' to ' num2str(time(length(time)))]);

	t = input ('Enter Range for Output [t1 t2]: ');

	if isempty(t)
		ti = [1 length(time)];
		disp('Full Range');
	else
		ti = [0 0];
		ti(1) = find(time >= (t(1) - I/1000/2) & time < (t(1) + I/1000/2));
		ti(2) = find(time >= (t(2) - I/1000/2) & time < (t(2) + I/1000/2));
		
		disp(' ');
		disp(['Selected Range: [' num2str(time(ti(1))) ' ' num2str(time(ti(2))) ']']);
	end

% Determine how many points to output
	disp(' ');
	disp(['Sampling I (usec):  ' num2str(I)]);
        disp(['Points per ms:      ' num2str(1000/I)]);

	skippts = input ('Output 1/x points. Enter x: '); 
	
	if isempty(skippts)
		skippts = 1;
		disp(['x: ' num2str(skippts)']);
	end

	x = [ti(1):skippts:ti(2)];
	data = [time(x);trace(x)];

% Open up file and write trace

	dumpfile = input('Enter File Name (e.g., c:\\matlab\\work\\sweep.txt) : ','s');

	if isempty(dumpfile)
		dumpfile = 'c:\matlab\work\sweep.txt';
	end

	dumpfileID = fopen(dumpfile,'w');
	fprintf(dumpfileID, '%f\t%f\n',data);
	fclose(dumpfileID);

disp('Done.');