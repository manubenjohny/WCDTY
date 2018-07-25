
%%
%%	LEAKAPW	Grabs a single APW sweep and does leak subtraction on it.
%%



%%%%%%%%%%%%%%%%%%%%%%%%% Get The Sweep %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FInfo = get(wcHandle,'UserData');
Hlines = FInfo(2,:);
Hcurrent=Hlines(2);

time = 	get(Hcurrent,'XData');
trace = get(Hcurrent,'YData');
TP = 	get(Hcurrent,'UserData');
TBlock = TP(3,:);

% Extract Information from TP

swpnum = TP(2,3);
I  = TBlock(20);
PRPF = TBlock(14);



%%%%%%%%%%%%%%%%%%%%%%%% Do Leak Subtraction %%%%%%%%%%%%%%%%%%%%%%%%%%

newtime = 0:I/1000:leakSPC;

newtrace = trace(time >= apwPOS & time <= apwPOS+leakSPC);
newtrace = newtrace - mean(newtrace(length(newtrace)-32:length(newtrace)));

leaks = zeros(1,length(newtime));
count = 0;

while (count < nleaks)
	
	leak = trace(time >= leakPOS + leakSPC*count & time <= leakPOS + leakSPC*(count+1));
	leak = leak - mean(leak(length(leak)-32:length(leak)));
	leaks = leaks + leak;
	count = count + 1;
end	

leaks = leaks/nleaks;

%%%%%%%%%%%%%%%%%%%%%%%%% Plot Sweep on Axes %%%%%%%%%%%%%%%%%%%%%%%%%%

Hleaksub = plot(newtime, newtrace - leaks*PX);
%Hdata= line(newtime,newtrace);
%Hleaks = line(newtime,leaks*PX);

%%%%%%%%%%%%%%%%%%%%%%%%% Calculations on APW %%%%%%%%%%%%%%%%%%%%%%%%%

consize = 4;			% Four Point Peak Definition (for tails)
minI = min(conv(ones(1,consize)/consize,[zeros(1,consize) (newtrace-leaks*PX) zeros(1,consize)]));
fprintf(1,'%6.1f\n',minI);

HLmin = line(newtime,minI*ones(size(newtime)),'Color',[0 0 1]);

%%
%% 	GET FIGURE INFORMATION AND UPDATE

FInfo = get(apwHandle,'UserData');
FInfo(2,2) = Hleaksub;

set(apwHandle,'UserData',FInfo);
set(Hleaksub,'UserData',TP);
