function getinfo2(submenu)

%% takes the final 128 integer-valued vector of infoblock
% Returns the comments found in infoblock along with the times of:
%	- first sweep
%	- last sweep
%	- infoblock save
%%%%%% Open the file and get infoblock %%%%%%

global datafilepath datafilename HFmain;
%% Check that a file has been opened
datafile=[datafilepath datafilename];
if strcmp(datafilename,'0')
	errcall('OPEN A FILE FIRST');
	return;
end
	
%% If file opened, then get run number
FInfo = get(HFmain,'UserData'); 
hlines= FInfo(2,:);
TP = get(hlines(2),'UserData');			% current active sweep
rnum = TP(2,1);

if strcmp(submenu,'info')

%% Get dirblock and info block
datafileID = fopen(datafile,'rb');
[dirblock,count]=fread(datafileID,256,'short');
maxrun=dirblock(1);

infoADRS = dirblock(rnum*2+1);
status = fseek(datafileID,512*infoADRS,-1);
[infoblock,count]=fread(datafileID,256,'short');

%% Retrieve first and last sweep for purposes of getting the timestamp
maxswp = infoblock(1+1);			% number of sweeps
LF = infoblock(8+1);				% leak flag
NB = infoblock(13+1);				% number of blocks per sweep
CW  =    infoblock(46+1)/1000; % Whole cell capacitance
RS  =    infoblock(47+1)/100;  % Series resistance
if LF,	maxswp = maxswp/2; end

%% For first sweep (swpnum=1):
if LF,	traceADRS = infoADRS+2+NB+2*NB*(1-1);
else	traceADRS = infoADRS+2+NB+NB*(1-1);
end
fseek(datafileID,512*traceADRS,-1);
[dtrace0,count]=fread(datafileID,256*NB,'short');

%% For last sweep (swpnum=maxswp):
if LF,	traceADRS = infoADRS+2+NB+2*NB*(maxswp-1);
else	traceADRS = infoADRS+2+NB+NB*(maxswp-1);
end
fseek(datafileID,512*traceADRS,-1);
[dtrace1,count]=fread(datafileID,256*NB,'short');

fclose(datafileID);


%%%%%% Read infoblock to get text %%%%%%

x=infoblock(128:256);
read_text1 = [];
read_text2 = [];
read_text3 = [];
read_text4 = [];

for i=1:40
	cur_val = x(i);
	if cur_val~=-1
		histr = floor(cur_val/256);
		lostr = cur_val - histr*256;
		if lostr >= 0
			cur_str = char(lostr);
			read_text1= [read_text1 cur_str];
		end
		if histr >= 0
			cur_str = char(histr);
			read_text1= [read_text1 cur_str];
		end
	end
end
read_text1;

for i=41:80
	cur_val = x(i);
	if cur_val~=-1
		histr = floor(cur_val/256);
		lostr = cur_val - histr*256;
		if lostr >= 0
			cur_str = char(lostr);
			read_text2= [read_text2 cur_str];
		end
		if histr >= 0
			cur_str = char(histr);
			read_text2= [read_text2 cur_str];
		end
	end
end
read_text2;

for i=81:86
	cur_val = x(i);
	if cur_val~=-1
		histr = floor(cur_val/256);
		lostr = cur_val - histr*256;
		if lostr >= 0
			cur_str = char(lostr);
			read_text3= [read_text3 cur_str];
		end
		if histr >= 0
			cur_str = char(histr);
			read_text3= [read_text3 cur_str];
		end
	end
end
read_text3;

for i=87:length(x)
	cur_val = x(i);
	if cur_val~=-1
		histr = floor(cur_val/256);
		lostr = cur_val - histr*256;
		if lostr >= 0
			cur_str = char(lostr);
			read_text4= [read_text4 cur_str];
		end
		if histr >= 0
			cur_str = char(histr);
			read_text4= [read_text4 cur_str];
		end
	end
end
read_text4;

%%%%%% Read infoblock and traces to get time %%%%%%

time0 = sec2time(dtrace0(length(dtrace0)-4)*5);
time1 = sec2time(dtrace1(length(dtrace1)-4)*5);
time2 = sec2time(infoblock(59)*5);

times = [time0; time1; time2];

end 

%% Display results
disp([datafilename ', run #' num2str(rnum) ' of ' num2str(maxrun) ', ' num2str(maxswp) ' sweeps'])
disp(read_text1)
disp(read_text2)
disp(read_text3)
disp(read_text4)
disp([time0 ', ' time1 ', ' time2])

