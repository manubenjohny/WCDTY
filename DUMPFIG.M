function dumpfig

%%
%%	DUMPFIG.M	Allows for Annotation Before Printing
%%


A = [''];

disp('Select Location for Annotation');
[x,y,button]=ginput(1);
Htext = text(x,y,A);

%while (button ~= 13)
%
%	[junk1,junk2,button]=ginput(1);
%
%	if (button == 8) & (length(A) > 0)
%		
%		A = get(Htext,'String');
%		A=A(1:length(A)-1);
%		set(Htext,'String',A);
%
%	elseif (button ~= 13)
%
%		char = setstr(button)';
%		A = get(Htext,'String');
%		A = [A char];
%		set(Htext,'String',A);
%	end
%end

A = input('Enter Annotation Text: ','s');
set(Htext,'String',A);

print;
delete(Htext);
