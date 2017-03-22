function checkboxvalue(hObject, ~, ~) %as with paramstoggle, place the handle of the uibutton whose tag you want to control with checkbox in the checkbox's tag
global g;
g.(get(hObject,'Tag')).Tag=num2str(get(hObject,'Value'));
end
