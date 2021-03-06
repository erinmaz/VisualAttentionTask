function [ run_name, run_data ] = experiment_run( run_number, window, grey, fixationFirst, xm, ym, dstRect, theta1, theta2, sin_freq, aperature_smooth, xCenter, yCenter, imSize,deviceString,blockdur,translation, practice)
% Edited Aug 10 2015, MM
% Edited Nov 12, 2015 ELM
% This function presents the experiment (fixation and attention conditions)
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
run_data.total_trials = 0;
run_data.false_alarm = 0;
run_data.flickertimes = [];
run_data.repeatnumbertimes = [];
run_data.numbers = [];
run_data.numberstime = [];
%run_data.baseline_response.false_alarm = 0;

% Task Variables
head_delay = blockdur;     % Just numbers, no arrow or grating
tail_delay = blockdur;     % Just numbers, no arrow or grating
time_on = head_delay+tail_delay;   % Numbers, grating, and arrow
quit_button = 20;       % 20 is the int value of 'q'
response_button = 6;    % 6 is the int value of 'c' - right index finger (blue button)
% Find using KbName('x') in command window

numberFontSize = 36;

%cycles_interleaved = 2; % number of task blocks (equally divided between fixation and attention)
% set condition order - must have cell arrays with length = cycles_interleaved
% if (fixationFirst)
%     condition = {'fixation' 'attention'};
% else
%     condition = {'attention' 'fixation'};
% end


num_trials_per_block = 6; % number of responses required per block. Needs to work with hardcoded intervals between flickers & repeating numbers below.
% set condition order - must have cell arrays with length = cycles_interleaved
if ~practice
    cycles_interleaved = 6; % number of task blocks (equally divided between fixation and attention)
    baseblock = [2.5 3.5 4.5 4.5 5.5 6.5] ;%set of intervals between responses (either repeating number or flicker)
    if (fixationFirst)
        condition = {'fixation' 'attention' 'fixation' 'attention' 'fixation' 'attention'};
    else
        condition = {'attention' 'fixation' 'attention' 'fixation' 'attention' 'fixation'};
    end
else
    cycles_interleaved = 4;
    baseblock = [2.5 2.5 2.5 3.5 3.5 3.5] ;%set of intervals between responses (either repeating number or flicker)
    condition = {'fixation' 'attention' 'fixation' 'attention'};
end

waitframes = 1; % time to wait in frames for a flip
ifi = Screen('GetFlipInterval', window); % inter frame inverval

% Stimulus Variables
freq = 60; % checkerboard refresh rate in Hz
num_freq = 2; % number frequency in Hz

%translation = 0.98; % Determines baseline opacity of flicker mask
amplitude = (1-translation)*.45; %flicker contrast is 45% of baseline contrast
angle = 0;
phase_index = 1; % controls movement of grating
flicker_deg = 0; % controls sinusoidal flicker mask

% Time we want to wait before updating the grating
checkFlipTimeSecs_stim = 1/freq; % moving grating refresh rate
checkFlipTimeFrames_stim = round(checkFlipTimeSecs_stim / ifi);

% Time we want to wait before flipping to the next number
checkFlipTimeSecs_nums = 1/num_freq;
checkFlipTimeFrames_nums = round(checkFlipTimeSecs_nums / ifi);

% Numbers are off for 200ms
numOff = 0.2;
numOffFrames = numOff/ifi;


%-----------------------------------------------------------------------
% CREATE STIMULI
%-----------------------------------------------------------------------

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

% RANDOM REPEATING NUMBERS
% Create the list of numbers that will flash on the screen
% Set the repeat intevals
xi = randperm(length(baseblock));
repeatblock1 = baseblock(xi); 
xi = randperm(length(baseblock));
repeatblock2 = baseblock(xi);
xi = randperm(length(baseblock));
repeatblock3 =  baseblock(xi);

repeat = [repeatblock1 repeatblock2 repeatblock3];
repeat2Hz = repeat * 2;


