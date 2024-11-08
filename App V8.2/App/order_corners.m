function ordered_corners = order_corners(origin_corners, u , v)
    %No es tan facil ordenar los puntos, ya que si la imagen
    %esta lo suficientemente deformada, una esquina correspondiente a una
    %esquina de la imagen esta mas cerca de una esquina vecina.
    
    %La idea es conseguir la distancia de cada esquina encontrada a cada
    %esquina de la imagen, de esta forma el orden correcto es el que tenga
    %menor suma de distancias de cada esquina encontrada, sin repetir.
    target_corners = [1 1 u u; v 1 1 v];
    %En la matriz de distancias guardamos las distancias de cada esquina
    %encontrada, las filas son las esquinas y las columnas son las
    %distancias de cada esquina a las esquinas de la imagen
    distance_matrix = zeros(4,4);
    
    for i = 1:4
        origin_corner = origin_corners(:, i);
        for j = 1:4
            target_corner = target_corners(1:2, j);
            distance_matrix(i, j) = sqrt((target_corner(1) - origin_corner(1))^2 + (target_corner(2) - origin_corner(2))^2);
        end
    end
    
    %Ahora analizamos todas las posibles combinaciones de asignacion de
    %esquinas, y evaluamos la suma de distancias, la combinacion correcta
    %es la que tiene menor suma de distancias.
    min_index = zeros(1,4);
    min_distance_sum = 4*sqrt(u^2 + v^2);
    for i = 1:4
        for j = 1:4
            for k = 1:4
                for l =1:4
                    if length(unique([i j k l])) == 4    %No queremos repetir esquinas
                        %dist_sum = distance_matrix(1,i) + distance_matrix(2,j) + distance_matrix(3,k) + distance_matrix(4,l);
                        dist_sum = distance_matrix(i,1) + distance_matrix(j,2) + distance_matrix(k,3) + distance_matrix(l,4);
                        if dist_sum < min_distance_sum
                            min_distance_sum = dist_sum;
                            min_index = [i j k l];
                        end
                    end
                end
            end
        end
    end
    %Ordenamos las esquinas
    ordered_corners = zeros(2,4);
    for i = 1:length(min_index)
        ordered_corners(:,i) = origin_corners(:,min_index(i));
    end
        
end
