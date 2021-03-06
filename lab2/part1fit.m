function out=part1fit(data,svnum,destime,type)
    timedata=[];
    out=zeros(1,4);
    x=[];
    y=[];
    z=[];
    for j=1:size(data,1)
        if data{j,1}==svnum
            timedata(end+1)=data{j,2};
            x(end+1)=data{j,type}(1);
            y(end+1)=data{j,type}(2);
            z(end+1)=data{j,type}(3);
        end
    end

    
    xspline=spline(timedata,x,timedata(1):10:timedata(end));
    yspline=spline(timedata,y,timedata(1):10:timedata(end));
    zspline=spline(timedata,z,timedata(1):10:timedata(end));
   
    out(1)=interp1(timedata(1):10:timedata(end),xspline,destime);
    out(2)=interp1(timedata(1):10:timedata(end),yspline,destime);
    out(3)=interp1(timedata(1):10:timedata(end),zspline,destime);
    out(4)=(out(1)-interp1(timedata(1):10:timedata(end),xspline,destime-1));
    out(5)=(out(2)-interp1(timedata(1):10:timedata(end),yspline,destime-1));
    out(6)=(out(3)-interp1(timedata(1):10:timedata(end),zspline,destime-1));
end