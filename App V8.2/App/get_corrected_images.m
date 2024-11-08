function [processed_image, corrected_line] = get_corrected_images(im, red_mask, green_mask, u_real, v_real, precision)
    %% Analisis de Hough
    drawn_line = get_lines_hough(red_mask, 1, 150, max(size(im)), false);
    border_lines = get_lines_hough(green_mask, 4, 150, max(size(im)), false);
    % Ahora tenemos un conjunto de lineas, idealmente deberian ser 5: 4
    % esquinas, y la linea a dibujar. Pero en caso de que hayan mas de esas 5
    % lineas debido a que el proceso de filtrado no pudo eliminar espurias,
    % separamos las 5 lineas importantes.
    
    %% Parametrizamos las lineas obtenidas
    %Obtenemos una lista de imagenes, donde cada imagen contiene unicamente
    %una de las lineas encontradas en la imagen
    im_border_lines_list = get_line_list(green_mask, border_lines);
    im_drawn_line = get_line_list(red_mask, drawn_line);
    
    %Obtenemos una sola imagen con todas las lineas encontradas,
    %proyectadas sobre la imagen filtrada origianl, solo dibujando las
    %partes de las lineas que coinciden con 1's de la original.
    im_border_lines = get_lines_disp(green_mask, im_border_lines_list);
    im_drawn_line = get_lines_disp(red_mask, im_drawn_line);

    %% Obtenemos las 4 esquinas (todavía con angulo)
    corners = get_corners(im_border_lines, im_border_lines_list);

    %% Escalamos la imagen de la linea a dibujar acorde a las posiciones objetivo
    corrected_line = correct_drawn_line(im_drawn_line, corners, u_real, v_real, precision);
    processed_image = correct_image(im, corners, u_real, v_real, precision);
end

function lines = get_lines_hough(filtered_image, n_lines, suppress, Nbins, debug)
% GET_LINES_HOUGH Realiza un Analisis de Hough para detectar lineas
%   lineas = get_lines_hough(filtered_image)
%
%   lines:  lista de lineas detectadas en la imagen 
%   filtered_edges: imagen filtrada
%   n_lines: cantidad de lineas deseadas
%   suppress: parametro supress de Hough
%   debug: variable auxiliar para debug

    imlin=Hough(filtered_image, 'nbins', Nbins);
    %Suprimimos las lineas que estan muy cerca de otras
    imlin.suppress = suppress;
    lines = imlin.lines;
    close all
    
    %A veces las lineas de los bordes tienen fuerzas bastante distintas, y
    %pueden no superar el threshold necesario para aparecer en el analisis,
    %por lo que hacemos que el threshold sea dinamico, bajandolo de a
    %pequeños incrementos hasta que encontremos las n cantidades de lineas
    %deseadas. Confiamos en que el filtrado de las imagenes no deje ninguna
    %linea no deseada con fuerza mayor al del resto de las deseadas.
    [m n] = size(lines);
    while n < n_lines && imlin.houghThresh > 0
        imlin.houghThresh = imlin.houghThresh - 0.1;
        if debug
            idisp(filtered_image);
            imlin.plot
        end
        
        lines = imlin.lines;
        [m n] = size(lines);
    end
    lines = lines(1:n_lines);
    if debug
        idisp(filtered_image);
        imlin.plot
    end
    
end

function im_line_list = get_line_list(filtered_edges, lines)
% GET_LINE_LIST Devuelve una lista de imagenes de lineas aisladas
%   im_line_list = get_line_list(filtered_edges, lines)
%
%   im_line_list: lista de imagenes de lineas aisladas
%   lines:  lista de lineas detectadas en la imagen 
%   filtered_edges: imagen filtrada

    [v,u] = size(filtered_edges);
    im_line_list = zeros(v, u);

    [~, n] = size(lines);
    %Creamos las lineas en la imagen, es decir, solo nos quedamos con un 1 si
    %la linea pasa por ahi, y la imagen original tenia un 1
    for i = 1:n
        line = generarlinea(lines(i).rho,lines(i).theta,size(filtered_edges,2),size(filtered_edges,1));
        im_line_list = [im_line_list line];
    end
    %Eliminamos el primer elemento de la lista, que es puros ceros
    im_line_list = im_line_list(1:v, ((1)*u+1): ((n+1)*u ));
