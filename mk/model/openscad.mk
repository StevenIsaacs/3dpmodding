#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Scripted custom parts using OpenSCAD and Python CAD tools.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment)
# -----

#+
# TODO: Add MuSCAD https://gitlab.com/guillp/muscad
# TODO: Add AnchorSCAD https://github.com/owebeeone/anchorscad
#-

OPENSCAD_VERSION = 2021.01-x86_64

# Use OSC_MOD_MODEL_PATH on the make command line to specify which model to build.
# e.g. make OSC_MOD_MODEL_PATH=<model path>
ifeq (${OSC_MOD_MODEL_PATH},)
  # Where the CAD model resides.
  OSC_MOD_MODEL_PATH = ${MOD_MODEL_PATH}/openscad
endif
# If the model directory doesn't exist then error or init.
ifeq ($(realpath ${OSC_MOD_MODEL_PATH}),)
  ifneq ($(call Is-Goal,${oscSeg}-init),)
    $(call Signal-Error,The model directory does not exist)
  endif
endif
$(call Info,OSC_MOD_MODEL_PATH=${OSC_MOD_MODEL_PATH})

# Where tools are installed.
OSC_BIN_PATH = ${BIN_PATH}/openscad/${OPENSCAD_VERSION}
# Included or imported files.
OSC_INC_PATH = ${OSC_MOD_MODEL_PATH}/inc
# 2D sketches.
OSC_DRAW_PATH = ${OSC_MOD_MODEL_PATH}/drawings
# Parts.
OSC_PART_PATH = ${OSC_MOD_MODEL_PATH}/parts
# Printable parts.
OSC_PRINT_PATH = ${OSC_MOD_MODEL_PATH}/prints
# Assemblies and subassemblies of printable parts.
OSC_ASM_PATH = ${OSC_MOD_MODEL_PATH}/assemblies
# Off the shelf components (downloaded from the net).
OSC_OTS_PATH = ${OSC_MOD_MODEL_PATH}/ots

# Output directories.
OSC_BUILD_PATH = ${MOD_BUILD_PATH}/model
OSC_DOC_PATH = ${MOD_STAGING_PATH}/doc
OSC_STL_PATH = ${MOD_STAGING_PATH}/stl
OSC_PNG_PATH = ${MOD_STAGING_PATH}/png

# Where common OpenSCAD libraries reside.
OSC_LIB_PATH = ${MK_PATH}/${oscSeg}-lib

OPENSCAD_APP = OpenSCAD-${OPENSCAD_VERSION}.AppImage
ifeq (${Platform},Microsoft)
  OPENSCAD_BIN = squashfs-root/AppRun
else
  OPENSCAD_BIN = ${OPENSCAD_APP}
endif
OPENSCAD_URL = https://files.openscad.org/${OPENSCAD_APP}
OPENSCAD_GUI = ${OSC_BIN_PATH}/${OPENSCAD_APP}
OPENSCAD_CLI = ${OSC_BIN_PATH}/${OPENSCAD_BIN}
OPENSCADPATH = ${OSC_MOD_MODEL_PATH}:${OSC_LIB_PATH}

# MODEL_LIBS and MODEL_DEPS are optionally defined in model.mk.
include $(wildcard ${OSC_MOD_MODEL_PATH}/model.mk)
_osc_model_deps = ${MODEL_LIBS} ${MODEL_DEPS}

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

all_model_deps = \
  ${OPENSCAD_CLI} \
  ${_osc_model_deps} \
  ${_osc_stl_files} \
  ${_osc_png_files} \
  ${_oscp_stl_files} \
  ${_oscp_png_files} \
  ${_oscp_doc_files}

${oscSeg}-all: ${all_model_deps}

# Only the parts files.
parts: ${_osc_stl_files} ${_oscp_stl_files}

#+
# If python files are present then assume Python CAD tools in a virtual Python
# environment is needed.
#-
$(call Info,Using Python CAD tools)

_osc_python_path = ${OSC_MOD_MODEL_PATH}:${OSC_LIB_PATH}

#+
# Python virtual Platform requirements.
#-
OSCP_PYTHON_VERSION = 3.8
OSCP_VIRTUAL_ENV_PATH = ${OSC_BIN_PATH}/_oscp_venv

_osc_python = ${OSCP_VIRTUAL_ENV_PATH}/bin/python3
_osc_requirements = ${MK_PATH}/oscp_requirements.txt
_osc_python_requirements = ${OSCP_VIRTUAL_ENV_PATH}/requiremets.txt
_osc_python_env_file = ${OSC_MOD_MODEL_PATH}/.env

_oscp_venv_package_path = ${OSCP_VIRTUAL_ENV_PATH}/lib/python${OSCP_PYTHON_VERSION}/site-packages

${_osc_python}:
> python3 -m venv --copies ${OSCP_VIRTUAL_ENV_PATH}

${_osc_python_requirements}: ${_osc_requirements} \
  ${_osc_python}
