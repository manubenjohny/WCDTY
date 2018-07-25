function isoTool(item)

%%
%%	ISOTOOL.M	Function Deals with Isochronal Measurements
%%			Default windows and increments are defined in wcinit
%%

global datafilepath datafilename HFmain;
global conv;

% Check that a file has been opened

datafile=[datafilepath datafilename];

if strcmp(datafilename,'0')
	errcall('OPEN A FILE FIRST');
	return;
end

%	FInfo:	Row 1: Handles for GUI


FInfo = get(HFmain,'UserData');			% Get UserData Matrix (handles for GUI and traces)

Hmenu = FInfo(1,8);				% Get Menu Handle
HBisoInc = FInfo(1,9);				% Increment Handle
HBisoReset = FInfo(1,10);			% Reset Handle
HBisoWin = FInfo(1,11);
HBisoCon = FInfo(1,17);

if strcmp(item,'menu')				% Menu Toggled (affects button)

	if strcmp(get(Hmenu,'Checked'),'on')
		set(Hmenu,'Checked','off');
		set(HBisoInc,'Visible','off');
		set(HBisoInc,'Callback','');
		set(HBisoCon,'Visible','off');
		set(HBisoCon,'Callback','');
		set(HBisoReset,'Visible','off');
		set(HBisoReset,'Callback','');
		set(HBisoWin,'Visible','off');
		set(HBisoWin,'Callback','');
	else
		set(Hmenu,'Checked','on');
		set(HBisoInc,'Visible','on');
		set(HBisoInc,'Callback','isoTool(''increment'')');
		set(HBisoCon,'Visible','on');
		set(HBisoCon,'Callback','isoTool(''setconv'')');
		set(HBisoReset,'Visible','on');
		set(HBisoReset,'Callback','isoTool(''reset'')');
		set(HBisoWin,'Visible','on');
		set(HBisoWin,'Callback','isoTool(''window'')');
		
	end
end

if strcmp(item,'window')

		disp('Define Windows for Isochronal Measurement')
		disp(' ')
	
		A = zeros(10,6);	
		W = [0 0 0];
		I = [0 0 0];
		count = 1;
		
		while (W ~= [])

			W = input('Enter a Window [Pulse Start End]: ');
			
			if (W ~=[])
				I = input('Enter an Increment [Pulse Start End]: '); 
				
				if (I ~= [])
					A(count,4:6) = I;
				else
					A(count,4:6) = [0 0 0];
				end				
				A(count,1:3) = W;
				count = count + 1;
			end	
		end
		
		set(Hmenu,'UserData',A);
		set(HBisoReset,'UserData',A(:,1:3));
end

if strcmp(item,'setconv')
	
	convalue = get(HBisoCon,'String');

	if strcmp(convalue, 'Pk: Tail')
	
		set(HBisoCon,'String','Pk: Pulse');
	end
	
	if strcmp(convalue, 'Pk: Pulse')
	
		set(HBisoCon,'String','Pk: Tail');
	end

end

if strcmp(item,'increment')
	
	A = get(Hmenu,'UserData');
	A(:,1:3) = A(:,1:3)+A(:,4:6);
	set(Hmenu,'UserData',A);
	
end

if strcmp(item,'reset')
	
	A = get(Hmenu,'UserData');
	R = get(HBisoReset,'UserData');
	A(:,1:3) = R;
	set(Hmenu,'UserData',A);	
end

%	Refresh the current trace and replot it

HIDline = FInfo(2,2);

TP = get(HIDline,'UserData');

datafile = setstr(nonzeros(TP(1,:))');
rnum = TP(2,1);
swpnum = TP(2,3);

plotswp(datafile,rnum,swpnum);