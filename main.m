clear all
% close all

mirror(1).angle  = -40;
mirror(2).angle  = 0;

cam.R = EulerZYX_Fast([pi, 0, 0])
cam.p = [0 0 8];
cam.view_angle = 1*pi/180;

% mirror 1
mirror(1).p = cam.p'  + cam.R(:,3)*4;% + cam.R(:,2)*0.04;
mirror(1).R = EulerZYX_Fast([-45,0,0]*pi/180)*EulerZYX_Fast([ mirror(1).angle 0 0]*pi/180);
% mirror 2
mirror(2).p = cam.p'  + cam.R(:,3)*4 + cam.R(:,2)*-4; 
mirror(2).R = EulerZYX_Fast([0,90,0]*pi/180)*EulerZYX_Fast([45,0,0]*pi/180)*EulerZYX_Fast( [mirror(2).angle 0 0]*pi/180);


t = linspace(0,2*pi,1000);

% cone-of-view intersection with mirror 1
for i = 1:numel(t)
    cam.cone_unit_vec(:,i) = EulerZYX_Fast([0,0,t(i)])*EulerZYX_Fast([cam.view_angle 0 0])*[0;0;1]; 
    cam.cone_mirror1_intersection(:,i) = line_plane_intersection(cam,mirror,1,i);
end

% reflection vector for cam->mirror1
for i = 1:numel(t)
    cam.cone_mirror1_reflection(:,i) = line_plane_reflection(cam,mirror(1),i);
end

% cone-of-view intersection with mirror 2
for i = 1:numel(t)    
    cam.cone_mirror2_intersection(:,i) = line_plane_intersection(cam,mirror,2,i);
end


%% graphics

%  draw camera
figure(1)
clf
hold on
cam.camera = plotCamera('AbsolutePose',rigid3d(cam.R,cam.p),'Opacity',0,'Size',0.5,'AxesVisible',true)

gnd.ph = patch([-1 -1 1 1]*10,[-1 1 1 -1]*10, [0 0 0 0],'k');
set(gnd.ph,'FaceAlpha',0.2,'facecolor','k')



mirror(1).ph = patch([-1 -1 1 1]*1,[-1 1 1 -1]*1, [0 0 0 0],'k');
set(mirror(1).ph,'FaceAlpha',0.2,'facecolor','y')
mirror(1).vertices = mirror(1).ph.Vertices';

mirror(1).vertices = mirror(1).R*mirror(1).vertices + mirror(1).p;
mirror(1).ph.Vertices = mirror(1).vertices'

mirror(1).normal = plot3(mirror(1).p(1)+[0 mirror(1).R(1,3)*1],...
                         mirror(1).p(2)+[0 mirror(1).R(2,3)*1],...
                         mirror(1).p(3)+[0 mirror(1).R(3,3)*1],'b','LineWidth',2)
mirror(1).rx =     plot3(mirror(1).p(1)+[0 mirror(1).R(1,1)*1],...
                         mirror(1).p(2)+[0 mirror(1).R(2,1)*1],...
                         mirror(1).p(3)+[0 mirror(1).R(3,1)*1],'r','LineWidth',2)
mirror(1).ry =     plot3(mirror(1).p(1)+[0 mirror(1).R(1,2)*1],...
                         mirror(1).p(2)+[0 mirror(1).R(2,2)*1],...
                         mirror(1).p(3)+[0 mirror(1).R(3,2)*1],'g','LineWidth',2)


mirror(2).ph = patch([-1 -1 1 1]*1,[-1 1 1 -1]*1, [0 0 0 0],'k');
set(mirror(2).ph,'FaceAlpha',0.2,'facecolor','y')
mirror(2).vertices = mirror(2).ph.Vertices';

mirror(2).vertices = mirror(2).R*mirror(2).vertices + mirror(2).p;
mirror(2).ph.Vertices = mirror(2).vertices'

mirror(2).normal = plot3(mirror(2).p(1)+[0 mirror(2).R(1,3)*1],...
                         mirror(2).p(2)+[0 mirror(2).R(2,3)*1],...
                         mirror(2).p(3)+[0 mirror(2).R(3,3)*1],'b','LineWidth',2)
mirror(2).rx =     plot3(mirror(2).p(1)+[0 mirror(2).R(1,1)*1],...
                         mirror(2).p(2)+[0 mirror(2).R(2,1)*1],...
                         mirror(2).p(3)+[0 mirror(2).R(3,1)*1],'r','LineWidth',2)
mirror(2).ry =     plot3(mirror(2).p(1)+[0 mirror(2).R(1,2)*1],...
                         mirror(2).p(2)+[0 mirror(2).R(2,2)*1],...
                         mirror(2).p(3)+[0 mirror(2).R(3,2)*1],'g','LineWidth',2)

% conical projection on mirrro1
plot3(cam.cone_mirror1_intersection(1,:),cam.cone_mirror1_intersection(2,:),cam.cone_mirror1_intersection(3,:),'y','LineWidth',2)

% conical projection on mirrro2
plot3(cam.cone_mirror2_intersection(1,:),cam.cone_mirror2_intersection(2,:),cam.cone_mirror2_intersection(3,:),'y','LineWidth',2)

%  transformed line of sight
camera.tf_los = [0 0 0]';
% 1 . camera to mirror 1
plot3([cam.p(1) mirror(1).p(1)],...
      [cam.p(2) mirror(1).p(2)],...
      [cam.p(3) mirror(1).p(3)],'k','LineWidth',2)
% 2. mirror 1 reflection




axis equal
xlim([-1 1]*10);
ylim([-1 1]*10);
zlim([0 1]*10);
view(20,20)
view(210,30)
view(100,30)

xlabel('x')
ylabel('y')