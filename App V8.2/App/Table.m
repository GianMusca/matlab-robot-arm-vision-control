classdef Table
    properties
        X0;
        Y0;
        Z0;
        width;
        length;
        color;
    end
    
    methods
        function obj = Table(X0,Y0,Z0,width,length,color)
            obj.X0 = X0;
            obj.Y0 = Y0;
            obj.Z0 = Z0;
            obj.width = width;
            obj.length = length;
            obj.color = color;
        end
        function drawTable(obj)
            X = [obj.X0, obj.X0 + obj.width, obj.X0 + obj.width, obj.X0];
            Y = [obj.Y0, obj.Y0, obj.Y0 + obj.length, obj.Y0 + obj.length];
            Z = [obj.Z0, obj.Z0, obj.Z0, obj.Z0];
            h = fill3(X,Y,Z,[0, 0, 1]);
            h.FaceColor = obj.color;
            h.FaceAlpha = 0.3;
        end
        
    end
end