function old_wheelOfFortuneCookies
    %% Initialization.
    % Close all figure windows so old figure windows from this program don't clutter the screen.
    close all;
    % Seed the random number generator (if this isn't done, the "random" numbers will be the same
    % everytime MATLAB restarts.
    rng shuffle;
    
    % Add all restaurants to the food list (they don't have to be in alphabetical order).
%     foodList = {'Afro Deli'
%                 'Annie''s Parlour'
%                 'Applebee''s'
%                 'Blaze Pizza'
%                 'Burger King'
%                 'Cane''s'
%                 'Chipotle'
%                 'D.P. Dough'
%                 'Five Guys'
%                 'Jimmy Johns'
%                 'McDonald''s'
%                 'Mesa Pizza'
%                 'My Burger'
%                 'Naf Naf Grill'
%                 'Noodles & Co.'
%                 'Potbelly'
%                 'Punch Pizza'
%                 'QDOBA'
%                 'Sally''s'
%                 'Stub and Herb''s'
%                 'Subway'
%                 'Wally''s'};
        foodList = {'Afro Deli'
                'Blaze Pizza'
                'Burger King'
                'Cane''s'
                'Chipotle'
                'D.P. Dough'
                'Five Guys'
                'Jimmy Johns'
                'McDonald''s'
                'Mesa Pizza'
                'My Burger'
                'Naf Naf Grill'
                'Noodles & Co.'
                'Potbelly'
                'Punch Pizza'
                'QDOBA'
                'Subway'
                'Wally''s'};

    % Sort the restaurant list alphabetically.
    foodList = sort(foodList);
    % Count the number of restaurants in the list.
    nFood = numel(foodList);
    
    % Set the number of selections each person gets.
    nSel = 2;
    
    
    %% Create figure windows.
    % =====================  Wheel Window  =====================
    % Create a blank figure window.
    F = figure;
    % Rename the figure window.
    F.Name = 'Wheel of Fortune Cookies | The Wheel';
    % Remove the number title (e.g., "Figure 1:").
    F.NumberTitle = 'off';
    % Hide the menu bar (zoom, menus, etc.).
    F.MenuBar = 'none';
    % Prevent the user from resizing the figure window.
    F.Resize = 'off';
    % Make the background of the fiugre window white.
    F.Color = 'W';
    
    % Set the width and the height of the figure window (in pixels).
    FW = 900;
    FH = 700;
    % Move the figure window so its center will be in the same position as when it opened after the
    % window is resized.
    F.Position(1:2) = F.Position(1:2) - 0.5*[FW,FH];
    % Resize the figure window.
    F.Position(3:4) = [FW,FH];
    
    % Get the handle of the axes object.
    A_F = gca;
    % Hide the axes.
    A_F.Visible = 'off';
    % Make the axes have the same scale (so circles look like circles).
    axis equal;
    
    % Add the "Spin" button that will randomly spin the wheel.
    createSpinButton(FW);
    
    % ++++++++++++++++++  UserData Storage  ++++++++++++++++++
    % Store the list of restaurants so the legend can include restaurant names.
    F.UserData.foodList = foodList;
    % Create the "list" variable that is used to track all resturants that have been selected.
    F.UserData.list = [];
    % Pre-allocate space for the vote results while also setting the initial vote count for all
    % restaurants to zero.
    F.UserData.votes = zeros(nFood,1);
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % =========================================================
    
    
    % ====================  Voting Window  ====================
    % Create a blank figure window.
    S = figure;
    % Rename the figure window.
    S.Name = 'Wheel of Fortune Cookies | Voting';
    % Remove the number title (e.g., "Figure 1:").
    S.NumberTitle = 'off';
    % Hide the menu bar (zoom, menus, etc.).
    S.MenuBar = 'none';
    % Prevent the user from resizing the figure window.
    S.Resize = 'off';
    
    % Set the width and the height of the figure window (in pixels)
    SW = 750;
    SH = 525;
    % Move the figure window so its center will be in the same position as when it opened after the
    % window is resized.
    S.Position(1:2) = S.Position(1:2) - 0.5*[SW,SH];
    % Resize the figure window.
    S.Position(3:4) = [SW,SH];
    
    
    % Add all of the restaurant check boxes.
    for ii = 1:nFood
        createCheckBox(foodList(ii),ii,SH);
    end
    % Add the "Vote" button that will be used to cast restaurant votes.
    createVoteButton(SW);
    
    % ++++++++++++++++++  UserData Storage  ++++++++++++++++++
    % Initialize the variable that tracks how many restaurants have been checked/selected.
    S.UserData.nChecked = 0;
    % Set the upper limit on number of restaurant selections.
    S.UserData.nCheckedLim = nSel;
    % Create the variable that is used to track which resturants have been selected.
    S.UserData.checkedList = [];
    % Store the handle of the wheel figure window. This is so the data of the wheel figure window
    % can be accessed after the "Vote" button is pressed.
    S.UserData.F = F;
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % =========================================================

    
    % Make "X" button prompt the user to make sure they want to close the program. This prevents
    % accidentally closing the windows and also is set-up to close both windows at the same time.
    F.CloseRequestFcn = {@closeProgram,F,S};
    S.CloseRequestFcn = {@closeProgram,F,S};
    
    
    
end


%% Sub-Functions.
% ==================================================================================================
% ==================================================================================================

% Below this line are all of the sub functions that are used to make the program work. They are
% listed in alphabetical order.

% ==================================================================================================
%===================================================================================================


%% arc
% Calculates the defining points of an arc. The position and swept angle of the arc can be
% specified.
function [x,y] = arc(fracStart,fracSwept,r)
    n = 100;
    th = -2*pi*linspace(fracStart,fracStart+fracSwept,n)+pi/2;
    x = zeros(n+1,1);
    y = zeros(n+1,1);
    
    R = r*exp(1i*th);
    x(1:n) = real(R);
    y(1:n) = imag(R);
end


%% calcWeights
% Calculates the weights that each restaurant should have on the voting wheel.
function weights = calcWeights(F,S)
    UDF = F.UserData;
    UDS = S.UserData;
    
    voteWeight = UDS.nCheckedLim/UDS.nChecked;
    
    UDF.list = union(UDF.list,UDS.checkedList);
    UDF.votes(UDS.checkedList) = UDF.votes(UDS.checkedList) + voteWeight;
    
    votes = UDF.votes;
    votes(votes == 0) = [];
    
    weights = votes/sum(votes);
    
    F.UserData = UDF;
    
end


%% checkboxCallback
% Defines what happens when a checkbox is clicked. The primary purpose of this function is to
% disable any unchecked boxes when the maximum number of boxes has been checked (maximum number of
% restaurant selections made) so the user's only options are to vote or to de-select one or more
% restaurants.
function checboxCallback(src,~)

    S = src.Parent;
    UD = S.UserData;
    C = src;
    n = C.UserData;
    
    nCheckedOld = UD.nChecked;
    
    if C.Value > 0
        UD.nChecked = UD.nChecked + 1;
        UD.checkedList = [UD.checkedList,n];
    else
        UD.nChecked = UD.nChecked - 1;
        UD.checkedList(UD.checkedList == n) = [];
    end
    
    if UD.nChecked == UD.nCheckedLim
        for ii = 1:numel(S.Children)
            if strcmp(S.Children(ii).Type,'uicontrol') && strcmp(S.Children(ii).Style,'checkbox')
                if isempty(find(UD.checkedList == S.Children(ii).UserData,1))
                    S.Children(ii).Enable = 'off';
                end
            end
        end
    elseif nCheckedOld == UD.nCheckedLim
        for ii = 1:numel(S.Children)
            if strcmp(S.Children(ii).Type,'uicontrol') && strcmp(S.Children(ii).Style,'checkbox')
                S.Children(ii).Enable = 'on';
            end
        end
    end
    
    S.UserData = UD;
    
end


%% closeProgram
% Creates a confirmation dialog before either figure window is closed and closes both figure
% windows simultaneously when the user confirms.
function closeProgram(~,~,F,S)
    
    if strcmp(questdlg('Are you sure you want to close?'),'Yes')
        % Close both windows by deleting their handles (using "close" would create a recursive loop).
        delete([F,S]);
    end

end


%% createCheckBox
function C = createCheckBox(name,n,SH)
    cPosStart = [50,SH-50];
    W = 200;
    H = 25;
    wPad = 225;
    hPad = -60;
    nCol = 3;
    C = uicontrol('Style','checkbox');
    C.FontSize = 14;
    C.FontName = 'FixedWidth';
    C.Position = [cPosStart + [mod(n-1,nCol)*wPad,floor((n-1)/nCol)*hPad],W,H];
    C.String = name;
    C.UserData = n;
    C.Callback = @checboxCallback;
end


%% createSpinButton
function C = createSpinButton(FW)
    hPad = 35;
    W = 75;
    H = 40;
    B = 30;
    L = FW - W - hPad;
    C = uicontrol('Style','pushbutton');
    C.FontSize = 14;
    C.FontName = 'FixedWidth';
    C.Position = [L,B,W,H];
    C.String = 'Spin';
    C.Callback = @spinWheel;
end


%% createVoteButton
function C = createVoteButton(SW)
    hPad = 35;
    W = 75;
    H = 40;
    B = 30;
    L = SW - W - hPad;
    C = uicontrol('Style','pushbutton');
    C.FontSize = 14;
    C.FontName = 'FixedWidth';
    C.Position = [L,B,W,H];
    C.String = 'Vote';
    C.Callback = @voteButtonCallback;
end


%% createWheel
function PO = createWheel(weights,F)
    UD = F.UserData;
    A_F = F.CurrentAxes;
    
    r = 1;
    n = numel(weights);
    
    for ii = numel(A_F.Children):-1:1
        delete(A_F.Children(ii));
    end
    
    [R,G,B] = makeRGBColors(n);
    
    PO = gobjects(n,1);
    
    for ii = 1:n
        [x,y] = arc(sum(weights(1:ii-1)),weights(ii),r);
        PO(ii) = patch(A_F,x,y,[R(ii),G(ii),B(ii)],'DisplayName',[char(UD.foodList(UD.list(ii))),' [',num2str(UD.votes(UD.list(ii))),']']);
    end
    
    L = legend(A_F,'Location','eastoutside');
    L.FontSize = 14;
end


%% makeRGBColors
function [R,G,B] = makeRGBColors(nColors)
    R = zeros(nColors,1);
    G = zeros(nColors,1);
    B = zeros(nColors,1);
    
    n = floor(linspace(0,5,nColors));
    j = mod(linspace(0,5,nColors),1);
    
    for ii = 1:nColors
        R(ii) = j(ii)*(n(ii) == 4) + 1*(n(ii) == 5 || n(ii) == 0) + (1 - j(ii))*(n(ii) == 1);
        G(ii) = j(ii)*(n(ii) == 0) + 1*(n(ii) == 1 || n(ii) == 2) + (1 - j(ii))*(n(ii) == 3);
        B(ii) = j(ii)*(n(ii) == 2) + 1*(n(ii) == 3 || n(ii) == 4) + (1 - j(ii))*(n(ii) == 5);
    end
end


%% rotateStep
function rotateStep(th,F)
    UD = F.UserData;
    
    
    for ii = 1:numel(UD.PO)
        x = UD.PO(ii).XData;
        y = UD.PO(ii).YData;
        UD.PO(ii).XData = x*cos(th) - y*sin(th);
        UD.PO(ii).YData = x*sin(th) + y*cos(th);
        
    end
end


%% spinWheel
function spinWheel(src,~)
    F = src.Parent;
    
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
    th_old = 0;
    
    for ii = 1:nAcc
        th_new = om(ii)*dt + th_old;
        rotateStep(th_new-th_old,F);
        drawnow;
        th_old = th_new;
    end
    
    om_old = om(end);
    
    while om_old > .2
        om_new = om_old*damp;
        th_new = om_new*dt + th_old;
        rotateStep(th_new-th_old,F);
        drawnow;
        th_old = th_new;
        om_old = om_new;
    end
    
    beep;
    
end


%% voteButtonCallback
function voteButtonCallback(src,~)
    S = src.Parent;
    UDS = S.UserData;
    F = UDS.F;
    weights = calcWeights(F,S);
    
    
    
    F.UserData.PO = createWheel(weights,F);
    
    for ii = 1:numel(S.Children)
        if strcmp(S.Children(ii).Type,'uicontrol') && strcmp(S.Children(ii).Style,'checkbox')
            S.Children(ii).Enable = 'on';
            S.Children(ii).Value = 0;
        end
    end
    
    S.UserData.nChecked = 0;
    S.UserData.checkedList = [];
end