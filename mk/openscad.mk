#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Scripted custom parts using OpenSCAD and _SolidPython.
#----------------------------------------------------------------------------
# Use MODEL_DIR on the make command line to specify which model to build.
# e.g. make MODEL_DIR=<model path>
ifeq (${MODEL_DIR},)
  # Where the CAD model resides.
  MODEL_DIR = ${MOD_DIR}/model
endif
# If the model directory doesn't exist then error or init.
ifeq ($(realpath ${MODEL_DIR}),)
  ifneq (${MAKECMDGOALS},osc-init)
    $(call signal-error,The model directory does not exist)
  endif
endif
$(info MODEL_DIR=${MODEL_DIR})

# Where tools are installed.
OSC_BIN_DIR = ${BIN_DIR}/openscad/${OPENSCAD_VARIANT}
# Included or imported files.
OSC_INC_DIR = ${MODEL_DIR}/inc
# 2D sketches.
OSC_DRAW_DIR = ${MODEL_DIR}/drawings
# Parts.
OSC_PART_DIR = ${MODEL_DIR}/parts
# Printable parts.
OSC_PRINT_DIR = ${MODEL_DIR}/prints
# Assemblies and subassemblies of printable pars.
OSC_ASM_DIR = ${MODEL_DIR}/assemblies
# Off the shelf components (downloaded from the net).
OSC_OTS_DIR = ${MODEL_DIR}/ots

# Output directories.
OSC_BUILD_DIR = ${MOD_BUILD_DIR}/model
OSC_DOC_DIR = ${MOD_STAGING_DIR}/doc
OSC_STL_DIR = ${MOD_STAGING_DIR}/stl
OSC_PNG_DIR = ${MOD_STAGING_DIR}/png

# Where common OpenSCAD libraries reside.
OSC_LIB_DIR = ${MK_DIR}/osc-lib

OPENSCAD_VARIANT = 2021.01-x86_64
OPENSCAD_APP = OpenSCAD-${OPENSCAD_VARIANT}.AppImage
ifeq (${Platform},Microsoft)
  OPENSCAD_BIN = squashfs-root/AppRun
else
  OPENSCAD_BIN = ${OPENSCAD_APP}
endif
OPENSCAD_URL = https://files.openscad.org/${OPENSCAD_APP}
OPENSCAD_GUI = ${OSC_BIN_DIR}/${OPENSCAD_APP}
OPENSCAD_CLI = ${OSC_BIN_DIR}/${OPENSCAD_BIN}
OPENSCADPATH = ${MODEL_DIR}:${OSC_LIB_DIR}

# MODEL_LIBS and MODEL_DEPS are optionally defined in model.mk.
include $(wildcard ${MODEL_DIR}/model.mk)
ModelDeps = ${MODEL_LIBS} ${MODEL_DEPS}

