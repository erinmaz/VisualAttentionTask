deviceString = 'Apple Internal Keyboard / Trackpad';
% deviceString = 'Lumina Keyboard';
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
quit_button = 20;       % 20 is the int value of 'q'
response_button = 4;    % 4 is the int value of 'a'

keys=[quit_button,response_button];
keylist=zeros(1,256);%%create a list of 256 zeros
keylist(keys)=1;%%set keys you interested in to 1
KbQueueCreate(device,keylist);%%make queue
KbQueueStart();

 KbQueueFlush();
        [pressed, firstpress]=KbQueueCheck(); %check response
        if firstpress(quit_button) > 0; %if hit response key
            % Quit condition
            % if keyInt == quit_button;
            quit = 1;
            %elseif keyInt == response_button;
        end