repeatFlicker=zeros(cycles_interleaved,num_trials_per_block);
xi = randperm(length(baseblock));
repeatFlicker(1,:) = baseblock(xi);
xi = randperm(length(baseblock));
repeatFlicker(2,:) = baseblock(xi);
xi = randperm(length(baseblock));
repeatFlicker(3,:) = baseblock(xi);
xi = randperm(length(baseblock));
repeatFlicker(4,:) = baseblock(xi);
xi = randperm(length(baseblock));
repeatFlicker(5,:) = baseblock(xi);
xi = randperm(length(baseblock));
repeatFlicker(6,:) = baseblock(xi);

random_frames = round(repeatFlicker / ifi);

%flicker_count = 1; % index of random_frames
first=true;
% Add to the value list one non-repeating chunk at a time
countto6 = 0;
for i = repeat2Hz % Numbers flicker at 2Hz so we multiply the repeat interval by 2
    countto6 = countto6+1;
    if first %get the val_list started
        list_append=[];
        if i > 9
            list_append = randperm(9,9);
            smallchunk=i-9;
            list_append2 = randperm(9,smallchunk);
            while list_append2(1) == list_append(end)
                list_append2 = randperm(9,smallchunk);
            end
            val_list = [list_append list_append2];
        else
            val_list = randperm(9,i);
        end
        repeat_val = val_list(end);
        val_list = [val_list repeat_val];
        first=false;
    else
        triple = true;
        % Add a smaller chunk with no repeats if i > 9
        if i > 9
            while triple
                list_append = randperm(9,9);
                if list_append(1) == val_list(end)
                    triple = true;
                else
                    triple = false;
                end
            end
            val_list = [val_list list_append];
            smallchunk = i - 9;
        else
            smallchunk = i;
        end
        % Add the remaining chunk or small chunk
        list_append = randperm(9,smallchunk);
        while list_append(1) == val_list(end)
            list_append = randperm(9,smallchunk);
        end
        
        % Add the new section
        val_list = [val_list list_append];
        % Add the repeating value
        repeat_val = val_list(end);
        val_list = [val_list repeat_val];
        if countto6 == 6
            list_append=randperm(9,9);
            while list_append(1)==repeat_val
                list_append=randperm(9,9);
            end
            list_append2=randperm(9,5);
            while list_append(end)==list_append2(1)
                list_append2=randperm(9,5);
            end
            val_list = [val_list list_append list_append2];
            countto6 = 0;
        end
    end
end

% RANDOM NON-REPEATING NUMBERS

