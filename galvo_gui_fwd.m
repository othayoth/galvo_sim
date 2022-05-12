function galvo_gui

    clear
    close all


    %% setup geometry
    
    mirror(1).angle  = -10;  % tilt (degree)
    mirror(2).angle  =  7.018;  % pan  (degree)
    
    % orientation, position, field of view (fov needs more work)
    cam.R = eulerzyx_fast([pi, 0, 0]);
    cam.p = [0 0 0];
    cam.view_angle = 00*pi/180; % set this to zero to see projection of point instead of square fov
    
    
    % mirror 1 -- tilt mirror position and orientation
    mirror(1).p = cam.p'  + cam.R(:,3)*10; % can add some offset along x and y and would still work
    mirror(1).R = eulerzyx_fast([0,0,180]*pi/180)*eulerzyx_fast([-45,0,0]*pi/180)*eulerzyx_fast([ mirror(1).angle 0 0]*pi/180);
    % mirror 2 -- pan mirror position and orientation
    mirror(2).p = mirror(1).p + cam.R(:,2)*10; % again, can add some offset and would still work 
    % the below one is temp; above one is accurate
    mirror(2).p = mirror(1).p + cam.R(:,2)*10; % again, can add some offset and would still work 
    mirror(2).R = eulerzyx_fast([0,-90,0]*pi/180)*eulerzyx_fast([-45,0,0]*pi/180)*eulerzyx_fast( [mirror(2).angle 0 0]*pi/180);


    %% setup figures
    ff.fh = figure(1);
    clf
    hold on 
    set(gcf,'position',[1 50 900 900],'color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
    
    ff.sp = subplot(1,2,1);
    hold on
    s = loadawobj('galvo_minimal.obj'); %  loads a minimal geometry with camera and mirror holders
    s.v(3,:) = -s.v(3,:);               %  need these coordinate flipping alond x and z direction
    s.v(1,:) = -s.v(1,:);
    ff.galvo_minimal = patch('Faces',s.f3','Vertices',s.v','facecolor','b','edgealpha',0.1);

    % ground plane patch
    ff.gnd = patch([-1 -1 1 1]*70,[-1 1 1 -1]*70, [1 1 1 1]*-28,'k');
    set(ff.gnd,'FaceAlpha',0.2,'facecolor','k');
    
    % tilt mirror patch
    ff.mirror(1) =  patch([-1 -1 1 1]*4,[-1 1 1 -1]*4, [0 0 0 0],'k');
    set(ff.mirror(1),'FaceAlpha',0.5,'facecolor','y');
    mirror(1).vertices = ff.mirror(1).Vertices';
    ff.mirror(1).Vertices =(mirror(1).R*mirror(1).vertices + mirror(1).p)';
        
    % pan mirror patch 
    ff.mirror(2) =  patch([-1 -1 1 1]*4,[-1 1 1 -1]*4, [0 0 0 0],'k');
    set(ff.mirror(2),'FaceAlpha',0.5,'facecolor','y');
    mirror(2).vertices = ff.mirror(2).Vertices';
    ff.mirror(2).Vertices =(mirror(2).R*mirror(2).vertices + mirror(2).p)';

    % field_of_view (square) projection on tilt mirror
    ff.ph.proj.tilt = plot3(0,0,0,'m','LineWidth',1,'marker','o','markersize',1);

    % field_of_view (square) projection on pan mirror
    ff.ph.proj.pan  = plot3(0,0,0,'m','LineWidth',1,'marker','o','markersize',1);

    % filed_of_view (square) projection on ground
    ff.ph.proj.gnd  = plot3(0,0,0,'m','LineWidth',1,'marker','o','markersize',1);
    
    %% gui controls

    % slider for tilt angle
    ff.sl.t = uicontrol('style','slider','units','pixel','string','tilt','tag','tag_sl_tilt'); 
    ff.sl.t.Max = max(-5);
    ff.sl.t.Min = min(-15);
    addlistener(ff.sl.t,'ContinuousValueChange',@(hObject, event) update_system(hObject, event,ff,cam,mirror));

    % slider for pan angle
    ff.sl.p = uicontrol('style','slider','units','pixel','string','pan','tag','tag_sl_pan'); 
    ff.sl.p.Max = max(10);
    ff.sl.p.Min = min(-10);
    addlistener(ff.sl.p,'ContinuousValueChange',@(hObject, event) update_system(hObject, event,ff,cam,mirror));
       
    % reset button
    ff.bt = uicontrol('style','pushbutton')
    addlistener(ff.bt,'ButtonDown',@(hObject, event) reset_system(ff,cam,mirror));

    % text labels
    for ii = 1:2
        ff.st(ii) = uicontrol('style','text','units','normalized','tag',['var_' num2str(ii)]);
    end

    % arrange the gui controls
    format_gui

    % bring system to a good home position
    reset_system(ff,cam,mirror)

    %% reset callback
function reset_system(ff,cam,mirror)
    
    subplot(ff.sp)

    % reset the angles
    mirror(1).angle  = -10; % tilt
    mirror(2).angle  =  10; % pan

    % reset mirror orientations
    mirror(1).R = eulerzyx_fast([0,0,180]*pi/180)*eulerzyx_fast([-45,0,0]*pi/180)*eulerzyx_fast([ mirror(1).angle 0 0]*pi/180);
    mirror(2).R = eulerzyx_fast([0,-90,0]*pi/180)*eulerzyx_fast([-45,0,0]*pi/180)*eulerzyx_fast( [mirror(2).angle 0 0]*pi/180);

    % update mirror patches
    ff.mirror(1).Vertices =(mirror(1).R*mirror(1).vertices + mirror(1).p)';
    ff.mirror(2).Vertices =(mirror(2).R*mirror(2).vertices + mirror(2).p)';

    % plot properties
    axis equal
    view(-75,30)
    xlim([-2.5 0.2]*30)
    ylim([-1 1]*30)
    zlim([-28 10])
    xlabel('x (in)')
    ylabel('y (in)')
    zlabel('z (in)')

    hh = findobj('tag','tag_sl_tilt');
    hh.Value = mirror(1).angle;
    hh = findobj('tag','tag_sl_pan');
    hh.Value = mirror(2).angle;

    gg = findobj('tag','var_1');     
    gg.String=['tilt = ' num2str(mirror(1).angle)  '°']; 
    gg = findobj('tag','var_2');     
    gg.String=['pan = ' num2str(mirror(2).angle)  '°']; 

   
    % update gaze and plot handles
    [cam,mirror] = find_gaze(cam,mirror);
    ff.ph.proj.tilt.XData = cam.pts.proj.tilt(1,:);
    ff.ph.proj.tilt.YData = cam.pts.proj.tilt(2,:);
    ff.ph.proj.tilt.ZData = cam.pts.proj.tilt(3,:);

    ff.ph.proj.pan.XData = cam.pts.proj.pan(1,:);
    ff.ph.proj.pan.YData = cam.pts.proj.pan(2,:);
    ff.ph.proj.pan.ZData = cam.pts.proj.pan(3,:);

    ff.ph.proj.gnd.XData = cam.pts.proj.ground(1,:);
    ff.ph.proj.gnd.YData = cam.pts.proj.ground(2,:);
    ff.ph.proj.gnd.ZData = cam.pts.proj.ground(3,:);
   
%% update callback
function update_system(hObject, event,ff,cam,mirror)
    
    % update mirror angles from reading the slider object values
    hh = findobj('tag','tag_sl_tilt');
    mirror(1).angle = hh.Value;
    hh = findobj('tag','tag_sl_pan');
    mirror(2).angle = hh.Value;

    % update mirror rotations
    mirror(1).R = eulerzyx_fast([0,0,180]*pi/180)*eulerzyx_fast([-45,0,0]*pi/180)*eulerzyx_fast([ mirror(1).angle 0 0]*pi/180);
    mirror(2).R = eulerzyx_fast([0,-90,0]*pi/180)*eulerzyx_fast([-45,0,0]*pi/180)*eulerzyx_fast( [mirror(2).angle 0 0]*pi/180);
    
    % update mirror plot patches
    ff.mirror(1).Vertices =(mirror(1).R*mirror(1).vertices + mirror(1).p)';
    ff.mirror(2).Vertices =(mirror(2).R*mirror(2).vertices + mirror(2).p)';

    % update text in plot
    gg = findobj('tag','var_1');     
    gg.String=['tilt = ' num2str(mirror(1).angle)  '°']; 
    gg = findobj('tag','var_2');     
    gg.String=['pan = ' num2str(mirror(2).angle)  '°']; 

    % update gaze and plot handles
    [cam,mirror] = find_gaze(cam,mirror);
    ff.ph.proj.tilt.XData = cam.pts.proj.tilt(1,:);
    ff.ph.proj.tilt.YData = cam.pts.proj.tilt(2,:);
    ff.ph.proj.tilt.ZData = cam.pts.proj.tilt(3,:);

    ff.ph.proj.pan.XData = cam.pts.proj.pan(1,:);
    ff.ph.proj.pan.YData = cam.pts.proj.pan(2,:);
    ff.ph.proj.pan.ZData = cam.pts.proj.pan(3,:);

    ff.ph.proj.gnd.XData = cam.pts.proj.ground(1,:);
    ff.ph.proj.gnd.YData = cam.pts.proj.ground(2,:);
    ff.ph.proj.gnd.ZData = cam.pts.proj.ground(3,:);
     
   
   
    