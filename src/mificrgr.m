function mificrgr() % autogenerated function wrapper
    % This function creates a grid with spacing dx, dy (in degrees)
    % The size is selected interactively in an input window.
    % The relative quiescence will be calculated for every grid point
    % for a specific time and plotted in a Seismolap-Quiescence map
    % mifigrid.m                              Alexander Allmann
    %
    % turned into function by Celso G Reyes 2017
    
    
    %global freq_field1 freq_field2 freq_field3 freq_field4 freq_field5
    %global freq_field6 ni mi me1 va1
    %global h1 map dx dy Mmin lap1 seismap
    %global normlap1 normlap2 mif1 mifmap
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun(mfilename('fullpath'));
    
    %input window
    %
    %default parameters
    dx= .5;                      %grid spacing east-west
    dy= .5;                      %grid spacing north-south
    %ldx=100;                     %side length of interaction zone in km (for seislap)
    %tlap=300;                    %interaction time in days (for seislap)
    Mmin=3;                      %minimum magnitude
    ni=100; % number of events
    
    %create a input window
    fig=figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'MenuBar','none',...
        'Position',[ ZG.wex+200 ZG.wey-200 700 250]);
    axis off
    
    gridOpts = GridParameterChoice(fig,'grid',[],{dx,'lon'},{dy,'lon'});
    selOpts = EventSelectionChoice(fig,'evsel',[],ni,[]);
    
    
    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.70 .05 .15 .12 ],...
        'Units','normalized','callback',@callbackfun_cancel,'String','Cancel');
    
    
    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'callback',@callbackfun_go,...
        'String','Go');
    
    set(gcf,'visible','on');
    watchoff
    
    function my_calculate()
        
        xsec_h=xsec_fig();
        
        if isempty(xsec_h) % best guess at figure handle variable
            nlammap
        else
            figure(xsec_h);
        end
        
        hold on
        ax=findobj(gcf,'Tag','mainmap_ax');
        [x,y, mouse_points_overlay] = select_polygon(ax);
        
        
        figure(xsec_h)
        
        plos2 = plot(x,y,'b-');        % plot outline
        sum3 = 0.;
        pause(0.3)
        
        %create a rectangular grid
        xvect=[min(x):dx:max(x)];
        yvect=[min(y):dy:max(y)];
        tmpgri=zeros((length(xvect)*length(yvect)),2);
        n=0;
        for i=1:length(xvect)
            for j=1:length(yvect)
                n=n+1;
                tmpgri(n,:)=[xvect(i) yvect(j)];
            end
        end
        %extract all gridpoints in chosen polygon
        XI=tmpgri(:,1);
        YI=tmpgri(:,2);
        
        ll = polygon_filter(x,y, XI, YI, 'inside');
        %grid points in polygon
        newgri=tmpgri(ll,:);
        
        % Plot all grid points
        gcf
        plot(newgri(:,1),newgri(:,2),'+k')
        drawnow
        
        if length(xvect) < 2  ||  length(yvect) < 2
            errordlg('Selection too small! (not a matrix)');
            return
        end
        
        
        
        %
        ZG.newcat=a;                   %ZG.newcat is only a local variable
        bcat=ZG.newcat;
        
        me1=zeros(length(newgri(:,1)),1);
        va1=zeros(length(newgri(:,1)),1);
        mic = mi(inde,:);
        
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Makegrid - Percent completed');
        drawnow
        
        for i= 1:length(me1)   %all eqs which are in spacewindow in east-west direction
            x = newgri(i,1);y = newgri(i,2);
            
            l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
            [s,is] = sort(l);
            b = ZG.newcat.subset(is) ;       % re-orders matrix to agree row-wise
            mi2 = mic(is(:,1),2);    % take first ni points
            mi2 = mi2(1:ni);
            me1(i) = mean(mi2);
            va1(i) = std(mi2);
            if rem(i,20)==0;  waitbar(i/length(me1));end
        end
        
        
        close(wai)
        %make a color map
        % Find out if figure already exists
        %
        mifmap=findobj('Type','Figure','-and','Name','Misfit-Map 2');
        
        % Set up the Seismicity Map window Enviroment
        %
        if isempty(mifmap)
            mifmap = figure_w_normalized_uicontrolunits( ...
                'Name','Misfit-Map 2',...
                'NumberTitle','off', ...
                'NextPlot','replace', ...
                'backingstore','on',...
                'Visible','off', ...
                'Position',[ 600 400 500 650]);
            % make menu bar
            
            
            
            hold on
        end
        
        figure(mifmap);
        delete(findobj(mifmap,'Type','axes'));
        
        set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on','SortMethod','childorder')
        
        %minimum and maximum of normlap2 for automatic scaling
        ZG.maxc = max(normlap2);
        ZG.minc = min(normlap2);
        
        %construct a matrix for the color plot
        normlap1=ones(length(tmpgri(:,1)),1);
        normlap2=nan(length(tmpgri(:,1)),1)
        normlap3=nan(length(tmpgri(:,1)),1)
        normlap1(ll)=me1;
        normlap2(ll)=normlap1(ll);
        normlap1(ll)=va1;
        normlap3(ll)=normlap1(ll);
        
        normlap2=reshape(normlap2,length(yvect),length(xvect));
        normlap3=reshape(normlap3,length(yvect),length(xvect));
        
        %plot color image
        orient tall
        gx = xvect; 
        gy = yvect;
        memifig
        
        return
        
        rect = [0.25,  0.60, 0.7, 0.35];
        axes('position',rect)
        hold on
        pco1 = pcolor(xvect,yvect,normlap2);
        shading interp
        colormap(jet)
        %axis([ s2 s1 s4 s3])
        axis([ min(gx) max(gx) min(gy) max(gy)])
        axis image
        
        hold on
        colorbar
        if exist('maex', 'var')
            hold on
            pl = plot(maex,-maey,'*m');
            set(pl,'MarkerSize',8,'LineWidth',2)
        end
        
        %overlay
        title('Mean of the Misfit','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        xlabel('Distance in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on','TickDir','out')
        
        rect = [0.25,  0.10, 0.7, 0.35];
        axes('position',rect)
        hold on
        pco1 = pcolor(xvect,yvect,normlap3);
        axis([ min(gx) max(gx) min(gy) max(gy)])
        axis image
        
        if exist('maex', 'var')
            hold on
            pl = plot(maex,-maey,'*w');
            set(pl,'MarkerSize',8,'LineWidth',2)
        end
        
        
        hold on
        shading interp
        colormap(jet)
        hold on
        colorbar
        title(' Variance of the Misfit','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        xlabel('Distance in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on','TickDir','out')
        
    end
    
    function callbackfun_cancel(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
    end
    
    function callbackfun_go(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dx=gridOpts.dx;
        dy=gridOpts.dy;
        ni=selOpts.ni;
        delete(gridOpts);
        delete(selOpts);
        close;
        my_calculate();
    end
    
end
