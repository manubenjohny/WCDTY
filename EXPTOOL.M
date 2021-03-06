function expTool(item)

%	EXPTOOL.M	Function Deals with Exponential fits with Simplex
%			
%

%%	Initialization	

global datafilepath datafilename HFmain;
global x TBlock;
global trace startpoint endpoint I flag fixedparameters;


options = zeros(1,14);
options(1)=0;
options(2)=1.e-4;
options(3)=1.e-4;
options(14)=2000;


% Check that a file has been opened

datafile=[datafilepath datafilename];

if strcmp(datafilename,'0')
	errcall('OPEN A FILE FIRST');
	return;
end


%	FInfo:	Row 1: Handles for GUI


FInfo = get(HFmain,'UserData');			% Get UserData Matrix (handles for GUI and traces)

Hmenu = FInfo(1,12);				% Get Menu Handle
HMexp1 = FInfo(1,13);				% Exp Button Handle
HBexp2 = FInfo(1,14);				% Exp Button Handle


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%							%%
%% 	Perform Action Determined by Passed Argument	%%
%%							%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(item,'menu')				% Menu Toggled (affects button)

	if strcmp(get(Hmenu,'Checked'),'on')
		set(Hmenu,'Checked','off');
		set(HMexp1,'Visible','off');
		set(HMexp1,'Callback','');
		set(HBexp2,'Visible','off');
		set(HBexp2,'Callback','');

	else
		set(Hmenu,'Checked','on');
		set(HMexp1,'Visible','on');
		set(HMexp1,'Callback','exptool(''expfit'')');
		set(HBexp2,'Visible','on');
		set(HBexp2,'Callback','exptool(''wipefit'')');
	end
end

if strcmp(item,'wipefit')
		
	Hfits= 	 FInfo(3,:);			% handles of fits
	FInfo(3,:) = zeros(size(FInfo(3,:)));	
	set(HFmain,'UserData',FInfo);

	if (Hfits(1) ~= 0)
		delete(nonzeros(Hfits(2:length(Hfits))));
	end		
end