> ( \
    . ${OSCP_VIRTUAL_ENV_PATH}/bin/activate; \
    pip3 install -r $<; \
    pip3 freeze -l > $@; \
  )

${_osc_python_env_file}: ${_osc_python_requirements}
> echo "PYTHONPATH=${_osc_python_path}" > ${_osc_python_env_file}

${oscSeg}-python: ${_osc_python_env_file}
> ( \
  . ${OSCP_VIRTUAL_ENV_PATH}/bin/activate; \
  cd ${OSC_MOD_MODEL_PATH}; \
  OPENSCADPATH=${OPENSCADPATH} \
  PYTHONPATH=${_osc_python_path} python; \
  deactivate; \
  )

_osc_pdoc = \
 . ${OSCP_VIRTUAL_ENV_PATH}/bin/activate; \
  cd ${OSC_MOD_MODEL_PATH}; \
  python -B -m pdoc --force -o $(dir $@) $<; \
  deactivate

_stl_files = $(foreach file, ${_printable_files}, \
  ${OSC_STL_PATH}/$(basename $(notdir $(file))).stl)
ifneq (${Platform},Microsoft)
_png_files = $(foreach file, ${_model_files}, \
  ${OSC_PNG_PATH}/$(basename $(notdir $(file))).png)
endif

