function main_experiment
% Last modified Aug10 - copy from Melany's working version
% This is the main file for the visual attention task shifting attention
% from central vision to peripheral vision. Run experiment from here.

%   This function draws the main menu and waits for a user selection. It
%   then passes the selection to one of the action functions.
%   INSTRUCTIONS:   ESC to end the experiment
%                   Q to quit a run
%                   1 or 2 to start a new run
%                   A to respond
%                   any key for trigger

% Define global variables
global quit
quit = 0;
% Clear the workspace and the screen
close all;
clear all;
% Psychtoolbox default settings
PsychDefaultSetup(2);

% Identify attached screens and the luminance
screens = Screen('Screens');
screenNumber = max(screens); %Draw to external screen
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Create a file to store response data
cd log;
[filename,pathname] = uiputfile('*.mat','Choose a log file'); %Asks user to input file name
resp_mat = [];
save (filename, 'resp_mat');%saves only the response matrix variable
cd ..;

%---------------------------------------------------------------------
% DRAW THE MAIN MENU
%---------------------------------------------------------------------
% Open a window and get its attributes
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
%[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

% Continue until escape is pressed

continueExperiment = true;
n = 0; % Run number iterator

while continueExperiment == true 
    % Display the main menu
    Screen('TextSize', window, 48);
    DrawFormattedText(window, '1 - Localizer \n\n 2 - Experiment','center', 'center', black);
    %fpintf('\nmain menu'); % This line isn't working, I dont know how to update
    %command window
    Screen('Flip', window);

    %------------------------------------------------------------------------
    % WAIT FOR THE USER TO MAKE A SELECTION AND CALL THEIR SELECTION
    %------------------------------------------------------------------------

    %DEBUG: Draw Box Test --------------------------------------------------
     bigRect = [0 0 340 340];
     smallRect = [0 0 8 8];
     fixRect = CenterRectOnPointd(smallRect, xCenter, yCenter); %Define fixation square
     stimRect = CenterRectOnPointd(bigRect, xCenter, yCenter); %Define stimulation area
    %-----------------------------------------------------------------------

    % Wait for menu selection
    respToBeMade = true;

    while respToBeMade == true
        % Wait for the person to press a key
        [secs, keyCode, deltaSecs] = KbWait(-1); % -1 causes it to check all keyboards
        
        % Identify the key
        keyName = KbName(logical(keyCode));%returns key name as a string
        keyInt = KbName(keyName);%returns the int value of the key

        % If a menu key is pressed, complete the menu action

        if keyInt == 30 % 1 KEY -> LOCALIZER
            n = n+1;
            % Call the localizer function
            [run_name, run_data] = localizer_run(n, window, fixRect, stimRect, white, grey, black);

            % Test function output 
            eval([run_name, '= run_data;']);
            cd log;
            save (filename, 'resp_mat'); 
            cd ..;

            respToBeMade = false;

        elseif keyInt == 31 % 2 KEY -> EXPERIMENT
            n = n+1;
                % Call the experiment function
                [run_name, run_data] = experiment_run(n, window, windowRect, fixRect, grey, black);

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

%-------------------------------------------------------------------------
% END THE SESSION
%-------------------------------------------------------------------------

% Clear the screen.
ShowCursor;
close all;
clear all;
sca;

end

