function kids(handle)

x=sort(get(handle,'Children'));

for y = 1:length(x)
	z= get(x(y),'Type');
	if strcmp(z,'uicontrol')
	  z = [z ':  ' get(x(y),'Style')];
	end
	z = [num2str(x(y)) ' ' z];
	disp(z);
end