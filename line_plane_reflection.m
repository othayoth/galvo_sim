function reflected_direction = line_plane_reflection(cam,mirror,i)
%incident direction
v = cam.cone_unit_vec(:,i);

% normal to plane
a = mirror.R(:,3);

% point on oplane
c = mirror.p;

reflected_direction = v- 2*a*(dot(v,a-c)/dot(a,a));

end