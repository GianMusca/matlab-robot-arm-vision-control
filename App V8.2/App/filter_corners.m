clear all
close all
clc
%% Importar imagenes sobre las que trabajamos
im_lines  =iread('G:\My Drive\Cursada\8° Cuatrimestre\Automación Industrial\Práctica\Vision\Playground TPF\Test Cases\TPF_Test21_LINES.jpg');
lines_disp=load("lines_disp.mat");
lines_disp = lines_disp.lines_disp;

im_line_list=load("im_line_list.mat");
im_line_list = im_line_list.im_line_list;

disp(get_corners(lines_disp, im_line_list))

function corners = get_corners(lines_disp, im_line_list)
% GET_CORNERS Devuelve las esquinas del area de trabajo, ordenados de la
% siguiente forma: [INF_IZQ, SUP_IZQ, SUP_DER, INF_DER]
%   corners = get_corners(lines_disp)
%
%   corners: esquinas del area de trabajo
%   lines_disp: imagen con las lineas proyectadas en la original

    [v, u] = size(lines_disp);
    [fil,col]=find(lines_disp == 2);        %%Fil y Col tienen las coordenadas de las interesecciones

    [v_mult ,u_mult] = size(im_line_list);

    for i = 1:u_mult/u
        single_line = im_line_list(1:v, ((i-1)*u + 1):(i*u));           %Analizamos una sola linea
        [multiple, discard_intersection] = check_multiple_interesction(lines_disp, single_line);
        if multiple == true
            [m, n] = size(discard_intersection);
            for j = 1:n
                fil = fil(fil~=discard_intersection(2,j));
                col = col(col~=discard_intersection(1,j));
            end
        end
    end

    corners_aux = zeros(2, length(fil));       %Lista con todas las intersecciones encontrados
    corners_aux(2,:) = fil(:);
    corners_aux(1,:) = col(:);
    
    %Sin embargo, find nos devuelve las esquinas ordenadas de menor a mayor en
    %las coordenadas x, asi que tenemos que matchear cada esquina con su
    %esquina correspondiente. Vamos a hacerlo de la siguiente forma:

    %Esquinas corregidas deseadas:
    target_corners = [1 1 u u; v 1 1 v];
    [m, n] = size(target_corners);
    corners = zeros(2,4);
    %Calculamos las distancias a cada punto
    for i = 1:n                         %Recorremos las posiciones finales
        min_dist = sqrt(u^2 + v^2);     %Ponemos un minimo muy alto como inicial para que pueda sobrepasarse facilmente 
        min_index = 0;
        target_corner = target_corners(1:2, i);
        for j = 1:n                     %Recorremos las posiciones iniciales
            origin_corner = corners_aux(1:2, j);
            dist = sqrt((target_corner(1) - origin_corner(1))^2 + (target_corner(2) - origin_corner(2))^2);
            if dist < min_dist
                min_dist = dist;
                min_index = j;
            end
        end
        corners(1:2, i) = corners_aux(1:2, min_index);
    end

    %Ahora las posiciones iniciales y finales ya estan en sus respectivas
    %variables, y estan ordenadas de modo que su posicion dentro de la variable
    %es la misma que su esquina objetivo
end

function [multiple, discard_intersection] = check_multiple_interesction(lines_disp, single_line)
    
    superimposed_line = lines_disp .* single_line;
    
    [fil,col]=find(superimposed_line == 2);        %%Fil y Col tienen las coordenadas de las interesecciones
    intersections = zeros(2, length(fil));       %Lista con todas las intersecciones encontrados
    intersections(2,:) = fil(:);
    intersections(1,:) = col(:);
    
    if length(fil) > 2         %Si hay mas de 2 intersecciones en una linea, hay un conflicto de bordes
        multiple = true;
        discard_intersection = zeros(2, length(fil) - 2);   %Hay que descartar todas las intersecciones menos las 2 correctas
        %Las intersecciones validas van a ser las que esten mas alejadas
        %una de la otra, para asegurarnos de que son parte de las esquinas
        distances = zeros(1, length(fil));
        for i = 1:length(fil)           %Buscamos la suma de las distancias de cada punto a cada punto
            for j = 1: length(fil)
                distances(i) = distances(i) + sqrt((intersections(1,i) - intersections(1,j))^2 + (intersections(2,i) - intersections(2,j))^2);
            end
        end
        
        %Ahora buscamos los dos puntos con la suma de distancias mas altas
        correct_points_distance = maxk(distances, 2);
        
        %De todos los puntos, si no es uno de los deseados, lo agregamos a
        %la lista de descarte
        discarded = 1;
        for i = 1:length(fil)
            if distances(i) ~= correct_points_distance(1) && distances(i) ~= correct_points_distance(2)
                discard_intersection(:,discarded) = intersections(:,i);
                discarded = discarded +1;
            end
        end
    else
        multiple = false;
        discard_intersection = 0;
    end
        
end
