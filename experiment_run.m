<<<<<<< HEAD
function [ run_name, run_data ] = experiment_run( run_number, window, windowRect, fixRect, stimRect, white, grey, black)
=======
function [ run_name, run_data ] = experiment_run( run_number, window, windowRect, fixRect, stimRect, grey, black)
>>>>>>> pr/1
% This function presents the experiment (control and attention conditions)
% and saves the run number and response data.

%   A block experiment with a peripheral flickering checkerboard and a
%   central fixation.  The control (fixation) condition includes a
%   one-back memory task on digits appearing at fixation. The attention
%   condition requires participants to monitor and report subtle contrast
%   changes of a low contrast peripheral grating. The function is organized in
%   chronological order.  First the fixation condition is presented,
%   followed by the attention condition.  Responses are monitored at every
%   frame of presentation.


%-----------------------------------------------------------------------
% INITIALIZE VARIABLES
%-----------------------------------------------------------------------
global quit
quit = 0;

% Output Variables
run_name = sprintf('resp_mat.run%d_experiment',run_number);
run_data = [];
run_data.complete = 'no';
run_data.correct = 0;
run_data.total = 0;

% Task Variables
<<<<<<< HEAD
time_head = 2;      %45
head_delay = 2;    %10
tail_delay = 2;    %55 change?
time_tail = 2;     %35 change?
time_on = 3;       %20
time_off = 3;      %60
cycles = 2;         % of EACH task (fixation or attention)
=======
time_head = 5;      %60
head_delay = 0;     %0
lead_up = 5;        %5
tail_delay = 0;     %0
lead_down = 0;      %0
time_tail = 10;     %35
time_on = 20;       %20
time_off = 20;      %55
cycles = 1;         % of EACH task (fixation or attention)
cycles_interleaved = 3; % number of interleaved attention + fixation cycles
>>>>>>> pr/1
quit_button = 20;       % 20 is the int value of 'q'
response_button = 4;    % 4 is the int value of 'a'
% Find using KbName('x') in command window

% Stimulus Variables
freq = 60; % checkerboard refresh rate in Hz
num_freq = 2; % number frequency in Hz

% Window Variables
[xCenter, yCenter] = RectCenter(windowRect);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
waitframes = 1; % time to wait in frames for a flip
ifi = Screen('GetFlipInterval', window); % inter frame inverval

% Fixation Arrow 
pointListIn = zeros(7,2);
yTrans = 18; % Vertical shift from center
pointListIn(:,1) = xCenter;
pointListIn(:,2) = yCenter + yTrans;
pointListIn(2,1) = pointListIn(1,1)-5;
pointListIn(2,2) = pointListIn(1,2)+8;
pointListIn(3,1) = pointListIn(1,1)-2;
pointListIn(3,2) = pointListIn(1,2)+8;
pointListIn(4,1) = pointListIn(1,1)-2;
pointListIn(4,2) = pointListIn(1,2)+20;
pointListIn(5,1) = pointListIn(1,1)+2;
pointListIn(5,2) = pointListIn(1,2)+20;
pointListIn(6,1) = pointListIn(1,1)+2;
pointListIn(6,2) = pointListIn(1,2)+8;
pointListIn(7,1) = pointListIn(1,1)+5;
pointListIn(7,2) = pointListIn(1,2)+8;

% Attention Arrow 
pointListOut = zeros(7,2);
%yTrans = 18; % Vertical shift from center
pointListOut(:,1) = xCenter;
pointListOut(:,2) = yCenter + yTrans + 20;
pointListOut(2,1) = pointListOut(1,1)-5;
pointListOut(2,2) = pointListOut(1,2)-8;
pointListOut(3,1) = pointListOut(1,1)-2;
pointListOut(3,2) = pointListOut(1,2)-8;
pointListOut(4,1) = pointListOut(1,1)-2;
pointListOut(4,2) = pointListOut(1,2)-20;
pointListOut(5,1) = pointListOut(1,1)+2;
pointListOut(5,2) = pointListOut(1,2)-20;
pointListOut(6,1) = pointListOut(1,1)+2;
pointListOut(6,2) = pointListOut(1,2)-8;
pointListOut(7,1) = pointListOut(1,1)+5;
pointListOut(7,2) = pointListOut(1,2)-8;


%-----------------------------------------------------------------------
% CREATE STIMULI
%-----------------------------------------------------------------------

% RANDOM REPEATING NUMBERS

% Create the list of numbers that will flash on the screen
% Set the repeat intevals
repeat = round(rand(1,108)*4+3); % list of ints between 3 and 7 (seconds of random repeating values)
repeatFlicker = round(rand(1,50)*3+3); % list between 3 and 6 to ensure sufficient number of flickers per stim block
repeat2Hz = repeat * 2;
% Set the first section - each section has 6 to 14 non repeating numbers followed by one repeat.
val_list = randperm(9,6); % 6 non-repeating values between 1 and 9
repeat_val = val_list(6);
val_list = [val_list repeat_val];

