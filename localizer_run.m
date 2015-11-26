function [ run_name, run_data ] = localizer_run( run_number, window, fixRect, black, xm, ym, dstRect, theta1, theta2, sin_freq, aperature_smooth,deviceString)
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
time_head = 36;  % 35
time_on = 36;   % 35
time_off = 36;  % 35
cycles = 4;     % 4

% Time to wait in frames for a flip
waitframes = 1;

%Grating variables
on_stim = [1 2]; % which contrast is flipped
freq = 7;% checkerboard frequency in Hz

quit_button = 20;       % 20 is the int value of 'q'


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

% Time we want to wait before reversing the contrast of the checkerboard
checkFlipTimeSecs = 1/freq;
ifi = Screen('GetFlipInterval', window);
checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);

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

%Clear screen
Screen('Flip', window);

% Wait for Trigger
KbTriggerWait(KbName('T'), device);

%Draw fixation
Screen('FillOval', window, black, fixRect);
Screen('Flip', window);


% DISPLAY THE HEAD

% Set Timer
t_stop = GetSecs + time_head;

% Draw the Fixation Circle
while GetSecs < t_stop
    Screen('FillOval', window, black, fixRect);
    Screen('Flip', window);
    
    % Check If User Quits - press 'q' to quit
    [~, ~, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
    keyName = KbName(logical(keyCode));%returns key name as a string
    keyInt = KbName(keyName);%changes string to int
    if keyInt == quit_button % 20 is the int value of 'q'
        quit = 1;
    end
    if quit, return; end
end


% DISPLAY THE CYCLES

% Initiate Cycle Loop
for i = 1:cycles
    
    % STIMULUS ON
    
    frameCounter = 0;
    
    % Set Timer
    t_stop = GetSecs + time_on;
    
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
        [~, ~, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int
        if keyInt == quit_button % 20 is the int value of 'q'
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
        [~, ~, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int
        if keyInt == quit_button % 20 is the int value of 'q'
            quit = 1;
        end
        if quit, return; end
    end
end

ShowCursor;
run_data.complete = 'yes';
end

