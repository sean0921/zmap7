classdef ZmapGridFunction < ZmapFunction
    % ZMAPGRIDFUNCTION is a ZmapFunction that produces a grid of 1 or more results as output
    % and can be plotted on a map
    %
    % see also ZMAPFUNCTION
    
    properties
        features='borders'; % features to show on the map, such as 'borders','lakes','coast',etc.
        active_col='';  % the name of the column of the results to be plotted
        showgridcenters=true; % toggle the grid points on and off.
        Grid % ZmapGrid
        EventSelector % how to choose events for the grid points
        Shape % shape to be used 
    end
    properties(Constant,Abstract)
        % array of {VariableNames, VariableDescriptions, VariableUnits}
        % that must contain the VariableNames: 'x', 'y', 'Radius_km', 'Number_of_Events'
        ReturnDetails; 
    end
    
    methods
        function obj=ZmapGridFunction(zap, active_col)
            % ZMAPGRIDFUNCTION constructor  assigns grid, event, catalog, and shape properties
            if isempty(zap)
                zap = ZmapAnalysisPkg.fromGlobal();
            end
            
            ZmapFunction.verify_catalog(zap.Catalog);
            
            obj.EventSelector = zap.EventSel;
            obj.RawCatalog = zap.Catalog;
            obj.Grid = zap.Grid;
            obj.Shape = zap.Shape;
            
            obj.active_col=active_col;
        end
        
        function saveToDesktop(obj)
            % SAVETODESKTOP saves the grid, eventselector and shape before calling superclass
            obj.Result.Grid = obj.Grid;
            obj.Result.EventSelector = obj.EventSelector;
            obj.Result.Shape = obj.Shape;
            
            % super must be called last, since it does the actual writing
            saveToDesktop@ZmapFunction(obj) 
        end
        
        
        function plot(obj,choice, varargin)
            % plots the results on the provided axes.
            if ~exist('choice','var')
                choice=obj.active_col;
            end
            if ~isnumeric(choice)
                choice = find(strcmp(obj.Result.values.Properties.VariableNames,choice));
            end
            
            mydesc = obj.Result.values.Properties.VariableDescriptions{choice};
            myname = obj.Result.values.Properties.VariableNames{choice};
            
            f=findobj(groot,'Tag',obj.PlotTag,'-and','Type','figure');
            if isempty(f)
                f=figure('Tag',obj.PlotTag);
            end
            figure(f);
            set(f,'name',['results from bvalgrid : ', myname])
            delete(findobj(f,'Type','axes'));
            
            % this is to show the data
            obj.Grid.pcolor([],obj.Result.values.(myname), mydesc);
            hold on;
            
            % the imagesc exists is to enable data cursor browsing.
            h=obj.Grid.imagesc([],obj.Result.values.(myname), mydesc);
            h.AlphaData=zeros(size(h.AlphaData))+0.0;
            
            % add some details that can be picked up by the interactive data cursor
            h.UserData.vals= obj.Result.values;
            h.UserData.choice=choice;
            h.UserData.myname=myname;
            h.UserData.myunit=obj.Result.values.Properties.VariableUnits{choice};
            h.UserData.mydesc=obj.Result.values.Properties.VariableDescriptions{choice};
            
            shading(obj.ZG.shading_style);
            hold on
            
            % show grid centers, but don't make them clickable
            gph=obj.Grid.plot(gca,'ActiveOnly');
            gph.Tag='pointgrid';
            gph.PickableParts='none';
            gph.Visible=tf2onoff(obj.showgridcenters);
            
            ft=obj.ZG.features(obj.features);
            copyobj(ft,gca);
            colorbar
            title(mydesc)
            xlabel('Longitude')
            ylabel('Latitude')
            
            dcm_obj=datacursormode(gcf);
            dcm_obj.Updatefcn=@ZmapGridFunction.mydatacursor;
            if isempty(findobj(gcf,'Tag','lookmenu'))
                add_menu_divider();
                lookmenu=uimenu(gcf,'label','graphics','Tag','lookmenu');
                shademenu=uimenu(lookmenu,'Label','shading','Tag','shading');
                exploremenu=uimenu(gcf,'label','explore');
                uimenu(exploremenu,'label','explore','Callback',@(src,ev)mapdata_viewer(obj.Result,gcf));
                uimenu(shademenu,'Label','interpolated','Callback',@(~,~)shading('interp'));
                uimenu(shademenu,'Label','flat','Callback',@(~,~)shading('flat'));
                plottype=uimenu(lookmenu,'Label','plot type');
                uimenu(plottype,'Label','Pcolor plot','Tag','plot_pcolor',...
                    'Callback',@(src,~)obj.plot(choice),'Checked','on');
                uimenu(plottype,'Label','Plot Contours','Tag','plot_contour',...
                    'enable','off',...not fully unimplmented
                    'Callback',@(src,~)obj.contour_cb(choice));
                uimenu(plottype,'Label','Plot filled Contours','Tag','plot_contourf',...
                    'enable','off',...not fully unimplmented
                    'Callback',@(src,~)contourf_cb(choice));
                uimenu(lookmenu,'Label','change contour interval','Enable','off',...
                    'callback',@(src,~)changecontours_cb(src));
                uimenu(lookmenu,'Label','Show grid centerpoints','Checked',tf2onoff(obj.showgridcenters),...
                    'callback',@togglegrid_cb);
                uimenu(lookmenu,'Label',['Show ', obj.RawCatalog.Name, ' events'],...
                    'callback',{@addquakes_cb,obj.RawCatalog});

                uimenu(lookmenu,'Separator','on',...
                    'Label','brighten',...
                    'Callback',@(~,~)brighten(0.4));
                uimenu(lookmenu,'Label','darken',...
                    'Callback',@(~,~)brighten(-0.4));
            end
            if isempty(findobj(gcf,'Tag','layermenu'))
                layermenu=uimenu(gcf,'Label','layer','Tag','layermenu');
                for i=1:width(obj.Result.values)
                    tmpdesc=obj.Result.values.Properties.VariableDescriptions{i};
                    tmpname=obj.Result.values.Properties.VariableNames{i};
                    uimenu(layermenu,'Label',tmpdesc,'Tag',tmpname,...
                        'Enable',tf2onoff(~all(isnan(obj.Result.values.(tmpname)))),...
                        'callback',@(~,~)plot_cb(tmpname));
                end
            end
            % make sure the correct option is checked
            layermenu=findobj(gcf,'Tag','layermenu');
            set(findobj(layermenu,'Tag',myname),'checked','on');
            
            % plot here
            function plot_cb(name)
                set(findobj(layermenu,'type','uimenu'),'Checked','off');
                obj.plot(name);
            end
            
            function addquakes_cb(src,~,catalog)
                qtag=findobj(gcf,'tag','quakes');
                if isempty(qtag)
                    hold on
                    plot(catalog.Longitude, catalog.Latitude, 'o',...
                        'markersize',3,...
                        'markeredgecolor',[.2 .2 .2],...
                        'tag','quakes');
                    hold off
                else
                    ison=strcmp(qtag.Visible,'on');
                    qtag.Visible=tf2onoff(~ison);
                    src.Checked=tf2onoff(~ison);
                    drawnow
                end
            end
            
            function contour_cb(~,~)
                % like plot, except with contours!
                [C,h]=contour(unique(xx),unique(yy),reshaper(zz),'LevelList',[floor(min(zz)):.1:ceil(max(zz))]);
                clabel(C,h)
            end
            function contourf_cb(~,~)
                % like plot, except with contours!
                [C,h]=contourf(unique(xx),unique(yy),reshaper(zz),'LevelList',[floor(min(zz)):.1:ceil(max(zz))]);
                clabel(C,h)
            end
            
            function togglegrid_cb(src,~)
                gph=findobj(gcf,'tag','pointgrid');
                if isempty(gph)
                    gph=obj.Grid.plot();
                    gph.Tag='pointgrid';
                    gph.PickableParts='none';
                    gph.Visible=tf2onoff(obj.showgridcenters);
                end
                switch src.Checked
                    case 'on'
                        src.Checked='off';
                        gph.Visible='off';
                        obj.showgridcenters=false;
                    case 'off'
                        src.Checked='on';
                        gph.Visible='on';
                        obj.showgridcenters=true;
                end
            end
            function changecontours_cb()
                dlgtitle='Contour interval';
                s.prompt='Enter interval';
                contr= findobj(gca,'Type','Contour');
                s.value=get(contr,'LevelList');
                if all(abs(diff(s.value)-diff(s.value(1:2))<=eps))
                    s.toChar = @(x)[num2str(x(1)),':',num2str(diff(x(1:2))),':',num2str(x(end))];
                end
                s.toValue = @mystr2vec;
                answer = smart_inputdlg(dlgtitle,s);
                set(contr,'LevelList',answer.value);
                
                function x=mystr2vec(x)
                    % ensures only valid charaters for the upcoming eval statement
                    if ~all(ismember(x,'(),:[]01234567890.- '))
                        x = str2num(x); %#ok<ST2NM>
                    else
                        x = eval(x);
                    end
                end
            end
            
            
        end
        function contour(obj,choice,intervals)
            % like plot, except with contours!
            if ~exist('intervals','var')
                intervals=[floor(min(zz)):.1:ceil(max(zz))];
            end
            [C,h]=contour(unique(xx),unique(yy),reshaper(zz),'LevelList',[floor(min(zz)):.1:ceil(max(zz))]);
            clabel(C,h)
        end
        function contourf(obj,choice,intervals)
            % like plot, except with contours!
            if ~exist('intervals','var')
                intervals=[floor(min(zz)):.1:ceil(max(zz))];
            end
            [C,h]=contourf(unique(xx),unique(yy),reshaper(zz),'LevelList',[floor(min(zz)):.1:ceil(max(zz))]);
            clabel(C,h)
        end
        
        
    end
    methods(Access=protected)
        function gridCalculations(obj, calculationFcn, nReturnValuesPerPoint, modificationFcn)
            % GRIDCALCULATIONS do requested calculation for each gridpoint and store result in obj.Result
            % GRIDCALCULATIONS(obj, calculationFcn, nReturnValuesPerPoint)
            %calculate values at all points
             [vals,nEvents,maxDists,maxMag, ll]=gridfun(calculationFcn,...
                obj.RawCatalog, ...
                obj.Grid, ...
                obj.EventSelector,...
                nReturnValuesPerPoint);
            
            
            returnFields = obj.ReturnDetails(:,1);
            returnDesc = obj.ReturnDetails(:,2);
            returnUnits = obj.ReturnDetails(:,3);
            
            
            vals(:,strcmp('x',returnFields))=obj.Grid.X(:);
            vals(:,strcmp('y',returnFields))=obj.Grid.Y(:);
            vals(:,strcmp('Number_of_Events',returnFields))=nEvents;
            vals(:,strcmp('Radius_km',returnFields))=maxDists;
            vals(:,strcmp('max_mag',returnFields))=maxMag;
            
            if exist('modificationFcn','var')
                vals= modificationFcn(vals);
            end
            
            myvalues = array2table(vals,'VariableNames', returnFields);
            myvalues.Properties.VariableDescriptions = returnDesc;
            myvalues.Properties.VariableUnits = returnUnits;
            
            obj.Result.values=myvalues;
        end
    end
    methods(Access=protected, Static)
        
        function txt = mydatacursor(~,event_obj)
            try
                % wrapped in Try-Catch because the datacursor routines fail relatively quietly on
                % errors. They simply mention that they couldn't update the datatip.
                
                pos=get(event_obj,'Position');
                
                im=event_obj.Target;
                details=im.UserData.vals(abs(im.UserData.vals.x - pos(1))<=.0001 & abs(im.UserData.vals.y-pos(2))<=.0001,:)
            catch ME
                
                disp(ME.message)
                ME
            end
            try
                mymapval=details.(im.UserData.myname);
                if isnumeric(mymapval)
                    trans=@(x)num2str(mymapval);
                elseif isa('datetime','val') || isa('duration','val')
                    trans=@(x)char(mymapval);
                else
                    trans=@(x)x;
                end
                txt={sprintf('Map Value [%s] : %s %s\n%s\n-------------',...
                    im.UserData.myname, trans(mymapval), im.UserData.myunit, im.UserData.mydesc)};
                for n=1:width(details)
                    fld=details.Properties.VariableNames{n};
                    val=details.(fld);
                    units=details.Properties.VariableUnits{n};
                    if isnumeric(val)
                        trans=@(x)num2str(val);
                    elseif isa('datetime','val') || isa('duration','val')
                        trans=@(x)char(val);
                    else
                        trans=@(x)x;
                    end
                    txt=[txt,{sprintf('%-10s : %s %s',fld, trans(val), units)}];
                end
                
            catch ME
                ME
                disp(ME.message)
            end
        end
        
    end
end