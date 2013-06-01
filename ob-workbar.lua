--[[
	Conky ob-workbar by Youmy001
	A light workspace indicator bar for Openbox by Youmy001
	
	Features:
		- Place the bar on any side of the screen
		- Seperate color for either the bar, inactive workspace and active workspace
		- Automatically adjust to the actual number of workspace
		- Support tranparency
		- Can work on any window manager
	
	Requires takao font
		sudo apt-get install ttf-takao
		
	This file is part of ob-workbar
	
]]--

require 'cairo'

--====== Global settings table ===============================================--
-- Change these values to alter the appearance of your indicator bar
setting_table = {
	-- General setting sfor the whole bar
	{
		width=21,				-- This is the size of the bar in pixel. The higher it is
								-- thicker the bar will become.
								
		position='bottom',		-- This is the side on which the bar will be displayed.
								-- It can be either 'top', 'bottom', 'left' and 'right'.
								
		background='0x000000',	-- Color of the bar's background
								
		alpha=0.5,				-- Transparency of the background color
	},
	-- Inactive workspace settings
	{
		width=20,				-- Size of an inactive workspace in pixel. The higher it
								-- is, thicker the bar will become.
		rounded=false,			-- Shall the corners be rounded. Not effective yet.
		background='0x888888',	-- Color of the inactive workspace
		background_alpha=0,		-- Transparency of the background color
		text_type='number',		-- Shall the inactive workspace number and name be 
								-- printed ? It can be 'none' or 'number'.
		text='0xFFFFFF',		-- Color of the text
		text_alpha=1,			-- Transparency of the text
	},
	-- Active workspace settings
	{
		width=28,				-- Size of an inactive workspace in pixel. The higher it
								-- is, thicker the bar will become.
		rounded=false,			-- Shall the corners be rounded. Not effective yet.
		background='0x02FEFE',	-- Color of the inactive workspace
		background_alpha=1,		-- Transparency of the background color
		text_type='both',		-- Shall the active workspace number and/or name be 
								-- printed ? It can be 'none', 'number', 'name' or 'both'.
		text='0x000000',		-- Color of the text
		text_alpha=1,			-- Transparency of the text
	},
}



function draw_ring(cr,t,pt)--t=percentage, pt=setting_table
	local w,h=conky_window.width,conky_window.height

	local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],
									pt['start_angle'],pt['end_angle']
	local bgc, bga, fgc, fga=pt['bg_colour'],pt['bg_alpha'],pt['fg_colour'],pt['fg_alpha']

	local angle_0=sa*(2*math.pi/360)-math.pi/2
	local angle_f=ea*(2*math.pi/360)-math.pi/2
	local t_arc=t*(angle_f-angle_0)

	-- Draw background ring

	cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
	cairo_set_line_width(cr,ring_w)
	cairo_stroke(cr)

	-- Draw indicator ring
	cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
	cairo_stroke(cr)
end

function draw_workspace(xPos,yPos,lenght,st,work_num)
	local workspace=tostring(conky_parse("${desktop_name}"));
		-- Workspace name
	local workspace_num=tostring(conky_parse("$desktop"));
		-- Workspace number
	
	if work_num ~= nil then
		workspace_num=work_num;
	end
	
	cairo_set_line_width (cr,st['width']);
	
	cairo_set_line_cap  (cr, CAIRO_LINE_CAP_BUTT);
	cairo_set_source_rgba (cr,rgb_to_r_g_b(st['background'],st['background_alpha']));
	cairo_move_to (cr,xPos,yPos);
	if setting_table[1]['position']=="top" or setting_table[1]['position']=="bottom" then
		cairo_rel_line_to (cr,lenght,0);
	else
		cairo_rel_line_to (cr,0,lenght);
	end
	cairo_stroke(cr);-- Draw object on surface
	
	--Text
	---------------------------
	if setting_table[1]['position']=="top" or setting_table[1]['position']=="bottom" then
		if st['text_type']=="name" then
			displayText(xPos+5,yPos+(st['width']/4)+1,"Liberation Sans Bold",st['width']-2,st['text'],st['text_alpha'],workspace);
		elseif st['text_type']=="number" then
			displayText(xPos+5,yPos+(st['width']/4)+1,"Liberation Sans Bold",st['width']-2,st['text'],st['text_alpha'],workspace_num..".");
		elseif st['text_type']=="both" then
			displayText(xPos+5,yPos+(st['width']/4)+1,"Liberation Sans Bold",st['width']-2,st['text'],st['text_alpha'],workspace_num..".  "..workspace);
		end
	end
end

function displayText(xPos,yPos,font,font_size,color,alpha,text)

		font_slant=CAIRO_FONT_SLANT_NORMAL;
		font_face=CAIRO_FONT_WEIGHT_NORMAL;
		----------------------------------
		cairo_select_font_face (cr, font, font_slant, font_face);
		cairo_set_font_size (cr, font_size);
		cairo_set_source_rgba (cr,rgb_to_r_g_b(color,alpha));
		cairo_move_to (cr,xPos,yPos);
		cairo_show_text (cr,text);
		cairo_stroke (cr);
end

