classdef spinnerWheel < handle
    %% Properties -- graphics
    properties (Transient, SetAccess = immutable)
        figAxes {mustBeScalarOrEmpty,mustBeA(figAxes,{'matlab.graphics.axis.Axes','matlab.ui.control.UIAxes'})} = matlab.graphics.axis.Axes.empty
    end

    properties (Transient, Access = private)
        wheelAngle (1,1) double = 0;
        startAngles (1,:) double
        endAngles (1,:) double
        names (1,:) string
        data (1,:)
        pointerAngle (1,1) double = pi

        PointerPS polyshape = polyshape.empty;
        PointerPatch = gobjects(1);
        WedgePatch = gobjects(1);
        WedgeText = gobjects(1);
        NoVotesText
    end

    properties (SetObservable = true)
        nPtsCirc (1,1) double {mustBeInteger,mustBeGreaterThanOrEqual(nPtsCirc,10)} = 100
    end

    %% Methods -- contructor/destructor
    methods
        function obj = spinnerWheel(figAxes)
            arguments
                figAxes (1,1) = gca
            end

            obj.figAxes = figAxes;

            obj.setupAxes;

            rng shuffle;
        end
    end


    %% Methods -- graphics
    methods
        function draw(obj,wedgeSizes,wedgeNames,wedgeData)
            arguments
                obj (1,1) spinnerWheel
                wedgeSizes (1,:) double {mustBeNonempty,mustBeReal,mustBeNonnegative}
                wedgeNames (1,:) string {mustBeNonempty}
                wedgeData (1,:)
            end

            delete(obj.WedgePatch)
            delete(obj.WedgeText)
            obj.WedgePatch = gobjects(1);
            obj.WedgeText = gobjects(1);

            delete(obj.PointerPatch)
            obj.PointerPatch = gobjects(1);
            
            if sum(wedgeSizes) == 0
                obj.NoVotesText.Visible = true;
                return
            else
                obj.NoVotesText.Visible = false;
            end

            obj.wheelAngle = 0;

            deleteInds = wedgeSizes == 0;
            wedgeSizes(deleteInds) = [];
            wedgeNames(deleteInds) = [];
            wedgeData(deleteInds) = [];

            nWedges = numel(wedgeSizes);
            
            obj.names = wedgeNames;
            obj.data = wedgeData;


            fracSpans = wedgeSizes/sum(wedgeSizes);

            fracStarts = [0,cumsum(fracSpans(1:end-1))];

            obj.endAngles = 2*pi-fracStarts*2*pi+pi/2;
            obj.startAngles = obj.endAngles-fracSpans*2*pi;

            RGB = obj.makeRGBColors(nWedges);

            fracCenters = fracStarts + fracSpans/2;

            centerAngsDeg = -fracCenters*360+90;

            obj.WedgePatch = gobjects(1,nWedges);
            obj.WedgeText = gobjects(1,nWedges);

            for ii = 1:nWedges

                if fracSpans(ii) == 0
                    continue
                end

                [x,y] = obj.calculateWedge(fracStarts(ii),fracSpans(ii));
                obj.WedgePatch(ii) = patch(obj.figAxes,x,y,RGB(ii,:),DisplayName=wedgeNames(ii));
                textXY = 0.9*[cosd(centerAngsDeg(ii)),sind(centerAngsDeg(ii))];

                % https://stackoverflow.com/questions/946544/good-text-foreground-color-for-a-given-background-color/946734#946734
                textColor = double(~round(rgb2gray(RGB(ii,:))));

                obj.WedgeText(ii) = text(obj.figAxes,textXY(1),textXY(2),wedgeNames(ii),Color=textColor,FontUnits='normalized',Rotation=centerAngsDeg(ii)+180,FontSize=0.04);
            end



            
            
            obj.drawPointer;


        end

        function drawPointer(obj,angleDeg)
            arguments
                obj (1,1) spinnerWheel
                angleDeg = rad2deg(obj.pointerAngle)
            end

            obj.pointerAngle = deg2rad(angleDeg);

            if ~isgraphics(obj.PointerPatch) || isempty(obj.PointerPS)
                xyArrow = [-1,0;
                        1,0;
                        1,3;
                        0,5;
                        -1,3;
                        -1,0];

                xyArrow = 0.075*xyArrow;
                obj.PointerPS = polyshape(xyArrow(:,1),xyArrow(:,2)).rotate(-90).translate([-1.3,0]);
                obj.PointerPatch = patch(obj.figAxes,NaN,NaN,'r',FaceAlpha=1,EdgeColor='k',LineWidth=3);
            end

            xy = obj.PointerPS.rotate(rad2deg(obj.pointerAngle)+180).Vertices;

            obj.PointerPatch.XData = xy(:,1);
            obj.PointerPatch.YData = xy(:,2);
        end

        function [winnerName,winnerData] = spin(obj)
            om_limL = 30;
            om_limH = 45;
            damp_limL = 0.98;
            damp_limH = 0.995;
            nAcc_limL = 50;
            nAcc_limH = 200;
            
            om_max = rand*(om_limH-om_limL) + om_limL;
            damp = rand*(damp_limH-damp_limL) + damp_limL;
            nAcc = rand*(nAcc_limH-nAcc_limL) + nAcc_limL;
            
            dt = 1/100;
            
            om = linspace(0,om_max,nAcc);
            th_old = obj.wheelAngle;

            for ii = 1:nAcc
                obj.wheelAngle = om(ii)*dt + th_old;
                rotateStep(obj.wheelAngle-th_old);
                th_old = obj.wheelAngle;
            end

           
            
            om_old = om(end);
            
            while om_old > .2
                om_new = om_old*damp;
                obj.wheelAngle = om_new*dt + th_old;
                rotateStep(obj.wheelAngle-th_old);

                th_old = obj.wheelAngle;
                om_old = om_new;
            end


            TF = isInAngRange(obj.wheelAngle+[obj.startAngles;obj.endAngles].',obj.pointerAngle);

            if sum(TF) == 1
                winnerName = obj.names(TF);
                winnerData = obj.data(TF);
            else
                winnerName = NaN;
                winnerData = [];
            end
            

            function rotateStep(thStep)
                thStep = rad2deg(thStep);
                rotate(obj.WedgePatch,[0,0,1],thStep,[0,0,0]);

                for WT = obj.WedgeText
                    thNew = WT.Rotation + thStep;
                    thNewTextXY = thNew-180;
                    textXYnew = 0.9*[cosd(thNewTextXY),sind(thNewTextXY)];

                    WT.Rotation = thNew;
                    WT.Position(1:2) = textXYnew;
                end
                drawnow
            end
        end
    end

    methods (Access = private)
        function setupAxes(obj)
            cla(obj.figAxes);

            obj.figAxes.Visible = false;
            disableDefaultInteractivity(obj.figAxes);
            obj.figAxes.Toolbar.Visible = false;
            hold(obj.figAxes,'on');
            axis(obj.figAxes,'square');
            axis(obj.figAxes,1.35*[-1,1,-1,1]);
            obj.NoVotesText = text(obj.figAxes,0,0,'No Votes Cast Yet',Color='r',FontUnits='normalized',FontSize=0.1,HorizontalAlignment='center');
        end

        function [x,y] = calculateWedge(obj,fracStart,fracSwept)
            nPts = max(round(fracSwept*obj.nPtsCirc),2);

            th = -2*pi*linspace(fracStart,fracStart+fracSwept,nPts)+pi/2;
            x = NaN(nPts+2,1);
            y = NaN(nPts+2,1);

            R = exp(1i*th);
            x(2:nPts+1) = real(R);
            y(2:nPts+1) = imag(R);

            x(1) = 0;
            y(1) = 0;
            x(end) = 0;
            y(end) = 0;
        end
    end

    %% Methods -- utilities
    methods (Static, Access = private)
        function RGB = makeRGBColors(nColors)
            R = NaN(nColors,1);
            G = NaN(nColors,1);
            B = NaN(nColors,1);
            
            n = floor(linspace(0,5,nColors));
            j = mod(linspace(0,5,nColors),1);
            
            for ii = 1:nColors
                R(ii) = j(ii)*(n(ii) == 4) + 1*(n(ii) == 5 || n(ii) == 0) + (1 - j(ii))*(n(ii) == 1);
                G(ii) = j(ii)*(n(ii) == 0) + 1*(n(ii) == 1 || n(ii) == 2) + (1 - j(ii))*(n(ii) == 3);
                B(ii) = j(ii)*(n(ii) == 2) + 1*(n(ii) == 3 || n(ii) == 4) + (1 - j(ii))*(n(ii) == 5);
            end

            RGB = [R,G,B];
        end
    end
end