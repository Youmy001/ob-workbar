--[[
	Conky ob-workbar by Youmy001
	A light workspace indicator bar for Openbox
	
	Features:
		- Automatically adjust to the actual number of workspace
		- The bar can the be placed on any side of the screen
		- Support tranparency
	
	Requires takao font
		sudo apt-get install ttf-takao
	
	
]]--
require 'cairo'

--====== Global settings table ===============================================--
-- Change these values to alter the appearance of your indicator bar
setting_table = {
	-- General setting sfor the whole bar
	{
		width=20,				-- This is the size of the bar in pixel. The higher it is
								-- thicker the bar will become.
		position='bottom'		-- This is the side on which the bar will be displayed.
								-- It can be either 'top', 'bottom', 'left' and 'right'.
		background='0x000000',	-- Color of the bar's background
		alpha=0,				-- Transparency of the background color
		inactive_text='none',	-- Shall the inactive workspace number and name be 
								-- printed ? It can be 'none', 'number', 'name' or 'both'.
								-- Not effective yet.
		active_text='both'		-- Shall the active workspace number and name be printed ?
								-- It can be 'none', 'number', 'name' or 'both'.
	},
	-- Inactive workspace settings
	{
		width=20,				-- Size of an inactive workspace in pixel. The higher it
								-- is, thicker the bar will become.
		rounded=false,			-- Shall the corners be rounded. Not effective yet.
		background='0x000000',	-- Color of the inactive workspace
		background_alpha=0,		-- Transparency of the background color
		text='0xFFFFFF',		-- Color of the text
		text_alpha=1			-- Transparency of the text
	},
	-- Active workspace settings
	{
		width=20,				-- Size of an inactive workspace in pixel. The higher it
								-- is, thicker the bar will become.
		rounded=false,			-- Shall the corners be rounded. Not effective yet.
		background='0x02FEFE',	-- Color of the inactive workspace
		background_alpha=1,		-- Transparency of the background color
		text='0x000000',		-- Color of the text
		text_alpha=1			-- Transparency of the text
	}
}



function draw_ring(cr,t,pt)--t=percentage, pt=setting_table
	local w,h=conky_window.width,conky_window.height

	local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
	local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

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



