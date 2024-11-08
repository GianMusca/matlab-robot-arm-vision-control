classdef Widow
    properties
        L1;
        L2;
        L3;
        L4;
        L5;
        Lee;
        Lp;
        widowx;
        rotation;
        currentPos;
    end
    
    methods
        function obj = Widow(L1,L2,L3,L4,L5,Lee,initPos)
            obj.L1 = L1;
            obj.L2 = L2;
            obj.L3 = L3;
            obj.L4 = L4;
            obj.L5 = L5;
            obj.Lee = Lee;
            
            N = 4;
            linksCell = cell(1,N);
            obj.Lp = sqrt(obj.L2^2+obj.L3^2);
            %theta d a alpha
            %L={[0 obj.L1 0 0], [0 0 0 pi/2], [0 0 obj.Lp 0], [0 0 obj.L4 0], [0 0 obj.L5 0]};
            L={[0 obj.L1 0 0], [0 0 0 pi/2], [0 0 obj.Lp 0], [0 0 obj.L4 0]};


            for i=1:N
                linksCell{i} = Link(L{i},'modified'); %Agregar los links uno a uno
            end
            %el marcador mide 100, pero se le puede cambiar el valor
            Tool = [0 1 0 obj.Lee; -1 0 0 -100; 0 0 1 0; 0 0 0 1];
            obj.widowx = SerialLink([linksCell{:}], 'name', 'Janiel Dacoby', 'tool', Tool);
            
%             hipotenusa = sqrt(obj.Lee^2 + 100^2);
%             sinalpha = -100/hipotenusa;
%             cosalpha = obj.Lee/hipotenusa;
%             
%             obj.rotation = [1,0,0; 
%                             0,cosalpha,-sinalpha; 
%                             0,sinalpha,cosalpha];

            hipotenusa = sqrt(initPos(1)^2 + initPos(2)^2);
            sinalpha = initPos(2)/hipotenusa;
            cosalpha = initPos(1)/hipotenusa;
            obj.rotation = [cosalpha,-sinalpha,0; 
                            sinalpha,cosalpha,0; 
                            0,0,1];
            obj.rotation = obj.rotation*[0,0,1;0,1,0;-1,0,0];
            obj.currentPos = initPos;
           
        end
        function drawRobot(obj)
            T = [obj.rotation, obj.currentPos'; 0 0 0 1];
            qTarget = obj.widowx.ikine(T, 'mask', [1 1 1 0 0 1],'tol',0.5);
            obj.widowx.plot(qTarget)
            %obj.widowx.teach();
        end
        function drawWorkspace(obj,thlim)
            hold on;
            N = 10000;
            q0=[0 0 0 0 0];  
            th1 = linspace(-double(thlim(1)),double(thlim(1)),double(thlim(1)))*pi/180;
            th2 = linspace(-double(thlim(2)),double(thlim(2)),10.0)*pi/180;
            th3 = linspace(-double(thlim(3)),double(thlim(3)),10.0)*pi/180;
            th4 = linspace(-double(thlim(4)),double(thlim(4)),40.0)*pi/180;            
            [theta1,theta2,theta3,theta4] = ndgrid(th1,th2,th3,th4);

            xM = obj.L5*((0.5*cos(theta1 + theta2 + theta3 + theta4)) + (0.5*cos(theta2 - theta1 + theta3 + theta4))) + obj.L4*((0.5*cos(theta1 + theta2 + theta3)) + (0.5*cos(theta2 - theta1 + theta3))) + obj.Lp*((0.5*cos(theta1 - theta2)) + (0.5*cos(theta1 + theta2)));
            yM = obj.L4*((0.5*sin(theta1 + theta2 + theta3)) - (0.5*sin(theta2 - theta1 + theta3))) - (obj.L5*(0.5*sin(theta2 - theta1 + theta3 + theta4) - 0.5*sin(theta1 + theta2 + theta3 + theta4))) + obj.Lp*((0.5*sin(theta1 - theta2)) + (0.5*sin(theta1 + theta2)));
            zM = obj.L1 + obj.L4*sin(theta2 + theta3) + obj.Lp*sin(theta2) + obj.L5*sin(theta2 + theta3 + theta4);
            plot3(xM(:),yM(:),zM(:),'o')
            hold off;
        end
        function drawLine(obj,initPos,endPos,step)
            xi = initPos(1);
            yi = initPos(2);
            xo = endPos(1);
            yo = endPos(2);
            %Aca asumo que el zi = zo, y solo tomo el de la posicion
            %inicial
            zio = initPos(3);
            if(xi ~= xo)
                b=(yo-yi)/(xo-xi);
                m=yo-xo*b;
                x=linspace(xi,xo,step);
                y=x*b+m;
            else
                y = linspace(yi,yo,step);
                x = xo+y*0;
            end
            P_ = [x;y];
            P = [P_', ones(step,1).*zio]';    
            T = zeros(4,4,step);
            for i=1:step
                
                hipotenusa = sqrt(x(i)^2 + y(i)^2);
                sinalpha = y(i)/hipotenusa;
                cosalpha = x(i)/hipotenusa;
                obj.rotation = [cosalpha,-sinalpha,0; 
                                sinalpha,cosalpha,0; 
                                0,0,1];
                obj.rotation = obj.rotation*[0,0,1;0,1,0;-1,0,0];
                T(:,:,i) = [obj.rotation, P(:,i); 0, 0, 0, 1];
            end
            qTarget = obj.widowx.ikine(T, 'mask', [1 1 1 0 0 1],'tol',0.5);
            hold on
            obj.widowx.plot(qTarget);
            plot3(x,y,zio.*linspace(1,1,step),'Color', [1, 0, 0], 'MarkerSize', 3, 'LineWidth', 2);
            hold off
            
        end

        
    end
end