end

function lines_disp = get_lines_disp(filtered_edges, im_line_list)
% GET_LINE_LIST Devuelve una imagen con las lineas que coinciden con la
% imagen filtrada original
%   lines_disp = get_lines_disp(filtered_edges, im_line_list)
%
%   lines_disp: imagen con las lineas proyectadas en la original
%   lines:  lista de lineas detectadas en la imagen 
%   filtered_edges: imagen filtrada
    [v,u] = size(filtered_edges);
    [~,u2] = size(im_line_list);
    n = u2/u;
    lines_disp = zeros(v, u);
    for i = 1:n
       lines_disp = lines_disp + filtered_edges .* im_line_list(1:v, ((i-1)*u + 1):(i*u));
    end
    
    %A veces pasa que las lineas si se cruzan, pero da la casualidad de que
    %ambas se mueven en diagonal de forma que nunca forman un pixel que
    %valga 2, si no que forman un cuadrado de 2x2, asi que salvamos este
    %caso buscando cuadrados de 2x2
    eroded = ierode(lines_disp, ones(2,2));
    dilated = idilate(eroded, ones(3,3));
    [fil, col] = find(dilated == 1);
    for i = 1:length(fil)
        if lines_disp(fil(i), col(i)) == 1
            lines_disp(fil(i), col(i)) = 2;
        end
    end
end

function corners = get_corners(lines_disp, im_line_list)
% GET_CORNERS Devuelve las esquinas del area de trabajo, ordenados de la
% siguiente forma: [INF_IZQ, SUP_IZQ, SUP_DER, INF_DER]
%   corners = get_corners(lines_disp)
%
%   corners: esquinas del area de trabajo
%   lines_disp: imagen con las lineas proyectadas en la original

    [v, u] = size(lines_disp);
    [fil,col]=find(lines_disp == 2);        %%Fil y Col tienen las coordenadas de las interesecciones

    [~ ,u_mult] = size(im_line_list);
    
    for i = 1:u_mult/u
        single_line = im_line_list(1:v, ((i-1)*u + 1):(i*u));           %Analizamos una sola linea
        [multiple, discard_intersection] = check_multiple_interesction(lines_disp, single_line);
        if multiple == true
            [~, n] = size(discard_intersection);
            for j = 1:n
                %fil = fil(fil~=discard_intersection(2,j));
                %col = col(col~=discard_intersection(1,j));
                for k = 1:length(fil)
                    if fil(k) == discard_intersection(2,j) && col(k) == discard_intersection(1,j)
                        fil(k) = [];
                        col(k) = [];
                        break;
                    end
                end
            end
        end
    end
    
    %Debido al posible mismatch de intersecciones, promediamos las que
    %estan demasiado cerca una de la otra
    
    if length(fil) > 4
        [fil, col] = filter_corners(fil, col);
    end
    corners_aux = zeros(2, 4);       %Lista con todas las intersecciones encontrados
    corners_aux(2,:) = fil;
    corners_aux(1,:) = col;
    
    
    %Sin embargo, find nos devuelve las esquinas ordenadas de menor a mayor en
    %las coordenadas x, asi que tenemos que matchear cada esquina con su
    %esquina correspondiente. Vamos a hacerlo de la siguiente forma:

    %Esquinas corregidas deseadas:
    corners = order_corners(corners_aux, u , v);
    %Ahora las posiciones iniciales y finales ya estan en sus respectivas
    %variables, y estan ordenadas de modo que su posicion dentro de la variable
    %es la misma que su esquina objetivo
end

