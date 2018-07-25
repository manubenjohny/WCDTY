function lopass

% 	LOPASS.M 	Program Takes a Trace and Lopass (Gaussian) Filters it.


%	T: sampling interval in seconds, 
%	N: number of points in the trace
%	fc: desired cutoff frequency in hz
%	trace: a row vector containing the data
% 	returns a row vector also

global datafilepath datafilename HFmain;
global trace TBlock;


% Get the Trace and Important Variables


	FInfo = get(HFmain,'UserData');			% Get UserData Matrix (handles for GUI and traces)

	% Get Information for the current sweep

	HIDline = FInfo(2,2);
	
	trace = get(HIDline,'YData');	% input trace (column vector)
	time = get(HIDline,'XData');

% Initialize Variables

	T = (time(2)-time(1))/1000;
	N = length(trace);

% Calculate Important Intermediate Variables

fc = input('Enter Cutoff Frequency: ');
%display('Automatically selected 500 Hz');
%fc = 500;

wc=2*pi*fc;							% Lopass cutoff
t=0:T:T*(N-1);							% time vector

N2=2^ceil(log(N)/log(2));					% next power of 2

w=0:2*pi/(N2*T):2*pi*(N2-1)/(N2*T);				% radians/sec 0:2*pi/T
w(N2/2+2:N2)=-2*pi/(2*T)+2*pi/(N2*T):2*pi/(N2*T):-2*pi/(N2*T);	% Adjust so +/- 2*pi/2T
f=w./(2*pi);							% Hz

% Calculate Fourier Transform of trace

spectrum1=fft(trace,N2);		

% Do Filter Calculation X(w)/H(w)

H3=GAUSS(w,wc,T);			% Gaussian Filter

trace3=real(ifft(H3.*spectrum1));
ftrace=trace3(1:N);
	
set(HIDline,'YData',ftrace);	
