classdef spinnerWheel < handle
    %% Properties -- graphics
    properties (SetAccess = immutable)
        figAxes {mustBeScalarOrEmpty,mustBeA(figAxes,{'matlab.graphics.axis.Axes','matlab.ui.control.UIAxes'})} = matlab.graphics.axis.Axes.empty
    end

    properties (SetObservable = true)
        nPtsCirc (1,1) double {mustBeInteger,mustBeGreaterThanOrEqual(nPtsCirc,10)} = 180
    end

    %% Methods -- contructor/destructor
    methods
        function obj = spinnerWheel(figAxes)
            arguments
                figAxes (1,1) = gca
            end

            obj.figAxes = figAxes;

            obj.setupAxes;
        end
    end


    %% Methods -- graphics
    methods
        function draw(obj,wedgeSizes,wedgeNames)
            arguments
                obj (1,1) spinnerWheel
                wedgeSizes (1,:) double {mustBeNonempty,mustBeReal,mustBeNonnegative}
                wedgeNames (1,:) string {mustBeNonempty}
            end

            cla(obj.figAxes);

            fracSpans = wedgeSizes/sum(wedgeSizes);
            nWedges = numel(wedgeSizes);

            fracStarts = [0,cumsum(fracSpans(1:end-1))];

            fracCenters = fracStarts + fracSpans/2;

            centerAngsDeg = -fracCenters*360+90;

            [R,G,B] = obj.makeRGBColors(nWedges);

            for ii = 1:nWedges
                [x,y] = obj.calculateWedge(fracStarts(ii),fracSpans(ii));
                patch(obj.figAxes,x,y,[R(ii),G(ii),B(ii)]);
                textXY = 0.95*[cosd(centerAngsDeg(ii)),sind(centerAngsDeg(ii))];
                text(obj.figAxes,textXY(1),textXY(2),wedgeNames(ii),FontUnits='normalized',Rotation=centerAngsDeg(ii)+180,FontSize=0.05);
            end
        end
    end

    methods (Access = private)
        function setupAxes(obj)
            cla(obj.figAxes);

            obj.figAxes.Visible = false;
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
        function [R,G,B] = makeRGBColors(nColors)
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
        end
    end
end