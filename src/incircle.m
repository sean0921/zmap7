function incircle() % autogenerated function wrapper
 % turned into function by Celso G Reyes 2017
 
ZG=ZmapGlobal.Data; % used by get_zmap_globals

%   Matlab script to input initial parameters for circle0 routine
%   in main Map Window
%                                                R. Zuniga, 6/94

report_this_filefun(mfilename('fullpath'));
%
if isempty(ZG.newcat), ZG.newcat = a; end   % verify whether to start with
% original catalogue
% make the interface for input
%
figure(mess);
clf;
cla;
set(gcf,'Name','Circle-Map Control Panel');
%  set(gcf,'visible','off');
set(gca,'visible','off');
set(gcf,'pos',[ 0.22  0.4 0.30 0.30])

%
freq_field1=uicontrol('Style','edit',...
    'Position',[.80 .70 .15 .10],...
    'Units','normalized','String',num2str(ni),...
    'callback',@callbackfun_001);

freq_field2=uicontrol('Style','edit',...
    'Position',[.80 .55 .15 .10],...
    'Units','normalized','String',num2str(rad),...
    'callback',@callbackfun_002);

freq_field3=uicontrol('Style','edit',...
    'Position',[.70 .40 .22 .10],...
    'Units','normalized','String',num2str(ya0,5),...
    'callback',@callbackfun_003);

freq_field4=uicontrol('Style','edit',...
    'Position',[.70 .25 .22 .10],...
    'Units','normalized','String',num2str(xa0,6),...
    'callback',@callbackfun_004);

close_button=uicontrol('Style','Pushbutton',...
    'Position',[.05 .85 .15 .1 ],...
    'Units','normalized','Callback',@(~,~)zmap_message_center(),'String','Cancel');

button1=uicontrol('Style','Pushbutton',...
    'Position',[.35 .15 .3 .1 ],...
    'Units','normalized',...
    'callback',@callbackfun_005,...
    'String','Center by Cursor');

button2=uicontrol('Style','Pushbutton',...
    'Position',[.10 .05 .2 .1 ],...
    'Units','normalized',...
    'callback',@callbackfun_006,...
    'String','Fix Radius');

button3=uicontrol('Style','Pushbutton',...
    'Position',[.70 .05 .3 .1 ],...
    'Units','normalized',...
    'callback',@callbackfun_007,...
    'String','ni Closest Events');

txt5 = text(...
    'Position',[0. 0.75 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'FontWeight','bold',...
    'String','Number of events (ni):');

txt4 = text(...
    'Position',[0. 0.58 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'FontWeight','bold',...
    'String','Radius (km):');

txt3 = text(...
    'Position',[0. 0.41 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'FontWeight','bold',...
    'String','Latitude of center:');

txt2 = text(...
    'Position',[0. 0.24 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'FontWeight','bold',...
    'String','Longitude of center:');

set(gcf,'visible','on');



function callbackfun_001(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  ni=str2double(freq_field1.String);
   freq_field1.String=num2str(ni);
end
 
function callbackfun_002(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  rad=str2double(freq_field2.String);
   freq_field2.String=num2str(rad);
end
 
function callbackfun_003(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  ya0=str2double(freq_field3.String);
   freq_field3.String=num2str(ya0,6);
end
 
function callbackfun_004(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  xa0=str2double(freq_field4.String);
   freq_field4.String=num2str(xa0,6);
end
 
function callbackfun_005(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
   ic = 1;
   circle0;
end
 
function callbackfun_006(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  zmap_message_center();
   ic = 2;
   circle0;
end
 
function callbackfun_007(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  zmap_message_center();
  ic = 3;
   circle0;
end
 
end
