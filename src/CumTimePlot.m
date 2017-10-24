classdef (Sealed) CumTimePlot < handle
    % CumTimePlot plots selected events as cummulative # over time
    
    properties
        catalog%= ZmapCatalogView('newt2') % catalog
        %BigView 
        
        fontsz = ZmapGlobal.Data.fontsz;
        hold_state = false;
        AxH % axes handle (may move to dependent)
    end
    properties(Constant)
        FigName='Cumulative Number';
        catname = 'newt2';
    end
    properties(Dependent)
        FigH % figure handle
        Edges % bin edges (datetime)
        RelativeEdges % bin edges (duration, offset from first event)
    end
    
    methods (Access = private)
        function obj = CumTimePlot
            report_this_filefun(mfilename('fullpath'));
            obj.catalog = ZmapCatalogView('newt2');
            %obj.BigView = ZmapCatalogView(obj.catalog); % major event(s)
            obj.plot()
        end
        function add_xlabel(obj)
            if (max(obj.catalog.Date)-min(obj.catalog.Date)) >= days(1)
                xlabel(obj.AxH,'Date',...
                    'FontSize',obj.fontsz.s)
            else
                statime=obj.catalog.Date(1);
                xlabel(obj.AxH,['Time in days relative to ',char(statime)],...
                    'FontSize',obj.fontsz.m)
            end
        end
        function add_ylabel(obj)
            ylabel(obj.AxH,'Cumulative Number ',...
                'FontSize',obj.fontsz.s)
        end
        function add_title(obj)
            title(obj.AxH,...
                sprintf('"%s": Cumulative Earthquakes over time', obj.catalog.Name),...
                'Interpreter','none');
        end
        function add_legend(obj)
            disp('CumTimePlot.add_legend (unimplemented)')
        end
    end
    
    methods
        function fig= get.FigH(obj)
            % FigH is the handle to the one-and-only timeplot figure
            persistent stored_fig
            if numel(stored_fig) ~= 1 || ~isvalid(stored_fig)
                % either this has never been called or something is wrong. start over.
                fig = findall(groot, 'Type','Figure','-and','Name',obj.FigName);
                delete(fig)
                stored_fig = obj.create_figure();
            end
            
            fig = stored_fig;
        end
        function reset(obj)
            obj.catalog = ZmapCatalogView('newt2');
            obj.plot();
        end
        function c = Catalog(obj,n)
            % Catalog get a catalog
            % c = Catalog(obj) returns the main catalog from timeplot
            % c = Catalog(obj,n) returns another catalog (for when multiple have been plotted
            if ~exist('n','var')
                n=1;
            end
            if numel(obj.catalog) <=n && n>0
                c = obj.catalog(n).Catalog;
            end
        end
        function update(obj)
            obj.plot()
        end
        
        function fig = create_figure(obj)
            % acquire_cumtimeplotfigure get handle to figure, otherwise create one and sync the appropriate hold_state
            % Set up the Cumulative Number window
            
            fig = figure_w_normalized_uicontrolunits( ...
                'Name',obj.FigName,...
                'NumberTitle','off', ...
                'NextPlot','replace', ...
                'backingstore','on',...
                'Tag','cum',...
                'Position',[ 100 100 (ZmapGlobal.Data.map_len - [100 20]) ]);
            
            obj.create_menu();
            obj.hold_state=false;
        end
        function addplot(obj, othercat, varargin)
            % addplot add another line to the plot
            % tdiff=mycat.DateSpan; % added by CR
            cumu = histcounts(othercat.Date, obj.Edges);
            cumu2 = cumsum(cumu);
            
            hold(obj.AxH,'on');
            axes(obj.AxH)
            tiplot2 = plot(obj.AxH,obj.catalog.Date,(1:obj.catalog.Count),'r','LineWidth',2.0);
            tiplot2.DisplayName=caller(dbstack);
            obj.hold_state=false;
            hold(obj.AxH,'off');
            
            function s=caller(ds)
                % call with dbstack
                if numel(ds)>1
                    s = ['from ' ds(2).name];
                else
                    s = 'from base (?)';
                end
            end
        end
        
        function plot(obj,varargin)
            myfig = obj.FigH; % will automatically create if it doesn't exist
            try
                figure(myfig);
            catch ME
                disp('failed to get figure!')
            end
            
            if isempty(obj.Catalog)
                ZmapMessageCenter.set_error('No Catalog','timeplot was passed an empty catalog');
                return
            end
            
            if obj.hold_state
                addplot(obj,varargin{:});
                return;
            end
            
            t0b = obj.catalog.DateRange(1);
            teb = obj.catalog.DateRange(2);
            
            delete(findobj(myfig,'Type','Axes'));
            watchon;
            obj.AxH=axes(myfig);
            
            set(obj.AxH,...
                ...'visible','off',...
                'FontSize',ZmapGlobal.Data.fontsz.s,...
                'FontWeight','normal',...
                'LineWidth',1.5,...
                'SortMethod','childorder')
            grid(obj.AxH,'on')
            % plot time series
            
            nu = (1:obj.Catalog.Count);
            
            hold(obj.AxH,'on')
            plot(obj.AxH, obj.Catalog.Date, nu, 'b',...
                'LineWidth', 2.0,...
                'UIContextMenu',menu_cumtimeseries());
            
            % plot marker at end of data
            pl = plot(obj.AxH, teb, obj.Catalog.Count,'rs');
            set(pl,'LineWidth',1.0,'MarkerSize',4,...
                'MarkerFaceColor','w','MarkerEdgeColor','r');
            
            set(obj.AxH,'Ylim',[0 obj.Catalog.Count*1.05]);
            
            obj.plot_big_events();
            
            obj.add_xlabel();
            obj.add_ylabel();
            obj.add_title();
            obj.add_legend();
            
            
            % Make the figure visible
            %
            set(obj.AxH,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,...
                'LineWidth',1.0,'TickDir','out');%,'Ticklength',[0.02 0.02],'Box','on')
            figure(myfig);
            axes(obj.AxH);
            set(myfig,'Visible','on');
            watchoff(myfig);
        end
        
        function ed = get.Edges(obj)
            ed = min(obj.catalog.Date) : obj.bin_dur : max(obj.catalog.Date);
        end
        
        function red = get.RelativeEdges(obj)
            red = 0 : obj.bin_dur : (max(obj.catalog.Date) - min(obj.catalog.Date));
            % (0: ZG.bin_dur :(tdiff + 2*ZG.bin_dur)));
        end
        function create_menu(obj)
            
            add_menu_divider();
            disp('CumTimePlot.create_menu (unimplemented)');
            mm=uimenu('Label','TimePlot');
            uimenu(mm,'Label','Reset','Callback',@(~,~)obj.reset);
        end
        
        function plot_big_events(obj)
            % plot big events on curve
            ZG=ZmapGlobal.Data;
            % select "big" events
            bigMask= obj.catalog.Magnitude >= ZG.big_eq_minmag;
            bigCat = obj.catalog.subset( bigMask );
            
            bigIdx = find(bigMask);
            
            if (max(obj.catalog.Date)-min(obj.catalog.Date))>=days(1) && ~isempty(bigCat)
                hold(obj.AxH,'on')
                plot(obj.AxH,bigCat.Date, bigIdx,'hm',...
                    'LineWidth',1.0,'MarkerSize',10,...
                    'MarkerFaceColor','y',...
                    'MarkerEdgeColor','k',...
                    'visible','on',...
                    'UIContextMenu',menu_cumtimeseries())
                stri4 = [];
                for i = 1: bigCat.Count
                    s = sprintf('  M=%3.1f',bigCat.Magnitude(i));
                    stri4 = [stri4 ; s];
                end
                t=text(obj.AxH,bigCat.Date,bigIdx,stri4);
                t.UIContextMenu=menu_cumtimeseries();
                hold(obj.AxH,'off');
            end
        end
        
        function refresh_catalog(obj)
            obj.catalog = ZmapCatalogView('newt2'); % catalog
        end
        
        function add_series(obj,catalog)
            % add_series(obj,catalog)
            disp('CumTimePlot.add_series (unimplemented)');
        end
    end
    
    methods(Static)
        % singleton.
        function singleObj = getInstance
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = CumTimePlot;
            end
            singleObj = localObj;
        end
    end
end