if strcmp(item,'expfit')


	% Get Information for the current sweep

	HIDline = FInfo(2,2);
	TP = get(HIDline,'UserData');
	TBlock = TP(3,:);
	
	duration = TBlock(8:11);
	duration(2)=TBlock(12);

	I = TBlock(20);
	
	trace = get(HIDline,'YData');
	time = get(HIDline,'XData');

	select = get(HMexp1,'Value');
		
	% Determine which fit was selected
	
	% 1 - Single Exponential Decay [1SED]
	% 2 - Single Exponential with Offset [1SEO]
	% 3 - Double Exponential Decay [1DED]
	% 4 - Double Decay Fixed Tau   [1DFT]	
	% 5 - 2-Pulse Double Exponential Decay, Same Taus  [2DED]
	% 6 - 2-Pulse Double Exponential Decay, Same Fixed Taus [2DFT]
	% 7 - Activation Rate [1SAR]
	% 8 - Whole Pulse Model [EXPwholePulse]


	if (select==1)	% 1 - Single Exponential Decay [1SED]


		window = input('Enter Region to Fit [pulse start end]: ');
	
		pulse=window(1);
		
		pulse = (pulse-floor((pulse-1)/4)*4); %modulo of sorts
		
		if (window(1) >= 9)

			starttime=window(2)+TBlock(12);
			endtime=window(3)+TBlock(12);
		else
			starttime = window(2);
			endtime = window(3);
		end

		startpoint = TBlock(14+pulse)+round(starttime*1000/TBlock(20)); 
		endpoint = TBlock(14+pulse)+round(endtime*1000/TBlock(20));

		% Define Initial Values for Fit [tau mag]
		
		value1 = mean(trace(startpoint:startpoint+round((endpoint-startpoint)*.1)));
		duration = (endtime-starttime);

		tau = duration;
		mag = value1;
	
		% Call the fitting routine
	
		x = [tau mag];
		%x = fmins('expF1SED',x,options,[],trace,startpoint,endpoint,I,0);
		
        flag = -1;       %0 reduce number of points to fit, -1 full number points to fit
        x = fminsearch('expF1SED',x,options);
                
        %fit = expF1SED(x,trace,startpoint,endpoint,I,1);
		flag = 1;       %full number of points for waveform of fit
        fit = expF1SED(x);
			
		disp('Fit parameters are as follows...');
        fprintf(1,'%3.1f\t',x(1:length(x)-1)),fprintf(1,'%3.1f\n',x(length(x)));
	
		Hfit = line(time(startpoint:endpoint),fit(1:(endpoint-startpoint+1)),'LineWidth', 2,'Color', [1 0 0]);
	
		Hfits = FInfo(3,:);
		Hfits(Hfits(1)+2)= Hfit;
		Hfits(1) = Hfits(1) + 1;
		FInfo(3,:)=Hfits;
		set(HFmain,'UserData', FInfo);

	end

	if (select==2)	% 2 - Single Exponential with Offset [1SEO]



		window = input('Enter Region to Fit [pulse start end]: ');
	
		pulse=window(1);
		pulse = (pulse-floor((pulse-1)/4)*4); %modulo of sorts
		
		if (window(1) >= 9)

			starttime=window(2)+TBlock(12);
			endtime=window(3)+TBlock(12);
		else
			starttime = window(2);
			endtime = window(3);
		end
		
		startpoint = TBlock(14+pulse)+round(starttime*1000/TBlock(20)); 
		endpoint = TBlock(14+pulse)+round(endtime*1000/TBlock(20));

		% Define Initial Values for Fit [tau mag offset]
		
		value1 = mean(trace(startpoint:startpoint+round((endpoint-startpoint)*.1)));
		value2 = mean(trace(startpoint+round((endpoint-startpoint)*.9):endpoint));
		duration = (endtime-starttime);

		mag = value1;
		offset = value2;
		tau = duration;
		
	
		% Call the fitting routine
	
		x = [tau mag offset];
		%x = fmins('expF1SEO',x,options,[],trace,startpoint,endpoint,I,0);
		%fit = expF1SEO(x,trace,startpoint,endpoint,I,1);
		
        flag = 0;
        x = fminsearch('expF1SEO',x,options);
                
        flag = 1;
        fit = expF1SEO(x);
        
		disp('Fit parameters are as follows...');
        fprintf(1,'%3.1f\t',x(1:length(x)-1)),fprintf(1,'%3.1f\n',x(length(x)));
	
		Hfit = line(time(startpoint:endpoint),fit(1:(endpoint-startpoint+1)),'LineWidth', 2,'Color', [1 0 0]);
	
		Hfits = FInfo(3,:);
		Hfits(Hfits(1)+2)= Hfit;
		Hfits(1) = Hfits(1) + 1;
		FInfo(3,:)=Hfits;
		set(HFmain,'UserData', FInfo);

	end

	if (select==3)			% Double Exponential Decay [1DED]

		window = input('Enter Region to Fit [pulse start end]: ');
		
		pulse=window(1);
		pulse = (pulse-floor((pulse-1)/4)*4); %modulo of sorts
		
		if (window(1) >= 9)

			starttime=window(2)+TBlock(12);
			endtime=window(3)+TBlock(12);
		else
			starttime = window(2);
			endtime = window(3);
		end
	
		startpoint = TBlock(14+pulse)+round(starttime*1000/TBlock(20)); 
		endpoint = TBlock(14+pulse)+round(endtime*1000/TBlock(20));

		% Define Initial Values for Fit [tau1 tau2 mag1 mag2]
		
		value1 = mean(trace(startpoint:startpoint+round((endpoint-startpoint)*.1)));
		value2 = mean(trace(startpoint+round((endpoint-startpoint)*.9):endpoint));
		duration = (endtime-starttime);

		mag1 = value1/2;		
		tau1 = duration/10;

		mag2 = value1/2;
		tau2 = duration;
	
		% Call the fitting routine
	
		x = [tau1 tau2 mag1 mag2];
        % 		x = fmins('expF1DED',x,options,[],trace,startpoint,endpoint,I,0);
        % 		fit = expF1DED(x,trace,startpoint,endpoint,I,1);
	
        flag = 0;       %reduce number of points to fit
        x = fminsearch('expF1DED',x,options);
                
        %fit = expF1SED(x,trace,startpoint,endpoint,I,1);
		flag = 1;       %full number of points for waveform of fit
        fit = expF1DED(x);
			
		disp('Fit parameters are as follows...');
		fprintf(1,'%6.1f\t',x(1:length(x)-1)),fprintf(1,'%6.1f\n',x(length(x)));

		Hfit = line(time(startpoint:endpoint),fit(1:(endpoint-startpoint+1)),'LineWidth', 2, 'Color', [1 0 0]);
	
		Hfits = FInfo(3,:);
		Hfits(Hfits(1)+2)= Hfit;
		Hfits(1) = Hfits(1) + 1;
		FInfo(3,:)=Hfits;
		set(HFmain,'UserData', FInfo);
	end

	if (select==4)			% Single Exponential Fixed Taus (2DFT)
			
		window = input('Enter Region to Fit [pulse start end]: ');
		
		pulse=window(1);
		pulse = (pulse-floor((pulse-1)/4)*4); %modulo of sorts
		
		if (window(1) >= 9)

			starttime=window(2)+TBlock(12);
			endtime=window(3)+TBlock(12);
		else
			starttime = window(2);
			endtime = window(3);
		end

		startpoint = TBlock(14+pulse)+round(starttime*1000/TBlock(20)); 
		endpoint = TBlock(14+pulse)+round(endtime*1000/TBlock(20));

		% Define Initial Values for Fit [mag1 mag2]
		
		value1 = mean(trace(startpoint:startpoint+round((endpoint-startpoint)*.1)));
		value2 = mean(trace(startpoint+round((endpoint-startpoint)*.9):endpoint));
		duration = (endtime-starttime);

		mag1 = value1/2;		
		mag2 = value1/2;

		tau1 = input('Enter Fast Tau: ');
		tau2 = input('Enter Slow Tau: ');
	
		% Call the fitting routine
	
		x = [mag1 mag2];
        fixedparameters = [];
        fixedparameters = [tau1 tau2];
        % 		x = fmins('expF1DFT',x,options,[],tau1,tau2,trace,startpoint,endpoint,I,0);
        % 		fit = expF1DFT(x,tau1,tau2,trace,startpoint,endpoint,I,1);
        %
        % 		x = [tau1 tau2 x];
        %
        % 		fprintf(1,'%6.1f\t',x(1:length(x)-1)),fprintf(1,'%6.1f\n',x(length(x)));
        %
        % 		Hfit = line(time(startpoint:endpoint),fit(1:(endpoint-startpoint+1)),'Color', [1 0 0]);

        flag = 0;       %reduce number of points to fit
        x = fminsearch('expF1DFT',x,options);
                
        flag = 1;       %full number of points for waveform of fit
        fit = expF1DFT(x);
		
        x = [tau1 tau2 x];
		disp('Fit parameters are as follows...');
		fprintf(1,'%6.1f\t',x(1:length(x)-1)),fprintf(1,'%6.1f\n',x(length(x)));

		Hfit = line(time(startpoint:endpoint),fit(1:(endpoint-startpoint+1)),'LineWidth', 2, 'Color', [1 0 0]);
        
		Hfits = FInfo(3,:);
		Hfits(Hfits(1)+2)= Hfit;
		Hfits(1) = Hfits(1) + 1;
		FInfo(3,:)=Hfits;
		set(HFmain,'UserData', FInfo);
	end	

	if (select==5)			% 2-Pulse Double Exponential Decay [2DED]
			
		window = zeros(2,3);

		for k = 1:2
		
			d=['Enter Region ' num2str(k) ' to Fit [pulse start end]: '];
			window(k,1:3) = input(d);
			
			pulse(k)=window(k,1);
			pulse(k) = (pulse(k)-floor((pulse(k)-1)/4)*4); %modulo of sorts
		
			if (window(k,1) >= 9)

				starttime(k)=window(k,2)+TBlock(12);
				endtime(k)=window(k,3)+TBlock(12);
			else
				starttime(k) = window(k,2);
				endtime(k) = window(k,3);
			end
			
			startpoint(k) = TBlock(14+pulse(k))+round(starttime(k)*1000/TBlock(20)); 
			endpoint(k) = TBlock(14+pulse(k))+round(endtime(k)*1000/TBlock(20));
		
			value1(k) = mean(trace(startpoint(k):startpoint(k)+round((endpoint(k)-startpoint(k))*.1)));
			value2(k) = mean(trace(startpoint(k)+round((endpoint(k)-startpoint(k))*.9):endpoint(k)));
			duration(k) = (endtime(k)-starttime(k));
		end

		
		% Define Initial Values for Fit [tau1 tau2 mag11 mag12 mag21 mag22]

		mag11 = value1(1)/2;		
		mag12 = value1(1)/2;	
		mag21 = value1(2)/2;		
		mag22 = value1(2)/2;	

		tau1 = 50;
		tau2 = 500;

        % Call the fitting routine
	
         		x = [tau1 tau2 mag11 mag12 mag21 mag22];
        % 		x = fmins('expF2DED',x,options,[],trace,startpoint,endpoint,I,0);
        % 		fit = expF2DED(x,trace,startpoint,endpoint,I,1);

        flag = 0;       %reduce number of points to fit
        x = fminsearch('expF2DED',x,options);
                
        flag = 1;       %full number of points for waveform of fit
        fit = expF2DED(x);
			
		disp('Fit parameters are as follows...');
        fprintf(1,'%6.1f\t',x(1:length(x)-1)),fprintf(1,'%6.1f\n',x(length(x)));
	
		Hfit1 = line([time(startpoint(1):endpoint(1))],...
			    [fit(startpoint(1):endpoint(1))],...
                            'LineWidth', 2,'Color', [1 0 0]);
        Hfit2 = line([time(startpoint(2):endpoint(2))],...
			    [fit(startpoint(2):endpoint(2))],...
                            'LineWidth', 2,'Color', [1 0 0]);
	
		Hfits = FInfo(3,:);
        
		Hfits(Hfits(1)+2)= Hfit1;
		Hfits(1) = Hfits(1) + 1;
        
        Hfits(Hfits(1)+2)= Hfit2;
		Hfits(1) = Hfits(1) + 1;
                
		FInfo(3,:)=Hfits;
		set(HFmain,'UserData', FInfo);
	end	
	
	if (select==6)			% 2-Pulse Double Exponential Fixed Taus (2DFT)
			
		window = zeros(2,3);

		for k = 1:2
		
			d=['Enter Region ' num2str(k) ' to Fit [pulse start end]: '];
			window(k,1:3) = input(d);
			
			pulse(k)=window(k,1);
			pulse(k) = (pulse(k)-floor((pulse(k)-1)/4)*4); %modulo of sorts
		
			if (window(k,1) >= 9)

				starttime(k)=window(k,2)+TBlock(12);
				endtime(k)=window(k,3)+TBlock(12);
			else
				starttime(k) = window(k,2);
				endtime(k) = window(k,3);
			end

			startpoint(k) = TBlock(14+pulse(k))+round(starttime(k)*1000/TBlock(20)); 
			endpoint(k) = TBlock(14+pulse(k))+round(endtime(k)*1000/TBlock(20));
			
			value1(k) = mean(trace(startpoint(k):startpoint(k)+round((endpoint(k)-startpoint(k))*.1)));
			value2(k) = mean(trace(startpoint(k)+round((endpoint(k)-startpoint(k))*.9):endpoint(k)));
			duration(k) = (endtime(k)-starttime(k));
		end

		
		% Define Initial Values for Fit [mag11 mag12 mag21 mag22]

		mag11 = value1(1)/2;
		mag12 = value1(1)/2;	
		mag21 = value1(2)/2;		
		mag22 = value1(2)/2;	

		tau1 = input('Enter Fast Tau: ');
		tau2 = input('Enter Slow Tau: ');
	
		% Call the fitting routine
        
        fixedparameters = [];
        fixedparameters = [tau1 tau2];
		
        x = [mag11 mag12 mag21 mag22];
		
        %         x = fmins('expF2DFT',x,options,[],tau1,tau2,trace,startpoint,endpoint,I,0);
        % 		fit = expF2DFT(x,tau1,tau2,trace,startpoint,endpoint,I,1);
		
        flag = 0;       %reduce number of points to fit
        x = fminsearch('expF2DFT',x,options);
                
        flag = 1;       %full number of points for waveform of fit
        fit = expF2DFT(x);
                
		x = [tau1 tau2 x];
        disp('Fit parameters are as follows...');
		fprintf(1,'%6.1f\t',x(1:length(x)-1)),fprintf(1,'%6.1f\n',x(length(x)));
	
        % 		Hfit = line([time(startpoint(1):endpoint(2))],...
        % 			    [fit(startpoint(1):endpoint(2))],...
        %                             'Color', [1 0 0]);
	
        Hfit1 = line([time(startpoint(1):endpoint(1))],...
			    [fit(startpoint(1):endpoint(1))],...
                            'LineWidth', 2,'Color', [1 0 0]);
        Hfit2 = line([time(startpoint(2):endpoint(2))],...
			    [fit(startpoint(2):endpoint(2))],...
                            'LineWidth', 2,'Color', [1 0 0]);
        
		Hfits = FInfo(3,:);
        
        Hfits(Hfits(1)+2)= Hfit1;
		Hfits(1) = Hfits(1) + 1;
        
        Hfits(Hfits(1)+2)= Hfit2;
		Hfits(1) = Hfits(1) + 1;
        
		FInfo(3,:)=Hfits;
		set(HFmain,'UserData', FInfo);
	end	

	if (select==7)	% 1 - Single Exponential Activation Rate [1SAR]

        hill_exp = input('Enter Hill Coefficient: ');
			
		        
		% Expand Region
		
		disp('Select Region to expand with the Mouse')

		[x1 y button] = ginput(1);	
		[x2 y2 button] = ginput(1);	
		set(gca,'Xlim',[x1 x2]);
		
		disp(' ')
		disp('Select Region [start plateau] with the Mouse')
		disp(' ')
		windowOK=0;

		while (windowOK==0)
			
			[x1 y button] = ginput(1);	
			ylim = get(gca,'YLim');
			Hline1 = line([x1 x1],ylim,'Color',[0 0 1]);

			[x2 y2 button] = ginput(1);	
			ylim = get(gca,'YLim');
			Hline2 = line([x2 x2],ylim,'Color',[0 0 1]);
			
			disp('left click to exit, right click to repeat...')
            [x, y, b] = ginput(1);
			if (b==1)
				windowOK=1;
            else
                delete(Hline1);
                delete(Hline2);
			end
		end
		
		pulse = 1;
		starttime = x1;
		endtime = x2;

		startpoint = TBlock(14+pulse)+round(starttime*1000/TBlock(20)); 
		endpoint = TBlock(14+pulse)+round(endtime*1000/TBlock(20));

		% Define Initial Values for Fit [tau mag]
		
		tau = endtime-starttime;
		mag = trace(endpoint);
	
		% Call the fitting routine
        fixedparameters = [];
        fixedparameters = [hill_exp];
		x = [tau mag];
        % 		x = fmins('expF1SAR',x,options,[],trace,startpoint,endpoint,I,0);
        % 		fit = expF1SAR(x,trace,startpoint,endpoint,I,1);
		
        flag = -1;       %reduce number of points to fit
        x = fminsearch('expF1SAR',x,options);
                
        flag = 1;       %full number of points for waveform of fit
        fit = expF1SAR(x);
			
		x = [hill_exp x];
        disp('Fit parameters are as follows...');	
		fprintf(1,'%3.1f\t',x(1:length(x)-1)),fprintf(1,'%3.1f\n',x(length(x)));
	
		Hfit = line(time(startpoint:endpoint),fit(1:(endpoint-startpoint+1)),'Color', [1 0 0]);
	
		Hfits = FInfo(3,:);
		Hfits(Hfits(1)+2)= Hfit;
		Hfits(1) = Hfits(1) + 1;
		FInfo(3,:)=Hfits;
		set(HFmain,'UserData', FInfo);
		
		delete(Hline1);
		delete(Hline2);

    end

