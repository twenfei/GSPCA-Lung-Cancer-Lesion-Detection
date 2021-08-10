function pca_gui
% This is a GUI for the PCANet lesion detection moodel with the following
% functions:
% 1. Generate and save the output binary maps.
% 2. Output the lesion counting result. (connected componenets on binary maps)
% 3. Demonstrate the overlaid results on the original image.
% Written by: Wenfei Tang
% Galban Lab, University of Michigan, Jan 2021

%  Create and then hide the UI as it is being constructed.
f = figure('Visible','off','Position',[450,200,700,700]);

%% Construct the components.

% Position: [distance from left, distance from bottom, width, height]
% Select files from folders.
hselect    = uicontrol('Style','pushbutton','String','Select file','Position',[315,520,100,25]);
% Run the model
hrun    = uicontrol('Style','pushbutton','String','Run','Position',[315,480,100,25]);        
% Save the generated binary map
hsave1 = uicontrol('Style','pushbutton','String','Save map','Position',[315,440,100,25]);
% Save the overlaid demo image
hsave2 = uicontrol('Style','pushbutton','String','Save overlay','Position',[315,400,100,25]);
% Reset and clear everything
hreset = uicontrol('Style','pushbutton','String','Reset','Position',[315,360,100,25]);

% Add axes
ha1 = axes('Units','Pixels','Position',[50,460,200,185]); 
ha2 = axes('Units','Pixels','Position',[50,260,200,185]); 
ha3 = axes('Units','Pixels','Position',[50,60,200,185]); 
align([hselect,hrun,hsave1,hsave2,hreset],'Center','None');
   
% Make the UI visible.
f.Visible = 'on';
end