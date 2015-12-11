function main_experiment
% Edited Aug 14 2015, MM

% This is the main file for the visual attention task shifting attention
% from central vision to peripheral vision. Run experiment from here.

%   This function draws the main menu and waits for a user selection. It
%   then passes the selection to one of the action functions.
%   INSTRUCTIONS:   ESC to end the experiment
%                   q to quit a run
%                   1, 2, or 3 to start a new run
%                   c to respond (blue button)
%                   T for trigger

% Define global variables
global quit
quit = 0;
% Clear the workspace and the screen
close all;
clear all;
% Psychtoolbox default settings
PsychDefaultSetup(2);

% SELECT RESPONSE DEVICE
deviceString = 'Apple Internal Keyboard / Trackpad';
%deviceString = 'Dell USB Entry Keyboard';
%deviceString = 'Lumina Keyboard';

translation = 0.95; % Determines baseline opacity of flicker mask

% Perform sync test to avoid flicker slowing when connected to projector.
% (Added Aug 31, 2015)
Screen('Preference','SkipSyncTests', 0)

% Identify attached screens and the luminance
screens = Screen('Screens');
screenNumber = max(screens); %Draw to external screen
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
fixationFirst = 1;
attentionFirst = 0;
blockdur = 18; % 36 s blocks
practiceblockdur = 6; %10 s blocks

% Create a file to store response data
cd log;
[filename,pathname] = uiputfile('*.mat','Choose a log file'); %Asks user to input file name
resp_mat = [];
save (filename, 'resp_mat');%saves only the response matrix variable
cd ..;

% Open a window and get its attributes
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

% Draw the Wait Screen
Screen('TextSize', window, 30);
DrawFormattedText(window, 'Calculating. Please Wait...', 'center', 'center');
Screen('Flip', window);

checksize_fract = 0.07; %size of grating as a fraction of screen size (determines check size)
trapezoid_fract = 0.093; %width of trapezoid (to smooth grating) as a fraction of screen size
inner_circle_fract = 0.28;
imSize = screenXpixels; %size of window
dim = imSize/2;
[x_ap, y_ap] = meshgrid(-dim:dim-1, -dim:dim-1);
circle = ((x_ap.^2)+(y_ap.^2) <= (dim)^2); % outer circle
circle2 = ((x_ap.^2)+(y_ap.^2) <= (imSize*inner_circle_fract)^2); % inner circle
aperature = circle - circle2;
trapwidth=screenXpixels*trapezoid_fract;
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
lambda = screenXpixels.*checksize_fract; % Wavelength determines check size
sin_freq = imSize/lambda;


%---------------------------------------------------------------------
% DRAW THE MAIN MENU
%---------------------------------------------------------------------

% Continue until escape is pressed

continueExperiment = true;
n = 0; % Run number iterator

while continueExperiment == true
    % Display the main menu
    Screen('TextSize', window, 36);
    DrawFormattedText(window, '1 - Localizer \n\n2 - Task 1 \n\n3 - Task 2\n\n4 - Practice task','center', 'center', black);
    fprintf('\nmain menu: 1=localizer; 2=task1; 3=task2; 4=practice\n'); 
    %command window
    Screen('Flip', window);
    
    %------------------------------------------------------------------------
    % WAIT FOR THE USER TO MAKE A SELECTION AND CALL THEIR SELECTION
    %------------------------------------------------------------------------
    
    %DEBUG: Draw Box Test --------------------------------------------------
    %bigRect = [0 0 340 340];
    smallRect = [0 0 8 8];
    fixRect = CenterRectOnPointd(smallRect, xCenter, yCenter); %Define fixation square
    %stimRect = CenterRectOnPointd(bigRect, xCenter, yCenter); %Define stimulation area
    %-----------------------------------------------------------------------
    
    % Wait for menu selection
    respToBeMade = true;
    
    while respToBeMade == true
        % Wait for the person to press a key
        [~, keyCode, ~] = KbWait(-1); % -1 causes it to check all keyboards
        
        % Identify the key
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%returns the int value of the key
        
        % If a menu key is pressed, complete the menu action
        
        if keyInt == 30 % 1 KEY -> LOCALIZER
            n = n+1;
            % Call the localizer function
            [run_name, run_data] = localizer_run( n, window, fixRect, black, xm, ym, dstRect, theta1, theta2, sin_freq, aperature_smooth,deviceString);
            
            % Test function output
            eval([run_name, '= run_data;']);
            cd log;
            save (filename, 'resp_mat');
            cd ..;
            
            respToBeMade = false;
            
        elseif keyInt == 31 % 2 KEY -> EXPERIMENT
            n = n+1;
            % Call the experiment function
            practice =0;
            [run_name, run_data] = experiment_run( n, window, grey, fixationFirst, xm, ym, dstRect, theta1, theta2, sin_freq, aperature_smooth, xCenter, yCenter, imSize,deviceString,blockdur, translation, practice);
            
            % Test function output
            eval([run_name, '= run_data;']);
            cd log;
            save (filename, 'resp_mat');
            cd ..;
            
            respToBeMade = false;
            
        elseif keyInt == 32 % 3 KEY -> EXPERIMENT
            n = n+1;
            % Call the experiment function
            practice=0;
            [run_name, run_data] = experiment_run( n, window, grey, attentionFirst, xm, ym, dstRect, theta1, theta2, sin_freq, aperature_smooth, xCenter, yCenter, imSize,deviceString,blockdur, translation, practice);
            
            % Test function output
            eval([run_name, '= run_data;']);
            cd log;
            save (filename, 'resp_mat');
            cd ..;
            
            respToBeMade = false;
            
        elseif keyInt == 33 % 4 KEY -> PRACTICE
            n = n+1;
            % Call the experiment function
            practice=1;
            deviceString = 'Apple Internal Keyboard / Trackpad';
            [run_name, run_data] = experiment_run( n, window, grey, attentionFirst, xm, ym, dstRect, theta1, theta2, sin_freq, aperature_smooth, xCenter, yCenter, imSize,deviceString, practiceblockdur,translation, practice);
            
            % Test function output
            eval([run_name, '= run_data;']);
            cd log;
            save (filename, 'resp_mat');
            cd ..;
            
            respToBeMade = false;
            
        elseif keyInt == 41 % ESCAPE KEY -> END SESSION
            continueExperiment = false;
            respToBeMade = false;
        end
    end
end

% Clear the screen.
ShowCursor;
close all;
clear all;
sca;
end

