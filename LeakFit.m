function leakfit(varargin)
if nargin==0
    InitializeGUI;
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        rethrow(lasterror);
    end
end

function InitializeGUI
global GUIDATA
GUIDATA.HFigure = figure('Name',	'Fancy Leak Subtraction', ...
		'NumberTitle', 'off', ...
		'Units', 'normal',...
		'Position', [.01 .33 .66 .60],...
		'UserData', zeros(4,30),'keypressfcn',@(obj, evd) keystroke(obj, evd));			% FInfo (Has Handle Info and Sweep Info)
GUIDATA.AxLkfit = axes('box', 'on', 'Position', [.04 .55 .75 .4]);
GUIDATA.AxLkFitSub = axes('box', 'on', 'Position', [.445 0.04  .345 .4]);
GUIDATA.AxLkSub = axes('box', 'on', 'Position', [0.04 .04 .345 .4]);

%Size constants (in normalized units)
LH = 0.03;  %height per line
S  = 0.005;  %spacer
ST = 0.005;
SS = 0.01;
AxW = 0.8;
BW  = (1-AxW)/4-1.25*S;

GUIDATA.lbloffset = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S .95 BW LH],'string','Offset:');
GUIDATA.offset = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*2+BW .95 BW LH],'string','','CallBack','leakfit(''ChangeFit'')');
GUIDATA.lbllambda = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95 BW LH],'string','Lambda:');
GUIDATA.lambda = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*4+3*BW .95 BW LH],'string','','CallBack','leakfit(''ChangeFit'')');
myColor = [0.2 0.2 0.2];
% ----------------------------------
GUIDATA.lblP2 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-LH-SS BW*2+S LH],'string','PULSE 2', ...
            'FontWeight','bold', 'BackgroundColor',myColor, ...
            'ForegroundColor',1-myColor);        
GUIDATA.lblP2offset = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-LH-SS BW LH],'string','Offset:');
GUIDATA.P2offset = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*4+3*BW .95-LH-SS BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblP2a0 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-2*(LH+SS) BW LH],'string','Amp0');
GUIDATA.P2a0 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*2+1*BW .95-2*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblP2tau0 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-2*(LH+SS) BW LH],'string','Tau0');
GUIDATA.P2tau0 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*4+3*BW .95-2*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblP2a1 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-3*(LH+SS) BW LH],'string','Amp1');
GUIDATA.P2a1 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*2+1*BW .95-3*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblP2tau1 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-3*(LH+SS) BW LH],'string','Tau1');
GUIDATA.P2tau1 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*4+3*BW .95-3*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');
% ----------------------------------        
GUIDATA.lblP3 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-4*(LH+SS) BW*2+S LH],'string','PULSE 3', ...
            'FontWeight','bold', 'BackgroundColor',myColor, ...
            'ForegroundColor',1-myColor);        
GUIDATA.lblP3offset = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-4*(LH+SS) BW LH],'string','Offset:');
GUIDATA.P3offset = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*4+3*BW .95-4*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblP3a0 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-5*(LH+SS) BW LH],'string','Amp0');
GUIDATA.P3a0 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*2+1*BW .95-5*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblP3tau0 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-5*(LH+SS) BW LH],'string','Tau0');
GUIDATA.P3tau0 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*4+3*BW .95-5*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblP3a1 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-6*(LH+SS) BW LH],'string','Amp1');
GUIDATA.P3a1 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*2+1*BW .95-6*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblP3tau1 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-6*(LH+SS) BW LH],'string','Tau1');
GUIDATA.P3tau1 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*4+3*BW .95-6*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');
                
% ----------------------------------        
GUIDATA.lblP4 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-7*(LH+SS) BW*2+S LH],'string','PULSE 4', ...
            'FontWeight','bold', 'BackgroundColor',myColor, ...
            'ForegroundColor',1-myColor);        
GUIDATA.lblP4offset = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-7*(LH+SS) BW LH],'string','Offset:');
GUIDATA.P4offset = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*4+3*BW .95-7*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblP4a0 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-8*(LH+SS) BW LH],'string','Amp0');
GUIDATA.P4a0 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*2+1*BW .95-8*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblP4tau0 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-8*(LH+SS) BW LH],'string','Tau0');
GUIDATA.P4tau0 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*4+3*BW .95-8*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblP4a1 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-9*(LH+SS) BW LH],'string','Amp1');
GUIDATA.P4a1 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*2+1*BW .95-9*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblP4tau1 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-9*(LH+SS) BW LH],'string','Tau1');
GUIDATA.P4tau1 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*4+3*BW .95-9*(LH+SS) BW LH],'string','','CallBack','leakfit(''ChangeFit'')');

