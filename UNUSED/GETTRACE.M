function [trace,leak]=gettrace(datafile,rnum,swpnum);

%%
%%	GETTRACE.M	Returns a trace and a leak from the datafile
%%
%%

% Get Information

datafileID = fopen(datafile,'rb');
[dirblock,count]=fread(datafileID,256,'short');
infoADRS = dirblock(rnum*2+1);
fseek(datafileID,infoADRS*512,-1);
[infoblock,count]=fread(datafileID,128,'short');
fclose(datafileID);

if infoblock(1)~=32100
   disp('There is a error in reading file, try it again!');
end

% Set Variables for the Run

N = 		infoblock(1+1);			% number of sweeps
VH =		infoblock(2+1);			% holding potential
I = 		infoblock(6+1)*1e-6;		% sample interval (sec)
G = 		infoblock(7+1)/10;		% gain (mV/pA)
LF = 		infoblock(8+1);			% leak flag
NB =		infoblock(13+1);		% number of blocks per sweep
PR =		infoblock(15+1);		% points before first pulse
ST =		infoblock(18+1);		% sample type (0-step, 1-ramp, 2-family)
NI =		infoblock(19+1);		% variable changed in family
HZ =		infoblock(21+1);		% lopass filter frequency

family(1:3)=	infoblock(23:25);		% Family start,stop,increment
PV(1:8) =	infoblock(29:36);		% Pulse Block PV(NI-3) incremented in family

DE1 =		infoblock(38+1);		% First pulse saved
DE2 =		infoblock(39+1);		% Last pulse saved


% Get the trace and leak

if (LF ~= 0)							% If there is interpulse leak subtraction
	
	traceADRS = infoADRS+2+NB+2*NB*(swpnum-1);
	leakADRS =  traceADRS+NB;
	
	datafileID = fopen(datafile,'rb');
	
	fseek(datafileID,512*traceADRS,-1);
	[trace,count]=fread(datafileID,256*NB,'short');
	
	fseek(datafileID,512*leakADRS,-1);
	[leak,count]=fread(datafileID,256*NB,'short');

	fclose(datafileID);

else								% No Interpulse leak subtraction

	traceADRS = infoADRS+2+NB+NB*(swpnum-1);
		
	datafileID = fopen(datafile,'rb');
	
	fseek(datafileID,512*traceADRS,-1);
	[trace,count]=fread(datafileID,256*NB,'short');
	leak = [];
	fclose(datafileID);
end