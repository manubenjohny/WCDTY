function aptrain(tlim,threshold)

%%
%%	APTRAIN	Gives Peak Values in APW Train for Current Sweep
%%

global locations values;

%%%%%%%%%%%%%%%%%%%%%%%%% Get The Sweep %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FInfo = get(gcf,'UserData');

HGUI = 	 FInfo(1,:);			% GUI Handles
Hlines = FInfo(2,:);			% Line Handles
Hdel= 	 FInfo(4,:);			% Objects to Delete for Refresh

Hcurrent = Hlines(2);

t = 	get(Hcurrent,'XData');
pA = 	get(Hcurrent,'YData');
TP = 	get(Hcurrent,'UserData');
TBlock = TP(3,:);

% Extract Information from TP

swpnum = TP(2,3);

%%%%%%%%%%%%%%%%%%%%%%%% Find Peak Values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xlim = [0 0];
xlim(1)= min(find(t >= tlim(1)));
xlim(2)= max(find(t <= tlim(2)));

y = pA(xlim(1):xlim(2));

consize = 3;
y = conv(ones(1,consize)/consize, y);
shift = floor(consize/2);
y = y(shift+1:length(y)-shift);

time = t(xlim(1):xlim(2));

minI = min(y);

y2 = y;
y2(find(y > minI/threshold)) = zeros(size(find(y > minI/threshold)));
d = [diff(y2) 0];
d2 = find(d > 0);
d3 = [0 find(diff(d2)>10)] + 1;

values = y(d2(d3));
locations = time(d2(d3));

%%%%%%%%%%%%%%%%%%%%%%%%% Plot Sweep on Axes %%%%%%%%%%%%%%%%%%%%%%%%%

Hline=line(locations,values,'LineStyle','o','Color',[0 0 1]);

Hdel(Hdel(1)+2)= Hline;
Hdel(1) = Hdel(1) + 1;

%%%%%%%%%%%%%%%%%%%%%%%%% Update UserData Matrix %%%%%%%%%%%%%%%%%%%%%

FInfo = get(gcf,'UserData');				% Get UserData Matrix (handles for GUI and traces)
FInfo(1,:)=HGUI;					% GUI Handles
FInfo(2,:)=Hlines;					% Line Handles
FInfo(4,:)=Hdel;					% Objects to Delete for Refresh
set(gcf,'UserData', FInfo);				% Write to UserData

%%%%%%%%%%%%%%%%%%%%%%%%% Print Values %%%%%%%%%%%%%%%%%%%%%%%%

fprintf(1,'%6.1f\t',values(1:length(values)-1)),fprintf(1,'%6.1f\n',values(length(values)));
fprintf(1,'%6.1f\t',abs(values(1:length(values)-1))),fprintf(1,'%6.1f\n',abs(values(length(values))));
fprintf(1,'%6.3f\t',values(1:length(values)-1)/values(1)),fprintf(1,'%6.3f\n',values(length(values))/values(1));

fidNorm = fopen('c:\pgp\data\a\apwnorm.txt','a+');
fprintf(fidNorm,'%6.3f\t',values(1:length(values)-1)/values(1)),fprintf(fidNorm,'%6.3f\n',values(length(values))/values(1));
fclose(fidNorm);

fidAbs =  fopen('c:\pgp\data\a\apwabs.txt','a+');
fprintf(fidAbs,'%6.1f\t',abs(values(1:length(values)-1))),fprintf(fidAbs,'%6.1f\n',abs(values(length(values))));
fclose(fidAbs);