# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

module AutomationLabsExportation

# Import packages
import PackageCompiler
import AutomationLabsDepot 
import DelimitedFiles

# Export methods
export proceed_controller_exportation

# Load files
include("controller_exportation.jl")

end
