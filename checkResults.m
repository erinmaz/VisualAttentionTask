load('fulltestDec10.mat');
names=fieldnames(resp_mat);
for i=1:length(names)
    if(strfind(names{i},'experiment'))
    flickertimes = resp_mat.(names{i}).flickertimes;
    repeatnumbertimes = resp_mat.(names{i}).repeatnumbertimes;
    numbertimes = resp_mat.(names{i}).numberstime;
    for j=1:length(flickertimes)-1
        flickerinterval(j)=flickertimes(j+1)-flickertimes(j);
    end
    for j=1:length(repeatnumbertimes)-1
        repeatnumberinterval(j)=repeatnumbertimes(j+1)-repeatnumbertimes(j);
    end
    for j=1:length(numbertimes)-1
        numberinterval(j)=numbertimes(j+1)-numbertimes(j);
    end
    figure
    hist(flickerinterval,100);
    figure
    hist(repeatnumberinterval,200);
    figure
    hist(numberinterval,10);
    end
end

        
        