# OpenSCAD source files.
_sc_drawing_files = $(wildcard ${OSC_DRAW_DIR}/*.scad)
_sc_printable_files = $(wildcard ${OSC_PRINT_DIR}/*.scad)
_sc_assembly_files = $(wildcard ${OSC_ASM_DIR}/${ASM}*.scad)
_sc_model_files = \
  ${_sc_drawing_files} ${_sc_printable_files} ${_sc_assembly_files}

_sc_stl_files = $(foreach file, ${_sc_printable_files}, ${OSC_STL_DIR}/$(basename $(notdir $(file))).stl)
_sc_png_files = $(foreach file, ${_sc_model_files}, ${OSC_PNG_DIR}/$(basename $(notdir $(file))).png)

_printable_files = ${_sc_printable_files}
_model_files = ${_sc_model_files}

# _SolidPython source files.
_sp_parts_files = $(wildcard ${OSC_PART_DIR}/*.py)
_sp_drawing_files = $(wildcard ${OSC_DRAW_DIR}/*.py)
_sp_printable_files = $(wildcard ${OSC_PRINT_DIR}/*.py)
_sp_assembly_files = $(wildcard ${OSC_ASM_DIR}/${ASM}*.py)
_sp_import_files = $(wildcard ${OSC_INC_DIR}/*.py)
_sp_model_files = ${_sp_drawing_files} ${_sp_printable_files} ${_sp_assembly_files}

_sp_dep_files = $(foreach file, ${_sp_model_files}, ${OSC_BUILD_DIR}/$(basename $(notdir $(file))).pdeps)
_sp_stl_files = $(foreach file, ${_sp_printable_files}, ${OSC_STL_DIR}/$(basename $(notdir $(file))).stl)
ifneq (${Platform},Microsoft)
_sp_png_files = $(foreach file, ${_sp_model_files}, ${OSC_PNG_DIR}/$(basename $(notdir $(file))).png)
endif
_sp_scad_files = $(foreach file, ${_sp_stl_files}, ${OSC_BUILD_DIR}/$(notdir $(file)).scad)
_sp_doc_files = $(foreach file, \
  ${_sp_model_files} ${_sp_import_files} ${_sp_parts_files}, \
  ${OSC_DOC_DIR}/$(basename $(notdir $(file))).md)

_printable_files += ${_sp_printable_files}
_model_files += ${_sp_model_files}

AllModelDeps = \
  ${OPENSCAD_CLI} \
  ${ModelDeps} \
  ${_sc_stl_files} \
  ${_sc_png_files} \
  ${_sp_stl_files} \
  ${_sp_png_files} \
  ${_sp_doc_files}

osc-all: ${AllModelDeps}

# Only the parts files.
parts: ${_sc_stl_files} ${_sp_stl_files}

#+
# If python files are present then assume SolidPython in a virtual Platform
# is needed.
#-
$(info Using SolidPython)

_SolidPythonPath = ${MODEL_DIR}:${OSC_LIB_DIR}

#+
# Python virtual Platform requirements.
#-
SP_PYTHON_VARIANT = 3.8
SP_VIRTUAL_ENV_DIR = ${OSC_BIN_DIR}/_sp_venv

_SpPythonEnvFile = ${MODEL_DIR}/.env

_SpVenvPackageDir = ${SP_VIRTUAL_ENV_DIR}/lib/python${SP_PYTHON_VARIANT}/site-packages

_VenvRequirements = \
  ${_SpVenvPackageDir}/ptvsd/__init__.py \
  ${_SpVenvPackageDir}/flake8/__init__.py \
  ${_SpVenvPackageDir}/pdoc/__init__.py \
  ${_SpVenvPackageDir}/configparser.py \
  ${_SpVenvPackageDir}/configobj.py \
  ${_SpVenvPackageDir}/cmd2/cmd2.py \
  ${_SpVenvPackageDir}/numpy/__init__.py

${SP_VIRTUAL_ENV_DIR}/bin/python3:
> python3 -m venv --copies ${SP_VIRTUAL_ENV_DIR}

define _SpInstallPythonPackage =
$(info ++++++++++++)
$(info _SpInstallPythonPackage $1)
> ( \
    . ${SP_VIRTUAL_ENV_DIR}/bin/activate; \
    pip3 install $1; \
  )
endef

${_SpVenvPackageDir}/ptvsd/__init__.py:
> $(call _SpInstallPythonPackage, ptvsd)

${_SpVenvPackageDir}/flake8/__init__.py:
> $(call _SpInstallPythonPackage, flake8)

${_SpVenvPackageDir}/pdoc/__init__.py:
> $(call _SpInstallPythonPackage, pdoc3)

${_SpVenvPackageDir}/configparser.py:
> $(call _SpInstallPythonPackage, configparser)

${_SpVenvPackageDir}/configobj.py:
> $(call _SpInstallPythonPackage, configobj)

${_SpVenvPackageDir}/cmd2/cmd2.py:
> $(call _SpInstallPythonPackage, cmd2)

${_SpVenvPackageDir}/numpy/__init__.py:
> $(call _SpInstallPythonPackage, numpy)

_SolidPython = ${_SpVenvPackageDir}/solid/__init__.py
${_SolidPython}: \
  ${SP_VIRTUAL_ENV_DIR}/bin/python3 \
  ${_VenvRequirements}
> $(call _SpInstallPythonPackage, solidpython)

${_SpPythonEnvFile}:
> echo "PYTHONPATH=${_SolidPythonPath}" > ${_SpPythonEnvFile}

solid-python: ${_SolidPython} ${_SpPythonEnvFile}
> ( \
  . ${SP_VIRTUAL_ENV_DIR}/bin/activate; \
  cd ${MODEL_DIR}; \
  OPENSCADPATH=${OPENSCADPATH} \
  PYTHONPATH=${_SolidPythonPath} python; \
  deactivate; \
  )

_PDoc = \
 . ${SP_VIRTUAL_ENV_DIR}/bin/activate; \
  cd ${MODEL_DIR}; \
  python -B -m pdoc --force -o $(dir $@) $<; \
  deactivate

_stl_files = $(foreach file, ${_printable_files}, \
  ${OSC_STL_DIR}/$(basename $(notdir $(file))).stl)
ifneq (${Platform},Microsoft)
_png_files = $(foreach file, ${_model_files}, \
  ${OSC_PNG_DIR}/$(basename $(notdir $(file))).png)
endif

$(info OpenSCAD libraries:)
$(info $(wildcard ${OSC_LIB_DIR}/*.mk))

include $(wildcard ${OSC_LIB_DIR}/*.mk)

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

osc-gui: ${OPENSCAD_GUI} ${ModelDeps} ${_stl_files} ${_sp_scad_files}
>  OPENSCADPATH=${OPENSCADPATH} ${OPENSCAD_CLI} \
>  ${_sc_model_files} ${_sp_scad_files} &
>  @echo "${OPENSCAD_CLI} started and has process ID: `pidof ${OPENSCAD_CLI}`"
else
osc-gui:
> $(call signal-error,Cannot run the OpenSCAD GUI in a WSL Platform.)
endif

osc-docs: ${_SolidPython} ${_sp_doc_files}

ifeq (${MAKECMDGOALS},osc-init)
$(info Initializing: ${MODEL_DIR})

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
> mkdir ${MODEL_DIR}
> @echo "# Model dependencies." > ${MODEL_DIR}/model.mk
> @echo "$$ModelReadMe" > ${MODEL_DIR}/README.md
endif

osc-clean:
> rm -rf ${OSC_BUILD_DIR}

OPENSCAD_STL = OPENSCADPATH=${OPENSCADPATH} \
  ${OPENSCAD_CLI} -m ${MAKE} -o ${OSC_STL_DIR}/$(notdir $@) \
  -d ${OSC_BUILD_DIR}/$(notdir $@).deps $<

OPENSCAD_PNG = OPENSCADPATH=${OPENSCADPATH} \
  ${OPENSCAD_CLI} -m ${MAKE} -o ${OSC_PNG_DIR}/$(notdir $@) \
  -d ${OSC_BUILD_DIR}/$(notdir $@).deps $<

_SolidPython_STL = \
  . ${SP_VIRTUAL_ENV_DIR}/bin/activate; \
  cd ${MODEL_DIR} && \
  OPENSCADPATH=${OPENSCADPATH} \
  PYTHONPATH=${_SolidPythonPath} \
  python -B $< ${OSC_BUILD_DIR}/$(notdir $@).scad && \
  deactivate && \
  ${OPENSCAD_CLI} -m ${MAKE} -o ${OSC_STL_DIR}/$(notdir $@) \
  -d ${OSC_BUILD_DIR}/$(notdir $@).deps ${OSC_BUILD_DIR}/$(notdir $@).scad

_SolidPython_PNG = \
  . ${SP_VIRTUAL_ENV_DIR}/bin/activate; \
  cd ${MODEL_DIR} && \
  OPENSCADPATH=${OPENSCADPATH} \
  PYTHONPATH=${_SolidPythonPath} \
  python -B $< ${OSC_BUILD_DIR}/$(notdir $@).scad && \
  deactivate && \
  ${OPENSCAD_CLI} -m ${MAKE} -o ${OSC_PNG_DIR}/$(notdir $@) \
    -d ${OSC_BUILD_DIR}/$(notdir $@).deps \
    ${OSC_BUILD_DIR}/$(notdir $@).scad

_PDeps = \
  . ${SP_VIRTUAL_ENV_DIR}/bin/activate; \
  cd ${MODEL_DIR} && \
  PYTHONPATH=${_SolidPythonPath} \
  python -B ${HELPERS_DIR}/pdeps.py $< > $@ && \
  deactivate

include $(wildcard ${OSC_BUILD_DIR}/*.deps)
# This will cause make to run the utility to generate the dependencies.
-include ${_sp_dep_files}

# Drawings
ifneq (${MAKECMDGOALS},clean)
ifneq (${MAKECMDGOALS},help)
$(info Defining pattern rules)
${OSC_PNG_DIR}/%.png: ${OSC_DRAW_DIR}/%.scad
> mkdir -p ${OSC_BUILD_DIR}
> mkdir -p $(dir $@)
> ${OPENSCAD_PNG}

# 3D printables
${OSC_STL_DIR}/%.stl: ${OSC_PRINT_DIR}/%.scad
> mkdir -p ${OSC_BUILD_DIR}
> mkdir -p $(dir $@)
> ${OPENSCAD_STL}

${OSC_PNG_DIR}/%.png: ${OSC_PRINT_DIR}/%.scad
> mkdir -p ${OSC_BUILD_DIR}
> mkdir -p $(dir $@)
> ${OPENSCAD_PNG}

# Assemblies
${OSC_STL_DIR}/%.stl: ${OSC_ASM_DIR}/%.scad
> mkdir -p ${OSC_BUILD_DIR}
> mkdir -p $(dir $@)
> ${OPENSCAD_STL}

${OSC_PNG_DIR}/%.png: ${OSC_ASM_DIR}/%.scad
> mkdir -p ${OSC_BUILD_DIR}
> mkdir -p $(dir $@)
> ${OPENSCAD_PNG}

# For _SolidPython intermediates and docs.

# Dependencies
${OSC_BUILD_DIR}/%.pdeps: \
  ${OSC_DRAW_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDeps}

${OSC_BUILD_DIR}/%.pdeps: \
  ${OSC_PRINT_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDeps}

${OSC_BUILD_DIR}/%.pdeps: \
  ${OSC_ASM_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDeps}

# Drawings.
${OSC_PNG_DIR}/%.png: \
  ${OSC_DRAW_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p ${OSC_BUILD_DIR}
> mkdir -p $(dir $@)
> ${_SolidPython_PNG}

# 3D printables.
${OSC_STL_DIR}/%.stl: \
  ${OSC_PRINT_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p ${OSC_BUILD_DIR}
> mkdir -p $(dir $@)
> ${_SolidPython_STL}

${OSC_PNG_DIR}/%.png: \
  ${OSC_PRINT_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p ${OSC_BUILD_DIR}
> mkdir -p $(dir $@)
> ${_SolidPython_PNG}

# Assemblies.
${OSC_STL_DIR}/%.stl: \
  ${OSC_ASM_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p ${OSC_BUILD_DIR}
> mkdir -p $(dir $@)
> ${_SolidPython_STL}

${OSC_PNG_DIR}/%.png: \
  ${OSC_ASM_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p ${OSC_BUILD_DIR}
> mkdir -p $(dir $@)
> ${_SolidPython_PNG}

# Generated docs.
${OSC_DOC_DIR}/%.md: \
  ${OSC_INC_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDoc}

${OSC_DOC_DIR}/%.md: \
  ${OSC_DRAW_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDoc}

${OSC_DOC_DIR}/%.md: \
  ${OSC_PART_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDoc}

${OSC_DOC_DIR}/%.md: \
  ${OSC_PRINT_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDoc}

${OSC_DOC_DIR}/%.md: \
  ${OSC_ASM_DIR}/%.py ${_SolidPython} ${_SpPythonEnvFile}
> mkdir -p $(dir $@)
> ${_PDoc}

endif
endif

ifeq (${MAKECMDGOALS},help-openscad)
define HelpOpenSCADMsg
Make segment: openscad.mk

OpenSCAD and _SolidPython are used to generate STL files from scripts which
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
  solid-python  Install _SolidPython an a Python virtual environment and
                start an interactive python session.
  help-openscad Display this help message (default).
  help-model    Display the model specific help.

Optionally defined in mod.mk or on the command line:
  MODEL_DIR = ${MODEL_DIR}
    The directory where the model is located.
    This defaults to:
      ${MOD_DIR}/model
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
  OSC_BIN_DIR = ${OSC_BIN_DIR}
    Where the OpenSCAD binaries and the _SolidPython virtual environment are
    installed.
  AllModelDeps = (use show-ModelDeps to display)
    The all model dependencies for the complete make.

  Standard model directories:
  OSC_INC_DIR = ${OSC_INC_DIR}
    Included by model scripts.
  OSC_DRAW_DIR = ${OSC_DRAW_DIR}
    Scripts describing drawings.
  OSC_PART_DIR = ${OSC_PART_DIR}
    Scripts describing individual parts.
  OSC_PRINT_DIR = ${OSC_PRINT_DIR}
    Scripts used to generate STLs from parts.
  OSC_ASM_DIR = ${OSC_ASM_DIR}
    Assemblies of parts. These scripts show parts in relationship to each
    other.
  OSC_OTS_DIR = ${OSC_OTS_DIR}
    Off the shelf parts. These are typically downloaded from the net in STL
    form but can also be scripts.
  OSC_LIB_DIR = ${OSC_LIB_DIR}
    OpenSCAD or _SolidPython script libraries. Most are from openscad.org.

  Output directories;
  OSC_BUILD_DIR = ${OSC_BUILD_DIR}
    Where the build output is stored. This is typically the staging
    directory for the mod.
  OSC_DOC_DIR = ${OSC_DOC_DIR}
    Where generated doc files are stored.
  OSC_STL_DIR = ${OSC_STL_DIR}
    Where output stl files are stored.
  OSC_PNG_DIR = ${OSC_PNG_DIR}
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
  SP_PYTHON_VARIANT = ${SP_PYTHON_VARIANT}
    The version of Python to use for the _SolidPython virtual environment.
    This must be Python version 3.8 or later. _SolidPython itself is
    installed using pip3.
  SP_VIRTUAL_ENV_DIR = ${SP_VIRTUAL_ENV_DIR}
    Where to setup the Python virtual environemnt for _SolidPython.

endef
export HelpOpenSCADMsg
help-openscad:
> @echo "$$HelpOpenSCADMsg" | less
endif
