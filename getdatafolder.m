function result = getdatafolder(varargin)
    global datafilepath HFmain;
    if nargin == 0
        datafilepath = uigetdir('C:\Users\manu\Documents');
        datafilepath = [datafilepath '\'];
    else
        FInfo = get(HFmain,'UserData'); 
        HGUI = 	 FInfo(1,:);        
        DirFilter = get(HGUI(25),'string');
        if ischar(varargin{1})
            datafilepath = varargin{1};
        end
        myfiles = dir([datafilepath DirFilter]);
        myfiles = myfiles(3:end);        
        numfiles = length(myfiles);
        datafilename = cell(numfiles,1);
        k = 1;
        for j = 1:numfiles      %3:numfiles
            datafile = [datafilepath myfiles(j).name];    
            datafileID = fopen(datafile,'rb');
            [dirblock,count]=fread(datafileID,256,'short');
            if ~isempty(dirblock)
            maxrun=dirblock(1);
            fclose(datafileID);
            if maxrun>0
                datafilename{k} = [myfiles(j).name];
                k = k +1;
            end
            end
        end
        FInfo = get(HFmain,'UserData'); 
        HGUI = 	 FInfo(1,:);        
        Hlistbox = HGUI(21);
        set(Hlistbox, 'string',datafilename);        
    end