% Add to the value list one non-repeating chunk at a time
for i = repeat2Hz % Numbers flicker at 2Hz so we extend the repeat interval by 2
    triple = true;
    double = true;
    % Add a smaller chunk with no repeats if i > 9
    if i > 9
        while double
            list_append = randperm(9,9);
            if list_append(1) == val_list(length(val_list))
                double = true;
            else
                double = false;
            end
        end
        val_list = [val_list list_append];
        i = i - 9;
    end
    % Add the remaining chunk or small chunk
    while triple  % Check that there are no triple repeats
        list_append = randperm(9,i); % i non-repeating numbers between 1 and 9
        if list_append(1) == val_list(length(val_list))
            triple = true;
        else
            triple = false;
        end
    end
    % Add the new section
    val_list = [val_list list_append];
    % Add the repeating value
    repeat_val = val_list(length(val_list));
    val_list = [val_list repeat_val];
    % End when the list is long enough (10% more #'s than needed at a rate of 2/sec)
    if length(val_list) > (head_delay + tail_delay + (lead_up + time_on + time_off) * cycles * cycles_interleaved) * 2.2
        break
    end
end

% RANDOM NON-REPEATING NUMBERS

% Set the first section
unique_list = randperm(9,9); % 9 non-repeating values between 1 and 9

% Add to the list one non-repeating chunk at a time
for i = 1:100
    double = true; % Check that there are no repeats
    while double
        list_append = randperm(9,9);
        if list_append(1) == unique_list(length(unique_list))
            double = true;
        else
            double = false;
        end
    end
    % Add the new section
    unique_list = [unique_list list_append];
    % End when the list is long enough (10% more #'s than needed at a rate of 2/sec)
    if length(unique_list) > (head_delay + tail_delay + (time_on + time_off) * cycles) * 2.2
        break
    end
end

% RANDOM FRAME INTERVALS

random_frames = round(repeatFlicker / ifi); %random frame values totaling 3 to 6 seconds
flicker_count = 1; % index of random list

% WAIT SCREEN

% The next step takes a long time, draw a "PLEASE WAIT" screen

% Prepare the Window
<<<<<<< HEAD

% HideCursor;
=======
% HideCursor;  % DEBUG ONLY %%%%%%%%%%%%%%%%%
>>>>>>> pr/1
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');% Set up alpha-blending for smooth (anti-aliased) lines

% Draw the Instructions
Screen('TextSize', window, 48);
DrawFormattedText(window, 'Calculating. Please Wait...', 'center', 'center');
Screen('Flip', window);

% PERIPHERAL CHECKERBOARD

% Define Aperature
% Moradi paper says they used a trapezoid function to smooth the aperature
% (over about 7% of total size (~60 pixels? check this?)

imSize = 890;% 890 is outer diameter of stimuli
dim = imSize/2; %size of window
[xm, ym] = meshgrid(-dim:dim-1, -dim:dim-1);

<<<<<<< HEAD
circle = ((xm.^2)+(ym.^2) <= dim^2); % 445 is the radius of the outer circle
circle2 = ((xm.^2)+(ym.^2) <= (dim/2)^2);
=======
circle = ((xm.^2)+(ym.^2) <= (dim-18)^2); % 445 is the radius of the outer circle
circle2 = ((xm.^2)+(ym.^2) <= 190^2); % 190 is radius of inner circle
>>>>>>> pr/1
aperature = circle - circle2;

trapvec = 0:.03333:1; %linear increase over 30 pixels (i.e., half of 60 - I'm not sure this is right)
[xtrap,ytrap] = meshgrid([trapvec,fliplr(trapvec)]);
linkern = xtrap.*ytrap;
aperature_smooth=(conv2(aperature,linkern,'same'))/1000;

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
lamda = 50; % Wavelength (in px) determines check size

sin_freq = imSize/lamda;
amplitude = 0.15; % Determines contrast of flicker mask during flicker
translation = 0.6; % Determines baseline opacity of flicker mask
textureList1 = zeros(1,240);
for i = 1 : 240 % pre-draw 240 of these (one full phase) to save time during frames
    phase = i*1.5; % VARIES WITH TIME
    phaseRad = (phase * (pi/180));
    thetaRad1 = (theta1 / 360) * 2*pi;
    thetaRad2 = (theta2 / 360) * 2*pi;
    grating1 = sin( (((xm * cos(thetaRad1))+(ym * sin(thetaRad1)))*sin_freq * 2*pi) + phaseRad);
    grating2 = sin( (((xm * cos(thetaRad2))+(ym * sin(thetaRad2)))*sin_freq * 2*pi) + phaseRad);
    finalgrating=(grating1.*grating2.*aperature_smooth);
    finalgrating=(finalgrating+1)/2;
    gratingTexture1 = Screen('MakeTexture', window, finalgrating);
    textureList1(i) = gratingTexture1;
end
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
% DRAW INSTRUCTIONS, WAIT FOR TRIGGER
%-----------------------------------------------------------------------

% Draw the Instructions
Screen('TextSize', window, 48);
DrawFormattedText(window, 'Keep eyes fixated at the center mark. \n\n\n\n When arrow points inward, press \n\n for repeating numbers. \n\n\n\n When arrow points outward, press \n\n for contrast flickers.', 'center', 'center');
Screen('Flip', window);

% Wait for Trigger : Any keystroke will work here
KbStrokeWait(-1);  % -1 causes it to check all keyboards
fprintf('Waiting for trigger.  Press any key to continue');


% DISPLAY THE HEAD
%------------------

% Set Timer
t_stop = GetSecs + time_head;


% Draw the Fixation Box
while GetSecs < t_stop
    rectColor = [0.8 0 0];
    Screen('FillOval', window, black, fixRect);
    Screen('FillPoly', window, rectColor, pointListIn);
    Screen('Flip', window);
    
    % Check If User Quits - press 'q' to quit
    [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
    keyName = KbName(logical(keyCode));%returns key name as a string
    keyInt = KbName(keyName);%changes string to int
    
    if keyInt == quit_button;
        quit = 1;
    end
    
    if quit, return; end
end
<<<<<<< HEAD
=======

for i = 1:cycles_interleaved
    cycle_name = sprintf('run_data.cycle%d',i);
    cycle_data = [];
    cycle_data.fixation_response.time = [];
    cycle_data.fixation_response.correct = 0;
    cycle_data.fixation_response.miss = 0;
    cycle_data.fixation_response.false_alarm = 0;
    cycle_data.fixation_response.repeat_tests = 0;
    cycle_data.attention_response.time = [];
    cycle_data.attention_response.correct = 0;
    cycle_data.attention_response.miss = 0;
    cycle_data.attention_response.false_alarm = 0;
    cycle_data.attention_response.flickers = 0;
    
    %-----------------------------------------------------------------------
    % FIXATION
    %-----------------------------------------------------------------------
>>>>>>> pr/1

    % DISPLAY THE HEAD
    %------------------

<<<<<<< HEAD
% Set Timer
t_stop = GetSecs + head_delay;

% Time we want to wait before flipping to the next number
checkFlipTimeSecs = 1/num_freq;
checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
=======
    % Set Timer
    t_stop = GetSecs + lead_up;
>>>>>>> pr/1


    % Draw the Fixation Box
    while GetSecs < t_stop
        rectColor = [0.8 0 0];
        Screen('FillOval', window, black, fixRect);
        Screen('FillPoly', window, rectColor, pointListIn);
        Screen('Flip', window);

        % Check If User Quits - press 'q' to quit
        [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int

<<<<<<< HEAD
while GetSecs < t_stop
    % Increment Counter
    frameCounter = frameCounter + 1;
    
    % DRAW STIMULI
    
    if frameCounter + 5 >= checkFlipTimeFrames % 5 frame pause between numbers
        % Draw just the fixation square
        Screen('FillRect', window, rectColor, fixRect);
    else
        % Draw the number on top of the fixation square
        Screen('TextSize', window, 32);
        Screen('FillRect', window, rectColor, fixRect);
        DrawFormattedText(window, num2str(val_list(listCounter)), 'center', 'center');
    end
    
    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    % Advance to next number in list
    if frameCounter == checkFlipTimeFrames
        listCounter = listCounter + 1;
        % Check if this number requires a response (new # = previous #)
        if val_list(listCounter-1) == val_list(listCounter)
            response_needed = true;
            response_not_needed = false;
            % Assume "miss" until response is given
            run_data.fixation_response.miss = run_data.fixation_response.miss + 1;
            run_data.fixation_response.repeat_tests = run_data.fixation_response.repeat_tests + 1;
            % Check if previous number required a response
        elseif (listCounter > 2) && (val_list(listCounter-2) == val_list(listCounter-1))
            response_not_needed = false; % leway time on false alarm trigger
        else
            response_needed = false;
            response_not_needed = true;
        end
        frameCounter = 0;
    end
    
    % USER RESPONSE
    
    % Check for a keyboard response (on EVERY frame)
    [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
    keyName = KbName(logical(keyCode));%returns key name as a string
    keyInt = KbName(keyName);%changes string to int
    % Quit condition
    if keyInt == quit_button;
        quit = 1;
    elseif keyInt == response_button;
        % Correct response to stimulus
        if response_needed
            run_data.fixation_response.time = [run_data.fixation_response.time secs];
            run_data.fixation_response.correct = run_data.fixation_response.correct + 1;
            run_data.fixation_response.miss = run_data.fixation_response.miss - 1;
            response_needed = false;
            % Incorrect response to stimulus
        elseif response_not_needed
            run_data.fixation_response.false_alarm = run_data.fixation_response.false_alarm + 1;
            response_not_needed = false;
        end
=======
        if keyInt == quit_button;
            quit = 1;
        end

        if quit, return; end
>>>>>>> pr/1
    end
    
    if quit, return; end
end

<<<<<<< HEAD
% DISPLAY THE CYCLES
%--------------------

% Initiate Cycle Loop
for i = 1:cycles
    
    % STIMULUS ON
    %-------------
    
    % Set Timer
    t_stop = GetSecs + time_on;
    
    % Stimulus Variables
    angle = 0;
    phase_index = 1; % controls movement of grating
    flicker_deg = 0; % controls sinusoidal flicker mask
    % Time we want to wait before reversing the contrast of the checkerboard
    checkFlipTimeSecs_stim = 1/freq; % moving grating refresh rate
    checkFlipTimeFrames_stim = round(checkFlipTimeSecs_stim / ifi);
    % Time we want to wait before flipping to the next number
    checkFlipTimeSecs_nums = 1/num_freq;
    checkFlipTimeFrames_nums = round(checkFlipTimeSecs_nums / ifi);
    
=======
    % DISPLAY NUMBERS (HEAD DELAY)
    %-----------------------------

    % Set Timer
    t_stop = GetSecs + head_delay;

    % Time we want to wait before flipping to the next number
    checkFlipTimeSecs = 1/num_freq;
    checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);

>>>>>>> pr/1
    % Sync us to the vertical retrace
    vbl = Screen('Flip', window);

    % Initialize loop
    frameCounter = 0;
    listCounter = 1; % place in the # list
    response_needed = false; % used for correct response count
    response_not_needed = true; % used for false alarm count
<<<<<<< HEAD
    flicker = false;
    
    % FRAME LOOP
    
    % Initiate Contrast Flipping
    while GetSecs < t_stop
        
=======

    % FRAME LOOP

    while GetSecs < t_stop
>>>>>>> pr/1
        % Increment Counter
        frameCounter = frameCounter + 1;

        % DRAW STIMULI
<<<<<<< HEAD
        
        % Draw Sin grating
        filterMode = 1; % Smooths sin grating
        Screen('DrawTextures', window, textureList1(phase_index), [], [], 0, filterMode);
     
        % Create an alpha mask to modulate flicker
        if flicker
            flickerScreen = amplitude * sin(flicker_deg*pi/180);
            greyTrans = [grey grey grey (translation + flickerScreen)];
        else
            greyTrans = [grey grey grey translation];
        end
        newRect = [0, 0, 1000, 1000];
        flickerRect = CenterRectOnPointd(newRect, xCenter, yCenter);
        Screen('FillOval', window, greyTrans, flickerRect);
        
        % Draw the fixation
        if frameCounter_nums + 5 >= checkFlipTimeFrames_nums % 5 frame pause between numbers
=======

        if frameCounter + 5 >= checkFlipTimeFrames % 5 frame pause between numbers
>>>>>>> pr/1
            % Draw just the fixation square
            Screen('FillPoly', window, rectColor, pointListIn);
            %Screen('FillOval', window, black, fixRect);
        else
            % Draw the number on top of the fixation square
            Screen('TextSize', window, 32);
            Screen('FillPoly', window, rectColor, pointListIn);
            %Screen('FillRect', window, rectColor, fixRect);
            DrawFormattedText(window, num2str(val_list(listCounter)), 'center', 'center');
        end
<<<<<<< HEAD
        
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        % Check if a flicker should start
        if frameCounter_flicker == random_frames(flicker_count)
            flicker = true;
            flicker_count = flicker_count + 1;
            flicker_deg = 0;
        end
        
        % Determine if flicker is over
        if flicker
            if flicker_deg == 360
                flicker = false;
                frameCounter_flicker = 0;
            end
        end
        
        % Keep the phase of the grating moving 60HZ
        if frameCounter_stim == checkFlipTimeFrames_stim
            phase_index = phase_index + 1;
            % Also advance the flicker contrast
            flicker_deg = flicker_deg + 12; %12 deg at 60Hz = 0.5 second for 360 deg
            % End of texture list, reset it
            if phase_index >= 241
                phase_index = 1;
            end
            angle = angle + 0.1;
            frameCounter_stim = 0;
        end
        
=======

        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

>>>>>>> pr/1
        % Advance to next number in list
        if frameCounter == checkFlipTimeFrames
            listCounter = listCounter + 1;
            % Check if this number requires a response (new # = previous #)
            if val_list(listCounter-1) == val_list(listCounter)
                response_needed = true;
                response_not_needed = false;
                % Assume "miss" until response is given
<<<<<<< HEAD
                run_data.fixation_response.miss = run_data.fixation_response.miss + 1;
                run_data.fixation_response.repeat_tests = run_data.fixation_response.repeat_tests + 1;
=======
                cycle_data.fixation_response.miss = cycle_data.fixation_response.miss + 1;
                cycle_data.fixation_response.repeat_tests = cycle_data.fixation_response.repeat_tests + 1;
>>>>>>> pr/1
                % Check if previous number required a response
            elseif (listCounter > 2) && (val_list(listCounter-2) == val_list(listCounter-1))
                response_not_needed = false; % leway time on false alarm trigger
            else
                response_needed = false;
                response_not_needed = true;
            end
            frameCounter = 0;
        end

        % USER RESPONSE

        % Check for a keyboard response (on EVERY frame)
        [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int
        % Quit condition
        if keyInt == quit_button;
            quit = 1;
        elseif keyInt == response_button;
            % Correct response to stimulus
            if response_needed
                cycle_data.fixation_response.time = [cycle_data.fixation_response.time secs];
                cycle_data.fixation_response.correct = cycle_data.fixation_response.correct + 1;
                cycle_data.fixation_response.miss = cycle_data.fixation_response.miss - 1;
                response_needed = false;
                % Incorrect response to stimulus
            elseif response_not_needed
                cycle_data.fixation_response.false_alarm = cycle_data.fixation_response.false_alarm + 1;
                response_not_needed = false;
            end
        end
        
        if quit, return; end
    end

    % DISPLAY THE CYCLES
    %--------------------

    % Initiate Cycle Loop
    for i = 1:cycles

        % STIMULUS ON
        %-------------

        % Set Timer
        t_stop = GetSecs + time_on;

        % Stimulus Variables
        angle = 0;
        phase_index = 1; % controls movement of grating
        flicker_deg = 0; % controls sinusoidal flicker mask
        % Time we want to wait before reversing the contrast of the checkerboard
        checkFlipTimeSecs_stim = 1/freq; % moving grating refresh rate
        checkFlipTimeFrames_stim = round(checkFlipTimeSecs_stim / ifi);
        % Time we want to wait before flipping to the next number
        checkFlipTimeSecs_nums = 1/num_freq;
        checkFlipTimeFrames_nums = round(checkFlipTimeSecs_nums / ifi);

        % Sync us to the vertical retrace
        vbl = Screen('Flip', window);

        % Initialize loop
        frameCounter_stim = 0;
        frameCounter_nums = 0;
        frameCounter_flicker = 0;
        response_needed = false; % used for correct response count
        response_not_needed = true; % used for false alarm count
        flicker = false;

        % FRAME LOOP

        % Initiate Contrast Flipping
        while GetSecs < t_stop

            % Increment Counter
            frameCounter_stim = frameCounter_stim + 1;
            frameCounter_nums = frameCounter_nums + 1;
            frameCounter_flicker = frameCounter_flicker + 1;

            % DRAW STIMULI

            % Draw Sin grating
            filterMode = 1; % Smooths sin grating
            Screen('DrawTextures', window, textureList1(phase_index), [], [], 0, filterMode);

            % Create an alpha mask to modulate flicker
            if flicker
                flickerScreen = amplitude * sin(flicker_deg*pi/180);
                greyTrans = [grey grey grey (translation + flickerScreen)];
            else
                greyTrans = [grey grey grey translation];
            end
            newRect = [0, 0, 1000, 1000];
            flickerRect = CenterRectOnPointd(newRect, xCenter, yCenter);
            Screen('FillOval', window, greyTrans, flickerRect);

            % Draw the fixation
            if frameCounter_nums + 5 >= checkFlipTimeFrames_nums % 5 frame pause between numbers
                % Draw just the fixation square
                Screen('FillPoly', window, rectColor, pointListIn);
                %Screen('FillRect', window, rectColor, fixRect);
            else
                % Draw the number on top of the fixation square
                Screen('TextSize', window, 32);
                Screen('FillPoly', window, rectColor, pointListIn);
                %Screen('FillRect', window, rectColor, fixRect);
                DrawFormattedText(window, num2str(val_list(listCounter)), 'center', 'center');
            end

            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

            % Check if a flicker should start
            if frameCounter_flicker == random_frames(flicker_count)
                flicker = true;
                flicker_count = flicker_count + 1;
                flicker_deg = 0;
            end

            % Determine if flicker is over
            if flicker
                if flicker_deg == 360
                    flicker = false;
                    frameCounter_flicker = 0;
                end
            end

            % Keep the phase of the grating moving 60HZ
            if frameCounter_stim == checkFlipTimeFrames_stim
                phase_index = phase_index + 1;
                % Also advance the flicker contrast
                flicker_deg = flicker_deg + 12; %12 deg at 60Hz = 0.5 second for 360 deg
                % End of texture list, reset it
                if phase_index >= 241
                    phase_index = 1;
                end
                angle = angle + 0.1;
                frameCounter_stim = 0;
            end

            % Advance to next number in list
            if frameCounter_nums == checkFlipTimeFrames_nums
                listCounter = listCounter + 1;
                % Check if this number requires a response (new # = previous #)
                if val_list(listCounter-1) == val_list(listCounter)
                    response_needed = true;
                    response_not_needed = false;
                    % Assume "miss" until response is given
                    cycle_data.fixation_response.miss = cycle_data.fixation_response.miss + 1;
                    cycle_data.fixation_response.repeat_tests = cycle_data.fixation_response.repeat_tests + 1;
                    % Check if previous number required a response
                elseif (listCounter > 2) && (val_list(listCounter-2) == val_list(listCounter-1))
                    response_not_needed = false; % leway time on false alarm trigger
                else
                    response_needed = false;
                    response_not_needed = true;
                end
                frameCounter_nums = 0;
            end

            % USER RESPONSE

            % Check for a keyboard response (on EVERY frame)
            [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
            keyName = KbName(logical(keyCode));%returns key name as a string
            keyInt = KbName(keyName);%changes string to int
            % Quit condition
            if keyInt == quit_button;
                quit = 1;
            elseif keyInt == response_button;
                % Correct response to stimulus
                if response_needed
                    cycle_data.fixation_response.time = [cycle_data.fixation_response.time secs];
                    cycle_data.fixation_response.correct = cycle_data.fixation_response.correct + 1;
                    cycle_data.fixation_response.miss = cycle_data.fixation_response.miss - 1;
                    response_needed = false;
                    % Incorrect response to stimulus
                elseif response_not_needed
                    cycle_data.fixation_response.false_alarm = cycle_data.fixation_response.false_alarm + 1;
                    response_not_needed = false;
                end
            end

            if quit, return; end
        end

        % STIMULUS OFF
        %--------------

        % Set Timer
        t_stop = GetSecs + time_off;

        % Sync us to the vertical retrace
        vbl = Screen('Flip', window);

        % Initialize loop
        frameCounter = 0;
        response_needed = false; % used for correct response count
        response_not_needed = true; % used for false alarm count

        % FRAME LOOP

        % Initiate Number Flipping
        while GetSecs < t_stop
            % Increment Counter
            frameCounter = frameCounter + 1;

            % DRAW STIMULI

            if frameCounter + 5 >= checkFlipTimeFrames % 5 frame pause between numbers
                % Draw just the fixation square
                Screen('FillPoly', window, rectColor, pointListIn);
                %Screen('FillOval', window, black, fixRect);
            else
                % Draw the number on top of the fixation square
                Screen('TextSize', window, 32);
                %Screen('FillRect', window, rectColor, fixRect);
                Screen('FillPoly', window, rectColor, pointListIn);
                DrawFormattedText(window, num2str(val_list(listCounter)), 'center', 'center');
            end

            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

            % Advance to next number in list
            if frameCounter == checkFlipTimeFrames
                listCounter = listCounter + 1;
                % Check if this number requires a response (new # = previous #)
                if val_list(listCounter-1) == val_list(listCounter)
                    response_needed = true;
                    response_not_needed = false;
                    % Assume "miss" until response is given
                    cycle_data.fixation_response.miss = cycle_data.fixation_response.miss + 1;
                    cycle_data.fixation_response.repeat_tests = cycle_data.fixation_response.repeat_tests + 1;
                    % Check if previous number required a response
                elseif (listCounter > 2) && (val_list(listCounter-2) == val_list(listCounter-1))
                    response_not_needed = false; % leway time on false alarm trigger
                else
                    response_needed = false;
                    response_not_needed = true;
                end
                frameCounter = 0;
            end

            % USER RESPONSE

            % Check for a keyboard response (on EVERY frame)
            [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
            keyName = KbName(logical(keyCode));%returns key name as a string
            keyInt = KbName(keyName);%changes string to int
            % Quit condition
            if keyInt == quit_button;
                quit = 1;
            elseif keyInt == response_button;
                % Correct response to stimulus
                if response_needed
                    cycle_data.fixation_response.time = [cycle_data.fixation_response.time secs];
                    cycle_data.fixation_response.correct = cycle_data.fixation_response.correct + 1;
                    cycle_data.fixation_response.miss = cycle_data.fixation_response.miss - 1;
                    response_needed = false;
                    % Incorrect response to stimulus
                elseif response_not_needed
                    cycle_data.fixation_response.false_alarm = cycle_data.fixation_response.false_alarm + 1;
                    response_not_needed = false;
                end
            end

            if quit, return; end
        end

    end

    % DISPLAY NUMBERS (TAIL DELAY)
    %-----------------------------

    % Set Timer
    t_stop = GetSecs + tail_delay;

    % Sync us to the vertical retrace
    vbl = Screen('Flip', window);
    
    % Initialize loop
    frameCounter = 0;
    response_needed = false; % used for correct response count
    response_not_needed = true; % used for false alarm count
    
    % FRAME LOOP

    % Initiate Number Flipping
    while GetSecs < t_stop
        % Increment Counter
        frameCounter = frameCounter + 1;

        % DRAW STIMULI
        
        if frameCounter + 5 >= checkFlipTimeFrames % 5 frame pause between numbers
            % Draw just the fixation square
            Screen('FillPoly', window, rectColor, pointListIn);
            %Screen('FillRect', window, rectColor, fixRect);
        else
            % Draw the number on top of the fixation square
            Screen('TextSize', window, 32);
            Screen('FillPoly', window, rectColor, pointListIn);
            %Screen('FillRect', window, rectColor, fixRect);
            DrawFormattedText(window, num2str(val_list(listCounter)), 'center', 'center');
        end
        
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        % Advance to next number in list
        if frameCounter == checkFlipTimeFrames
            listCounter = listCounter + 1;
            % Check if this number requires a response (new # = previous #)
            if val_list(listCounter-1) == val_list(listCounter)
                response_needed = true;
                response_not_needed = false;
                % Assume "miss" until response is given
<<<<<<< HEAD
                run_data.fixation_response.miss = run_data.fixation_response.miss + 1;
                run_data.fixation_response.repeat_tests = run_data.fixation_response.repeat_tests + 1;
=======
                cycle_data.fixation_response.miss = cycle_data.fixation_response.miss + 1;
                cycle_data.fixation_response.repeat_tests = cycle_data.fixation_response.repeat_tests + 1;
>>>>>>> pr/1
                % Check if previous number required a response
            elseif (listCounter > 2) && (val_list(listCounter-2) == val_list(listCounter-1))
                response_not_needed = false; % leway time on false alarm trigger
            else
                response_needed = false;
                response_not_needed = true;
            end
            frameCounter = 0;
        end
        
        % USER RESPONSE

        % Check for a keyboard response (on EVERY frame)
        [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int
        % Quit condition
        if keyInt == quit_button;
            quit = 1;
        elseif keyInt == response_button;
            % Correct response to stimulus
            if response_needed
                cycle_data.fixation_response.time = [cycle_data.fixation_response.time secs];
                cycle_data.fixation_response.correct = cycle_data.fixation_response.correct + 1;
                cycle_data.fixation_response.miss = cycle_data.fixation_response.miss - 1;
                response_needed = false;
                % Incorrect response to stimulus
            elseif response_not_needed
                cycle_data.fixation_response.false_alarm = cycle_data.fixation_response.false_alarm + 1;
                response_not_needed = false;
            end
        end
<<<<<<< HEAD
        
        if quit, return; end
    end
    
end

% DISPLAY NUMBERS (TAIL DELAY)
%-----------------------------

% Set Timer
t_stop = GetSecs + tail_delay;
=======

        if quit, return; end
    end
>>>>>>> pr/1


    % DISPLAY TAIL
    %--------------

<<<<<<< HEAD
% Initiate Number Flipping
while GetSecs < t_stop
    % Increment Counter
    frameCounter = frameCounter + 1;
    
    % DRAW STIMULI
    
    if frameCounter + 5 >= checkFlipTimeFrames % 5 frame pause between numbers
        % Draw just the fixation square
        Screen('FillRect', window, rectColor, fixRect);
    else
        % Draw the number on top of the fixation square
        Screen('TextSize', window, 32);
        Screen('FillRect', window, rectColor, fixRect);
        DrawFormattedText(window, num2str(val_list(listCounter)), 'center', 'center');
        %Screen('Flip', window);
    end
    
    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    % Advance to next number in list
    if frameCounter == checkFlipTimeFrames
        listCounter = listCounter + 1;
        % Check if this number requires a response (new # = previous #)
        if val_list(listCounter-1) == val_list(listCounter)
            response_needed = true;
            response_not_needed = false;
            % Assume "miss" until response is given
            run_data.fixation_response.miss = run_data.fixation_response.miss + 1;
            run_data.fixation_response.repeat_tests = run_data.fixation_response.repeat_tests + 1;
            % Check if previous number required a response
        elseif (listCounter > 2) && (val_list(listCounter-2) == val_list(listCounter-1))
            response_not_needed = false; % leway time on false alarm trigger
        else
            response_needed = false;
            response_not_needed = true;
        end
        frameCounter = 0;
    end
    
    % USER RESPONSE
    
    % Check for a keyboard response (on EVERY frame)
    [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
    keyName = KbName(logical(keyCode));%returns key name as a string
    keyInt = KbName(keyName);%changes string to int
    % Quit condition
    if keyInt == quit_button;
        quit = 1;
    elseif keyInt == response_button;
        % Correct response to stimulus
        if response_needed
            run_data.fixation_response.time = [run_data.fixation_response.time secs];
            run_data.fixation_response.correct = run_data.fixation_response.correct + 1;
            run_data.fixation_response.miss = run_data.fixation_response.miss - 1;
            response_needed = false;
            % Incorrect response to stimulus
        elseif response_not_needed
            run_data.fixation_response.false_alarm = run_data.fixation_response.false_alarm + 1;
            response_not_needed = false;
        end
    end
    
    if quit, return; end
end


% DISPLAY TAIL
%--------------

% Set Timer
t_stop = GetSecs + time_tail;

% Draw the Fixation Box
while GetSecs < t_stop
    rectColor = [0.8 0 0];
    Screen('FillRect', window, rectColor, fixRect);
    Screen('Flip', window);
    
    % Check If User Quits - press 'q' to quit
    [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
    keyName = KbName(logical(keyCode));%returns key name as a string
    keyInt = KbName(keyName);%changes string to int
    
    if keyInt == quit_button;
        quit = 1;
    end
    
    if quit, return; end
end


%-----------------------------------------------------------------------
% ATTENTION
%-----------------------------------------------------------------------

% DISPLAY THE HEAD
%------------------

% Set Timer
t_stop = GetSecs + time_head;

% Draw the Fixation Box
while GetSecs < t_stop
    rectColor = [0.8 0 0];
    Screen('FillRect', window, rectColor, fixRect);
    Screen('Flip', window);
    
    % Check If User Quits - press 'q' to quit
    [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
    keyName = KbName(logical(keyCode));%returns key name as a string
    keyInt = KbName(keyName);%changes string to int
    
    if keyInt == quit_button;
        quit = 1;
    end
    
    if quit, return; end
end
=======
    % Set Timer
    t_stop = GetSecs + lead_down;

    % Draw the Fixation Box
    while GetSecs < t_stop
        rectColor = [0.8 0 0];
        %Screen('FillPoly', window, rectColor, pointListIn);
        Screen('FillOval', window, rectColor, fixRect);
        Screen('Flip', window);

        % Check If User Quits - press 'q' to quit
        [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int

        if keyInt == quit_button;
            quit = 1;
        end

        if quit, return; end
    end
    run_data.correct = run_data.correct + cycle_data.fixation_response.correct;
    run_data.total = run_data.total + cycle_data.fixation_response.repeat_tests;

>>>>>>> pr/1

    %-----------------------------------------------------------------------
    % ATTENTION
    %-----------------------------------------------------------------------

<<<<<<< HEAD
% Set Timer
t_stop = GetSecs + head_delay;

% Time we want to wait before flipping to the next number
checkFlipTimeSecs = 1/num_freq;
checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
FAresetFrames = round(1/ifi);
=======
    % DISPLAY THE HEAD
    %------------------
>>>>>>> pr/1

    % Set Timer
    t_stop = GetSecs + lead_up;

    % Draw the Fixation Box
    while GetSecs < t_stop
        rectColor = [0.8 0 0];
        Screen('FillPoly', window, rectColor, pointListOut);
        Screen('FillOval', window, black, fixRect);
        Screen('Flip', window);

<<<<<<< HEAD
while GetSecs < t_stop
    % Increment Counter
    frameCounter = frameCounter + 1;
    if response_not_needed == false
        FAresetCounter = FAresetCounter + 1;
    end
    
    % DRAW STIMULI
    
    if frameCounter + 5 >= checkFlipTimeFrames % 5 frame pause between numbers
        % Draw just the fixation square
        Screen('FillRect', window, rectColor, fixRect);
    else
        % Draw the fixation square on top of the number
        Screen('TextSize', window, 32);
        DrawFormattedText(window, num2str(unique_list(listCounter)), 'center', 'center');
        Screen('FillRect', window, rectColor, fixRect);
    end
    
    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    % Advance to next number in list
    if frameCounter == checkFlipTimeFrames
        listCounter = listCounter + 1;
        frameCounter = 0;
    end
    
    % USER RESPONSE
    
    % Reset the false alarm check after it has been off for 1s
    if FAresetCounter == FAresetFrames
        response_not_needed = true;
    end
    
    % Check for a keyboard response (on EVERY frame)
    [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
    keyName = KbName(logical(keyCode));%returns key name as a string
    keyInt = KbName(keyName);%changes string to int
    % Quit condition
    if keyInt == quit_button;
        quit = 1;
    elseif keyInt == response_button;
        % No stimulus, only false alarms recorded
        if response_not_needed
            run_data.attention_response.false_alarm = run_data.attention_response.false_alarm + 1;
            response_not_needed = false;
            FAresetCounter = 0;
        end
    end
    
    if quit, return; end
end

% DISPLAY THE CYCLES
%--------------------

% Initiate Cycle Loop
for i = 1:cycles
    
    % STIMULUS ON
    %-------------
    
    % Set Timer
    t_stop = GetSecs + time_on;
    
    % Stimulus Variables
    angle = 0;
    phase_index = 1; % controls movement of grating
    flicker_deg = 0; % controls sinusoidal flicker mask
    % Time we want to wait before advancing the phase of the grating
    checkFlipTimeSecs_stim = 1/freq; % moving grating refresh rate
    checkFlipTimeFrames_stim = round(checkFlipTimeSecs_stim / ifi);
    % Time we want to wait before flipping to the next number
    checkFlipTimeSecs_nums = 1/num_freq;
    checkFlipTimeFrames_nums = round(checkFlipTimeSecs_nums / ifi);
    
=======
        % Check If User Quits - press 'q' to quit
        [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int

        if keyInt == quit_button;
            quit = 1;
        end

        if quit, return; end
    end

    % DISPLAY NUMBERS (HEAD DELAY)
    %-----------------------------

    % Set Timer
    t_stop = GetSecs + head_delay;

    % Time we want to wait before flipping to the next number
    checkFlipTimeSecs = 1/num_freq;
    checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
    FAresetFrames = round(1/ifi);

>>>>>>> pr/1
    % Sync us to the vertical retrace
    vbl = Screen('Flip', window);

    % Initialize loop
    frameCounter = 0;
    listCounter = 1; % place in the # list
    %response_needed = false; % used for correct response count
    response_not_needed = true; % used for false alarm count
    FAresetCounter = 0;
    
    % FRAME LOOP
<<<<<<< HEAD
    while GetSecs < t_stop
        
        % Increment Counter
        frameCounter_stim = frameCounter_stim + 1;
        frameCounter_nums = frameCounter_nums + 1;
        frameCounter_flicker = frameCounter_flicker + 1;
        % False alarm happened
        if response_not_needed == false && response_needed == false
=======

    while GetSecs < t_stop
        % Increment Counter
        frameCounter = frameCounter + 1;
        if response_not_needed == false
>>>>>>> pr/1
            FAresetCounter = FAresetCounter + 1;
        end

        % DRAW STIMULI
<<<<<<< HEAD
        
        % Draw Sin grating
        filterMode = 1; % Smooths sin grating
        Screen('DrawTextures', window, [textureList1(phase_index), textureList2(phase_index)], [], dstRect, 0, filterMode);
        
        % Draw the Aperature
        Screen('DrawTextures', fullWindowMask, masktexc, [], dstRect)% draw gausian aperature onto full screen aperature mask
        Screen('DrawTexture', window, fullWindowMask); % draw mask
        
        % Draw the Middle
        % Screen('FillOval', window, grey, stimRect);
        
        % Create an alpha mask to modulate flicker
        if flicker
            flickerScreen = amplitude * sin(flicker_deg*pi/180);
            greyTrans = [grey grey grey (translation + flickerScreen)];
        else
            greyTrans = [grey grey grey translation];
        end
        newRect = [0, 0, 890, 890];
        flickerRect = CenterRectOnPointd(newRect, xCenter, yCenter);
        Screen('FillOval', window, greyTrans, flickerRect);
        
        % Draw the fixation
        if frameCounter_nums + 5 >= checkFlipTimeFrames_nums % 5 frame pause between numbers
=======

        if frameCounter + 5 >= checkFlipTimeFrames % 5 frame pause between numbers
>>>>>>> pr/1
            % Draw just the fixation square
            Screen('FillPoly', window, rectColor, pointListOut);
            %Screen('FillRect', window, rectColor, fixRect);
        else
            % Draw the fixation square on top of the number
            Screen('TextSize', window, 32);
            DrawFormattedText(window, num2str(unique_list(listCounter)), 'center', 'center');
            %Screen('FillRect', window, rectColor, fixRect);
            Screen('FillPoly', window, rectColor, pointListOut);
        end
<<<<<<< HEAD
        
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        % Check if a flicker should start
        if GetSecs + 1 <= t_stop % Only if there's enough time
            if frameCounter_flicker == random_frames(flicker_count)
                flicker = true;
                flicker_response_block = true;
                flicker_count = flicker_count + 1;
                flicker_deg = 0;
                response_needed = true;
                response_not_needed = false;
                % Assume miss untill correct response given
                run_data.attention_response.miss = run_data.attention_response.miss + 1;
            end
        end
        
        % Determine if flicker is over
        if flicker
            if flicker_deg == 360
                flicker = false;
                frameCounter_flicker = 0;
                run_data.attention_response.flickers = run_data.attention_response.flickers + 1;
            end
        end
        
        % Extra time to respond to flicker
        if flicker_response_block
            if flicker_deg == 720
                flicker_response_block = false;
                response_needed = false;
                response_not_needed = true;
            end
        end
        
        % Keep the phase of the grating moving 60HZ
        if frameCounter_stim == checkFlipTimeFrames_stim
            phase_index = phase_index + 1;
            flicker_deg = flicker_deg + 12; %12 deg at 60Hz = 0.5 second for 360 deg
            % End of list, index first texture in list
            if phase_index >= 241
                phase_index = 1;
            end
            angle = angle + 0.1;
            frameCounter_stim = 0;
        end
        
=======

        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

>>>>>>> pr/1
        % Advance to next number in list
        if frameCounter == checkFlipTimeFrames
            listCounter = listCounter + 1;
            frameCounter = 0;
        end

        % USER RESPONSE

        % Reset the false alarm check after it has been off for 1s
        if FAresetCounter == FAresetFrames
            response_not_needed = true;
        end

        % Check for a keyboard response (on EVERY frame)
        [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int
        % Quit condition
        if keyInt == quit_button;
            quit = 1;
        elseif keyInt == response_button;
<<<<<<< HEAD
            % Correct response to stimulus
            if response_needed
                run_data.attention_response.time = [run_data.attention_response.time secs];
                run_data.attention_response.correct = run_data.attention_response.correct + 1;
                run_data.attention_response.miss = run_data.attention_response.miss - 1;
                response_needed = false;
                % Incorrect response to stimulus
            elseif response_not_needed
                run_data.attention_response.false_alarm = run_data.attention_response.false_alarm + 1;
=======
            % No stimulus, only false alarms recorded
            if response_not_needed
                cycle_data.attention_response.false_alarm = cycle_data.attention_response.false_alarm + 1;
>>>>>>> pr/1
                response_not_needed = false;
                FAresetCounter = 0;
            end
        end
        
        if quit, return; end
    end

    % DISPLAY THE CYCLES
    %--------------------

    % Initiate Cycle Loop
    for i = 1:cycles

        % STIMULUS ON
        %-------------

        % Set Timer
        t_stop = GetSecs + time_on;

        % Stimulus Variables
        angle = 0;
        phase_index = 1; % controls movement of grating
        flicker_deg = 0; % controls sinusoidal flicker mask
        % Time we want to wait before advancing the phase of the grating
        checkFlipTimeSecs_stim = 1/freq; % moving grating refresh rate
        checkFlipTimeFrames_stim = round(checkFlipTimeSecs_stim / ifi);
        % Time we want to wait before flipping to the next number
        checkFlipTimeSecs_nums = 1/num_freq;
        checkFlipTimeFrames_nums = round(checkFlipTimeSecs_nums / ifi);

        % Sync us to the vertical retrace
        vbl = Screen('Flip', window);

        % Initialize loop
        frameCounter_stim = 0;
        frameCounter_nums = 0;
        frameCounter_flicker = 0;
        response_needed = false; % used for correct response count
        response_not_needed = true; % used for false alarm count
        flicker = false;
        flicker_response_block = false;
        FAresetCounter = 0;

        % FRAME LOOP
        while GetSecs < t_stop

            % Increment Counter
            frameCounter_stim = frameCounter_stim + 1;
            frameCounter_nums = frameCounter_nums + 1;
            frameCounter_flicker = frameCounter_flicker + 1;
            % False alarm happened
            if response_not_needed == false && response_needed == false
                FAresetCounter = FAresetCounter + 1;
            end

            % DRAW STIMULI

            % Draw Sin grating
            filterMode = 1; % Smooths sin grating
            Screen('DrawTextures', window, textureList1(phase_index), [], dstRect, 0, filterMode);

    %         % Draw the Aperature
    %         Screen('DrawTextures', fullWindowMask, masktexc, [], dstRect)% draw gausian aperature onto full screen aperature mask
    %         Screen('DrawTexture', window, fullWindowMask); % draw mask

            % Draw the Middle
            % Screen('FillOval', window, grey, stimRect);

            % Create an alpha mask to modulate flicker
            if flicker
                flickerScreen = amplitude * sin(flicker_deg*pi/180);
                greyTrans = [grey grey grey (translation + flickerScreen)];
            else
                greyTrans = [grey grey grey translation];
            end
            newRect = [0, 0, 1000, 1000];
            flickerRect = CenterRectOnPointd(newRect, xCenter, yCenter);
            Screen('FillOval', window, greyTrans, flickerRect);

            % Draw the fixation
            if frameCounter_nums + 5 >= checkFlipTimeFrames_nums % 5 frame pause between numbers
                % Draw just the fixation square
                %Screen('FillRect', window, rectColor, fixRect);
                Screen('FillPoly', window, rectColor, pointListOut);
            else
                % Draw the fixation square on top of the number
                Screen('TextSize', window, 32);
                DrawFormattedText(window, num2str(unique_list(listCounter)), 'center', 'center');
                Screen('FillPoly', window, rectColor, pointListOut);
                %Screen('FillRect', window, rectColor, fixRect);
            end

            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

            % Check if a flicker should start
            if GetSecs + 1 <= t_stop % Only if there's enough time
                if frameCounter_flicker == random_frames(flicker_count)
                    flicker = true;
                    flicker_response_block = true;
                    flicker_count = flicker_count + 1;
                    flicker_deg = 0;
                    response_needed = true;
                    response_not_needed = false;
                    % Assume miss untill correct response given
                    cycle_data.attention_response.miss = cycle_data.attention_response.miss + 1;
                end
            end

            % Determine if flicker is over
            if flicker
                if flicker_deg == 360
                    flicker = false;
                    frameCounter_flicker = 0;
                    cycle_data.attention_response.flickers = cycle_data.attention_response.flickers + 1;
                end
            end

            % Extra time to respond to flicker
            if flicker_response_block
                if flicker_deg == 720
                    flicker_response_block = false;
                    response_needed = false;
                    response_not_needed = true;
                end
            end

            % Keep the phase of the grating moving 60HZ
            if frameCounter_stim == checkFlipTimeFrames_stim
                phase_index = phase_index + 1;
                flicker_deg = flicker_deg + 12; %12 deg at 60Hz = 0.5 second for 360 deg
                % End of list, index first texture in list
                if phase_index >= 241
                    phase_index = 1;
                end
                angle = angle + 0.1;
                frameCounter_stim = 0;
            end

            % Advance to next number in list
            if frameCounter_nums == checkFlipTimeFrames_nums
                listCounter = listCounter + 1;
                frameCounter_nums = 0;
            end

            % Reset false alarm trigger
            if FAresetCounter == FAresetFrames
                response_not_needed = true;
            end

            % USER RESPONSE

            % Check for a keyboard response (on EVERY frame)
            [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
            keyName = KbName(logical(keyCode));%returns key name as a string
            keyInt = KbName(keyName);%changes string to int
            % Quit condition
            if keyInt == quit_button;
                quit = 1;
            elseif keyInt == response_button;
                % Correct response to stimulus
                if response_needed
                    cycle_data.attention_response.time = [cycle_data.attention_response.time secs];
                    cycle_data.attention_response.correct = cycle_data.attention_response.correct + 1;
                    cycle_data.attention_response.miss = cycle_data.attention_response.miss - 1;
                    response_needed = false;
                    % Incorrect response to stimulus
                elseif response_not_needed
                    cycle_data.attention_response.false_alarm = cycle_data.attention_response.false_alarm + 1;
                    response_not_needed = false;
                    FAresetCounter = 0;
                end
            end

            if quit, return; end
        end

        % STIMULUS OFF
        %--------------

        % Set Timer
        t_stop = GetSecs + time_off;

        % Sync us to the vertical retrace
        vbl = Screen('Flip', window);

        % Initialize loop
        frameCounter = 0;
        response_needed = false; % used for correct response count
        response_not_needed = true; % used for false alarm count

        % FRAME LOOP

        % Initiate Number Flipping
        while GetSecs < t_stop
            % Increment Counter
            frameCounter = frameCounter + 1;

            % DRAW STIMULI

            if frameCounter + 5 >= checkFlipTimeFrames % 5 frame pause between numbers
                % Draw just the fixation square
                Screen('FillPoly', window, rectColor, pointListOut);
                %Screen('FillRect', window, rectColor, fixRect);
            else
                % Draw the fixation square on top of the number
                Screen('TextSize', window, 32);
                DrawFormattedText(window, num2str(unique_list(listCounter)), 'center', 'center');
                Screen('FillPoly', window, rectColor, pointListOut);
                %Screen('FillRect', window, rectColor, fixRect);
            end

            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

            % Advance to next number in list
            if frameCounter == checkFlipTimeFrames
                listCounter = listCounter + 1;
                % Check if this number requires a response (new # = previous #)
                if unique_list(listCounter-1) == unique_list(listCounter)
                    response_needed = true;
                    response_not_needed = false;
                    % Assume "miss" until response is given
                    cycle_data.attention_response.miss = cycle_data.attention_response.miss + 1;
                    % Check if previous number required a response
                elseif (listCounter > 2) && (unique_list(listCounter-2) == unique_list(listCounter-1))
                    response_not_needed = false; % leway time on false alarm trigger
                else
                    response_needed = false;
                    response_not_needed = true;
                end
                frameCounter = 0;
            end

            % USER RESPONSE

            % Check for a keyboard response (on EVERY frame)
            [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
            keyName = KbName(logical(keyCode));%returns key name as a string
            keyInt = KbName(keyName);%changes string to int
            % Quit condition
            if keyInt == quit_button;
                quit = 1;
            elseif keyInt == response_button;
                % Correct response to stimulus
                if response_needed
                    cycle_data.attention_response.time = [cycle_data.attention_response.time secs];
                    cycle_data.attention_response.correct = cycle_data.attention_response.correct + 1;
                    cycle_data.attention_response.miss = cycle_data.attention_response.miss - 1;
                    response_needed = false;
                    % Incorrect response to stimulus
                elseif response_not_needed
                    cycle_data.attention_response.false_alarm = cycle_data.attention_response.false_alarm + 1;
                    response_not_needed = false;
                end
            end

            if quit, return; end
        end

    end

    % DISPLAY NUMBERS (TAIL DELAY)
    %-----------------------------

    % Set Timer
    t_stop = GetSecs + tail_delay;

    % Time we want to wait before flipping to the next number
    checkFlipTimeSecs = 1/num_freq;
    checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
    FAresetFrames = round(1/ifi);

    % Sync us to the vertical retrace
    vbl = Screen('Flip', window);
    
    % Initialize loop
    frameCounter = 0;
    %listCounter = 1; % place in the # list
    %response_needed = false; % used for correct response count
    response_not_needed = true; % used for false alarm count
<<<<<<< HEAD
    
=======
    FAresetCounter = 0;

>>>>>>> pr/1
    % FRAME LOOP

    while GetSecs < t_stop
        % Increment Counter
        frameCounter = frameCounter + 1;
        if response_not_needed == false
            FAresetCounter = FAresetCounter + 1;
        end

        % DRAW STIMULI
        
        if frameCounter + 5 >= checkFlipTimeFrames % 5 frame pause between numbers
            % Draw just the fixation square
            Screen('FillPoly', window, rectColor, pointListOut);
            %Screen('FillRect', window, rectColor, fixRect);
        else
            % Draw the fixation square on top of the number
            Screen('TextSize', window, 32);
            DrawFormattedText(window, num2str(unique_list(listCounter)), 'center', 'center');
            Screen('FillPoly', window, rectColor, pointListOut);
            %Screen('FillRect', window, rectColor, fixRect);
        end
        
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        % Advance to next number in list
        if frameCounter == checkFlipTimeFrames
            listCounter = listCounter + 1;
<<<<<<< HEAD
            % Check if this number requires a response (new # = previous #)
            if unique_list(listCounter-1) == unique_list(listCounter)
                response_needed = true;
                response_not_needed = false;
                % Assume "miss" until response is given
                run_data.fixation_response.miss = run_data.fixation_response.miss + 1;
                % Check if previous number required a response
            elseif (listCounter > 2) && (unique_list(listCounter-2) == unique_list(listCounter-1))
                response_not_needed = false; % leway time on false alarm trigger
            else
                response_needed = false;
                response_not_needed = true;
            end
=======
>>>>>>> pr/1
            frameCounter = 0;
        end
        
        % USER RESPONSE

        % Reset the false alarm check after it has been off for 1s
        if FAresetCounter == FAresetFrames
            response_not_needed = true;
        end

        % Check for a keyboard response (on EVERY frame)
        [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int
        % Quit condition
        if keyInt == quit_button;
            quit = 1;
        elseif keyInt == response_button;
<<<<<<< HEAD
            % Correct response to stimulus
            if response_needed
                run_data.fixation_response.time = [run_data.fixation_response.time secs];
                run_data.fixation_response.correct = run_data.fixation_response.correct + 1;
                run_data.fixation_response.miss = run_data.fixation_response.miss - 1;
                response_needed = false;
                % Incorrect response to stimulus
            elseif response_not_needed
                run_data.fixation_response.false_alarm = run_data.fixation_response.false_alarm + 1;
=======
            % No stimulus, only false alarms recorded
            if response_not_needed
                cycle_data.attention_response.false_alarm = cycle_data.attention_response.false_alarm + 1;
>>>>>>> pr/1
                response_not_needed = false;
                FAresetCounter = 0;
            end
        end
<<<<<<< HEAD
        
        if quit, return; end
    end
    
end

% DISPLAY NUMBERS (TAIL DELAY)
%-----------------------------

% Set Timer
t_stop = GetSecs + tail_delay;
=======

        if quit, return; end
    end
>>>>>>> pr/1


    % DISPLAY TAIL
    %--------------

    % Set Timer
    t_stop = GetSecs + lead_down;

    % Draw the Fixation Box
    while GetSecs < t_stop
        rectColor = [0.8 0 0];
        %Screen('FillPoly', window, rectColor, pointListOut);
        Screen('FillOval', window, rectColor, fixRect);
        Screen('Flip', window);

<<<<<<< HEAD
while GetSecs < t_stop
    % Increment Counter
    frameCounter = frameCounter + 1;
    if response_not_needed == false
        FAresetCounter = FAresetCounter + 1;
    end
    
    % DRAW STIMULI
    
    if frameCounter + 5 >= checkFlipTimeFrames % 5 frame pause between numbers
        % Draw just the fixation square
        Screen('FillRect', window, rectColor, fixRect);
    else
        % Draw the fixation square on top of the number
        Screen('TextSize', window, 32);
        DrawFormattedText(window, num2str(unique_list(listCounter)), 'center', 'center');
        Screen('FillRect', window, rectColor, fixRect);
    end
    
    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    % Advance to next number in list
    if frameCounter == checkFlipTimeFrames
        listCounter = listCounter + 1;
        frameCounter = 0;
    end
    
    % USER RESPONSE
    
    % Reset the false alarm check after it has been off for 1s
    if FAresetCounter == FAresetFrames
        response_not_needed = true;
    end
    
    % Check for a keyboard response (on EVERY frame)
    [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
    keyName = KbName(logical(keyCode));%returns key name as a string
    keyInt = KbName(keyName);%changes string to int
    % Quit condition
    if keyInt == quit_button;
        quit = 1;
    elseif keyInt == response_button;
        % No stimulus, only false alarms recorded
        if response_not_needed
            run_data.attention_response.false_alarm = run_data.attention_response.false_alarm + 1;
            response_not_needed = false;
            FAresetCounter = 0;
        end
    end
    
    if quit, return; end
end
=======
        % Check If User Quits - press 'q' to quit
        [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int

        if keyInt == quit_button;
            quit = 1;
        end
>>>>>>> pr/1

        if quit, return; end
    end
    eval([cycle_name, '= cycle_data;']);
    run_data.correct = run_data.correct + cycle_data.attention_response.correct;
    run_data.total = run_data.total + cycle_data.attention_response.flickers;
end

% DISPLAY TAIL
%--------------

% Set Timer
t_stop = GetSecs + time_tail;

% Draw the Fixation Box
while GetSecs < t_stop
    Screen('FillOval', window, black, fixRect);
    Screen('Flip', window);
    
    % Check If User Quits - press 'q' to quit
    [keyIsDown, secs, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
    keyName = KbName(logical(keyCode));%returns key name as a string
    keyInt = KbName(keyName);%changes string to int
    
    if keyInt == quit_button;
        quit = 1;
    end
    
    if quit, return; end
end

%-----------------------------------------------------------------------
% END THE RUN
%-----------------------------------------------------------------------

ShowCursor;
run_data.complete = 'yes';
end