GUIDATA.BAutofit = uicontrol('Style','pushbutton', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-10*(LH+SS) 2*BW+S 1*LH],'string','Auto Fit','CallBack','leakfit(''AutoFit'')');
GUIDATA.BWrite = uicontrol('Style','pushbutton', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-10*(LH+SS) 2*BW+S 1*LH],'string','WriteData','CallBack','leakfit(''WriteData'')');

GUIDATA.lblError = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-11*(LH+SS) 2*BW+S 1*LH],'string','ERROR:  ', ...            
            'FontWeight','bold', 'BackgroundColor',myColor, ...
            'ForegroundColor',1-myColor);
GUIDATA.Error = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-11*(LH+SS) 2*BW+S 1*LH],'ForegroundColor','red','FontWeight','bold','string','0');
% ---------------------------------
GUIDATA.lblT1 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-12*(LH+SS) BW 1*LH],'string','T1:  ' ...            
            );
GUIDATA.T1 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*2+1*BW .95-12*(LH+SS) BW 1*LH],'callback','leakfit(''ChangeFit'')');

GUIDATA.lblT2 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-12*(LH+SS) BW 1*LH],'string','T2:  ' ...            
            );
GUIDATA.T2 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*4+3*BW .95-12*(LH+SS) BW 1*LH],'CallBack','leakfit(''ChangeFit'')');

GUIDATA.lblT3 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-13*(LH+SS) BW 1*LH],'string','T3:  ' ...            
            );
GUIDATA.T3 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*2+1*BW .95-13*(LH+SS) BW 1*LH],'callback','leakfit(''ChangeFit'')');

GUIDATA.lblT4 = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-13*(LH+SS) BW 1*LH],'string','T4:  ' ...            
            );
GUIDATA.T4 = uicontrol('Style','edit', 'Units','normalized',...
			'Position',[AxW+S*4+3*BW .95-13*(LH+SS) BW 1*LH],'CallBack','leakfit(''ChangeFit'')');
GUIDATA.lblMask = uicontrol('Style','text', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-14*(LH+SS) 4*BW+3*S 1*LH],'string','Mask  ', ...            
            'FontWeight','bold', 'BackgroundColor',myColor, ...
            'ForegroundColor',1-myColor);
GUIDATA.Mask = uicontrol('Style','listbox', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-18*(LH+SS) 4*BW+3*S 5*LH-S]);
GUIDATA.MaskAdd = uicontrol('Style','pushbutton', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-19*(LH+SS) 2*BW+S 1*LH],'string','AddMask','CallBack','leakfit(''AddMask'')');
GUIDATA.MaskDel = uicontrol('Style','pushbutton', 'Units','normalized',...
			'Position',[AxW+S*3+2*BW .95-19*(LH+SS) 2*BW+S 1*LH],'string','DelMask','CallBack','leakfit(''DelMask'')');       
GUIDATA.Filter = uicontrol('Style','pushbutton', 'Units','normalized',...
			'Position',[AxW+S*1+0*BW .95-20*(LH+SS) 2*BW+S 1*LH],'string','AddMask','CallBack','leakfit(''FilterTrace'')');        
% Now let us get the timetrace, leak trace. trace without leak subtraction,
% and leak subtracted trace also get the Duration of pulses etc        
% -- Current File
global curplot
datafile = curplot.curfile;
rnum = curplot.currun;
swpnum = curplot.curswp;

datafileID = fopen(datafile,'rb');
[dirblock,count]=fread(datafileID,256,'short');
maxrun=dirblock(1);
infoADRS = dirblock(rnum*2+1);
status = fseek(datafileID,512*infoADRS,-1);
[infoblock,count]=fread(datafileID,128,'short');
fclose(datafileID);

% Current Run Parameters
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
CW  =    infoblock(46+1)/1000; % Whole cell capacitance
RS  =    infoblock(47+1)/100;  % Series resistance
    if (PR == 0)
		PR = 1;
	end

	if (HZ == 0)
		PF = 0;
    else
		PF = 	1000*(3.48*exp(-HZ/150)+ ...
			0.73*exp(-HZ/650)+ ...
			0.2*exp(-HZ/2700)+ ...
			0.032*exp(-HZ/43500));
		PF = round(PF/infoblock(6+1));
	end
