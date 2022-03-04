%  source -- https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection#Algebraic_form

% add sanity check to avoid the singular case
function intersecting_point = line_plane_intersection(cam,mirror,mirror_id,i)

% point on plane (mirror)
if(mirror_id==1)
    p0 = mirror(1).p;
else
    p0 = mirror(2).p;
end


% point on line (camera cone)
if(mirror_id==1)
    l0 = cam.p';
else
    l0 = cam.cone_mirror1_intersection(:,i)
end
% normal vector of plane
n = mirror(mirror_id).R(:,3);

% vector in the direction of line
if(mirror_id==1)
    l = cam.cone_unit_vec(:,i);
else
    l = cam.cone_mirror1_reflection(:,i);
end

% line parameters
d = dot(p0-l0,n)/dot(l,n);

intersecting_point =  l0 + l*d;
