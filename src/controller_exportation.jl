# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

function proceed_controller_exportation(
    controller_name,
    system_name,
    project_name;
    kws_...
)

    # Get argument kws
    dict_kws = Dict{Symbol,Any}(kws_)
    kws = get(dict_kws, :kws, kws_)

    # System jld2 systems verification
    system_loaded = AutomationLabsDepot.load_system_local_folder_db(string(project_name), string(system_name))

    if system_loaded == nothing 
        @error "The system is not present in the database"
    end

    # Controller jld2 verification
    kws_controller = AutomationLabsDepot.load_controller_local_folder_db(project_name, controller_name)
    if kws_controller == nothing 
        @error "The controller is not present in the database"
    end

    # Compiled the controller with packagecompiler              
    path_module_export_controller = DEPOT_PATH[begin] * "/automationlabs" * "/" * "exportations" * "/" * "AutomationLabsExportationController/"
    path_export_controller = DEPOT_PATH[begin] * "/automationlabs" * "/" * "exportations" * "/" * controller_name * "/"

    PackageCompiler.create_app(path_module_export_controller, path_export_controller)

    # Write the name of the controller 
    mkdir(path_export_controller * "share" * "/" * "julia" * "/" *  "automationlabs")
    DelimitedFiles.writedlm(path_export_controller * "share" * "/" * "julia" * "/" *  "automationlabs" * "/" * "system_name.txt", system_name)
    DelimitedFiles.writedlm(path_export_controller * "share" * "/" * "julia" * "/" * "automationlabs" * "/" * "controller_name.txt", controller_name)

    # Copy the systems jld2 and controlelr jld2 on the share folder of the controller created
    path_system_automationlabs = DEPOT_PATH[begin] * "/automationlabs" * "/" * "systems" * "/" * system_name * ".jld2"
    path_controller_automationlabs = DEPOT_PATH[begin] * "/automationlabs" * "/" * "controllers" * "/" * controller_name * ".jld2"
    path_new_system = path_export_controller * "share" * "/" * "julia" * "/" * "automationlabs" * "/" * system_name * ".jld2"
    path_new_controller = path_export_controller * "share" * "/" * "julia" * "/" * "automationlabs" * "/" *controller_name * ".jld2"

    # Copy the system jld2 file
    cp(path_system_automationlabs, path_new_system)

    # Copy the controller jld2 file
    cp(path_controller_automationlabs, path_new_controller)

    return true
end