traceADRS = infoADRS+2+NB+2*NB*(swpnum-1);
leakADRS =  traceADRS+NB;
datafileID = fopen(datafile,'rb');
fseek(datafileID,512*traceADRS,-1);
[dtrace,count]=fread(datafileID,256*NB,'short'); % This gives us our trace
fseek(datafileID,512*leakADRS,-1);
[leak,count]=fread(datafileID,256*NB,'short'); % This gives us leak
fclose(datafileID);
dleaksubtrace=	[dtrace(1:NB*256-12) - ...
			(leak(1:NB*256-12) - mean(leak(1:PR)))*infoblock(37)/16;...
			dtrace(NB*256-11:NB*256)];

pAtrace = dtrace*(10000/2048)/G;
pAtraceleaksub = dleaksubtrace*(10000/2048)/G;
leak = pAtrace - pAtraceleaksub;
time = I/1000*([1:NB*256]-(PR+PF+1));		% PR+PF+1 is where first pulse starts
GUIDATA.data.pAtrace = pAtrace;
GUIDATA.data.pAtraceleaksub = pAtraceleaksub;
GUIDATA.data.leak = leak;
GUIDATA.data.time = time;
GUIDATA.data.LkScale = infoblock(37)/16;
GUIDATA.data.PR = PR;
GUIDATA.data.G = G;
GUIDATA.data.TPulse = [time(1) PV(6)+PV(7)+PV(8)-time(1)];
xlimits(1) = round(-(PR+PF)*I/1000);
xlimits(2) = sum(PV(5:8));
Times = PV(5:8);
GUIDATA.data.Times = Times;

axes(GUIDATA.AxLkfit)
plot(time, leak,'r-',time, pAtrace,'g-')
xlim(xlimits)		
title('Leak')
axes(GUIDATA.AxLkSub)
plot(time, pAtraceleaksub,'k-')
zoom xon;
xlim(xlimits)
title('Leak Subtracted')
axes(GUIDATA.AxLkFitSub)
title('Leak Fit Subtracted')
zoom xon;

head = getheader();
GUIDATA.data.comment = head.raw{end};
try
GUIDATA.data.construct = head.construct;
end
set(GUIDATA.HFigure,'Name',['Leak Subtraction - ' GUIDATA.data.comment])
Params = [0.8, 300,  80,   3, -30, 100, ...
                        -25, -40,   1,   0, 0.4  ...
                        -25,   0.1, 0.2,   0.1, 1.5 .8];
GUIDATA.data.Params = Params;
setParams(Params)                    
% GUIDATA.Params = Params;
% leakfit = FITLeak(Params,time);
% axes(GUIDATA.AxLkfit)
% GUIDATA.lkfit = line(time, leakfit);
ChangeFit();

function AddMask()
global GUIDATA
curMasks = get(GUIDATA.Mask, 'string');
if isempty(curMasks)
    curMasks = {};
end
axes(GUIDATA.AxLkfit)
[x,y] = ginput(2);
disp([x(1),x(2)])
t(1) = GUIDATA.data.time(find(((GUIDATA.data.time-x(1)).^2)==min((GUIDATA.data.time-x(1)).^2)));
t(2) = GUIDATA.data.time(find(((GUIDATA.data.time-x(2)).^2)==min((GUIDATA.data.time-x(2)).^2)));
t = sort(t);
mytext = [num2str(t(1)),',',num2str(t(2))];
curMasks(length(curMasks)+1)={mytext};
set(GUIDATA.Mask,'string',curMasks);
ChangeFit();

function DelMask()
global GUIDATA
curMasks = get(GUIDATA.Mask, 'string');
selected = get(GUIDATA.Mask, 'value');
if length(curMasks)==0
    disp('Error: No Masks to delete')
    return;    
end
if (selected>1) && (selected<length(curMasks))
    newMasks = curMasks([1:selected-1,selected+1:length(curMasks)]);    
elseif (selected==length(curMasks))
    newMasks = curMasks(1:end-1);
elseif (selected==1)
    newMasks = curMasks(2:end);
end      
set(GUIDATA.Mask,'string',newMasks);
if selected>length(newMasks)
    set(GUIDATA.Mask,'Value',max(1,length(newMasks)));
end
ChangeFit()