% Set the first section
unique_list = randperm(9,9); % 9 non-repeating values between 1 and 9
% Add to the list one non-repeating chunk at a time
% End when the list is long enough (50% more #'s than needed at a rate of 2/sec)
while length(unique_list) < ((head_delay + tail_delay + time_on) * cycles_interleaved * 3)
    double = true; % Check that there are no repeats
    while double
        list_append = randperm(9,9);
        if list_append(1) == unique_list(end)
            double = true;
        else
            double = false;
        end
    end
    % Add the new section
    unique_list = [unique_list list_append];
end


% WAIT SCREEN

% The next step takes a long time, draw a "PLEASE WAIT" screen

% Prepare the Window
HideCursor;
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');% Set up alpha-blending for smooth (anti-aliased) lines

% Draw the Wait Screen
Screen('TextSize', window, 30);
DrawFormattedText(window, 'Calculating. Please Wait...', 'center', 'center');
Screen('Flip', window);

numPhases=240;
% PERIPHERAL GRATING
%textureList1 = zeros(1,240);
textureList1 = zeros(1,numPhases);
%textureList1={};
for i = 1:numPhases
    %for i = 1 : 240 % pre-draw 240 of these (one full phase at 60Hz refresh rate and 0.25Hz drift) to save time during frames
    %this is actually two phases
    phase = i*0.75; % VARIES WITH TIME
    %phase=i;
    phaseRad = (phase * (pi/180));
    thetaRad1 = (theta1 / 360) * 2*pi;
    thetaRad2 = (theta2 / 360) * 2*pi;
    grating1 = sin( (((xm * cos(thetaRad1))+(ym * sin(thetaRad1)))*sin_freq * 2*pi) + phaseRad);
    grating2 = sin( (((xm * cos(thetaRad2))+(ym * sin(thetaRad2)))*sin_freq * 2*pi) + phaseRad);
    finalgrating=(grating1.*grating2.*aperature_smooth);
    finalgrating=(finalgrating+1)/2;
    gratingTexture1 = Screen('MakeTexture', window, finalgrating);
    textureList1(i) = gratingTexture1;
    %textureList1{i} = finalgrating;
end

% Setup flicker mask
newRect = [0, 0, imSize*1.25, imSize*1.25];
%newRect = [0, 0, imSize, imSize];
flickerRect = CenterRectOnPointd(newRect, xCenter, yCenter);

%-----------------------------------------------------------------------
% PREPARE RESPONSE DEVICE
%-----------------------------------------------------------------------

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

keys=response_button;
keylist=zeros(1,256);%%create a list of 256 zeros
keylist(keys)=1;%%set keys you interested in to 1


%-----------------------------------------------------------------------
% DRAW INSTRUCTIONS, WAIT FOR TRIGGER
%-----------------------------------------------------------------------

% Draw the Instructions
Screen('TextSize', window, 30);
DrawFormattedText(window, 'Keep your eyes on the flashing numbers. \n\n When red arrow points inward, \n press for repeating numbers. \n\n When blue arrow points outward, \n press for contrast flickers. \n\n Press the button when you are ready to start.', 'center', 'center');
Screen('Flip', window);

% Wait for participant to push button
KbTriggerWait(KbName('c'), device);

%Clear screen
Screen('Flip', window);

% Wait for Trigger
if (~practice)
    KbTriggerWait(KbName('T'), device);
else WaitSecs(2);
end

% Set up queue for responses
KbQueueCreate(device,keylist);%%make queue
KbQueueStart(device);
redColor = [0.8 0 0];
blueColor = [0 0 0.8];
listCounter = 1;
ulistCounter = 1;
frameCounter = 0;

% Sync us to the vertical retrace
vbl = Screen('Flip', window);

for i = 1:cycles_interleaved
    cycle_name = sprintf('run_data.cycle%d',i);
    cycle_data = [];
    
    cycle_data.fixation_response.time = [];
    cycle_data.fixation_response.rt = [];
    cycle_data.fixation_response.correct = 0;
    cycle_data.fixation_response.miss = 0;
    cycle_data.fixation_response.false_alarm = 0;
    cycle_data.fixation_response.repeat_tests = 0;
    cycle_data.fixation.repeatnumbertimes = [];
    cycle_data.fixation.flickertimes = [];
    
    cycle_data.attention_response.time = [];
    cycle_data.attention_response.rt = [];
    cycle_data.attention_response.correct = 0;
    cycle_data.attention_response.miss = 0;
    cycle_data.attention_response.false_alarm = 0;
    cycle_data.attention_response.flickers = 0;
    cycle_data.attention.flickertimes = [];
    
    cycle_data.baseline_response.false_alarm = 0;
    
    
    % DISPLAY NUMBERS (HEAD DELAY)
    %-----------------------------
    
    % Set Timer
    t_stop = GetSecs + head_delay;
    
    % Sync us to the vertical retrace
    %vbl = Screen('Flip', window);
    
    % FRAME LOOP
    KbQueueFlush(device);
    while GetSecs < t_stop
        % Increment Counter
        if frameCounter == 0
            run_data.numbers = [run_data.numbers unique_list(ulistCounter)];
            run_data.numberstime = [run_data.numberstime GetSecs];
        end
        frameCounter = frameCounter + 1;
        
        % DRAW STIMULI
        
        if frameCounter + numOffFrames >= checkFlipTimeFrames_nums % 200 ms pause between numbers
            % Do nothing
        else
            % Draw the number
            Screen('TextSize', window, numberFontSize);
            DrawFormattedText(window, num2str(unique_list(ulistCounter)), 'center', 'center');
        end
        
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        % Advance to next number in list
        if frameCounter == checkFlipTimeFrames_nums
            ulistCounter = ulistCounter + 1;
            frameCounter = 0;
        end
        
        % USER RESPONSE
        
        % Check for a keyboard response (on EVERY frame)
        [~, firstpress] = KbQueueCheck(device); %check response
        if firstpress(response_button) > 0
            % No responses are expected during head_delay
            cycle_data.baseline_response.false_alarm = cycle_data.baseline_response.false_alarm + 1;
            KbQueueFlush(device);
        end
        [~, ~, keyCode] = KbCheck(-1); % -1 = check all keyboards
        keyName = KbName(logical(keyCode)); % returns key name as a string
        keyInt = KbName(keyName); % changes string to int
        if keyInt == quit_button
            quit = 1;
        end
        if quit
            return;
        end
        
    end
    %   run_data.false_alarm = run_data.false_alarm + cycle_data.baseline_response.false_alarm;
    
    if strcmp(condition(i),'fixation')
        
        % STIMULUS ON (Fixation)
        %-------------
        
        % Set Timer
        t_stop = GetSecs + time_on;
        % Sync us to the vertical retrace
        %vbl = Screen('Flip', window);
        
        % Initialize loop
        starttime=GetSecs;
        frameCounter_stim = 0;
        frameCounter_flicker = 0;
        response_needed = false; % used for correct response count
        response_not_needed = true; % used for false alarm count
        flicker = false;
        flicker_count = 1;
        
        % FRAME LOOP
        KbQueueFlush(device);
        
        % Initiate Contrast Flipping
        while GetSecs < t_stop
            frameCounter = frameCounter + 1;
            frameCounter_flicker = frameCounter_flicker + 1;
            frameCounter_stim = frameCounter_stim + 1;
            
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
            
            Screen('FillOval', window, greyTrans, flickerRect);
            
            % Draw the arrow
            if frameCounter + numOffFrames >= checkFlipTimeFrames_nums % pause between numbers
                Screen('FillPoly', window, redColor, pointListIn);
                
            else
                % Draw the number and arrow
                Screen('TextSize', window, numberFontSize);
                Screen('FillPoly', window, redColor, pointListIn);
                DrawFormattedText(window, num2str(val_list(listCounter)), 'center', 'center');
            end
            
            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            
            % Check if a flicker should start
            if flicker_count <= num_trials_per_block
                %if mod(flicker_count,7) == 0; %no time for a flicker in this block, but
                %   flicker_count = flicker_count + 1;
                %else
                if frameCounter_flicker == random_frames(i,flicker_count)
                    flicker = true;
                    flicker_count = flicker_count + 1;
                    flicker_deg = 0;
                    cycle_data.fixation.flickertimes = [cycle_data.fixation.flickertimes GetSecs];
                    
                end
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
                if phase_index > 240
                    phase_index = 1;
                end
                angle = angle + 0.1;
                frameCounter_stim = 0;
            end
            
            % Advance to next number in list
            if frameCounter == checkFlipTimeFrames_nums
                listCounter = listCounter + 1;
                frameCounter = 0;
                run_data.numbers = [run_data.numbers val_list(listCounter)];
                run_data.numberstime = [run_data.numberstime GetSecs];
                
                % Check if this number requires a response (new # = previous #)
                if val_list(listCounter-1) == val_list(listCounter)
                    if frameCounter == 0
                        starttime=GetSecs;
                        cycle_data.fixation.repeatnumbertimes = [cycle_data.fixation.repeatnumbertimes starttime];
                        % end
                        response_needed = true;
                        response_not_needed = false;
                        % Assume "miss" until response is given
                        cycle_data.fixation_response.miss = cycle_data.fixation_response.miss + 1;
                        cycle_data.fixation_response.repeat_tests = cycle_data.fixation_response.repeat_tests + 1;
                    end
                    % Check if previous number required a response
                    
                elseif (listCounter > 2) && (val_list(listCounter-2) == val_list(listCounter-1))
                    response_not_needed = false; % leeway time on false alarm trigger
                    response_needed = true;
                else
                    response_needed = false;
                    response_not_needed = true;
                end
            end
            
            % USER RESPONSE
            secs=GetSecs;
            [~, firstpress]=KbQueueCheck(device); %check response
            if firstpress(response_button) > 0
                % Correct response to stimulus
                if response_needed
                    cycle_data.fixation_response.time = [cycle_data.fixation_response.time secs];
                    cycle_data.fixation_response.rt = [cycle_data.fixation_response.rt (secs-starttime)];
                    cycle_data.fixation_response.correct = cycle_data.fixation_response.correct + 1;
                    cycle_data.fixation_response.miss = cycle_data.fixation_response.miss - 1;
                    response_needed = false;
                    
                    % Incorrect response to stimulus
                elseif response_not_needed
                    cycle_data.fixation_response.false_alarm = cycle_data.fixation_response.false_alarm + 1;
                    response_not_needed = false;
                end
                KbQueueFlush(device);
            end
            
            [~, ~, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
            keyName = KbName(logical(keyCode));%returns key name as a string
            keyInt = KbName(keyName);%changes string to int
            if keyInt == quit_button
                quit = 1;
            end
            if quit
                return;
            end
            
            
        end
        
        eval([cycle_name, '= cycle_data;']);
        run_data.correct = run_data.correct + cycle_data.fixation_response.correct;
        run_data.total_trials = run_data.total_trials + cycle_data.fixation_response.repeat_tests;
        run_data.false_alarm = run_data.false_alarm + cycle_data.fixation_response.false_alarm;
        run_data.flickertimes = [run_data.flickertimes cycle_data.fixation.flickertimes];
        run_data.repeatnumbertimes = [run_data.repeatnumbertimes cycle_data.fixation.repeatnumbertimes];
        
        %-----------------------------------------------------------------------
        % ATTENTION
        %-----------------------------------------------------------------------
        
    else
        % Set Timer
        t_stop = GetSecs + time_on;
        
        % Sync us to the vertical retrace
        %vbl = Screen('Flip', window);
        
        % Stimulus Variables
        angle = 0;
        phase_index = 1; % controls movement of grating
        flicker_deg = 0; % controls sinusoidal flicker mask
        
        % Initialize loop
        starttime=GetSecs;
        frameCounter_stim = 0;
        %frameCounter = 0;
        frameCounter_flicker = 0;
        response_needed = false; % used for correct response count
        response_not_needed = true; % used for false alarm count
        flicker = false;
        flicker_response_block = false;
        
        flicker_count = 1;
        
        KbQueueFlush(device);
        
        % FRAME LOOP
        while GetSecs < t_stop
            
            % Increment Counter
            frameCounter_stim = frameCounter_stim + 1;
            frameCounter = frameCounter + 1;
            frameCounter_flicker = frameCounter_flicker + 1;
            
            % DRAW STIMULI
            
            % Draw Sin grating
            filterMode = 1; % Smooths sin grating
            Screen('DrawTextures', window, textureList1(phase_index), [], dstRect, 0, filterMode);
            
            % Create an alpha mask to modulate flicker
            if flicker
                flickerScreen = amplitude * sin(flicker_deg*pi/180);
                greyTrans = [grey grey grey (translation + flickerScreen)];
            else
                greyTrans = [grey grey grey translation];
            end
            Screen('FillOval', window, greyTrans, flickerRect);
            
            % Draw the fixation
            if frameCounter + numOffFrames >= checkFlipTimeFrames_nums % 200 ms pause between numbers
                % Draw just the arrow
                Screen('FillPoly', window, blueColor, pointListOut);
            else
                % Draw the number and the arrow
                Screen('TextSize', window, numberFontSize);
                DrawFormattedText(window, num2str(unique_list(ulistCounter)), 'center', 'center');
                Screen('FillPoly', window, blueColor, pointListOut);
            end
            
            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            
            % Check if a flicker should start
            if flicker_count <= num_trials_per_block
                %  if flicker_count <= length(repeatFlicker) % only if there are more flickers left to do
                %       if GetSecs + 1 <= t_stop % Only if there's enough time
                if frameCounter_flicker == random_frames(i,flicker_count)
                    flicker = true;
                    flicker_response_block = true;
                    flicker_count = flicker_count + 1;
                    flicker_deg = 0;
                    response_needed = true;
                    response_not_needed = false;
                    starttime=GetSecs;
                    cycle_data.attention.flickertimes = [cycle_data.attention.flickertimes starttime];
                    % Assume miss untill correct response given
                    cycle_data.attention_response.miss = cycle_data.attention_response.miss + 1;
                end
                %     end
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
                %if flicker_deg == 720
                if flicker_deg == 1080 %1500ms?
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
                %              if phase_index >= 241
                if phase_index > numPhases
                    phase_index = 1;
                end
                angle = angle + 0.1;
                frameCounter_stim = 0;
            end
            
            % Advance to next number in list
            if frameCounter == checkFlipTimeFrames_nums
                ulistCounter = ulistCounter + 1;
                frameCounter = 0;
                run_data.numbers = [run_data.numbers unique_list(ulistCounter)];
                run_data.numberstime = [run_data.numberstime GetSecs];
            end
            
            % USER RESPONSE
            
            % Check for a keyboard response (on EVERY frame)
            secs=GetSecs;
            [~, firstpress]=KbQueueCheck(device); %check response
            if firstpress(response_button) > 0
                
                % Correct response to stimulus
                if response_needed
                    cycle_data.attention_response.rt = [cycle_data.attention_response.rt (secs-starttime)];
                    cycle_data.attention_response.time = [cycle_data.attention_response.time secs];
                    cycle_data.attention_response.correct = cycle_data.attention_response.correct + 1;
                    cycle_data.attention_response.miss = cycle_data.attention_response.miss - 1;
                    response_needed = false;
                    
                    % Incorrect response to stimulus
                elseif response_not_needed
                    cycle_data.attention_response.false_alarm = cycle_data.attention_response.false_alarm + 1;
                    response_not_needed = false;
                end
                KbQueueFlush(device);
            end
            [~, ~, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
            keyName = KbName(logical(keyCode));%returns key name as a string
            keyInt = KbName(keyName);%changes string to int
            if keyInt == quit_button
                quit = 1;
            end
            if quit
                return;
            end
        end
    end
    eval([cycle_name, '= cycle_data;']);
    run_data.correct = run_data.correct + cycle_data.attention_response.correct;
    run_data.total_trials = run_data.total_trials + cycle_data.attention_response.flickers;
    run_data.false_alarm = run_data.false_alarm + cycle_data.attention_response.false_alarm;
    run_data.flickertimes = [run_data.flickertimes cycle_data.attention.flickertimes];
    
    
    % DISPLAY NUMBERS (TAIL DELAY)
    %-----------------------------
    
    % Set Timer
    t_stop = GetSecs + tail_delay;
    
    % Sync us to the vertical retrace
    %vbl = Screen('Flip', window);
    
    % Initialize loop
    %frameCounter = 0;
    response_not_needed = true; % used for false alarm count
    
    % FRAME LOOP
    KbQueueFlush(device);
    
    
    while GetSecs < t_stop
        
        % Increment Counter
        frameCounter = frameCounter + 1;
        
        % DRAW STIMULI
        
        if frameCounter + numOffFrames >= checkFlipTimeFrames_nums % 200 ms pause between numbers
            % do nothing
        else
            % Draw the number
            Screen('TextSize', window, numberFontSize);
            DrawFormattedText(window, num2str(unique_list(ulistCounter)), 'center', 'center');
        end
        
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        % Advance to next number in list
        if frameCounter == checkFlipTimeFrames_nums
            ulistCounter = ulistCounter + 1;
            frameCounter = 0;
            run_data.numbers = [run_data.numbers unique_list(ulistCounter)];
            run_data.numberstime = [run_data.numberstime GetSecs];
        end
        
        % USER RESPONSE
        % Check for a keyboard response (on EVERY frame)
        [~, firstpress]=KbQueueCheck(device); %check response
        if firstpress(response_button) > 0
            
            % No stimulus, only false alarms recorded
            if response_not_needed
                cycle_data.baseline_response.false_alarm = cycle_data.baseline_response.false_alarm + 1;
                response_not_needed = false;
            end
            KbQueueFlush(device);
        end
        
        [~, ~, keyCode] = KbCheck(-1); % -1 causes it to check all keyboards
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%changes string to int
        if keyInt == quit_button
            quit = 1;
        end
        if quit
            return;
        end
    end
    
    run_data.false_alarm = run_data.false_alarm + cycle_data.baseline_response.false_alarm;
end

KbQueueRelease();
ShowCursor;
run_data.complete = 'yes';
end