function rgb_to_r_g_b(colour,alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha;
end

function conky_workbar_main()
	if conky_window == nil then
		return "Error";
	end
	
	local cs = cairo_xlib_surface_create(conky_window.display,
		conky_window.drawable, conky_window.visual,
		conky_window.width, conky_window.height);
	cr = cairo_create(cs);
	
	local updates=tonumber(conky_parse('${updates}'));
	
	if updates>2 then
		
		
		-- Variables
		local line_width=setting_table[1]['width'];
			-- Width of the workspace indicator
		local line_cap=CAIRO_LINE_CAP_BUTT;
			-- Style of the indicator
		local b_red,b_green,b_blue,b_alpha=rgb_to_r_g_b(setting_table[2]['background'],setting_table[2]['background_alpha']);
			-- Color of the whole bar
		local f_red,f_green,f_blue,f_alpha=rgb_to_r_g_b(setting_table[3]['background'],setting_table[3]['background_alpha']);
			-- Color of the workspace indicator
		local b_x,b_y,f_x,f_y,f_lenght;
			-- Miscellaneous positonning and workspace indicator width
		local workspace=tostring(conky_parse("${desktop_name}"));
			-- Workspace name
		local workspace_num=tostring(conky_parse("$desktop"));
			-- Workspace number
		local ctr=0;
		
		-- Data
		----------------------------
		if setting_table[1]['position']=="top" then
			b_x=0;
			f_lenght=tonumber(conky_window.width/conky_parse("${desktop_number}"));
			b_y=((line_width/2)+2);
			f_x=(conky_parse("${desktop}")*f_lenght)-f_lenght;
			f_y=b_y;
		elseif setting_table[1]['position']=="bottom" then
			b_x=0;
			f_lenght=tonumber(conky_window.width/conky_parse("${desktop_number}"));
			b_y=conky_window.height-(line_width/2)-4;
			f_x=(conky_parse("${desktop}")*f_lenght)-f_lenght;
			f_y=b_y;
		elseif setting_table[1]['position']=="right" then
			b_y=0;
			f_lenght=tonumber(conky_window.height/conky_parse("${desktop_number}"));
			b_x=conky_window.width-((line_width/2)+4);
			f_y=(conky_parse("${desktop}")*f_lenght)-f_lenght;
			f_x=b_x;
		elseif setting_table[1]['position']=="left" then
			b_y=0;
			f_lenght=tonumber(conky_window.height/conky_parse("${desktop_number}"));
			b_x=(line_width/2)+2;
			f_y=(conky_parse("${desktop}")*f_lenght)-f_lenght;
			f_x=b_x;
		end
		----------------------------
		-- End Data
		
		
		-- Background
		----------------------------
		cairo_set_line_width (cr,line_width);
		cairo_set_line_cap  (cr, line_cap);
		cairo_set_source_rgba (cr,rgb_to_r_g_b(setting_table[1]['background'],setting_table[1]['alpha']));
		cairo_move_to (cr,b_x,b_y);
		if setting_table[1]['position']=="top" or setting_table[1]['position']=="bottom" then
			cairo_rel_line_to (cr,conky_window.width,0);
		else
			cairo_rel_line_to (cr,0,conky_window.height);
		end
		cairo_stroke(cr);-- Draw object on surface
		----------------------------
		-- End background
		
		
		-- Inactive workspace
		----------------------------
		while ctr<=tonumber(conky_parse("${desktop_number}")) do
			if setting_table[1]['position']=="top" or setting_table[1]['position']=="bottom" then
				w_x=(ctr*f_lenght)-f_lenght;
				w_y=f_y;
			elseif setting_table[1]['position']=="left" or setting_table[1]['position']=="right" then
				w_y=(conky_parse("${desktop}")*f_lenght)-f_lenght;
				w_x=f_x;
			end
			draw_workspace(w_x,w_y,f_lenght,setting_table[2],ctr);
			ctr=ctr+1;
		end
		----------------------------
		-- End inactive workspace
		
		
		-- Bottom bar
		----------------------------
		cairo_set_line_width (cr,2);
		cairo_set_line_cap  (cr, line_cap);
		cairo_set_source_rgba (cr,f_red,f_green,f_blue,f_alpha);
		
		if setting_table[1]['position']=="top" then
		
			cairo_move_to (cr,b_x,1);
			cairo_rel_line_to (cr,conky_window.width,0);
			
		elseif setting_table[1]['position']=="bottom" then
		
			cairo_move_to (cr,b_x,conky_window.height-3);
			cairo_rel_line_to (cr,conky_window.width,0);
			
		elseif setting_table[1]['position']=="right" then
			
			cairo_move_to (cr,conky_window.width-4,0);
			cairo_rel_line_to (cr,0,conky_window.height);
			
		elseif setting_table[1]['position']=="left" then
			
			cairo_move_to (cr,2,0);
			cairo_rel_line_to (cr,0,conky_window.height);
			
		end
		cairo_stroke(cr);-- Draw object on surface
		----------------------------
		-- End Bottom bar
		
		
		-- Active workspace
		----------------------------
		draw_workspace(f_x,f_y,f_lenght,setting_table[3]);
		----------------------------
		-- End Active Workspace
		
		
	end
	
	cairo_destroy(cr);
	cairo_surface_destroy(cs);
	cr=nil;
	
end
