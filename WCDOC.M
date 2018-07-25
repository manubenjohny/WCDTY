% whole cell doc, crude program

eval(['cd c:\data\lpj;']);

datafilename = 0;
	
while (datafilename == 0)
	[datafilename,datafilepath] = uigetfile('e*.*','Select Data File');
	datafile=[datafilepath datafilename];
end

rnum=input('enter run number:');


datafileID = fopen(datafile,'rb+');
[dirblock,count]=fread(datafileID,256,'short');
maxrun=dirblock(1);

infoADRS = dirblock(rnum*2+1);
status = fseek(datafileID,infoADRS*512,-1);
[infoblock,count]=fread(datafileID,128,'short');

if infoblock(1) == 32100
	fileOK = 1;
else
	datafilename = 0;
end




maxswp = 	infoblock(1+1);			% number of sweeps
VH =		infoblock(2+1);			% holding potential
I = 		infoblock(6+1);			% sample interval (usec)
G = 		infoblock(7+1)/10;		% gain (mV/pA)
LF = 		infoblock(8+1);			% leak flag
if LF
	maxswp = maxswp/2;
end;

NB =		infoblock(13+1);		% number of blocks per sweep
PR =		infoblock(15+1);		% points before first pulse
ST =		infoblock(18+1);		% sample type (0-step, 1-ramp, 2-family)
NI =		infoblock(19+1);		% variable changed in family
HZ =		infoblock(21+1);		% lopass filter frequency

family(1:3)=	infoblock(23:25);		% Family start,stop,increment
PV(1:8) =	infoblock(29:36);		% Pulse Block PV(NI-3) incremented in family

DE1 =		infoblock(38+1);		% First pulse saved
DE2 =		infoblock(39+1);		% Last pulse saved

PF = 	1000*(3.48*exp(-HZ/150)+ ...
	0.73*exp(-HZ/650)+ ...
	0.2*exp(-HZ/2700)+ ...
	0.032*exp(-HZ/43500));

PF = round(PF/infoblock(6+1));



TBlock(13) = 0;  				% Offset (in points) of initial region
TBlock(14) = PR+PF;  				% Length (in points) of initial region
TBlock(15) = TBlock(14)+1;			% Location of Start Pulse 1 (points)
TBlock(16) = TBlock(15)+round(PV(5)*1000/I);	% Location of Start Pulse 2 (points)	
TBlock(17) = TBlock(16)+round(PV(6)*1000/I);	% Location of Start Pulse 3 (points)
TBlock(18) = TBlock(17)+round(PV(7)*1000/I);	% Location of Start Pulse 4 (points)
TBlock(19) = TBlock(18)+round(PV(8)*1000/I)-1;	% Last Point of Pulse 4

tpulse1 = 5;
SPnew(1) = PF+PR+1;
SPnew(2) = SPnew(1) + round(tpulse1*1000/I);
SPnew(3) = SPnew(2) + round(PV(6)*1000/I);
SPnew(4) = SPnew(3) + round(PV(7)*1000/I);
SPnew(5) = SPnew(4) + round(PV(8)*1000/I);
NBnew = round(SPnew(5)/256);
dtracenew = zeros(1:NBnew*256);
leaknew = zeros(1:NBnew*256);

for swpnum = 1:maxswp
	disp(swpnum)


	traceADRS = infoADRS+2+NB+2*NB*(swpnum-1);
	leakADRS =  traceADRS+NB;
	
%	datafileID = fopen(datafile,'rb+');
	
	fseek(datafileID,512*traceADRS,-1);
	[dtrace,count]=fread(datafileID,256*NB,'short');
	
	fseek(datafileID,512*leakADRS,-1);
	[leak,count]=fread(datafileID,256*NB,'short');

	leaknew(1:PF+PR) = leak(1:PF+PR);
	leaknew(SPnew(1):SPnew(2)-1) = leak(TBlock(15):TBlock(15)+round(tpulse1*1000/I)-1);
	leaknew(SPnew(2):SPnew(3)-1) = leak(TBlock(16):TBlock(17)-1);
	leaknew(SPnew(3):SPnew(4)-1) = leak(TBlock(17):TBlock(18)-1);
	leaknew(SPnew(4):SPnew(5)-1) = leak(TBlock(18):TBlock(19));
	leaknew(NBnew*256-14:NBnew*256) = leak(NB*256-14:NB*256);
	
	dtracenew(1:PF+PR) = dtrace(1:PF+PR);
	dtracenew(SPnew(1):SPnew(2)-1) = dtrace(TBlock(15):TBlock(15)+round(tpulse1*1000/I)-1);
	dtracenew(SPnew(2):SPnew(3)-1) = dtrace(TBlock(16):TBlock(17)-1);
	dtracenew(SPnew(3):SPnew(4)-1) = dtrace(TBlock(17):TBlock(18)-1);
	dtracenew(SPnew(4):SPnew(5)-1) = dtrace(TBlock(18):TBlock(19));
	dtracenew(NBnew*256-14:NBnew*256) = dtrace(NB*256-14:NB*256);
	
	
	tracenADRS = infoADRS+2+NBnew+2*NBnew*(swpnum-1);
	leaknADRS = tracenADRS+NBnew;

	fseek(datafileID,512*tracenADRS,-1);
	count = fwrite(datafileID,dtracenew,'short');
	
	fseek(datafileID,512*leaknADRS,-1);
	count = fwrite(datafileID,leaknew,'short');

end

infoblock(33) = 5;
infoblock(14) = NBnew;
status = fseek(datafileID,512*infoADRS,-1)
count = fwrite(datafileID,infoblock,'short')

fclose(datafileID);


%swpnum=input('enter trace number:');

%wcdoctr;

%TBlock(12) = dtrace(NB*256-1);			% Value of Familied Variable

% find pulse boundries of the trace (will use for lk subtrace)
%Family_Var = NI-7;
%for pulse = 1:4
%	if (NI-3) >= 5 & ST == 2 & pulse > Family_Var 
%		TBlock(14+pulse) = TBlock(14+pulse)-round(PV(Family_Var+4)*1000/TBlock(20))+round(TBlock(12)*1000/TBlock(20));
%	end
%end
%wcdoci;