$(call Info,OpenSCAD libraries:)
$(call Info,$(wildcard ${OSC_LIB_PATH}/*.mk))

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

${oscSeg}-stl: ${OPENSCAD_CLI} ${_osc_model_deps} ${_stl_files}

# See if running in WSL. If so The OpenSCAD GUI can't be started without
# an X server running which is outside the scope of this product.
ifneq (${Platform},Microsoft)
${oscSeg}-png: ${OPENSCAD_CLI} ${_osc_model_deps} ${_png_files}

${oscSeg}-gui: ${OPENSCAD_GUI} ${_osc_model_deps} ${_stl_files} ${_oscp_scad_files}
>  OPENSCADPATH=${OPENSCADPATH} ${OPENSCAD_CLI} \
>  ${_osc_model_files} ${_oscp_scad_files} &
>  @echo "${OPENSCAD_CLI} started and has process ID: `pidof ${OPENSCAD_CLI}`"
else
${oscSeg}-gui:
> $(call Signal-Error,Cannot run the OpenSCAD GUI in a WSL Platform.)
endif

${oscSeg}-docs: ${_osc_python} ${_oscp_doc_files}

ifeq (${MAKECMDGOALS},${oscSeg}-init)
$(call Info,Initializing: ${OSC_MOD_MODEL_PATH})

define _model_readme
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
export _model_readme
${oscSeg}-init:
> mkdir ${OSC_MOD_MODEL_PATH}
> @echo "# Model dependencies." > ${OSC_MOD_MODEL_PATH}/model.mk
> @echo "$$_model_readme" > ${OSC_MOD_MODEL_PATH}/README.md
endif

${oscSeg}-clean:
> rm -rf ${OSC_BUILD_PATH}

OPENSCAD_STL = OPENSCADPATH=${OPENSCADPATH} \
  ${OPENSCAD_CLI} -m ${MAKE} -o ${OSC_STL_PATH}/$(notdir $@) \
  -d ${OSC_BUILD_PATH}/$(notdir $@).deps $<

OPENSCAD_PNG = OPENSCADPATH=${OPENSCADPATH} \
  ${OPENSCAD_CLI} -m ${MAKE} -o ${OSC_PNG_PATH}/$(notdir $@) \
  -d ${OSC_BUILD_PATH}/$(notdir $@).deps $<

_osc_python_STL = \
  . ${OSCP_VIRTUAL_ENV_PATH}/bin/activate; \
  cd ${OSC_MOD_MODEL_PATH} && \
  OPENSCADPATH=${OPENSCADPATH} \
  PYTHONPATH=${_osc_python_path} \
  python -B $< ${OSC_BUILD_PATH}/$(notdir $@).scad && \
  deactivate && \
  ${OPENSCAD_CLI} -m ${MAKE} -o ${OSC_STL_PATH}/$(notdir $@) \
    -d ${OSC_BUILD_PATH}/$(notdir $@).deps \
    ${OSC_BUILD_PATH}/$(notdir $@).scad

_osc_python_PNG = \
  . ${OSCP_VIRTUAL_ENV_PATH}/bin/activate; \
  cd ${OSC_MOD_MODEL_PATH} && \
  OPENSCADPATH=${OPENSCADPATH} \
  PYTHONPATH=${_osc_python_path} \
  python -B $< ${OSC_BUILD_PATH}/$(notdir $@).scad && \
  deactivate && \
  ${OPENSCAD_CLI} -m ${MAKE} -o ${OSC_PNG_PATH}/$(notdir $@) \
    -d ${OSC_BUILD_PATH}/$(notdir $@).deps \
    ${OSC_BUILD_PATH}/$(notdir $@).scad

_osc_pdeps = \
  . ${OSCP_VIRTUAL_ENV_PATH}/bin/activate; \
  cd ${OSC_MOD_MODEL_PATH} && \
  PYTHONPATH=${_osc_python_path} \
  python -B ${HELPERS_PATH}/pdeps.py $< > $@ && \
  deactivate

include $(wildcard ${OSC_BUILD_PATH}/*.deps)
# This will cause make to run the utility to generate the dependencies.
-include ${_oscp_dep_files}

# Drawings
ifneq ($(call Is-Goal,clean),)
ifneq ($(call Is-Goal,help-${oscSeg},)
$(call Info,Defining pattern rules)
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

# For _osc_python intermediates and docs.

# Dependencies
${OSC_BUILD_PATH}/%.pdeps: \
  ${OSC_DRAW_PATH}/%.py ${_osc_python_env_file}
> mkdir -p $(dir $@)
> ${_osc_pdeps}

${OSC_BUILD_PATH}/%.pdeps: \
  ${OSC_PRINT_PATH}/%.py ${_osc_python_env_file}
> mkdir -p $(dir $@)
> ${_osc_pdeps}

${OSC_BUILD_PATH}/%.pdeps: \
  ${OSC_ASM_PATH}/%.py ${_osc_python_env_file}
> mkdir -p $(dir $@)
> ${_osc_pdeps}

# Drawings.
${OSC_PNG_PATH}/%.png: \
  ${OSC_DRAW_PATH}/%.py ${_osc_python_env_file}
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${_osc_python_PNG}

# 3D printables.
${OSC_STL_PATH}/%.stl: \
  ${OSC_PRINT_PATH}/%.py ${_osc_python_env_file}
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${_osc_python_STL}

${OSC_PNG_PATH}/%.png: \
  ${OSC_PRINT_PATH}/%.py ${_osc_python_env_file}
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${_osc_python_PNG}

# Assemblies.
${OSC_STL_PATH}/%.stl: \
  ${OSC_ASM_PATH}/%.py ${_osc_python_env_file}
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${_osc_python_STL}

${OSC_PNG_PATH}/%.png: \
  ${OSC_ASM_PATH}/%.py ${_osc_python_env_file}
> mkdir -p ${OSC_BUILD_PATH}
> mkdir -p $(dir $@)
> ${_osc_python_PNG}

# Generated docs.
${OSC_DOC_PATH}/%.md: \
  ${OSC_INC_PATH}/%.py ${_osc_python_env_file}
> mkdir -p $(dir $@)
> ${_osc_pdoc}

${OSC_DOC_PATH}/%.md: \
  ${OSC_DRAW_PATH}/%.py ${_osc_python_env_file}
> mkdir -p $(dir $@)
> ${_osc_pdoc}

${OSC_DOC_PATH}/%.md: \
  ${OSC_PART_PATH}/%.py ${_osc_python_env_file}
> mkdir -p $(dir $@)
> ${_osc_pdoc}

${OSC_DOC_PATH}/%.md: \
  ${OSC_PRINT_PATH}/%.py ${_osc_python_env_file}
> mkdir -p $(dir $@)
> ${_osc_pdoc}

${OSC_DOC_PATH}/%.md: \
  ${OSC_ASM_PATH}/%.py ${_osc_python_env_file}
> mkdir -p $(dir $@)
> ${_osc_pdoc}

endif
endif

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

OpenSCAD and Python CAD tools are used to generate STL files from scripts which
describe custom parts for a mod. These can also be used to modify existing
off the shelf STL files.

Optionally defined in mod.mk or on the command line:
  OSC_MOD_MODEL_PATH = ${OSC_MOD_MODEL_PATH}
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
  all_model_deps = (use show-_osc_model_deps to display)
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
  OPENSCAD_VERSION = ${OPENSCAD_VERSION}
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
  OSCP_PYTHON_VERSION = ${OSCP_PYTHON_VERSION}
    The version of Python to use for the Python CAD tools virtual environment.
    This must be Python version 3.8 or later. The Python CAD tools are
    installed using pip3.
  OSCP_VIRTUAL_ENV_PATH = ${OSCP_VIRTUAL_ENV_PATH}
    Where to setup the Python virtual environment for Python CAD tools.

Command line goals:
  ${oscSeg}-all
    All assembly files are processed and .stl and .png files produced.
  ${oscSeg}-stl
    Only the stl files are generated.
  ${oscSeg}-png
    Only the png files are generated. Not available in WSL.
  ${oscSeg}-gui
    Run the OpenSCAD GUI for each of the assembly files. Not available in WSL.
  ${oscSeg}-init
    Initialize a new model directory. This creates a git repository in the
    models directory.
  ${oscSeg}-docs
    Generate documentation from model files.
  ${oscSeg}-clean
    Remove the dependency files and the output files. <asmfile>.stl Use this
    target to process a single assembly file. NOTE: The ASM command line
    variable can also be used for this purpose.
  ${oscSeg}-python
    Install OpenSCAD Python scripting tools in a Python virtual environment
    and start an interactive Python session.
  help-model
    Display the model specific help.
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
