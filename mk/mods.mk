#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load a mod -- the mod has already been handled.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,ModFW Mods.)
# -----

$(call Use-Segment,kits)

define _help
Make segment: ${Seg}.mk

A mod defines all of the tools and build procedures for a specific component.
Mods are always contained within a kit and are not available until the
containing kit has either been installed or created.

A mod is referenced using the kit name and the mod in a dot notation making
it possible for more than one kit to contain mods having the same name. A mod
reference is shown in the following sections as <kit>.<mod>. This is consistent
with a path since a mod directory is a subdirectory of a kit.
e.g. samplekit.samplemod references the kit samplekit and the mod samplemod.

NOTE: The <kit>.<mod> reference should be equal to $${<kit>.<mod>.SegUN} after loading the mod segment file which can be used as a sanity check.

WARNING: Because of a mod reference being a dot notation, kit and mod names
cannot contain dots. e.g. sample.kit.sample.mod will cause unpredictable
results.

If a mod is referenced but the kit containing the mod has not been installed
then the kit is installed.

All mods are child nodes of the containing kit node.

Like with projects and kits, mods are required to have a segment file.

Unlike projects and kits, a mod is NOT a repo.

Command line goals:
  help-<mod>
    Display the help message for a mod.
  help-${Seg}
    Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,mod-vars,Variables for managing mods.)

_var := this_mod
${_var} :=
define _help
${_var}
  The name of the current mod being used. The mod segment can use this
  variable to access mod attributes.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := mods
${_var} :=
define _help
${_var}
  The list of declared mods.
endef

_var := mod_prefixes
${_var} :=
define _help
${_var}
  The list of registered mod prefixes. This is used to avoid situations where
  multiple mods use the same prefix. Each prefix must be unique.
endef

_var := mod_ignored_nodes
${_var} := BUILD_DIR STAGING_DIR
define _help
${_var}
  These nodes are not part of the git repository and therefore are ignored using
  .gitignore.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := mod_node_names
${_var} := INC_DIR ${mod_ignored_nodes}
define _help
${_var}
  A mod is always contained within a kit which contains a number of mods. A kit
  also defines context for the mods within a kit. See help-modfw_structure for
  more information.

endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := mod_attributes
${_var} := goals kit mod prefixes seg_f
define _help
${_var}
  A mod is basically a tree node and has the same attributes as the node.

  Additional attributes:
  <kit>.<mod>.goals
    The list of goals for the mod.
  <kit>.<mod>.kit
    The kit name portion of the mod reference. This is also equal to the name
    of the mod parent node.
  <kit>.<mod>.mod
    The mod name portion of the mod reference.
  <kit>.<mod>.prefixes
    The list of registered prefixes for the mod. This is used to help make mod
    specific symbols unique without using lengthy <kit>.<mod> references. A mod
    prefix must be registered using register-mod-prefix in order to ensure
    prefixes do not conflict with other mods.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

$(call Add-Help-Section,mod-ref-macros,Macros for referencing mods.)

_macro := is-valid-mod-reference
define _help
${_macro}
  Returns a non-empty value if a mod reference is valid.
  Parameters:
    1 = <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),kit.mod=$(1))
  $(if $(word 3,$(subst ., ,$(1))),
    $(call Verbose,Reference $(1) is NOT a valid mod reference.)
  ,
    $(if $(word 2,$(subst ., ,$(1))),
      $(call Verbose,Reference $(1) is a valid mod reference.)
      yes
    ,
      $(call Verbose,Reference $(1) is NOT a valid mod reference.)
    )
  )
  $(call Exit-Macro)
)
endef

_macro := kit-name
define _help
${_macro}
  Returns the kit portion of a mod reference.
  Parameters:
    1 = <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(word 1,$(subst ., ,$(1)))

_macro := mod-name
define _help
${_macro}
  Returns the mod portion of a mod reference.
  Parameters:
    1 = <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(word 2,$(subst ., ,$(1)))

_macro := kit-path
define _help
${_macro}
  Returns the path of the node containing the kit which contains the mod.
  Parameters:
    1 = <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = ${${$(1).kit}.path}

_macro := mod-path
define _help
${_macro}
  Returns the path of the node containing the mod.
  Parameters:
    1 = <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = ${$(1).path}

