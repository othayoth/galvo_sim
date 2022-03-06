function [cam,mirror] = find_gaze(cam,mirror)

% variable for closed path such as scircle or square
t = linspace(0,2*pi,1000);

for i = 1:numel(t)

    %% 1. field of view (square) and normal vectors along the edges

    % parametrisation of square field of view emitted from square
    cam.fov_square_x(i) = tan(cam.view_angle)*cos(t(i))/max(abs(cos(t(i))),abs(sin(t(i))));
    cam.fov_square_y(i) = tan(cam.view_angle)*sin(t(i))/max(abs(cos(t(i))),abs(sin(t(i))));
    cam.fov_square_z(i) = 1;
    % create unit vectors emitting from camera
    cam.fov(:,i) = [cam.fov_square_x(i);cam.fov_square_y(i);cam.fov_square_z(i)];
    cam.fov(:,i) = cam.fov(:,i)/norm(cam.fov(:,i));     
    cam.fov(:,i) = cam.R*cam.fov(:,i); 

    %% 2. projection :: camera_line_of_sight --> tilt_mirror_plane
    % https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection#Algebraic_form
    p0 = mirror(1).p;                       % point on plane (tilt mirror)
    n = mirror(1).R(:,3);                   % normal vector of plane (tilt mirror)
    l0 = cam.p';                            % point on line (camera fov)    
    l = cam.fov(:,i);                       % direction vector of line (camera fov)
    d = dot(p0-l0,n)/dot(l,n);              % line parameters at for intersecting condition
    cam.pts.proj.tilt(:,i) = l0 + l*d;

    %% 3. reflection:: camera_line_of_sight --> tilt_mirror_plane    
    v = cam.fov(:,i);                       % incident direction (camera fov)
    a = mirror(1).R(:,3);                   % normal vector of plane (tilt mirror)
    c = mirror(1).p;                        % point on plane (tilt mirror)        
    cam.vec.reflect.tilt(:,i) = v-2*a*(dot(v,a)/dot(a,a));
    cam.vec.reflect.tilt(:,i) = cam.vec.reflect.tilt(:,i)/norm(cam.vec.reflect.tilt(:,i)); 

    %% 4. projection :: tilt_mirror_reflection --> pan_mirror_plane
    % https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection#Algebraic_form
    p0 = mirror(2).p;                       % point on plane (pan mirror)
    n = mirror(2).R(:,3);                   % normal vector of plane (pan mirror)
    l0 = cam.pts.proj.tilt(:,i) ;           % point on line (tilt mirror projection)    
    l = cam.vec.reflect.tilt(:,i);          % direction vector of line (tilt mirror reflection)
    d = dot(p0-l0,n)/dot(l,n);              % line parameters at for intersecting condition
    cam.pts.proj.pan(:,i) = l0 + l*d;

    %% 5. reflection:: tilt_mirror_reflection --> pan_mirror_plane    
    v = cam.vec.reflect.tilt(:,i);          % incidecnt direction (tilt mirror reflection)
    a = mirror(2).R(:,3);                   % normal vector of plane (pan mirror)
    c = mirror(2).p;                        % point on plane (pan mirror)        
    cam.vec.reflect.pan(:,i) = v-2*a*(dot(v,a)/dot(a,a));
    cam.vec.reflect.pan(:,i) = cam.vec.reflect.pan(:,i)/norm(cam.vec.reflect.pan(:,i)); 

    %% 6. projection :: pan_mirror_reflection --> ground_plane
    % https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection#Algebraic_form
    p0 = [0 0 -28]';                       % point on plane (ground)
    n = [0 0 1];                           % normal vector of plane (griund)
    l0 = cam.pts.proj.pan(:,i);            % point on line (pan mirror projection)    
    l = cam.vec.reflect.pan(:,i);          % direction vector of line (pan mirror reflection)
    d = dot(p0-l0,n)/dot(l,n);             % line parameters at for intersecting condition
    cam.pts.proj.ground(:,i) = l0 + l*d;
end