function result = ApplyMask()
global GUIDATA
myLeakFit = GUIDATA.data.leakfit;
leak = GUIDATA.data.leak;
time = GUIDATA.data.time;
myMasks = get(GUIDATA.Mask,'string');
if ~isempty(myMasks)
    for i =1:length(myMasks)
        TempMask = str2num(myMasks{i});
        Ta = (time-TempMask(1)).^2;
        Tb = (time-TempMask(2)).^2;
        TempTindex = [find(Ta==min(Ta)) find(Tb==min(Tb))];
        myLeakFit(TempTindex(1):TempTindex(2)) = leak(TempTindex(1):TempTindex(2));
    end
    result = myLeakFit;
    return;
else
    result = myLeakFit;
    return;
end
    

function ChangeFit()
global GUIDATA;
Params = getParams();
GUIDATA.data.Params
time = GUIDATA.data.time;
myleakfit = FITLeak(Params,time);
try
if isfield(GUIDATA,'lkfit')    
    delete(GUIDATA.lkfit);
    GUIDATA = rmfield(GUIDATA,'lkfit');    
end
end
GUIDATA.data.leakfit = myleakfit;
GUIDATA.data.pALkFitNoMask = GUIDATA.data.leakfit;
GUIDATA.data.leakfit = ApplyMask();