function [filtered_fil, filtered_col] = filter_corners(fil, col)
    skip_index = 0;
    counter = 1;
    filtered_fil = [0];
    filtered_col = [0];
    for i = 1:length(fil)
        duplicate = false;
        for j = i+1:length(fil)
            if abs(fil(i)-fil(j)) < 3 && abs(col(i)-col(j)) < 3 && skip_index ~= i
                filtered_fil = [filtered_fil round((fil(i)+fil(j))/2)];
                filtered_col = [filtered_col round((col(i)+col(j))/2)];
                counter = counter + 1;
                duplicate = true;
                skip_index = j;
                break;
            end
        end
        
        if duplicate == false  && skip_index ~= i
            filtered_fil = [filtered_fil fil(i)];
            filtered_col = [filtered_col col(i)];
            counter = counter + 1;
        end
    end
    
    filtered_fil = filtered_fil(2:end)';
    filtered_col = filtered_col(2:end)';
    
    %En caso de que aun hayan mas de 5 intersecciones, es porque alguna
    %sobrevivio el proceso de filtrado, así que directamente elegimos las 4
    %intersecciones que presenten mayor modulo de matriz de covarianza 
    %entre ellas
    if length(filtered_fil) > 4
        points = zeros(2, length(filtered_col));
        points(2, :) = filtered_fil;
        points(1, :) = filtered_col;
        combinations = combntns(1:length(filtered_col), 4); %Posibles combinaciones de agarrar 4 puntos
        [n_comb, ~] = size(combinations);

        max_sqr_determinant = 0;
        max_indexes = zeros(1, 4);
        for i = 1:n_comb
            set_of_4 = points(:,combinations(i,:));
            mean = [sum(set_of_4(1,:))/4; sum(set_of_4(2,:))/4];
            u_variance = sum((set_of_4(1,:)- mean(1)).^2)/4;
            v_variance = sum((set_of_4(2,:)- mean(2)).^2)/4;
            covar = sum((set_of_4(1,:)- mean(1)).*(set_of_4(2,:)- mean(2)))/4;
            sqr_determinant = sqrt(u_variance*v_variance - covar^2);
            if sqr_determinant > max_sqr_determinant
                max_sqr_determinant = sqr_determinant;
                max_indexes = combinations(i,:);
            end
        end
        filtered_fil = filtered_fil(max_indexes);
        filtered_col = filtered_col(max_indexes);
    end
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
        max_distance = 0;
        i_max = 0;
        j_max = 0;
        for i = 1:length(fil)           %Buscamos la mayor distancia entre puntos
            for j = 1: length(fil)
                distance = sqrt((intersections(1,i) - intersections(1,j))^2 + (intersections(2,i) - intersections(2,j))^2);
                if distance > max_distance
                    max_distance = distance;
                    i_max = i;
                    j_max = j;
                end
            end
        end
       
        %De todos los puntos, si no es uno de los deseados, lo agregamos a
        %la lista de descarte
        discarded = 1;
        for i = 1:length(fil)
            if i ~= i_max && i ~= j_max
                discard_intersection(:,discarded) = intersections(:,i);
                discarded = discarded +1;
            end
        end
    else
        multiple = false;
        discard_intersection = 0;
    end
        
end

function corrected_line = correct_drawn_line(drawn_line, corners, u_real, v_real, precision)
% CORRECT_DRAWN_LINE Devuelve una imagen con la linea a dibujar, corregida
% para que el espacio de trabajo sea un rectangulo
%   corrected_line = correct_drawn_line(drawn_line, corners)
%
%   corrected_line: imagen con la linea corregida en el espacio de trabajo
%   drawn_line: imagen con la linea sin corregir
%   corners: lista con las 4 esquinas del espacio de trabajo, en
%   coordenadas de la imagen original sin correccion por angulo

    target_corners = [1 1 u_real/precision u_real/precision; v_real/precision 1 1 v_real/precision];
    %Matriz de homografia
    matH = homography(corners, target_corners);
    %Corregimos la imagen de la linea a dibujar
    corrected_line = homwarp(matH, drawn_line, 'size', [u_real/precision, v_real/precision]);
    corrected_line = corrected_line>0.5;
end

function corrected_im = correct_image(im, corners, u_real, v_real, precision)
% CORRECT_IMAGE Devuelve una imagen warpeada segun las esquinas dadas
%   corrected_im = correct_image(im, corners)
%
%   corrected_im: imagen warpeada
%   im: imagen a corregir
%   corners: lista con las 4 esquinas del espacio de trabajo, en
%   coordenadas de la imagen original sin correccion por angulo
    target_corners = [1 1 u_real/precision u_real/precision; v_real/precision 1 1 v_real/precision];
    %Matriz de homografia
    matH = homography(corners, target_corners);
    %Corregimos la imagen de la linea a dibujar
    corrected_im = homwarp(matH, im, 'size', [u_real/precision, v_real/precision]);
end