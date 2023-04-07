# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

module AutomationLabsExportationController

import JLD2;
import AutomationLabsModelPredictiveControl;
import AutomationLabsSystems;
import DelimitedFiles;

function julia_main()::Cint
    try
        real_main()
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end

function real_main()
    
    @show ARGS
    @show Base.PROGRAM_FILE
    @show DEPOT_PATH
    @show DEPOT_PATH[begin]
    @show LOAD_PATH
    @show pwd()
    @show Base.active_project()
    @show Sys.BINDIR
    
    # Load the name of the controller and the system
    a = DEPOT_PATH[begin] * "/automationlabs" * "/" * "system_name.txt"
    @show a
    system_name = join(DelimitedFiles.readdlm(DEPOT_PATH[begin] * "/automationlabs" * "/" * "system_name.txt"));
    controller_name = join(DelimitedFiles.readdlm(DEPOT_PATH[begin] * "/automationlabs" * "/" * "controller_name.txt"));

    # Load the jld2 file of the controller saved
    #path_file = DEPOT_PATH[begin] * "/automationlabs" * "/controllers" *"/" * controller_name * ".jld2"
    path_file_controller = DEPOT_PATH[begin] * "/automationlabs" * "/" * controller_name * ".jld2"
    kws =  JLD2.load(path_file_controller, "controller");
    
    # Load the jld2 file of the system laod
    #path_file_system = DEPOT_PATH[begin] * "/automationlabs" * "/systems" *"/" * system_name * ".jld2"
    path_file_system = DEPOT_PATH[begin] * "/automationlabs" * "/" * system_name * ".jld2"
    system_loaded = JLD2.load(path_file_system, "system");

    # Tune the controller on AutomationLabsModelPredictiveControl
    predictive_controller = AutomationLabsModelPredictiveControl.proceed_controller(
        system_loaded,
        kws[:mpc_controller_type],
        kws[:mpc_horizon],
        kws[:mpc_sample_time],
        kws[:mpc_state_reference],
        kws[:mpc_input_reference];
        kws,
    );

    # Initialize the controller with the stats and inputs init and compute
    initialization = parse.(Float64, ARGS) #string to vector

    AutomationLabsModelPredictiveControl.update_initialization!(
        predictive_controller,
        initialization,
    );

    # Calculate the opimization x and u
    AutomationLabsModelPredictiveControl.calculate!(predictive_controller);

    # Retrieve the computed results 
    @show predictive_controller.computation_results.x
    @show predictive_controller.computation_results.e_x
    @show predictive_controller.computation_results.e_u
    @show predictive_controller.computation_results.u

    #Save txt the u_opt results
    DelimitedFiles.writedlm(DEPOT_PATH[begin] * "/automationlabs" * "/" * "u_opt.txt", predictive_controller.computation_results.u)
    DelimitedFiles.writedlm(DEPOT_PATH[begin] * "/automationlabs" * "/" * "x_opt.txt", predictive_controller.computation_results.x)
    DelimitedFiles.writedlm(DEPOT_PATH[begin] * "/automationlabs" * "/" * "e_u_opt.txt", predictive_controller.computation_results.e_u)
    DelimitedFiles.writedlm(DEPOT_PATH[begin] * "/automationlabs" * "/" * "e_x_opt.txt", predictive_controller.computation_results.e_x)

    # Return the u computed 
    return 0
end

end