$(call Add-Help-Section,mod-ifs,Macros for checking mod status.)

_macro := mod-is-declared
define _help
${_macro}
  Returns a non-empty value if the mod has been declared.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(if $(filter $(1),${mods}),1)

_macro := prefix-is-registered
define _help
${_macro}
  Returns a non-empty value if the mod prefix is already registered.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(if $(filter $(1),${mod_prefixes}),1)

_macro := mod-exists
define _help
${_macro}
  This returns a non-empty value if a node contains a makefile segment.
  Parameters:
    1 = The name of a previously declared mod. This should be a <kit>.<mod>
        reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(call node-exists,$(1))

_macro := is-modfw-mod
define _help
${_macro}
  Returns a non-empty value if the mod conforms to the ModFW pattern. A
  ModFW mod will always have a makefile segment having the same name as the
  mod and the repo.
  The mod is contained in a node of the same name. The makefile segment file
  will contain the same name to indicate it is customized for the mod.
  Parameters:
    1 = A <kit>.<mod> reference to a previously declared mod.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),kit.mod=$(1))
  $(if $(wildcard ${$(1).seg_f}),
    $(call Run,grep ${$(1).mod} ${$(1).seg_f},quiet)
    $(if ${Run_Rc},
      $(call Verbose,grep returned:${Run_Rc})
    ,
      $(call Verbose,Checking:${$(1).path}/.gitignore)
      $(if $(wildcard ${$(1).path}/.gitignore),
        $(call Verbose,File exists:${$(1).path}/.gitignore)
        1
      )
    )
  )
  $(call Exit-Macro)
)
endef

$(call Add-Help-Section,mod-decl,Macros for declaring mods.)

_macro := declare-mod
define _help
${_macro}
  Define the attributes of a mod. A mod must be declared before any other mod
  related macros can be used. The containing kit is also declared.
  Parameters:
    1 = The <kit>.<mod> reference to the mod.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),kit.mod=$(1) KITS_DIR=${KITS_DIR})

$(if $(call mod-is-declared,$(1)),
  $(call Attention,Mod $(1) has already been declared.)
,
  $(eval _valid := $(call is-valid-mod-reference,$(1)))
  $(if ${_valid},
    $(if $(call node-is-declared,$(1)),
      $(call Signal-Error,\
        A node having the mod name $(1) has already been declared.)
    ,
      $(eval _k := $(call kit-name,$(1)))
      $(eval _m := $(call mod-name,$(1)))
      $(if $(call kit-is-declared,${_k}),
        $(call Verbose,Using previously declared kit ${_k})
      ,
        $(call declare-kit,${_k})
      )
      $(if ${Errors},
        $(call Signal-Error,Declaration of kit ${_k} failed.)
      ,
        $(call Verbose,Declaring mod $(1).)
        $(eval $(1).kit := ${_k})
        $(eval $(1).mod := ${_m})
        $(eval $(1).prefixes :=)
        $(call Verbose,Kit=${_k} Mod:${_m})
        $(call declare-child-node,$(1),${_k}.${MODS_DIR},${_m})
        $(foreach _node,${mod_node_names},
          $(call declare-child-node,$(1).${${_node}},$(1),${${_node}})
        )
        $(eval $(1).goals := )
        $(eval $(1).seg_f := ${$(1).path}/${_m}.mk)
        $(call register-mod,$(1),$($(1).kit))
        $(eval mods += $(1))
      )
    )
  ,
    $(call Signal-Error,Mod $(1) is NOT a valid mod reference.)
  )
)

$(call Exit-Macro)
endef

_macro := undeclare-mod
define _help
${_macro}
  Remove a mod declaration. If undeclaring the mod results in the containing
  kit no longer having any declared mods then the kit is also undeclared.
  Parameters:
    1 = The <kit>.<mod> reference to the mod.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),mod=$(1))

