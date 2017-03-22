function good(hObject,~,~)
global g;
itm = get(hObject,'String');
    sel = get(hObject,'Value');
    g.GoodParams.(get(hObject,'Tag'))=str2double(itm{sel});
end %place the goodness to change in the popup tag, and this function will set it to the popup value.
