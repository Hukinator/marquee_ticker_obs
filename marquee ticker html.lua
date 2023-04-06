obs = obslua

-- marquee like news ticker for election data

-- begin obs variables
source_name       = ""
directory_name    = ""
file_name         = "/ticker.html"
text_input        = ""
css               = " "
css_font_size     = 20
css_font_face     = ""
css_font_style    = ""
css_rgba          = ""
text_rgb          = ""
is_stonks         = false
setting_global    = ""

-- end obs variables

-- begin internal variables
html              = ""
color_green       = ""
color_red         = ""
font_end          = ""
font_open         = false
temp              = ""
end_of_text       = 0
i                 = 0

--end internal variables


-- begin user variable
default_path      = "C:\\"
-- end user variable

-- function courtesy Bart Kiers
function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function file_write(file, text)
    local f = io.open(file, "w")
    -- print(text)
    if f then
        f:write(text)
        f:close()
    end
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_path(props, "file_name", "Save Location", obs.OBS_PATH_DIRECTORY, "Folder", default_path)

    -- Drop-down list of sources
    local list_property = obs.obs_properties_add_list(props, "source_name", "Source name",
    obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_STRING)
    populate_list_property_with_source_names(list_property)

    --  properties for text customisation
    obs.obs_properties_add_bool(props, "stonks", "Stock mode")
    obs.obs_properties_add_font(props, "font", "Font")
    obs.obs_properties_add_color_alpha(props, "color", "background color")
    obs.obs_properties_add_color(props, "text_color", "Text color")
    obs.obs_properties_add_text(props, "text", "Text", obs.OBS_TEXT_MULTILINE)
    obs.obs_properties_add_button(props, "update", "update settings", update_browser_source)


    return props
end
-- fills the list with the obs sources
function populate_list_property_with_source_names(list_property)
    local sources = obs.obs_enum_sources()
    obs.obs_property_list_clear(list_property)
    obs.obs_property_list_add_string(list_property, "", "")
    for _,source in pairs(sources) do
        local name = obs.obs_source_get_name(source)
        obs.obs_property_list_add_string(list_property, name, name)
    end
    obs.source_list_release(sources)
end

function script_defaults(settings)
    obs.obs_data_set_bool(settings, "stonks", false)
    obs.obs_data_set_string(settings, "text", "Your text here")
    obs.obs_data_set_int(settings, "color", 2147549441)
    obs.obs_data_set_int(settings, "text_color", 4294967295)
    obs.obs_data_set_string(settings, "source_name", " ")
end

function reset()

end

-- function to insert a string inside of another one
-- thanks to lhf
-- https://stackoverflow.com/a/59561933/20703243
function string.insert(str1, str2, pos)
    return str1:sub(1,pos) .. str2 .. str1:sub(pos+1)
end

function script_description()
    return "Creates a news style ticker. \n\nPress the update settings button to update the browser source. If it's not updating refresh the browser cache of the current page. Author: Hauke Mordhorst (See source for additional code acknowledgements)"
