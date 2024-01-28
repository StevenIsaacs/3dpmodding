#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Macros to support ModFW nodes.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Macros to support ModFW nodes.)
# -----

_var := nodes
nodes :=
define _help
${_var}
  The list of declared nodes.
endef

_var := node_attributes
${_var} := name var parent children path
define _help
${_var}
  ModFW components are organized into a classic tree structure. Each node of a
  ModFW tree has the following attributes:
  <node>.name
    The name of the node.
  <node>.var
    A shell variable compatible form of the node name.
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

_macro := is-a-child-of
define _help
${_macro}
  Returns a non-empty value if the node is a child of the parent.
  Parameters:
    1 = The child node name.
    2 = The parent node name.
endef
help-${_macro} := $(call _help)
${_macro} = $(if $(filter $(1),${$(2).children}),1)

_macro := declare-child-node
define _help
${_macro}
  Declare a node in a ModFW tree. A child node uses its parent node path.
  Parameters:
    1 = The name of the node.
    2 = The name of the parent node.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2))
  $(if $(call node-is-declared($(1))),
    $(call Signal-Error,Node $(1) has already been declared.)
  ,
    $(call Info,Declaring child node:$(1))
    $(if $(2),
      $(if $(call node-is-declared,$(2)),
        $(eval nodes += $(1))
        $(eval $(1).name := $(1))
        $(eval $(1).var := $(call To-Shell-Var,$(1)))
        $(eval $(1).path := ${$(2).path}/$(1))
        $(eval $(1).parent := $(2))
        $(eval $(1).children := )
        $(eval $(2).children += $(1))
      ,
        $(call Signal-Error,Parent node $(2) has not been declared.)
      )
    ,
      $(call Signal-Error,The parent for node $(1) has not been specified.)
    )
  )
  $(call Exit-Macro)
endef

_macro := undeclare-child-node
define _help
${_macro}
  Remove a child node declaration. Child nodes must have parents. If there is
  no parent then an error will be issued and the node will not be undeclared.
  If the child node also has children then an error will be issued and the
  node will not be undeclared.
  NOTE: This does not affect the node files or directory.
  Parameters:
    1 = The root node to undeclare.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared,$(1)),
    $(if ${$(1).children},
      $(call Signal-Error,Child node $(1) has children -- NOT undeclaring.)
    ,
      $(eval ${$(1).parent}.children := \
        $(filter-out $(1),${${$(1).parent}.children}))
      $(foreach _a,${node-attributes},
        $(eval undefine $(1).${_a})
      )
      $(eval nodes := $(filter-out $(1),${nodes}))
    )
  ,
    $(call Signal-Error,Node $(1) is NOT declared -- NOT undeclaring.)
  )
  $(call Exit-Macro)
endef

_macro := declare-root-node
define _help
${_macro}
  Declare a root node for a new tree. A root node has no parent.
  Parameters:
    1 = The name of the node (<node>).
    2 = This is the path (<path>) to the directory where the node contents
        are stored. NOTE: The path does not need to exist when the node is
        declared. See create-node for more information.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2))
  $(if $(call node-is-declared($(1))),
    $(call Signal-Error,Node $(1) has already been declared.)
  ,
    $(if $(2),
      $(call Info,Declaring root node:$(1))
      $(eval nodes += $(1))
      $(eval $(1).name := $(1))
      $(eval $(1).var := $(call To-Shell-Var,$(1)))
      $(eval $(1).path := $(2)/$(1))
      $(eval $(1).parent := )
      $(eval $(1).children := )
    ,
      $(call Signal-Error,Path for root node $(1) has not been provided.)
    )
  )
  $(call Exit-Macro)
endef

_macro := undeclare-root-node
define _help
${_macro}
  Remove a root node declaration. All of the child nodes are also undeclared.
  NOTE: This does not affect the node files or directory.
  Parameters:
    1 = The root node to undeclare.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared,$(1)),
    $(if ${$(1).children},
      $(call Signal-Error,Root node $(1) has children -- NOT undeclaring.)
    ,
      $(foreach _a,${node-attributes},
        $(eval undefine $(1).${_a})
      )
    $(eval nodes := $(filter-out $(1),${nodes}))
    )
  ,
    $(call Signal-Error,Node $(1) is NOT declared -- NOT undeclaring.)
  )
  $(call Exit-Macro)
endef

_macro := create-node
define _help
${_macro}
  Create the node path if it doesn't already exist. The node must first be
  declared. A makefile segment is generated for the node.
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
      $(if $(call Confirm,Create node:$(1)?,y),
        $(call Run,mkdir -p ${$(1).path})
      ,
        $(call Info,Declined -- not creating node $(1).)
      )
    )
  ,
    $(call Signal-Error,Node $(1) has not been declared.)
  )
  $(call Exit-Macro)
endef

_macro := destroy-node
define _help
${_macro}
  Delete all files and subdirectories for the node.
  WARNING: This is potentially destructive and cannot be undone, unless of
  course, the directory is also a repo in which case the repo can be cloned
  again. Use with caution. To help mitigate this problem this first verifies
  the node has been declared and the path exists.
  WARNING: All components within the node are also deleted.
  Parameters:
    1 = The node name.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared),
    $(if $(call node-exists,$(1)),
      $(if $(call Confirm,Remove repo:$(1)?,y),
        $(call Run,rm -r ${$(1).path})
      ,
        $(call Info,Declined -- not deleting $(1).)
      )
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
__h := \
  $(or \
    $(call Is-Goal,help-${Seg}),\
    $(call Is-Goal,help-${SegUN}),\
    $(call Is-Goal,help-${SegID}))
ifneq (${__h},)
define __help
Make segment: ${Seg}.mk

In ModFW nodes defines macros for declaring and using nodes in a tree structure.
A node is essentially the point where a branch in a tree occurs. A node is
essentially a directory in the file system. The name of the node and the name
of the directory are the same. In ModFW each node must contain a makefile
segment having the same name as the node and, therefore, the directory.

${help-nodes}

${help-node_attributes}

Defines the macros:

${help-node-is-declared}

${help-node-exists}

${help-declare-root-node}

${help-declare-child-node}

${help-create-node}

${help-undeclare-node}

${help-delete-node}

Command line goals:
  help-${SegUN}   Display this help.
endef
${__h} := ${__help}
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
