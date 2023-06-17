#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Scripted custom parts using OpenSCAD and Python CAD tools.
#----------------------------------------------------------------------------

#+
# TODO: Add MuSCAD https://gitlab.com/guillp/muscad
# TODO: Add AnchorSCAD https://github.com/owebeeone/anchorscad
#-

OPENSCAD_VARIANT = 2021.01-x86_64

# Use OSC_MODEL_PATH on the make command line to specify which model to build.
# e.g. make OSC_MODEL_PATH=<model path>
ifeq (${OSC_MODEL_PATH},)
  # Where the CAD model resides.
  OSC_MODEL_PATH = ${MODEL_PATH}/openscad
endif
# If the model directory doesn't exist then error or init.
ifeq ($(realpath ${OSC_MODEL_PATH}),)
  ifneq (${MAKECMDGOALS},osc-init)
    $(call signal-error,The model directory does not exist)
  endif
endif
$(info OSC_MODEL_PATH=${OSC_MODEL_PATH})

# Where tools are installed.
OSC_BIN_PATH = ${BIN_PATH}/openscad/${OPENSCAD_VARIANT}
# Included or imported files.
OSC_INC_PATH = ${OSC_MODEL_PATH}/inc
# 2D sketches.
OSC_DRAW_PATH = ${OSC_MODEL_PATH}/drawings
# Parts.
OSC_PART_PATH = ${OSC_MODEL_PATH}/parts
# Printable parts.
OSC_PRINT_PATH = ${OSC_MODEL_PATH}/prints
# Assemblies and subassemblies of printable parts.
OSC_ASM_PATH = ${OSC_MODEL_PATH}/assemblies
# Off the shelf components (downloaded from the net).
OSC_OTS_PATH = ${OSC_MODEL_PATH}/ots

# Output directories.
OSC_BUILD_PATH = ${MOD_BUILD_PATH}/model
OSC_DOC_PATH = ${MOD_STAGING_PATH}/doc
OSC_STL_PATH = ${MOD_STAGING_PATH}/stl
OSC_PNG_PATH = ${MOD_STAGING_PATH}/png

# Where common OpenSCAD libraries reside.
OSC_LIB_PATH = ${MK_PATH}/osc-lib

OPENSCAD_APP = OpenSCAD-${OPENSCAD_VARIANT}.AppImage
ifeq (${Platform},Microsoft)
  OPENSCAD_BIN = squashfs-root/AppRun
else
  OPENSCAD_BIN = ${OPENSCAD_APP}
endif
OPENSCAD_URL = https://files.openscad.org/${OPENSCAD_APP}
OPENSCAD_GUI = ${OSC_BIN_PATH}/${OPENSCAD_APP}
OPENSCAD_CLI = ${OSC_BIN_PATH}/${OPENSCAD_BIN}
OPENSCADPATH = ${OSC_MODEL_PATH}:${OSC_LIB_PATH}

# MODEL_LIBS and MODEL_DEPS are optionally defined in model.mk.
include $(wildcard ${OSC_MODEL_PATH}/model.mk)
ModelDeps = ${MODEL_LIBS} ${MODEL_DEPS}

