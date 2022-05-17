

    % input
    p_target = [-37.0752;-23.4943;-28];
    p_target = [-32.7509;-14.1172;-28];
    p_target = [-48.7694; 0.832783;-28];
    p_target = [-44.4767; 2.13809 ;-28];
    p_target = [-13.6123; 6.2224; -28];
    p_target = [-33.3419; -14.2099 ; -28];

    %% setup geometry
    
    mirror(1).angle  = 0;  % tilt (degree)
    mirror(2).angle  = 0;  % pan  (degree)
    
    % orientation, position, field of view (fov needs more work)
    cam.R = eulerzyx_fast([pi, 0, 0]);
    cam.p = [0 0 0];
    cam.view_angle = 00*pi/180; % set this to zero to see projection of point instead of square fov
    
    
    % mirror 1 -- tilt mirror position and orientation
    mirror(1).p = cam.p' + cam.R(:,3)*10; % can add some offset along x and y and would still work
    mirror(1).R = eulerzyx_fast([0,0,180]*pi/180)*eulerzyx_fast([0,0,0]*pi/180)*eulerzyx_fast([ mirror(1).angle 0 0]*pi/180);
    % mirror 2 -- pan mirror position and orientation
    mirror(2).p = mirror(1).p + cam.R(:,2)*10; % again, can add some offset and would still work 
    mirror(2).R = eulerzyx_fast([180,90,-90]*pi/180)*eulerzyx_fast([0,0,0]*pi/180)*eulerzyx_fast( [mirror(2).angle 0 0]*pi/180);

    %% 0 . Solve for pan angle
    pan_angle = -0.5*atan2(mirror(2).p(1) - p_target(1), p_target(2) - mirror(2).p(2)) ;

    %% 1 . find normal vector to the second camera
    n_m2  = eulerzyx_fast([0,0,-pan_angle])*mirror(2).R(:,3);

    %% 2 . find parameters of plane containing normal and two points
    p1 = mirror(1).p;
    p2 = p_target;
    n_plane = cross((p1-p2)/norm(p1-p2),n_m2);

    %% 3 . intersection between plane of action and line of mirror 2
    p0 = mirror(1).p;   % point on plane5
    l0 = mirror(2).p;   % point on mirror 2
    n  = n_plane;       % normal to plane
    l  = mirror(2).R(:,1);   % line of mirror 2
    d  = dot(p0-l0, n) / dot(l,n);
    p_incidence = l0 + l*d;

    %% 4 . find tilt angle
    tilt_angle = 0.5*atan2(mirror(2).p(2) - mirror(1).p(2), p_incidence(3) - mirror(1).p(3) );

    [tilt_angle, pan_angle]*180/pi