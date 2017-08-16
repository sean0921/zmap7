function mi_ma() % autogenerated function wrapper
%  misfit_magnitude
% August 95 by Zhong Lu
 % turned into function by Celso G Reyes 2017
 
ZG=ZmapGlobal.Data; % used by get_zmap_globals

report_this_filefun(mfilename('fullpath'));

figNumber=findobj('Type','Figure','-and','Name','Misfit as a Function of Magnitude');



if isempty(figNumber)
    mif88 = figure_w_normalized_uicontrolunits( ...
        'Name','Misfit as a Function of Magnitude',...
        'NumberTitle','off', ...
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [300 500]) ZmapGlobal.Data.map_len]);

    
    
    hold on

end
figure_w_normalized_uicontrolunits(mif88)
hold on


plot(ZG.a.Magnitude,mi(:,2),'go');

grid
%set(gca,'box','on',...
%        'SortMethod','childorder','TickDir','out','FontWeight',...
%        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2);

xlabel('Magnitude of Earthquake','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
ylabel('Misfit Angle ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
hold off;

done

end
