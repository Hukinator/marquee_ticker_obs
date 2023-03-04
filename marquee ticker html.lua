obs = obslua

-- marquee like news ticker for election data

-- begin obs variables
source_name       = ""
file_name         = ""
html              = ""
-- end obs variables

-- begin user variable
default_path      = "C:\\"
-- end user variable

-- function courtesy Bart Kiers

function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function file_write(file, html)
    local f = io.open(file, "w")
    if f ~= nil then
        f:write(html)
    end
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_path(props, "file_name", "Source File", obs.OBS_PATH_FILE, "Folder", default_path)
    obs.obs_properties_add_list(props, "Liste","Liste von Parteien", OBS_COMBO_TYPE_EDITABLE, OBS_COMBO_FORMAT_STRING)
    return props
end

function script_defaults(settings)

end

function reset()

end

function script_description()
    return "Creates a teletype-effect rotating file reader. \n\nAuthor: Phoebe Zeitler (See source for additional code acknowledgements)"
end

function script_update(settings)
    file_name = obs.obs_data_get_string(settings, "file_name")
    reset()
end

function script_load(settings)

end