end
-- best way to not update browser source on every script_update when a button is pressed
function update_browser_source()
    print("updating browser source")

    is_stonks = obs.obs_data_get_bool(setting_global, "stonks")
    css = "body { background-color: rgba(" .. css_rgba .. "); margin: 0px; overflow: hidden;}"

    -- sanitizing text input
    text_input = obs.obs_data_get_string(setting_global, "text")
    text_input = string.gsub(text_input, "\n", "  ")
    -- print("original text input: " .. text_input)

    -- adding the green and red color for + and - with spans cause its the most straightforward way
    if is_stonks then
        repeat
            temp = text_input:sub(i, i)
            if (temp == "+" and font_open == false) then
                color_green = ("<span style = \"color:green; font-family:".. css_font_face .. ";font-size:" .. css_font_size .. "px;font-style:" .. css_font_style .. ";\">")
                -- print("color green is: " .. color_green)
                text_input = string.insert(text_input, color_green, (i-1))
                -- print("text green:  " .. text_input)
                font_open = true
            elseif (temp == "-" and font_open == false) then
                color_red = ("<span style = \"color:red; font-family:".. css_font_face .. ";font-size:" .. css_font_size .. "px;font-style:" .. css_font_style .. ";\">")
                -- print("color red is: " .. color_red)
                text_input = string.insert(text_input, color_red, (i-1))
                -- print("text red: " .. text_input)
                font_open = true
            elseif (temp == "%" and font_open) then
                font_end = ("</span>")
                text_input = string.insert(text_input, font_end, (i))
                -- print("text: " .. text_input)
                font_open =false
            end
            end_of_text = string.len(text_input)
            i = i+1

        until(i > end_of_text)
    end
    i = 0
    if (font_open) then
        font_end = ("</span>")
        -- print(text_input)
        text_input = string.insert(text_input, font_end, (i))
        font_open = false
    end

    html = ("<marquee style = \"color:rgba(" .. text_rgb .."); font-family: " .. css_font_face .. ";font-size:" .. css_font_size .. "px;font-style:" .. css_font_style .. ";\">" .. text_input .. "</marquee>")
    -- print("html output" .. html)
    directory_name = obs.obs_data_get_string(setting_global, "file_name")
    -- print("html output : ")
    file_write(directory_name .. file_name, html)
    print("saving html file to: " .. directory_name .. file_name)

    -- changing settings of selected browser source
    source_name = obs.obs_data_get_string(setting_global, "source_name")
    print("selected source: " .. source_name)
    local browser_source = obs.obs_get_source_by_name(source_name)
    local browser_source_settings = obs.obs_source_get_settings(browser_source)
    obs.obs_data_set_bool(browser_source_settings, "is_local_file", true)
    obs.obs_data_set_string(browser_source_settings, "local_file", (directory_name .. file_name))
    obs.obs_data_set_int(browser_source_settings, "width", 1920)
    obs.obs_data_set_int(browser_source_settings, "height", 96)
    obs.obs_data_set_int(browser_source_settings, "fps", 60)
    obs.obs_data_set_bool(browser_source_settings, "fps_custom", true)
    obs.obs_data_set_string(browser_source_settings, "css", css)
    -- updating the source
    obs.obs_source_update(browser_source, browser_source_settings)

    -- releasing the references

    obs.obs_data_release(data)
    obs.obs_source_release(browser)
end

function script_update(settings)
    setting_global = settings
    local color_int = obs.obs_data_get_int(settings, "color")
    obs.obs_data_set_int(settings, "color", color_int)
    local hex_code = string.format("%x", color_int)
    css_rgba = hex_to_rgba(hex_code)
    print("Background Color: " .. css_rgba)
    local color_int2 = obs.obs_data_get_int(settings, "text_color")
    obs.obs_data_set_int(settings, "text_color", color_int2)
    local hex_code2 = string.format("%x", color_int2)
    text_rgb = hex_to_rgba(hex_code2)
    print("text color: " .. text_rgb)
    local css_font = obs.obs_data_create
    css_font = obs.obs_data_get_obj(settings, "font")
    css_font_face = obs.obs_data_get_string(css_font, "face")
    css_font_style = obs.obs_data_get_string(css_font, "style")
    css_font_size = obs.obs_data_get_int(css_font, "size")
    print("font: " .. css_font_face)
    print("font Style: " .. css_font_style)
    print("font size: " .. css_font_size)
    obs.obs_data_release(css_font)
end

function script_save(settings)

end

-- converts the hex values with or without alpha to rgba (they are encoded in abgr cause why not... thx obs)
-- created by chatgpt and changed around some values cause abgr
function hex_to_rgba(hex_value)
    -- Remove any leading '#' characters
    hex_value = hex_value:gsub("#","")

    -- Convert hex string to rgba
    local r, g, b, a
    if #hex_value == 5 then
       hex_value = string.insert(hex_value, "0", 0)
    end
    if #hex_value == 8 then -- If hex has alpha value
        r = tonumber(hex_value:sub(7, 8), 16)
        g = tonumber(hex_value:sub(5, 6), 16)
        b = tonumber(hex_value:sub(3, 4), 16)
        -- print(b)
        a = tonumber(hex_value:sub(1, 2), 16) / 255
    else -- If hex does not have alpha value
        -- print(hex_value)
        r = tonumber(hex_value:sub(5, 6), 16)
        g = tonumber(hex_value:sub(3, 4), 16)
        b = tonumber(hex_value:sub(1, 2), 16)
        -- print(b)
        a = 1.0
    end

    -- Return rgba values as table
    return (r .. ", " .. g ..", " .. b .. ", " .. a)
end

-- just creating the settings object for later updating
function script_load(settings)
    setting_global = obs.obs_data_create
end
