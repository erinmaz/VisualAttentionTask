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

%deviceString = 'Apple Internal Keyboard / Trackpad';
deviceString = 'Dell USB Entry Keyboard';
%deviceString = 'Lumina Keyboard';

% Output Variables
run_name = sprintf('resp_mat.run%d_localizer',run_number);
run_data = [];
run_data.complete = 'no';

% Task Variables
time_head = 56;  % 20
time_on = 35;   % 25
time_off = 35;  % 25
cycles = 4;     % 7

% Grating Variables
on_stim = [1 2]; % which contrast is flipped
freq = 7; % checkerboard frequency in Hz
%matrix_size = 16; % checkerboard  % use this one to change check size

% Window Coordinates
[screenXpixels, screenYpixels] = Screen('WindowSize', window);


%-----------------------------------------------------------------------
% DRAW INSTRUCTIONS, WAIT FOR TRIGGER
%-----------------------------------------------------------------------
% Prepare the Window
HideCursor;
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');% Set up alpha-blending for smooth (anti-aliased) lines

% Draw the Instructions
Screen('TextSize', window, 30);
DrawFormattedText(window, 'Calculating. Please Wait...', 'center', 'center');
Screen('Flip', window);

imSize = screenXpixels; %size of window
dim = imSize/2;
[xm, ym] = meshgrid(-dim:dim-1, -dim:dim-1);
inner_circle_fract = 0.22; 

circle = ((xm.^2)+(ym.^2) <= (dim)^2); % outer circle
circle2 = ((xm.^2)+(ym.^2) <= (imSize*inner_circle_fract)^2); % inner circle
aperature = circle - circle2;

trapwidth=screenXpixels*0.07;
trapinterval=1/trapwidth;
trapvec = 0:trapinterval:1;
[xtrap,ytrap] = meshgrid([trapvec,fliplr(trapvec)]);
linkern = xtrap.*ytrap;
aperature_smooth=(conv2(aperature,linkern,'same'));
scale = max(aperature_smooth(:));
aperature_smooth = aperature_smooth/scale;

% Define aperature coordinates
xg = screenXpixels / 2;
yg = screenYpixels / 2;
[s1, s2] = size(aperature_smooth);
dstRect = CenterRectOnPointd([0 0 s1, s2], xg, yg);

% Make 2d grating
x = 1:imSize;
x0 = (x / imSize) - .5;
[xm, ym] = meshgrid(x0, x0);
theta1 = 45; % Right slanted sin grating
theta2 = 135; % Left slanted sin grating

%check if lambda corresponds to visual angle in Moradi paper
lamda = screenXpixels*.06; % Wavelength (in px) determines check size
sin_freq = imSize/lamda;

phaseRad = 0;
thetaRad1 = (theta1 / 360) * 2*pi;
thetaRad2 = (theta2 / 360) * 2*pi;
grating1 = sin( (((xm * cos(thetaRad1))+(ym * sin(thetaRad1)))*sin_freq * 2*pi) + phaseRad);
grating2 = sin( (((xm * cos(thetaRad2))+(ym * sin(thetaRad2)))*sin_freq * 2*pi) + phaseRad);
finalgrating_a=(grating1.*grating2.*aperature_smooth);
finalgrating_a=(finalgrating_a+1)/2;

%2nd grating 180 degrees out of phase with first grating
phaseRad = pi/2;
thetaRad1 = (theta1 / 360) * 2*pi;
thetaRad2 = (theta2 / 360) * 2*pi;
grating1 = sin( (((xm * cos(thetaRad1))+(ym * sin(thetaRad1)))*sin_freq * 2*pi) + phaseRad);
grating2 = sin( (((xm * cos(thetaRad2))+(ym * sin(thetaRad2)))*sin_freq * 2*pi) + phaseRad);
finalgrating_b=(grating1.*grating2.*aperature_smooth);
finalgrating_b=(finalgrating_b+1)/2; % CHECK RANGE

gratingTexture(1) = Screen('MakeTexture', window, finalgrating_a);
gratingTexture(2) = Screen('MakeTexture', window, finalgrating_b); % inverse contrast

% SETUP RESPONSE DEVICE
[id,name] = GetKeyboardIndices;
device=0;
for i=1:length(name)
    if strcmp(name{i},deviceString)
        device=id(i);
        break;
    end
end
if device==0 %%error checking
    disp('No device by that name was detected');
end

% Draw the Instructions, 
Screen('TextSize', window, 30);
DrawFormattedText(window, 'Keep eyes fixated at the center mark\n\nPush the button when you are ready to start', 'center', 'center');
Screen('Flip', window);

%Wait for participant to push button
KbTriggerWait(KbName('c'), device);

%Draw fixation
Screen('FillOval', window, black, fixRect);
Screen('Flip', window);

% Wait for Trigger
KbTriggerWait(KbName('T'), device);


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
        filterMode = 1; % Smooths sin grating
        Screen('DrawTextures', window, gratingTexture(on_stim(1)), [], dstRect, 0, filterMode);
        
        % Draw the fixation
        Screen('FillOval', window, black, fixRect);
        
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

