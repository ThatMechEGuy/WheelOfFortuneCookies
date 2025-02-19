classdef SpinnerWheel < handle
    %% Properties -- graphics
    properties (Transient, SetAccess = immutable)
        figureAxes {mustBeScalarOrEmpty,...
            mustBeA(figureAxes,["matlab.graphics.axis.Axes","matlab.ui.control.UIAxes"])} = ...
            matlab.graphics.axis.Axes.empty
    end

    properties (Transient, Access = private)
        wheelAngle (1,1) double = 0
        startAngles (1,:) double
        endAngles (1,:) double
        names (1,:) string
        restaurants (1,:) WheelOfFortuneCookies.Restaurant.Restaurant = WheelOfFortuneCookies.Restaurant.Restaurant.empty
        pointerAngle (1,1) double = pi

        pointerPolyshape polyshape = polyshape.empty;
        pointerPatch = gobjects(1);
        wedgePatch = gobjects(1);
        wedgeText = gobjects(1);
        noVotesText
    end

    properties (SetObservable = true, AbortSet = true)
        nPointsForCircle (1,1) double ...
            {mustBeInteger,mustBeGreaterThanOrEqual(nPointsForCircle,10)} = 100
    end

    %% Methods -- contructor/destructor
    methods
        function obj = SpinnerWheel(figureAxes)
            arguments (Input)
                figureAxes (1,1) = gca
            end

            arguments (Output)
                obj (1,1) WheelOfFortuneCookies.SpinnerWheel
            end

            obj.figureAxes = figureAxes;

            obj.setupAxes;

            % Shuffling the random number generator ensures that we will get random behavior every
            % time the wheel is run, even after restarting MATLAB.
            rng shuffle;
        end
    end


    %% Methods -- graphics
    methods
        function draw(obj,restaurants)
            arguments (Input)
                obj (1,1) WheelOfFortuneCookies.SpinnerWheel
                restaurants (1,:) WheelOfFortuneCookies.Restaurant.Restaurant {mustBeNonempty}
            end

            wedgeSizes = [restaurants.nVotes];
            wedgeNames = [restaurants.name];

            delete(obj.wedgePatch)
            delete(obj.wedgeText)
            obj.wedgePatch = gobjects(1);
            obj.wedgeText = gobjects(1);

            delete(obj.pointerPatch)
            obj.pointerPatch = gobjects(1);
            
            if sum(wedgeSizes) == 0
                obj.noVotesText.Visible = true;
                return
            else
                obj.noVotesText.Visible = false;
            end

            obj.wheelAngle = 0;

            deleteInds = wedgeSizes == 0;
            wedgeSizes(deleteInds) = [];
            wedgeNames(deleteInds) = [];
            restaurants(deleteInds) = [];

            nWedges = numel(wedgeSizes);
            
            obj.names = wedgeNames;
            obj.restaurants = restaurants;


            fracSpans = wedgeSizes/sum(wedgeSizes);

            fracStarts = [0,cumsum(fracSpans(1:end-1))];

            obj.endAngles = 2*pi-fracStarts*2*pi+pi/2;
            obj.startAngles = obj.endAngles-fracSpans*2*pi;

            RGB = obj.makeRGBColors(nWedges);

            fracCenters = fracStarts + fracSpans/2;

            centerAngsDeg = -fracCenters*360+90;

            obj.wedgePatch = gobjects(1,nWedges);
            obj.wedgeText = gobjects(1,nWedges);

            for i = 1:nWedges

                if fracSpans(i) == 0
                    continue
                end

                [x,y] = obj.calculateWedge(fracStarts(i),fracSpans(i));
                obj.wedgePatch(i) = patch(obj.figureAxes,x,y,RGB(i,:),DisplayName=wedgeNames(i));
                textXY = 0.9*[cosd(centerAngsDeg(i)),sind(centerAngsDeg(i))];

                % https://stackoverflow.com/questions/946544/good-text-foreground-color-for-a-given-background-color/946734#946734
                textColor = double(~round(rgb2gray(RGB(i,:))));

                obj.wedgeText(i) = text(obj.figureAxes,textXY(1),textXY(2),wedgeNames(i),Color=textColor,FontUnits='normalized',Rotation=centerAngsDeg(i)+180,FontSize=0.04);
            end



            
            
            obj.drawPointer;


        end

        function drawPointer(obj,angleDeg)
            arguments (Input)
                obj (1,1) WheelOfFortuneCookies.SpinnerWheel
                angleDeg = rad2deg(obj.pointerAngle)
            end

            obj.pointerAngle = deg2rad(angleDeg);

            if ~isgraphics(obj.pointerPatch) || isempty(obj.pointerPolyshape)
                xyArrow = [-1,0;
                        1,0;
                        1,3;
                        0,5;
                        -1,3;
                        -1,0];

                xyArrow = 0.075*xyArrow;
                obj.pointerPolyshape = polyshape(xyArrow(:,1),xyArrow(:,2)).rotate(-90).translate([-1.3,0]);
                obj.pointerPatch = patch(obj.figureAxes,NaN,NaN,'r',FaceAlpha=1,EdgeColor='k',LineWidth=3);
            end

            xy = obj.pointerPolyshape.rotate(rad2deg(obj.pointerAngle)+180).Vertices;

            obj.pointerPatch.XData = xy(:,1);
            obj.pointerPatch.YData = xy(:,2);
        end

        function winnerRestaurant = spin(obj)
            arguments (Input)
                obj (1,1) WheelOfFortuneCookies.SpinnerWheel
            end

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


            TF = WheelOfFortuneCookies.HelperFunctions.isInAngularRange(obj.wheelAngle+[obj.startAngles;obj.endAngles].',obj.pointerAngle);

            if sum(TF) == 1
                winnerRestaurant = obj.restaurants(TF);
            else
                winnerRestaurant = [];
            end
            

            function rotateStep(thStep)
                thStep = rad2deg(thStep);
                rotate(obj.wedgePatch,[0,0,1],thStep,[0,0,0]);

                for WT = obj.wedgeText
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
            arguments (Input)
                obj (1,1) WheelOfFortuneCookies.SpinnerWheel
            end

            cla(obj.figureAxes);

            obj.figureAxes.Visible = false;
            disableDefaultInteractivity(obj.figureAxes);
            obj.figureAxes.Toolbar.Visible = false;
            hold(obj.figureAxes,'on');
            axis(obj.figureAxes,'square');
            axis(obj.figureAxes,1.35*[-1,1,-1,1]);
            obj.noVotesText = text(obj.figureAxes,0,0,'No Votes Cast Yet',Color='r',FontUnits='normalized',FontSize=0.1,HorizontalAlignment='center');
        end

        function [x,y] = calculateWedge(obj,fracStart,fracSwept)
            arguments (Input)
                obj (1,1) WheelOfFortuneCookies.SpinnerWheel
                fracStart
                fracSwept
            end

            arguments (Output)
                x
                y
            end

            nPts = max(round(fracSwept*obj.nPointsForCircle),2);

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
            arguments (Input)
                nColors
            end

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