$(if $(call mod-is-declared,$(1)),
  $(if $(call node-is-declared,$(1)),
    $(if $(call is-a-child-node,$(1)),
      $(if $(call kit-is-declared,${$(1).kit}),
        $(call unregister-mod,$(1),${$(1).kit})
        $(call undeclare-node-descendants,$(1))
        $(call undeclare-child-node,$(1))
        $(if $(call kit-has-declared-mods,${$(1).kit}),
          $(call Verbose,Kit ${$(1).kit} still has declared mods.)
        ,
          $(call Verbose,Undeclaring kit ${$(1).kit})
          $(call undeclare-kit,${$(1).kit})
        )
        $(foreach _att,${mod_attributes},
          $(eval undefine $(1).${_att})
        )
        $(eval mods := $(filter-out $(1),${mods}))
      ,
        $(call Signal-Error,Kit ${$(1).kit} is NOT declared.)
      )
    ,
      $(call Signal-Error,Mod $(1) is not a child node.)
    )
  ,
    $(call Signal-Error,Mod $(1) does not have a declared node.)
  )
,
  $(call Signal-Error,The mod $(1) has not been declared.)
)
$(call Exit-Macro)
endef

$(call Add-Help-Section,mod-install,Macros for installing or creating mods.)

_macro := register-mod-prefix
define _help
${_macro}
  Register a prefix to be used by a mod for symbol names to avoid symbol
  name conflicts with other mods and to avoid lengthy <kit>.<mod> references.
  A prefix must be unique. A detected prefix conflict triggers an error exit.

  A mod can register multiple prefixes.

  Registration also defines a variable using the prefix as the variable name.
  This variable contains the <kit>.<mod> reference.

  The prefix for a mod can be retrieved using the <kit>.<mod>.prefixes
  attribute.

  WARNING: Mods must register themselves.

  Parameters:
    1 = The <kit>.<mod> reference to the mod.
    2 = The prefix to associate with the mod.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),mod=$(1) prefix=$(2))
$(if $(call mod-is-declared,$(1)),
  $(if $(filter $(2),${$(1).prefixes}),
    $(call Attention,Mod $(1) has already registered prefix $(2).)
  ,
    $(if $(call prefix-is-registered,$(2)),
      $(call Signal-Error,Mod prefix $(2) is already registered.,exit)
    ,
      $(eval $(1).prefixes += $(2))
      $(eval $(2) := $(1))
      $(eval mod_prefixes += $(2))
    )
  )
,
  $(call Signal-Error,\
    Mod $(1) has not been declared - cannot register prefix.)
)
$(call Exit-Macro)
endef

_macro := display-mod
define _help
${_macro}
  Display the attributes of a declared mod.
  Parameters:
    1 = The name of the mod.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),mod=$(1))