%     if (select==8)			% Fit Two Pulses with Model in Which Taus of RFI
% 					% are calculated
% 			
% 		window = zeros(2,3);
% 
% 		for k = 1:2
% 		
% 			d=['Enter Region ' num2str(k) ' to Fit [pulse start end]: '];
% 			window(k,1:3) = input(d);
% 			pulse(k)=window(k,1);
% 			starttime(k) = window(k,2);
% 			endtime(k) = window(k,3);
% 
% 			startpoint(k) = TBlock(14+pulse(k))+round(starttime(k)/1000/TBlock(20)); 
% 			endpoint(k) = TBlock(14+pulse(k))+round(endtime(k)/1000/TBlock(20));
% 		end
% 
% 		
% 		% Define Initial Values for Fit [mag11 mag12 tauI1 tauI2 tauR1 tauR2]
% 		
% 		mag11 = trace(startpoint(1))/2;		% pA
% 		mag12 = trace(startpoint(1))/2;	
% 		
% 		tauI1 = 50;
% 		tauI2 = 500;
% 
% 		tauR1 = 300;		
% 		tauR2 = 1000;	
% 	
% 		% Call the fitting routine
% 	
% 		x = [mag11 mag12 tauI1 tauI2 tauR1 tauR2];
% 		x = fmins('expFMDL',x,options,[],trace,startpoint,endpoint,duration,I,0);
% 		fit = expFMDL(x,trace,startpoint,endpoint,duration,I,1);
% 		
% 		fprintf(1,'%6.1f\t',x(1:length(x)-1)),fprintf(1,'%6.1f\n',x(length(x)));
% 	
% 		Hfit = line([time(startpoint(1):endpoint(2))],...
% 			    [fit(startpoint(1):endpoint(2))],...
%                             'Color', [1 0 0]);
% 	
% 		Hfits = FInfo(3,:);
% 		Hfits(Hfits(1)+2)= Hfit;
% 		Hfits(1) = Hfits(1) + 1;
% 		FInfo(3,:)=Hfits;
% 		set(HFmain,'UserData', FInfo);
%     end
 
    if (select==8)			% Fit Complete Pulse with activation
                            % are calculated
			
	window = input('Enter Region to Fit [pulse start end]: ');
		
		pulse=window(1);
		pulse = (pulse-floor((pulse-1)/4)*4); %modulo of sorts
		
		if (window(1) >= 9)

			starttime=window(2)+TBlock(12);
			endtime=window(3)+TBlock(12);
		else
			starttime = window(2);
			endtime = window(3);
		end

		startpoint = TBlock(14+pulse)+round(starttime*1000/TBlock(20)); 
		endpoint = TBlock(14+pulse)+round(endtime*1000/TBlock(20));

		% Define Initial Values for Fit [mag1 mag2]
		
		value1 = mean(trace(startpoint:startpoint+round((endpoint-startpoint)*.1)));
		value2 = mean(trace(startpoint+round((endpoint-startpoint)*.9):endpoint));
		duration = (endtime-starttime);

		mag1 = value1/2;		
		mag2 = value1/2;
        
        magtot = mag1 + mag2;
        hill_exp = input('Enter Initial Hill Coefficient for Activation: ');
        tau0 = input('Enter Initial Activation Tau: ');
		tau1 = input('Enter Initial Fast Inactivation Tau: ');
		tau2 = input('Enter Initial Slow Inactivation Tau: ');
        Ffast = input('Enter Initial Fraction of Fast Inactivation: ');
	
        
		% Call the fitting routine
	
		x = [magtot hill_exp tau0 tau1 tau2 Ffast];
        
        % 		x = fmins('expF1DFT',x,options,[],tau1,tau2,trace,startpoint,endpoint,I,0);
        % 		fit = expF1DFT(x,tau1,tau2,trace,startpoint,endpoint,I,1);
        %
        % 		x = [tau1 tau2 x];
        %
        % 		fprintf(1,'%6.1f\t',x(1:length(x)-1)),fprintf(1,'%6.1f\n',x(length(x)));
        %
        % 		Hfit = line(time(startpoint:endpoint),fit(1:(endpoint-startpoint+1)),'Color', [1 0 0]);

        flag = -1;       %reduce number of points to fit
        x = fminsearch('EXPwholePulse',x,options);
                
        flag = 1;       %full number of points for waveform of fit
        fit = EXPwholePulse(x);
		
        disp('Fit parameters are as follows...');
		fprintf(1,'%6.1f\t',x(1:length(x)-1)),fprintf(1,'%6.1f\n',x(length(x)));

		Hfit = line(time(startpoint:endpoint),fit(1:(endpoint-startpoint+1)),'LineWidth', 2, 'Color', [1 0 0]);
        
		Hfits = FInfo(3,:);
		Hfits(Hfits(1)+2)= Hfit;
		Hfits(1) = Hfits(1) + 1;
		FInfo(3,:)=Hfits;
		set(HFmain,'UserData', FInfo);
    end	
    
    disp('Fit copied to clipboard...');
    if length(startpoint) == 1
        CopyToClipboard( [time(startpoint:endpoint)' fit(1:(endpoint-startpoint+1))'],[],[] );
    elseif length(startpoint) > 1
        CopyToClipboard( [time(1:end)' fit(1:end)'],[],[] );
    end
    
end