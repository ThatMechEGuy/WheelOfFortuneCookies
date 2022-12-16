classdef spinnerWheel < handle
    %% Properties -- graphics
    properties (Transient, SetAccess = immutable)
        figAxes {mustBeScalarOrEmpty,mustBeA(figAxes,{'matlab.graphics.axis.Axes','matlab.ui.control.UIAxes'})} = matlab.graphics.axis.Axes.empty
    end

    properties (Transient, Access = private)
        wheelAngle (1,1) double = 0;
        startAngles (1,:) double
        names (1,:) string
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
        function draw(obj,wedgeSizes,wedgeNames,pointerAngle,opts)
            arguments
                obj (1,1) spinnerWheel
                wedgeSizes (1,:) double {mustBeNonempty,mustBeReal,mustBeNonnegative}
                wedgeNames (1,:) string {mustBeNonempty}
                pointerAngle (1,1) double {mustBeReal,mustBeFinite} = 0;
                opts.onlyUpdatePointer (1,1) logical = false
            end

            cla(obj.figAxes);

            if sum(wedgeSizes) == 0
                return
            end

            if opts.onlyUpdatePointer
                return
            end

            deleteInds = wedgeSizes == 0;
            wedgeSizes(deleteInds) = [];
            wedgeNames(deleteInds) = [];

            nWedges = numel(wedgeSizes);
            
            obj.names = wedgeNames;


            fracSpans = wedgeSizes/sum(wedgeSizes);

            fracStarts = [0,cumsum(fracSpans(1:end-1))];

            obj.startAngles = fracStarts*2*pi;

            [R,G,B] = obj.makeRGBColors(nWedges);

            fracCenters = fracStarts + fracSpans/2;

            centerAngsDeg = -fracCenters*360+90;

            for ii = 1:nWedges

                if fracSpans(ii) == 0
                    continue
                end

                [x,y] = obj.calculateWedge(fracStarts(ii),fracSpans(ii));
                patch(obj.figAxes,x,y,[R(ii),G(ii),B(ii)],DisplayName=wedgeNames(ii));
                textXY = 0.9*[cosd(centerAngsDeg(ii)),sind(centerAngsDeg(ii))];
                text(obj.figAxes,textXY(1),textXY(2),wedgeNames(ii),FontUnits='normalized',Rotation=centerAngsDeg(ii)+180,FontSize=0.05);
            end



            xyArrow = [-1,0;
                        1,0;
                        1,3;
                        0,5;
                        -1,3;
                        -1,0];

            xyArrow = 0.075*xyArrow;

            A = polyshape(xyArrow(:,1),xyArrow(:,2));
            A = A.rotate(-90).translate([-1.3,0]).rotate(pointerAngle-180);

            hold(obj.figAxes,'on');
            plot(obj.figAxes,A,FaceColor='r',FaceAlpha=1,EdgeColor='k',LineWidth=3);
            



            axis(obj.figAxes,'equal');

            xlim(obj.figAxes,[-1.35,1.35]);
        end

        function winner = spin(obj)
            C = obj.figAxes.Children;

            textInds = arrayfun(@(x)isa(x,'matlab.graphics.primitive.Text'),C);

            TextObjs = C(textInds);


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

            stopAng = wrapTo2Pi(obj.wheelAngle);

            dists = stopAng-obj.startAngles;

            dists(dists<0) = NaN;

            [~,winInd] = min(dists);

            winner = obj.names(winInd);
            

            function rotateStep(thStep)
                thStep = rad2deg(thStep);
                rotate(C(~textInds),[0,0,1],thStep,[0,0,0]);

                for jj = 1:numel(TextObjs)
                    thNew = TextObjs(jj).Rotation + thStep;
                    thNewTextXY = thNew-180;
                    textXYnew = 0.9*[cosd(thNewTextXY),sind(thNewTextXY)];

                    TextObjs(jj).Rotation = thNew;
                    TextObjs(jj).Position(1:2) = textXYnew;
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