setParams(Params);
LSQERROR = sum((GUIDATA.data.leak-myleakfit').^2);
set(GUIDATA.Error, 'String', num2str(LSQERROR))

axes(GUIDATA.AxLkfit)
GUIDATA.lkfit = line(time, GUIDATA.data.leakfit);

axes(GUIDATA.AxLkFitSub)
GUIDATA.data.pALkFitSub = GUIDATA.data.pAtrace - GUIDATA.data.leakfit';
% fcutoff = 900;
% GUIDATA.data.pALkFitSub = filt2(time, GUIDATA.data.pALkFitSub', fcutoff)';

plot(time, GUIDATA.data.pALkFitSub)
xlim([time(1), sum(GUIDATA.data.Times)])

function WriteData()
global GUIDATA
AnalysisData = GUIDATA.data;

[name,path] =  uiputfile('*.*');
fname = [path  name];
fname
save([fname 'Struct.mat'],'AnalysisData');
% ti = [1 length(time)];
data = [GUIDATA.data.time; GUIDATA.data.pALkFitSub'];
dumpfileID = fopen([fname '.txt'],'w');
fprintf(dumpfileID, '%f\t%f\n',data);
fclose(dumpfileID);


function Params = getParams()
global GUIDATA;
offset    = str2num(get(GUIDATA.offset    ,'string'));
P2offset  = str2num(get(GUIDATA.P2offset  ,'string'));
P2a0      = str2num(get(GUIDATA.P2a0      ,'string'));
P2tau0    = str2num(get(GUIDATA.P2tau0    ,'string'));
P2a1      = str2num(get(GUIDATA.P2a1      ,'string'));
P2tau1    = str2num(get(GUIDATA.P2tau1    ,'string'));
P3offset  = str2num(get(GUIDATA.P3offset  ,'string'));
P3a0      = str2num(get(GUIDATA.P3a0      ,'string'));
P3tau0    = str2num(get(GUIDATA.P3tau0    ,'string'));
P3a1      = str2num(get(GUIDATA.P3a1      ,'string'));
P3tau1    = str2num(get(GUIDATA.P3tau1    ,'string'));
P4offset  = str2num(get(GUIDATA.P4offset  ,'string'));
P4a0      = str2num(get(GUIDATA.P4a0      ,'string'));
P4tau0    = str2num(get(GUIDATA.P4tau0    ,'string'));
P4a1      = str2num(get(GUIDATA.P4a1      ,'string'));
P4tau1    = str2num(get(GUIDATA.P4tau1    ,'string'));
lambda    = str2num(get(GUIDATA.lambda    ,'string'));
Params = [offset,P2offset,P2a0,P2tau0,P2a1,P2tau1,P3offset,P3a0, ... 
     P3tau0,P3a1,P3tau1,P4offset,P4a0,P4tau0,P4a1,P4tau1,lambda];
 GUIDATA.data.Params = Params;
 
 Times(1) = str2num(get(GUIDATA.T1    ,'string'));
 Times(2) = str2num(get(GUIDATA.T2    ,'string'));
 Times(3) = str2num(get(GUIDATA.T3    ,'string'));
 Times(4) = str2num(get(GUIDATA.T4    ,'string'));
 GUIDATA.data.Times = Times;
 if length(Params)<16
     disp('Error: Some Param is Invalid or Missing')
 end
 
function setParams(Params)
global GUIDATA
set(GUIDATA.offset   ,'string',Params(1) );                                                                  
set(GUIDATA.P2offset ,'string',Params(2) );                                                                  
set(GUIDATA.P2a0     ,'string',Params(3) );                                                                  
set(GUIDATA.P2tau0   ,'string',Params(4) );                                                                  
set(GUIDATA.P2a1     ,'string',Params(5) );                                                                  
set(GUIDATA.P2tau1   ,'string',Params(6) );                                                                  
set(GUIDATA.P3offset ,'string',Params(7) );                                                                  
set(GUIDATA.P3a0     ,'string',Params(8) );                                                                  
set(GUIDATA.P3tau0   ,'string',Params(9) );                                                                  
set(GUIDATA.P3a1     ,'string',Params(10));                                                                  
set(GUIDATA.P3tau1   ,'string',Params(11));                                                                  
set(GUIDATA.P4offset ,'string',Params(12));                                                                  
set(GUIDATA.P4a0     ,'string',Params(13));                                                                  
set(GUIDATA.P4tau0   ,'string',Params(14));                                                                  
set(GUIDATA.P4a1     ,'string',Params(15));                                                                  
set(GUIDATA.P4tau1   ,'string',Params(16)); 
set(GUIDATA.lambda   ,'string',Params(17)); 

% --------------------------------
set(GUIDATA.T1   ,'string',GUIDATA.data.Times(1));                                                                  
set(GUIDATA.T2   ,'string',GUIDATA.data.Times(2));                                                                  
set(GUIDATA.T3   ,'string',GUIDATA.data.Times(3)); 
set(GUIDATA.T4   ,'string',GUIDATA.data.Times(4)); 





function myleakfit = FITLeak(Params,t)
global GUIDATA;
T = cumsum(GUIDATA.data.Times);
P2 = Params(2)*ones(size(t)) + Params(3)*exp(-(t-T(1))/Params(4)) + Params(5)*exp(-(t-T(1))/Params(6));
P2 = P2.*(t>=T(1)).*(t<=T(2));
P3 = Params(7)*ones(size(t)) + Params(8)*exp(-(t-T(2))/Params(9)) + Params(10)*exp(-(t-T(2))/Params(11));
P3 = P3.*(t>=T(2)).*(t<=T(3));
P4 = zeros(size(t));
testP4 = Params(13)*exp(-(t-T(3))/Params(14)) + Params(15)*exp(-(t-T(3))/Params(16));
P4 = P4+Params(12)*ones(size(t)) + (testP4<Inf).*testP4;
P4 = P4.*(t>=T(3)).*(t<=T(4));
myleakfit =Params(1)+zeros(size(t));
P2 = MovingAvg(Params(17),5,P2);
P3 = MovingAvg(Params(17),5,P3);
P4 = MovingAvg(Params(17),5,P4);
for i =1:length(t)    
   if (t(i)>=T(1) && t(i)<T(2))
       myleakfit(i) = P2(i);
   elseif (t(i)>=T(2) && t(i)<T(3))
       myleakfit(i) = P3(i);
   elseif (t(i)>=T(3) && t(i)<T(4))
       myleakfit(i) = P4(i);
   end
end
myleakfit = myleakfit;

function smoothx = MovingAvg(lambda,npt, x)
% npt- forward filter.
smoothx = zeros(size(x));
smoothx(1:npt)= x(1:npt);
slambda = 0;
for i = 1:npt
   smoothx(npt+1:end) =  smoothx(npt+1:end)+lambda^(i-1)*x(npt-i+2:end-i+1);
   slambda = slambda + lambda^(i-1);
end
smoothx(npt+1:end) = smoothx(npt+1:end).*1/slambda;

function AutoFit()
global GUIDATA
leak = GUIDATA.data.leak;
time = GUIDATA.data.time;
Params = getParams();
beta = nlinfit(time,leak',@FITLeak,Params);
try
    autoleakfit = FITLeak(beta, time);
catch
    disp('Error: NO AutoFIT Possible with Current Guess')   
    return;
end



if isfield(GUIDATA,'lkfit')    
    delete(GUIDATA.lkfit);
    GUIDATA = rmfield(GUIDATA,'lkfit');    
end

axes(GUIDATA.AxLkfit)
GUIDATA.lkfit = line(time, autoleakfit, 'color', 'k');


resp = questdlg('Keep AutoFit?');
if (strcmp(resp(1),'N')) || (strcmp(resp(1),'C'))
    ChangeFit();
else
    setParams(beta);
    ChangeFit();
end