$(if $(call mod-is-declared,$(1)),
  $(call Display-Vars,\
    $(foreach _a,${mod_attributes},$(1).${_a}) \
    $(foreach _a,${mod_node_names},$(1).${_a})
  )
  $(foreach _n,${mod_node_names},
    $(if $(call node-exists,${_n}),
      $(call Info,Mod node ${_n} exists.)
    ,
      $(call Info,Mod node ${_n} does NOT exist.)
    )
  )
,
  $(call Warn,Mod $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := gen-mod-segment-text
define ${_macro}
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# $(strip $(2))
#----------------------------------------------------------------------------
# +++++
$$(call Last-Segment-UN)
$.ifndef $${LastSegUN}.SegID
$$(call Enter-Segment,$(2))
# -----

$.define _help
Make segment: $${Seg}.mk

<Overview of makefile segment>

Command line goals:
  # Describe additional goals provided by the segment.
  help-$${SegUN}
    Display this help.
$.endef
help-$${SegID} := $$(call _help)
$$(call Add-Help,$${SegID})

# Customize this segment then remove this error.
$$(call Signal-Error,Mod segment $${this_mod} has not been completed.)

# Register a prefix to be used as a shorthand reference to the mod. This prefix
# must be unique. Other modules which need to use the prefix can retrieve its
# name from the <kit>.<mod>.prefixes attribute.
# A mod can register multiple prefixes.
# TODO: Change _prefix to the actual prefix name throughout this module.
$$(call Attention,TODO:Declare prefix(es) for this mod.)
$$(eval _prefix := $${this_mod})
$$(call register-mod-prefix,$${this_mod},$${_prefix})

# TODO: Remove the following line after completing this segment.
$$(call Attention,TODO: Add common variables, macros, goals, and recipes here.)
$$(call Verbose,SegUN = $${SegUN})

$$(call Add-Help-Section,${_prefix}_vars,<variable declarations>)

_var := $${_prefix}_var
$${_var} :=
$.define _help
$${_var}
  This is a template for declaring mod specific variables.
$.endef

$$(call Add-Help-Section,${_prefix}_macros,Mod specific macros.)

_macro := $${_prefix}_macro
$${_macro} :=
$.define _help
$${_macro}
  This is a template for declaring mod specific macros.
$.endef
help-$${_macro} := $$(call _help)
$$(call Add-Help,$${_macro})
$.define $${_macro}
$$(call Enter-Macro,$$(0),Context=$$(1))
# TODO: Put macro code here.
$$(call Exit-Macro)
$.endef

_macro := $${_prefix}-declare-mod-context
$.define _help
$${_macro}
  Establish a new $${Seg} context for a mod which is using this mod. This is
  designed to be called by the mod or project using this mod which allows this
  mod to be used by multiple mods or multiple times by the same mod.

  Parameters:
    1 = The name or registered prefix to use to establish a new context for a
        user of this segment.
$.endef
help-$${_macro} := $$(call _help)
$$(call Add-Help,$${_macro})
$.define $${_macro}
$$(call Enter-Macro,$$(0),Context=$$(1))
$$(call Info,Initializing mod $(1) for context $$(1).)
$$(if $${$${_prefix}.$$(1).context},
  $$(call Signal-Error,Mod ${$${_prefix}} context $$(1) has already been declared.)
$.,
  $$(eval $${_prefix}.$$(1).context := $$(1))
  $$(eval new_context := <prefix>.$$(1))
  # TODO:Add context specific code here.

$.)
$$(call Exit-Macro)
$.endef

# The command line goal for the segment.
$${this_mod}: $${SegF}

# +++++
# Postamble
# Define help only if needed.
$.__h := $$(or $\
  $$(call Is-Goal,help-$${Seg}),$\\
  $$(call Is-Goal,help-$${SegUN}),$\\
  $$(call Is-Goal,help-$${SegID}))
$.ifneq ($${__h},)
$.define __help
$$(call Display-Help-List,$${SegID})
$.endef
$${__h} := $${__help}
$.endif # help goal message.

$$(call Exit-Segment)
$.else # $$(call Last-Segment-Basename).SegID exists
$$(call Check-Segment-Conflicts)
$.endif # $$(call Last-Segment-Basename).SegID
# -----

endef
# Help is at the end of the macro declaration in this case because the
# macro is used to generate a portion of the help.
define _help
${_macro}
  This generates segment text which can then be written to a file.
  Parameters:
    1 = The name of the node to associate with the segment.
    2 = A one line description.
  For example:
  $$(call Gen-Segment,This is a sample mod segment.)
  generates:
$(call gen-mod-segment-text,<kit>.<mod>,This is a sample mod segment.)
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})

_macro := gen-mod-segment
define _help
${_macro}
  This uses Gen-Segment-Text to generate a segment file and writes it to the
  specified file.
  Parameters:
    1 = The <kit>.<mod> reference for the mod. This is used to name the segment
        file, associated variable and, specific goals.
    2 = The full path to where to write the segment file.
    3 = A one line description.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Seg=$(1) Path=$(2) Desc=$(call To-String,$(3)))
  $(file >$(2),$(call gen-mod-segment-text,$(1),$(3)))
  $(call Attention,\
    Segment file for mod $(1) has been generated -- remember to customize.)
  $(call Exit-Macro)
endef

_macro := mk-mod
define _help
${_macro}
  Declare and initialize a new mod within a kit. A makefile segment is
  generated from a template. The dev must then complete the makefile segment
  before attempting a build. The kit is installed if necessary.

  NOTE: This is designed to be callable from the make command line using the
  helpers call-<macro> goal.
  For example:
    make ${_macro}.PARMS=<kit>.<mod> call-${_macro}
  Parameters:
    1 = The <kit>.<mod> name of the new mod.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),kit.mod=$(1))

