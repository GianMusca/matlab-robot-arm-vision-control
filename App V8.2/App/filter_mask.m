function filtered = filter_mask(im)
    closed = iclose(im, kcircle(5));
    
    %Ahora intentamos eliminar los bordes de la hoja que molestan
    opened = iopen(closed, kcircle(2));

    % Terminamos de rellenar las esquinas: Apertura
    filtered = iclose(opened, kcircle(12));
end