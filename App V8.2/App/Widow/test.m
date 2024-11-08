%Initial table position
X0 = 100;
Y0 = 100;
Z0 = 150;
width = 200;
length = 150;
color = [0 0 1];

%create table
table = Table(X0,Y0,Z0,width,length,color);


%% Parametros del Robot
L1 = 130;
L2 = 144;
L3 = 53;
L4 = 144;
L5 = 144;
Lee = 144;

%Limites de joints
theta1 = 80;
theta2 = 80;
theta3 = 80;
theta4 = 80;
theta5 = 80;

thlim = [theta1, theta2, theta3, theta4, theta5];

initPos = [X0, Y0, Z0];

%Create robot
robot = Widow(L1,L2,L3,L4,L5,Lee,initPos);


table.drawTable();
%Show robot in initial position
robot.drawRobot();
%Show workspace considering limits
%robot.drawWorkspace(thlim)

%Move robot, draw line from initial to final position in 10 steps
robot.drawLine([X0 Y0 Z0], [X0+200 Y0+150 Z0], 10);
% for i=1:10
%     robot.drawLine([X0 Y0 Z0], [X0+200 Y0+150 Z0], 10);
% end