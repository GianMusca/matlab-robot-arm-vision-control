function real_points = get_real_points(corrected_line, precision)
    %% Obtenemos los dos puntos que forman la linea a dibujar

    [fil,col]=find(corrected_line);          %Obtenemos todos los puntos por los que pasa la linea
    points = zeros(2,2);           
    %En esta lista de puntos, los puntos que definen a la linea son el
    %primero y el ultimo, ya que se pueden unir y asi formar una linea
    points(:,1) = [col(1); fil(1)];
    points(:,2) = [col(length(col)); fil(length(fil))];

    %% Escalamos los puntos obtenidos sabiendo las dimensiones del espacio de trabajo
    real_points = points.*precision';
end