# OpenSCAD source files.
_osc_drawing_files = $(wildcard ${OSC_DRAW_PATH}/*.scad)
_osc_printable_files = $(wildcard ${OSC_PRINT_PATH}/*.scad)
_osc_assembly_files = $(wildcard ${OSC_ASM_PATH}/${ASM}*.scad)
_osc_model_files = \
  ${_osc_drawing_files} ${_osc_printable_files} ${_osc_assembly_files}

_osc_stl_files = $(foreach file, ${_osc_printable_files}, ${OSC_STL_PATH}/$(basename $(notdir $(file))).stl)
_osc_png_files = $(foreach file, ${_osc_model_files}, ${OSC_PNG_PATH}/$(basename $(notdir $(file))).png)

_printable_files = ${_osc_printable_files}
_model_files = ${_osc_model_files}

# Python CAD tools source files.
_oscp_parts_files = $(wildcard ${OSC_PART_PATH}/*.py)
_oscp_drawing_files = $(wildcard ${OSC_DRAW_PATH}/*.py)
_oscp_printable_files = $(wildcard ${OSC_PRINT_PATH}/*.py)
_oscp_assembly_files = $(wildcard ${OSC_ASM_PATH}/${ASM}*.py)
_oscp_import_files = $(wildcard ${OSC_INC_PATH}/*.py)
_oscp_model_files = ${_oscp_drawing_files} ${_oscp_printable_files} ${_oscp_assembly_files}

_oscp_dep_files = $(foreach file, ${_oscp_model_files}, ${OSC_BUILD_PATH}/$(basename $(notdir $(file))).pdeps)
_oscp_stl_files = $(foreach file, ${_oscp_printable_files}, ${OSC_STL_PATH}/$(basename $(notdir $(file))).stl)
ifneq (${Platform},Microsoft)
_oscp_png_files = $(foreach file, ${_oscp_model_files}, ${OSC_PNG_PATH}/$(basename $(notdir $(file))).png)
endif
_oscp_scad_files = $(foreach file, ${_oscp_stl_files}, ${OSC_BUILD_PATH}/$(notdir $(file)).scad)
_oscp_doc_files = $(foreach file, \
  ${_oscp_model_files} ${_oscp_import_files} ${_oscp_parts_files}, \
  ${OSC_DOC_PATH}/$(basename $(notdir $(file))).md)

_printable_files += ${_oscp_printable_files}
_model_files += ${_oscp_model_files}

AllModelDeps = \
  ${OPENSCAD_CLI} \
  ${ModelDeps} \
  ${_osc_stl_files} \
  ${_osc_png_files} \
  ${_oscp_stl_files} \
  ${_oscp_png_files} \
  ${_oscp_doc_files}

osc-all: ${AllModelDeps}

# Only the parts files.
parts: ${_osc_stl_files} ${_oscp_stl_files}

#+
# If python files are present then assume Python CAD tools in a virtual Platform
# is needed.
#-
$(info Using Python CAD tools)

_OscPythonPath = ${OSC_MODEL_PATH}:${OSC_LIB_PATH}

#+
# Python virtual Platform requirements.
#-
OSCP_PYTHON_VARIANT = 3.8
OSCP_VIRTUAL_ENV_PATH = ${OSC_BIN_PATH}/_oscp_venv

_OscPython = ${OSCP_VIRTUAL_ENV_PATH}/bin/python3
_OscpRequirements = ${MK_PATH}/oscp_requirements.txt
_PythonRequirements = ${OSCP_VIRTUAL_ENV_PATH}/requiremets.txt
_OscPythonEnvFile = ${OSC_MODEL_PATH}/.env

_OscpVenvPackagePath = ${OSCP_VIRTUAL_ENV_PATH}/lib/python${OSCP_PYTHON_VARIANT}/site-packages

${_OscPython}:
> python3 -m venv --copies ${OSCP_VIRTUAL_ENV_PATH}

${_PythonRequirements}: ${_OscpRequirements} \
  ${_OscPython}
> ( \
    . ${OSCP_VIRTUAL_ENV_PATH}/bin/activate; \
    pip3 install -r $<; \
    pip3 freeze -l > $@; \
  )

${_OscPythonEnvFile}: ${_PythonRequirements}
> echo "PYTHONPATH=${_OscPythonPath}" > ${_OscPythonEnvFile}

osc-python: ${_OscPythonEnvFile}
> ( \
  . ${OSCP_VIRTUAL_ENV_PATH}/bin/activate; \
  cd ${OSC_MODEL_PATH}; \
  OPENSCADPATH=${OPENSCADPATH} \
  PYTHONPATH=${_OscPythonPath} python; \
  deactivate; \
  )

_PDoc = \
 . ${OSCP_VIRTUAL_ENV_PATH}/bin/activate; \
  cd ${OSC_MODEL_PATH}; \
  python -B -m pdoc --force -o $(dir $@) $<; \
  deactivate

_stl_files = $(foreach file, ${_printable_files}, \
  ${OSC_STL_PATH}/$(basename $(notdir $(file))).stl)
ifneq (${Platform},Microsoft)
_png_files = $(foreach file, ${_model_files}, \
  ${OSC_PNG_PATH}/$(basename $(notdir $(file))).png)
endif

$(info OpenSCAD libraries:)
$(info $(wildcard ${OSC_LIB_PATH}/*.mk))

include $(wildcard ${OSC_LIB_PATH}/*.mk)

# This assumes downloading an executable binary (e.g. Appimage).
${OPENSCAD_GUI}:
> wget -O $@ ${OPENSCAD_URL}
> touch $@
> chmod +x $@

ifeq (${Platform},Microsoft)
${OPENSCAD_CLI}: ${OPENSCAD_GUI}
> cd $(<D); \
> ${OPENSCAD_GUI} --appimage-extract
endif

osc-stl: ${OPENSCAD_CLI} ${ModelDeps} ${_stl_files}

# See if running in WSL. If so The OpenSCAD GUI can't be started without
# an X server running which is outside the scope of this project.
ifneq (${Platform},Microsoft)
osc-png: ${OPENSCAD_CLI} ${ModelDeps} ${_png_files}

osc-gui: ${OPENSCAD_GUI} ${ModelDeps} ${_stl_files} ${_oscp_scad_files}
>  OPENSCADPATH=${OPENSCADPATH} ${OPENSCAD_CLI} \
>  ${_osc_model_files} ${_oscp_scad_files} &
>  @echo "${OPENSCAD_CLI} started and has process ID: `pidof ${OPENSCAD_CLI}`"
else
osc-gui:
> $(call signal-error,Cannot run the OpenSCAD GUI in a WSL Platform.)
endif

osc-docs: ${_OscPython} ${_oscp_doc_files}

ifeq (${MAKECMDGOALS},osc-init)
$(info Initializing: ${OSC_MODEL_PATH})

define ModelReadMe
# Describe the model here.

Model...

## Recommended directory names.

- model.mk      Model dependencies.
- ots           Model specific off the shelf components.
- inc           File shared with model scripts.
- parts         Files describing parts used for prints and assemblies.
- prints        Files describing 3D printed parts.
- assemblies    Files describing assemblies of parts and their relationships.
- drawings      Files describing dimensioned drawings.
endef

# This will fail if the model already exists.
export ModelReadMe
osc-init:
> mkdir ${OSC_MODEL_PATH}
> @echo "# Model dependencies." > ${OSC_MODEL_PATH}/model.mk
> @echo "$$ModelReadMe" > ${OSC_MODEL_PATH}/README.md
endif

osc-clean:
> rm -rf ${OSC_BUILD_PATH}

OPENSCAD_STL = OPENSCADPATH=${OPENSCADPATH} \
  ${OPENSCAD_CLI} -m ${MAKE} -o ${OSC_STL_PATH}/$(notdir $@) \
  -d ${OSC_BUILD_PATH}/$(notdir $@).deps $<

OPENSCAD_PNG = OPENSCADPATH=${OPENSCADPATH} \
  ${OPENSCAD_CLI} -m ${MAKE} -o ${OSC_PNG_PATH}/$(notdir $@) \
  -d ${OSC_BUILD_PATH}/$(notdir $@).deps $<

_OscPython_STL = \
  . ${OSCP_VIRTUAL_ENV_PATH}/bin/activate; \
  cd ${OSC_MODEL_PATH} && \
  OPENSCADPATH=${OPENSCADPATH} \
  PYTHONPATH=${_OscPythonPath} \
  python -B $< ${OSC_BUILD_PATH}/$(notdir $@).scad && \
  deactivate && \
  ${OPENSCAD_CLI} -m ${MAKE} -o ${OSC_STL_PATH}/$(notdir $@) \
    -d ${OSC_BUILD_PATH}/$(notdir $@).deps \
    ${OSC_BUILD_PATH}/$(notdir $@).scad

_OscPython_PNG = \
  . ${OSCP_VIRTUAL_ENV_PATH}/bin/activate; \
  cd ${OSC_MODEL_PATH} && \
  OPENSCADPATH=${OPENSCADPATH} \
  PYTHONPATH=${_OscPythonPath} \
  python -B $< ${OSC_BUILD_PATH}/$(notdir $@).scad && \
  deactivate && \
  ${OPENSCAD_CLI} -m ${MAKE} -o ${OSC_PNG_PATH}/$(notdir $@) \
    -d ${OSC_BUILD_PATH}/$(notdir $@).deps \
    ${OSC_BUILD_PATH}/$(notdir $@).scad

_PDeps = \
  . ${OSCP_VIRTUAL_ENV_PATH}/bin/activate; \
  cd ${OSC_MODEL_PATH} && \
  PYTHONPATH=${_OscPythonPath} \
  python -B ${HELPERS_PATH}/pdeps.py $< > $@ && \
  deactivate

include $(wildcard ${OSC_BUILD_PATH}/*.deps)
# This will cause make to run the utility to generate the dependencies.
-include ${_oscp_dep_files}

# Drawings
ifneq (${MAKECMDGOALS},clean)
ifneq (${MAKECMDGOALS},help)
$(info Defining pattern rules)
${OSC_PNG_PATH}/%.png: ${OSC_DRAW_PATH}/%.scad
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${OPENSCAD_PNG}

# 3D printables
${OSC_STL_PATH}/%.stl: ${OSC_PRINT_PATH}/%.scad
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${OPENSCAD_STL}

${OSC_PNG_PATH}/%.png: ${OSC_PRINT_PATH}/%.scad
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${OPENSCAD_PNG}

# Assemblies
${OSC_STL_PATH}/%.stl: ${OSC_ASM_PATH}/%.scad
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${OPENSCAD_STL}

${OSC_PNG_PATH}/%.png: ${OSC_ASM_PATH}/%.scad
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${OPENSCAD_PNG}

# For _OscPython intermediates and docs.

# Dependencies
${OSC_BUILD_PATH}/%.pdeps: \
  ${OSC_DRAW_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDeps}

${OSC_BUILD_PATH}/%.pdeps: \
  ${OSC_PRINT_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDeps}

${OSC_BUILD_PATH}/%.pdeps: \
  ${OSC_ASM_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDeps}

# Drawings.
${OSC_PNG_PATH}/%.png: \
  ${OSC_DRAW_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${_OscPython_PNG}

# 3D printables.
${OSC_STL_PATH}/%.stl: \
  ${OSC_PRINT_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${_OscPython_STL}

${OSC_PNG_PATH}/%.png: \
  ${OSC_PRINT_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${_OscPython_PNG}

# Assemblies.
${OSC_STL_PATH}/%.stl: \
  ${OSC_ASM_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${_OscPython_STL}

${OSC_PNG_PATH}/%.png: \
  ${OSC_ASM_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${_OscPython_PNG}

# Generated docs.
${OSC_DOC_PATH}/%.md: \
  ${OSC_INC_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDoc}

${OSC_DOC_PATH}/%.md: \
  ${OSC_DRAW_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDoc}

${OSC_DOC_PATH}/%.md: \
  ${OSC_PART_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDoc}

${OSC_DOC_PATH}/%.md: \
  ${OSC_PRINT_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDoc}

${OSC_DOC_PATH}/%.md: \
  ${OSC_ASM_PATH}/%.py ${_OscPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDoc}

endif
endif

ifeq (${MAKECMDGOALS},help-openscad)
define HelpOpenSCADMsg
Make segment: openscad.mk

OpenSCAD and Python CAD tools are used to generate STL files from scripts which
describe custom parts for a mod. These can also be used to modify existing
off the shelf STL files.

Possible targets:
  osc-all       All assembly files are processed and .stl and .png files
                produced.
  osc-stl       Only the stl files are generated.
  osc-png       Only the png files are generated. Not available in WSL.
  osc-gui       Run the OpenSCAD GUI for each of the assembly files.
                Not available in WSL.
  osc-init      Initialize a new model directory. This creates a git
                repository in the models directory.
  osc-docs      Generate documentation from model files.
  osc-clean     Remove the dependency files and the output files.
  <asmfile>.stl Use this target to process a single assembly file. NOTE: The
                ASM command line variable can also be used for this purpose.
  osc-python    Install OpenSCAD Python scripting tools in a Python virtual
                environment and start an interactive Python session.
  help-openscad Display this help message (default).
  help-model    Display the model specific help.

Optionally defined in mod.mk or on the command line:
  OSC_MODEL_PATH = ${OSC_MODEL_PATH}
    The directory where the model is located.
    This defaults to:
      ${MOD_PATH}/model
  ASM = ${ASM}
    This is the assembly prefix. The assemblies directory is scanned for
    files having this prefix and only those files are processed. This
    defaults to all Python files in the assembly directory.
  OSC_TARGET = ${OSC_TARGET}
    A single target or a custom model specific target.

Defined by the model in model.mk:
  MODEL_DEPS = ${MODEL_DEPS}
    Model specific dependencies. This is most often used to trigger download
    of off the shelf parts but can be used for other model defined
    dependencies.
  MODEL_LIBS = ${MODEL_LIBS}
    OpenSCAD libraries used by the model.

Defines:
  OSC_BIN_PATH = ${OSC_BIN_PATH}
    Where the OpenSCAD binaries.
  AllModelDeps = (use show-ModelDeps to display)
    The all model dependencies for the complete make.

  Standard model directories:
  OSC_INC_PATH = ${OSC_INC_PATH}
    Included by model scripts.
  OSC_DRAW_PATH = ${OSC_DRAW_PATH}
    Scripts describing drawings.
  OSC_PART_PATH = ${OSC_PART_PATH}
    Scripts describing individual parts.
  OSC_PRINT_PATH = ${OSC_PRINT_PATH}
    Scripts used to generate STLs from parts.
  OSC_ASM_PATH = ${OSC_ASM_PATH}
    Assemblies of parts. These scripts show parts in relationship to each
    other.
  OSC_OTS_PATH = ${OSC_OTS_PATH}
    Off the shelf parts. These are typically downloaded from the net in STL
    form but can also be scripts.
  OSC_LIB_PATH = ${OSC_LIB_PATH}
    OpenSCAD or Python CAD tools script libraries. Most are from openscad.org.

  Output directories;
  OSC_BUILD_PATH = ${OSC_BUILD_PATH}
    Where the build output is stored. This is typically the staging
    directory for the mod.
  OSC_DOC_PATH = ${OSC_DOC_PATH}
    Where generated doc files are stored.
  OSC_STL_PATH = ${OSC_STL_PATH}
    Where output stl files are stored.
  OSC_PNG_PATH = ${OSC_PNG_PATH}
    Where generated images are stored. These are useful for documentation
    and web sites.

  Configuration:
  OPENSCAD_VARIANT = ${OPENSCAD_VARIANT}
    The version or variant of OpenSCAD to install.
  OPENSCAD_APP = ${OPENSCAD_APP}
    The executable binary. This is typically an AppImage.
  OPENSCAD_BIN = ${OPENSCAD_BIN}
    The OpenSCAD binary used to process scripts. This is normally platform
    dependent.
  OPENSCAD_URL = ${OPENSCAD_URL}
    The URL to use to download the OpenSCAD app.
  OPENSCAD_CLI = ${OPENSCAD_CLI}
    The command line interface for OpenSCAD.
  OPENSCAD_GUI = ${OPENSCAD_GUI}
    The OpenSCAD GUI interface. This is used to display parts.
  OPENSCADPATH = ${OPENSCADPATH}
    This is used on the OpenSCAD command line to set the search paths for
    the model or included libraries.
  OSCP_PYTHON_VARIANT = ${OSCP_PYTHON_VARIANT}
    The version of Python to use for the Python CAD tools virtual environment.
    This must be Python version 3.8 or later. The Python CAD tools are
    installed using pip3.
  OSCP_VIRTUAL_ENV_PATH = ${OSCP_VIRTUAL_ENV_PATH}
    Where to setup the Python virtual environemnt for Python CAD tools.

endef
export HelpOpenSCADMsg
help-openscad:
> @echo "$$HelpOpenSCADMsg" | less
endif
