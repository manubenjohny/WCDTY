function keystroke(obj, evd)
global HFmain
FInfo = get(HFmain,'UserData'); 
HGUI = 	 FInfo(1,:);
hlistbox = HGUI(21);

switch evd.Key
    case 'return'
        wcivcal300()
    case 'comma'
        newswp('back')
    case 'period'
        newswp('next')        
    case 'rightarrow'
        newrun('next')
    case 'leftarrow'
        newrun('back')
    case 'downarrow'
        cur = get(hlistbox, 'value');
        maxval  = length(get(hlistbox,'string'));
        if cur<maxval
            set(hlistbox, 'value', cur+1)
            NEWFILE_LBox
        end
    case 'uparrow'
        cur = get(hlistbox, 'value');
        if cur>1
            set(hlistbox, 'value', cur-1)
            NEWFILE_LBox
        end        
    case 'space'
        holdswp('keep')
    case 'escape'
        holdswp('wipe')
    case 'c'
        print -dmeta        
    case 'hyphen'
        scale(0.99)
    case 'equal'
        scale(1.01)
end