function [ run_name, run_data ] = localizer_run( run_number, window, fixRect, stimRect, white, grey, black)
% Edited Aug 14 2015, MM
% This function presents the localizer and saves the run number.

%   A block experiment with a peripheral flickering checkerboard and a 
%   central fixation.  This function uses a high contrast checkerboard in 
%   the same region as the peripheral grating of the experiment. The
%   function is organized in chronological order.


%-----------------------------------------------------------------------
% INITIALIZE VARIABLES
%-----------------------------------------------------------------------
global quit
quit = 0;

% Output Variables
run_name = sprintf('resp_mat.run%d_localizer',run_number);
run_data = [];
run_data.complete = 'no';

% Task Variables
time_head = 5;  % 20
time_on = 15;   % 25
time_off = 15;  % 25
cycles = 4;     % 7

% Grating Variables
on_stim = [1 2]; % which contrast is flipped
freq = 10; % checkerboard frequency in Hz
matrix_size = 16; % checkerboard  % use this one to change check size

% Window Coordinates
[screenXpixels, screenYpixels] = Screen('WindowSize', window);


%-----------------------------------------------------------------------
% DRAW INSTRUCTIONS, WAIT FOR TRIGGER
%-----------------------------------------------------------------------
% Prepare the Window
HideCursor;
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');% Set up alpha-blending for smooth (anti-aliased) lines

% Draw the Instructions
Screen('TextSize', window, 48);
DrawFormattedText(window, 'Keep eyes fixated at the center mark', 'center', 'center');
Screen('Flip', window);

% Wait for Trigger : Any keystroke will work here
KbStrokeWait(-1);  % -1 causes it to check all keyboards
fprintf('Waiting for trigger.  Press any key to continue');


%-----------------------------------------------------------------------
% LOCALIZER
%-----------------------------------------------------------------------

% DISPLAY THE HEAD

% Set Timer
t_stop = GetSecs + time_head;

% Draw the Fixation Circle
while GetSecs < t_stop
    %rectColor = [0.8 0 0];
    Screen('FillOval', window, black, fixRect);
    Screen('Flip', window);

    % Check If User Quits - press 'q' to quit
    [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
    keyName = KbName(logical(keyCode));%returns key name as a string
    keyInt = KbName(keyName);%changes string to int
    
    if keyInt == 20; % 20 is the int value of 'q'
        quit = 1;
    end

if quit, return; end
end    

% DISPLAY THE CYCLES 

% Define Aperature Shading
imSize = 1001; %size of the circle mask
dimA = imSize/2; %size of window
[xm, ym] = meshgrid(-dimA:dimA-1, -dimA:dimA-1);
circle1 = ((xm.^2)+(ym.^2) <= (440-18)^2); % 440 is the radius of the outer circle
circle2 = ((xm.^2)+(ym.^2) <= 190^2); % 190 is radius of inner circle
aperature = circle1 - circle2;
trapvec = 0:.03333:1; %linear increase over 30 pixels (i.e., half of 60 - I'm not sure this is right)
[xtrap,ytrap] = meshgrid([trapvec,fliplr(trapvec)]);
linkern = xtrap.*ytrap;
aperature_smooth=(conv2(aperature,linkern,'same'))/1000;

% Define Checkerboard
checkerboard = repmat(eye(2), matrix_size, matrix_size);
checkerTexture(1) = Screen('MakeTexture', window, checkerboard);
checkerTexture(2) = Screen('MakeTexture', window, 1-checkerboard); % inverse contrast

% Define Aperature 
dim = 500; % Do not change
[xm, ym] = meshgrid(-dim:dim, -dim:dim);
circle = ((xm.^2)+(ym.^2) <= 445^2); % 445 is the radius of the outer circle
[s1, s2] = size(circle);
% Plain aperature
maskc = ones(s1, s2, 2) * grey;
maskc(:, :, 2) = white * (1 - circle);%* abs(1-aperature_smooth);%1001*1001, zero on checkers
% Shaded aperature
maska = ones(s1, s2, 2) * grey;
maska(:, :, 2) = abs(1-aperature_smooth);
masktexc = Screen('MakeTexture', window, maska);
% Make a grey texture to cover the full window
fullWindowMask = Screen('MakeTexture', window, ones(screenYpixels, screenXpixels) .* grey);
% Define aperature coordinates
xg = screenXpixels / 2;
yg = screenYpixels / 2;
dstRect = CenterRectOnPointd([0 0 s1, s2], xg, yg);


% Initiate Cycle Loop
for i = 1:cycles

    % STIMULUS ON
    
    % Set Timer
    t_stop = GetSecs + time_on;
    
    % Time we want to wait before reversing the contrast of the checkerboard
    checkFlipTimeSecs = 1/freq;
    ifi = Screen('GetFlipInterval', window);
    checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
    frameCounter = 0;

    % Time to wait in frames for a flip
    waitframes = 1;

    % Sync us to the vertical retrace
    vbl = Screen('Flip', window);

    % Initiate Contrast Flipping
    while GetSecs < t_stop

        % Increment Counter
        frameCounter = frameCounter + 1;

        % Draw the Chosen Contrast
        filterMode = 0;
        Screen('DrawTextures', window, checkerTexture(on_stim(1)), [], dstRect, 45, filterMode);
        
        % Draw the Aperatue
        Screen('DrawTextures', fullWindowMask, masktexc, [], dstRect)% draw circle aperature onto full screen aperature mask
        Screen('DrawTexture', window, fullWindowMask); % draw mask


        % Draw the Middle
        Screen('FillOval', window, grey, stimRect);
           
        % Draw the fixation point     
        Screen('FillOval', window, black, fixRect);
 
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

        % Reverse the Texture Cue
        if frameCounter == checkFlipTimeFrames
            on_stim = fliplr(on_stim);
            frameCounter = 0;
        end
        
        % Check If User Quits 
        [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int

        if keyInt == 20; % 20 is the int value of 'q'
            quit = 1;
        end

        if quit, return; end
    end
    
    % STIMULUS OFF
    
    % Set Timer
    t_stop = GetSecs + time_off;
    
    % Draw Fixation
    while GetSecs < t_stop
        Screen('FillOval', window, black, fixRect);
        Screen('Flip', window);
        
        % Check If User Quits - press 'q' to quit
        [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int

        if keyInt == 20; % 20 is the int value of 'q'
            quit = 1;
        end

        if quit, return; end
        
    end
    
end


%-----------------------------------------------------------------------
% END THE RUN
%-----------------------------------------------------------------------

ShowCursor;
run_data.complete = 'yes';
end

