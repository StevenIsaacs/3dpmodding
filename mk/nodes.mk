#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Macros to support ModFW nodes.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment)
# -----

_var := nodes
nodes :=
define _help
${_var}
  The list of declared nodes.
endef

_var := node_attributes
${_var} := name var parent path
define _help
${_var}
  ModFW components are organized into a classic tree structure. Each node of a
  ModFW tree has the following attributes:
  <node>.name
    The name of the node. This is also the name of the makefile segment (<seg>)
    for the node.
  <node>.var
    A shell variable compatible version of the node name.
  <node>.parent
    The name of the parent node. If this is empty then the node is a root node.
  <node>.children
    This is a list of node names of all children of this node.
  <node>.path
    The full path to the node in the file system.
endef
help-${_var} := $(call _help)

_macro := node-is-declared
define _help
${_macro}
  Returns a non-empty value if the node has been declared.
  Parameters:
    1 = The node name.
endef
help-${_macro} := $(call _help)
${_macro} = $(if $(filter $(1),${nodes}),1)

_macro := node-exists
define _help
${_macro}
  Returns a non-empty value if the node path exists.
  Parameters:
    1 = The node name.
endef
help-${_macro} := $(call _help)
${_macro} = $(if $(wildcard ${$(1).path}),1,)

_macro := declare-node
define _help
${_macro}
  Add a node to a ModFW tree or declare a root node for a new tree.
  Parameters:
    1 = The name of the node (<node>).
    2 = The name of the parent node. If this is empty then the node is
        a root node.
    3 = This is the path (<path>) to the directory where the node contents
        are stored. If this is empty then the parent node path is used. Root
        nodes must use this parameter.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2))
  $(if $(call node-is-declared($(1))),
    $(call Warn,Node $(1) has already been declared.)
  ,
    $(call Info,Declaring node:$(1))
    $(eval nodes += $(1))
    $(eval $(1).name := $(1))
    $(eval $(1).var := $(call To-Shell-Var,$(1)))
    $(eval $(1).parent := $(2))
    $(if $(2),
      $(if $(call node-is-declared,$(2)),
        $(if $(3),
          $(eval $(1).path := $(3))
        ,
          $(eval $(1).path := ${$(2).path}/$(1))
        )
      ,
        $(call Signal-Error,Parent node $(2) has not been declared.)
      )
    ,
      $(call Info,Node $(1) is a root node.)
      $(if $(3),
        $(eval $(1).path := $(3))
      ,
        $(call Signal-Error,Path for root node $(1) has not been specified.)
      )
    )
  )
  $(call Exit-Macro)
endef

_macro := create-node
define _help
${_macro}
  Create the node path if it doesn't already exist. The node must first be
  declared.
  Parameters:
    1 = The node name.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared),
    $(if $(call node-exists,$(1)),
      $(call Verbose,Node $(1) exists -- not creating.)
    ,
      $(call Run,mkdir -p ${$(1).path})
    )
  ,
    $(call Signal-Error,Node $(1) has not been declared.)
  )
  $(call Exit-Macro)
endef

_macro := remove-node
define _help
${_macro}
  Remove a node declaration. This un-defines all the node variables.
  The node directory is not removed.
  Parameters:
    1 = The node (<node>) to remove.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared,$(1)),
    $(foreach _a,${node-attributes},
      $(eval undefine $(1).${_a})
    )
    $(eval nodes := $(filter-out $(1),${nodes}))
  ,
    $(call Warning,Node $(1) is NOT declared -- NOT removing.)
  )
  $(call Exit-Macro)
endef

_macro := destroy-node
define _help
${_macro}
  Delete all files and subdirectories for the node.
  WARNING: This is potentially destructive and cannot be undone. Use with
  caution. To help mitigate this problem this first verifies the node has been declared and the path exists.
  WARNING: All components with the node are also deleted.
  Parameters:
    1 = The node name.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared),
    $(if $(call node-exists,$(1)),
      $(call Run,rm -r ${$(1).path})
    ,
      $(call Verbose,Node $(1) does not exist -- not removing.)
    )
  ,
    $(call Signal-Error,Node $(1) has not been declared.)
  )
  $(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help-${Seg}
Make segment: ${Seg}.mk

ModFW

${help-nodes}

${help-node_attributes}

Defines the macros:

${help-node-is-declared}

${help-node-exists}

${help-declare-node}

${help-remove-node}

${help-create-node}

${help-destroy-node}

Command line goals:
  help-${Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