$(call declare-mod,$(1))
$(if ${Errors},
  $(call Attention,An error occurred when declaring mod $(1).)
,
  $(call install-kit,${$(1).kit})
  $(if ${Errors},
    $(call Attention,An error occurred when installing kit ${$(1).kit})
  ,
    $(if $(call is-modfw-kit,${$(1).kit}),
      $(if $(call node-exists,$(1)),
        $(call Signal-Error,A node $(1) already exists.)
      ,
        $(call mk-node,$(1))
        $(call gen-mod-segment,$(1),${$(1).seg_f},\
          <Mod:${$(1).mod} edit this description>)
        $(call add-file-to-repo,${$(1).kit},${$(1).seg_f})
        $(file >${$(1).path}/.gitignore,$(call gen-mod-gitignore,$(1)))
        $(call add-file-to-repo,${$(1).kit},${$(1).path}/.gitignore)
      )
    ,
      $(call Signal-Error,Kit ${_k} is not a ModFW style repo.)
    )
  )
)

$(call Exit-Macro)
endef

_macro := mk-mod-from-template
define _help
${_macro}
  Copy an existing mod to serve as the template for a new mod. The makefile
  segment for the template mod is used to generate the new makefile segment with
  references to the template mod changed to reference the new mod. The
  template makefile segment is retained for reference but no longer used.

  NOTE: The kits containing the the new mod or the template mod are installed
  if necessary.

  NOTE: This is designed to be callable from the make command line using the
  helpers call-<macro> goal.
  For example:
    make ${_macro}.PARMS=<kit>.<mod>:<tkit>.<tmod> call-${_macro}
  Parameters:
    1 = The <kit>.<mod> name of the new mod.
    2 = The <kit>.<mod> name of the existing mod to use as a template.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),kit.mod=$(1) template=$(2))

$(call Verbose,Installing template mod kit.)
$(call declare-mod,$(2))
$(if ${Errors},
  $(call Attention,An error occurred when declaring template mod $(2))
,
  $(call install-kit,${$(2).kit})
  $(if ${Errors},
    $(call Attention,An error occurred when installing kit ${$(2).kit})
  ,
    $(if $(call mod-exists,$(2)),
      $(call declare-mod,$(1))
      $(if ${Errors},
        $(call Attention,An error occurred when declaring mod $(1))
      ,
        $(call install-kit,${$(1).kit})
        $(if ${Errors},
          $(call Attention,An error occurred when installing kit ${$(1).kit})
        ,
          $(if $(call mod-exists,$(1)),
            $(call Attention,Mod $(1) already exists.)
          ,
            $(call Info,Basing mod $(1) on mod $(2))
            $(call Run,cp -r ${$(2).path} ${$(1).path},quiet)
            $(if ${Run_Rc},
              $(call Signal-Error,\
                Copying template mod $(2) to the new kit $(1) failed.)
            ,
              $(call Derive-Segment-File,\
                ${$(2).mod},${$(2).seg_f},${$(1).mod},${$(1).seg_f})
              $(call add-file-to-repo,${$(1).kit},.)
            )
          )
        )
      )
    ,
      $(call Signal-Error,Template mod $(2) does not exist.)
    )
  )
)
$(call Exit-Macro)
endef

_macro := use-mod
define _help
${_macro}
  Use a mod. The kit containing the mod is installed if necessary.
  Parameters:
    1 = A <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),kit.mod=$(1))

$(call declare-mod,$(1))
$(if ${Errors},
,
  $(call use-kit,${$(1).kit})
  $(if ${Errors},
  ,
    $(if $(call is-modfw-kit,${$(1).kit}),
      $(call Info,Using mod ${$(1).mod} from kit ${$(1).kit}.)
      $(if $(call is-modfw-mod,$(1)),
        $(foreach _node,${mod_node_names},
          $(if $(call node-exists,$(1).${${_node}}),
            $(call Info,Using existing node $(1).${${_node}})
          ,
            $(call mk-node,$(1).${${_node}})
          )
        )
        $(eval this_mod := $(1))
        $(call Use-Segment,${$(1).seg_f})
      ,
        $(call Signal-Error,Mod $(1) is not a ModFW style mod.)
      )
    ,
      $(call Signal-Error,Kit ${_k} is not a ModFW style kit.)
    )
  )
)

$(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
__h := $(or \
  $(call Is-Goal,help-${SegUN}),\
  $(call Is-Goal,help-${SegID}),\
  $(call Is-Goal,help-${Seg}))
ifneq (${__h},)
define __help
$(call Display-Help-List,${SegID})
endef
${__h} := ${__help}
endif # help goal message.

$(call Exit-Segment)
else # SegId exists
$(call Check-Segment-Conflicts)
endif # SegId
# -----
