function tracetogglebutton(hObject,~,fid,index,beadnum,AssertNorm)
global g;
% set the visibility of the window to the value of the togglebutton (ie on or off)
    if AssertNorm
        if get(hObject,'Value')
            g.FIGS.plot(fid).bead(beadnum).norm(index).Visible = 'On';
        else
            g.FIGS.plot(fid).bead(beadnum).norm(index).Visible = 'Off';
        end
    else
        if get(hObject,'Value')
            g.FIGS.plot(fid).bead(beadnum).smooth(index).Visible = 'On';
        else
            g.FIGS.plot(fid).bead(beadnum).smooth(index).Visible = 'Off';
        end
    end
end %toggles visibility of paramters
