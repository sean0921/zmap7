function cirpva() 
    % unclear purpose, having to do with a circle selection
%   This subroutine "circle"  selects the Ni closest earthquakes
%   around a interactively selected point.  Resets ZG.newcat and ZG.newt2
%   Operates on "primeCatalog".
 % turned into function by Celso G Reyes 2017
 
ZG=ZmapGlobal.Data; % used by get_zmap_globals

%  Input Ni:
%
report_this_filefun();
ZG=ZmapGlobal.Data;

delete(findobj('Tag','plos1'));

axes(h1)
%zoom off

titStr ='Selecting EQ in Circles                         ';
messtext= ...
    ['                                                '
    '  Please use the LEFT mouse button              '
    ' to select the center point.                    '
    ' The "ni" events nearest to this point          '
    ' will be selected and displayed in the map.     '];

msg.dbdisp(messtext, titStr);

% Input center of circle with mouse
%
[xa0,ya0]  = ginput(1);

stri1 = [ 'Circle: ' num2str(xa0,5) '; ' num2str(ya0,4)];
stri = stri1;
pause(0.1)

if met == 'ni'
    % take first ni and sort by time
    [ZG.newt2, max_rad] = ZG.primeCatalog.selectClosestEvents(ya0, xa0, [], ni);
    messtext = ['Radius of selected Circle:' num2str(maxrad)  ' km' ];
    disp(messtext)
elseif  met == 'ra'
    ZG.newt2 = ZG.primeCatalog.selectRadius(ya0, xa0, ra,'kilometer');
    messtext = ['Number of selected events: ' num2str(ZG.newt2.Count)  ];
    disp(messtext)
elseif met == 'ti'
    global t1 t2 t3 t4
    ZG.newt2 = copy(ZG.primeCatalog);
    lt =  ZG.newt2.Date >= t1 &  ZG.newt2.Date <t2 ;
    bdiff(ZG.newt2.subset(lt));
    ZG.hold_state=true;
    lt =  ZG.newt2.Date >= t3 &  ZG.newt2.Date <t4 ;
    bdiff(ZG.newt2.subset(lt));

end
R2 = ra;

%
% plot Ni clostest events on map as 'x':

set(gca,'NextPlot','add')
plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'xk','Tag','plos1');

% plot circle containing events as circle
x = -pi-0.1:0.1:pi;
pl = plot(xa0+sin(x)*R2/(cosd(ya0)*111), ya0+cos(x)*R2/(cosd(ya0)*111),'k')


set(gcf,'Pointer','arrow')

%
newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2

        ZG=ZmapGlobal; 
        ctp=CumTimePlot(ZG.newt2);
        ctp.plot();
MyPvalClass.pvalcat

end
