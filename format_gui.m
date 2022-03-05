% set top right subplot emptly
subplot(1,2,2)
hold on 
set(gca,'visible','off')

% set slider and its text positions
fn=fieldnames(ff.sl)
for ii = 1:numel(fn)
   ff.sl.(fn{ii}).Units='normalized';
   ff.sl.(fn{ii}).Position = [0.65 0.80-(ii-1)*0.1 .2 .02] 
   ff.st(ii).Position      = [0.65 0.83-(ii-1)*0.1 .2 .03] 
   ff.st(ii).FontSize      = 15;
   ff.st(ii).BackgroundColor = 'w';
   
   switch fn{ii}
       case 't'
           ff.st(ii).String = 'tilt'
       case 'p'
           ff.st(ii).String = 'pan'
   end
   
end

ff.st(ii).FontSize = 15;

% reset button
ff.bt.Units = 'normalized';
ff.bt.Position = [0.65 0.9 0.2 0.03]; 
ff.bt.String = 'Right click here to reset'
ff.bt.FontSize = 15;