function draw_workspace_bar(ori,pos,width,bg_color,bg_alpha,fg_color,fg_alpha, option)
	-- Workspace bar
	-- ------------------
	-- Indicates which desktop is the active one.
	-- The bar is seperated into as many parts as workspaces. It can be
	-- positionned on each border of the conky surface.
	--
	-- To make the bar span the whole height or width of screen ensure
	-- the conky size fits your screen resolution.
	--
	-- The available option are name, number, both and none. 
	--
	-- Variables
	local line_width=width;
		-- Width of the workspace indicator
	local line_cap=CAIRO_LINE_CAP_BUTT;
		-- Style of the indicator
	local b_red,b_green,b_blue,b_alpha=rgb_to_r_g_b(bg_color,bg_alpha);
		-- Color of the whole bar
	local f_red,f_green,f_blue,f_alpha=rgb_to_r_g_b(fg_color,fg_alpha);
		-- Color of the workspace indicator
	local b_x,b_y,f_x,f_y,f_lenght;
		-- Miscellaneous positonning and workspace indicator width
	local workspace=tostring(conky_parse("${desktop_name}"));
		-- Wokspace name
	local workspace_num=tostring(conky_parse("$desktop"));
	
	if ori=="h" then
		b_x=0;
		f_lenght=tonumber(conky_window.width/conky_parse("${desktop_number}"));
		if pos=="t" then
			b_y=(width/2);
		else
			b_y=conky_window.height-(width/2);
		end
		f_x=(conky_parse("${desktop}")*f_lenght)-f_lenght;
		f_y=b_y;
	elseif ori=="v" then
		b_y=0;
		f_lenght=tonumber(conky_window.height/conky_parse("${desktop_number}"));
		if pos=="r" then
			b_x=conky_window.width-(width/2);
		else
			b_x=(width/2);
		end
		f_y=(conky_parse("${desktop}")*f_lenght)-f_lenght;
		f_x=b_x;
	end
	
	-- Bottom bar(if position is bottom and orientation is horizontal)
	----------------------------
	if ori=="h" then
		cairo_set_line_width (cr,1);
		cairo_set_line_cap  (cr, line_cap);
		cairo_set_source_rgba (cr,f_red,f_green,f_blue,f_alpha);
		if pos=="t" then
			cairo_move_to (cr,b_x,1);
		else
			cairo_move_to (cr,b_x,conky_window.height-1);
		end
		cairo_rel_line_to (cr,conky_window.width,0);
		cairo_stroke(cr);-- Draw object on surface
	elseif ori=="v" then
		cairo_set_line_width (cr,1);
		cairo_set_line_cap  (cr, line_cap);
		cairo_set_source_rgba (cr,f_red,f_green,f_blue,f_alpha);
		if pos=="r" then
			cairo_move_to (cr,conky_window.width-2,0);
		else
			cairo_move_to (cr,1,0);
		end
		cairo_rel_line_to (cr,0,conky_window.height);
		cairo_stroke(cr);-- Draw object on surface
	end
	
	-- Background
	----------------------------
	cairo_set_line_width (cr,line_width);
	cairo_set_line_cap  (cr, line_cap);
	cairo_set_source_rgba (cr,b_red,b_green,b_blue,b_alpha);
	cairo_move_to (cr,b_x,b_y);
	if ori=="h" then
		cairo_rel_line_to (cr,conky_window.width,0);
	else
		cairo_rel_line_to (cr,0,conky_window.height);
	end
	cairo_stroke(cr);-- Draw object on surface
	
	-- Foreground
	----------------------------
	cairo_set_line_width (cr,line_width);
	cairo_set_line_cap  (cr, line_cap);
	cairo_set_source_rgba (cr,f_red,f_green,f_blue,f_alpha);
	cairo_move_to (cr,f_x,f_y);
	if ori=="h" then
		cairo_rel_line_to (cr,f_lenght,0);
	else
		cairo_rel_line_to (cr,0,f_lenght);
	end
	cairo_stroke(cr);-- Draw object on surface
	
	--Text
	----------------------------
	if ori=="h" then
		if option=="name" then
			displayText(f_x+5,f_y+(line_width/4)+1,"Liberation Sans Bold",line_width-2,bg_color,1,workspace);
		elseif option=="number" then
			displayText(f_x+5,f_y+(line_width/4)+1,"Liberation Sans Bold",line_width-2,bg_color,1,workspace_num..".")
		elseif option=="both" then
			displayText(f_x+5,f_y+(line_width/4)+1,"Liberation Sans Bold",line_width-2,bg_color,1,workspace_num..".  "..workspace)
		end
	end
	
end	-- End of draw_workspace_bar



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

function conky_main()
	if conky_window == nil then return end;
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height);
	cr = cairo_create(cs);
	
	local updates=tonumber(conky_parse('${updates}'));
	
	if updates>2 then
	
		-- Get data to display
		time_date=tostring(conky_parse("${time %Y年%m月%d日}"));
		time_time=tostring(conky_parse("${time %H時%M分%S秒}"));
		time_day=tostring(conky_parse("${time %a}"));
		workspace=tostring(conky_parse("${desktop_name}"));
		
		-- Print Time and date
		displayText(5,103,"takao gothic",120,0x02FEFE,1.0,time_day);
		displayText(125,70,"takao gothic",72,0xFFFFFF,1.0,time_date);
		displayText(128,107,"takao gothic",34,0xFFFFFF,1.0,time_time);
		
		displayText(1145,193,"Liberation Sans Bold",250,0x02FEFE,1.0,"#!");
		
		cairo_rotate (cr, -60*math.pi/180);
		
		displayText(-385,845,"takao gothic",32,0x02FEFE,1.0,"クランチバン");
		
		cairo_rotate (cr, 60*math.pi/180);
		
		draw_workspace_bar("h","b",20,0x000000,0,0x02FEFE,1,"both");
		
		
	end
	
	cairo_destroy(cr);
	cairo_surface_destroy(cs);
	cr=nil;
	
end
