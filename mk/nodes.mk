#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Macros to support ModFW nodes.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Macros to support ModFW nodes.)
# -----

define _help
Make segment: ${Seg}.mk

In ModFW nodes defines macros for declaring and using nodes in a tree structure.
A node is essentially the point where a branch in a tree occurs. A node is
essentially a directory in the file system. The name of the node and the name
of the directory are the same. In ModFW each node must contain a makefile
segment having the same name as the node and, therefore, the directory.

Command line goals:
  help-${SegUN}   Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,node-vars,Variables for managing repos.)

_var := nodes
nodes :=
define _help
${_var}
  The list of declared nodes.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := node_attributes
${_var} := name node_un var parent children path
define _help
${_var}
  ModFW components are organized into a classic tree structure. Each node of a
  ModFW tree has the following attributes:
  <node>.name
    The name of the node.
  <node>.node_un
    The unique name of the node in dot notation. In the case of a root node
    this is the directory of the node and the name (e.g. <dir>.<node>). In the
    case of a child node this is the name of the parent and the node
    (e.g. <parent>.<node>).
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
$(call Add-Help,${_var})

$(call Add-Help-Section,node-ifs,Macros for checking node status.)

_macro := node-is-declared
define _help
${_macro}
  Returns a non-empty value if the node has been declared.
  Parameters:
    1 = The node name.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(if $(filter $(1),${nodes}),1)

_macro := node-exists
define _help
${_macro}
  Returns a non-empty value if the node path exists.
  Parameters:
    1 = The node name.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(if $(wildcard ${$(1).path}),1,)

_macro := is-a-child-node
define _help
${_macro}
  Returns a non-empty value if the node is a child node.
  Parameters:
    1 = The child node name.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(if ${$(1).parent},1,)

_macro := is-a-child-of
define _help
${_macro}
  Returns a non-empty value if the node is a child of the parent.
  Parameters:
    1 = The child node name.
    2 = The parent node name.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(if $(filter $(1),${$(2).children}),1)

$(call Add-Help-Section,node-reports,Macros for reporting nodes.)

_macro := display-node
define _help
${_macro}
  Display node attributes.
  Parameters:
    1 = The name of the node.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared,$(1))
    $(call Display-Vars,\
      $(foreach _a,${node_attributes},$(1).${_a})
    )
    $(if ${$(1).path},
      $(call Test-Info,Node $(1) can be a node.)
    ,
      $(call Test-Info,Node $(1) is NOT a valid node.)
    )
    $(if ${$(1).parent},
      $(call Test-Info,Node $(1) is a child node.)
    ,
      $(call Test-Info,Node $(1) is a root node.)
    )
    $(if $(call node-exists,$(1)),
      $(call Test-Info,Node $(1) path exists.)
    ,
      $(call Test-Info,Node $(1) path does not exist.)
    )
  ,
    $(call Test-Info,Node $(1) is not a member of ${nodes})
  )
  $(call Exit-Macro)
endef

_macro := display-node-tree
define _help
${_macro}
  Display a tree starting with a node.
  Parameters:
    1 = The name of the node.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared,$(1))
    $(call Display-Vars,\
      $(foreach _a,${node_attributes},$(1).${_a})
    )
    $(if ${$(1).path},
      $(call Test-Info,Node $(1) can be a node.)
    ,
      $(call Test-Info,Node $(1) is NOT a valid node.)
    )
    $(if $(call node-exists,$(1)),
      $(call Test-Info,Node $(1) path exists.)
      $(eval $(call Run,tree $(1).path))
      $(call Test-Info:${Run_Output})
    ,
      $(call Test-Info,Node $(1) path does not exist.)
    )
  ,
    $(call Test-Info,Node $(1) is not a member of ${nodes})
  )
  $(call Exit-Macro)
endef

$(call Add-Help-Section,node-decl,Declaring nodes.)

_macro := declare-root-node
define _help
${_macro}
  Declare a root node for a new tree. A root node has no parent.
  Parameters:
    1 = The name of the node (<node>).
    2 = This is the path (<path>) to the directory where the node contents
        are stored. NOTE: The path does not need to exist when the node is
        declared. See mk-node for more information.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
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
      $(call Path-To-UN,${$(1).path},$(1).node_un)
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
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared,$(1)),
    $(if ${$(1).children},
      $(call Signal-Error,Root node $(1) has children -- NOT undeclaring.)
    ,
      $(foreach _a,${node_attributes},
        $(eval undefine $(1).${_a})
      )
    $(eval nodes := $(filter-out $(1),${nodes}))
    )
  ,
    $(call Signal-Error,Node $(1) is NOT declared -- NOT undeclaring.)
  )
  $(call Exit-Macro)
endef

_macro := declare-child-node
define _help
${_macro}
  Declare a node in a ModFW tree. A child node uses its parent node path. The
  parent node must have been previously declared.
  Parameters:
    1 = The name of the node.
    2 = The name of the parent node.
    3 = If not empty use this as the directory name in the path instead of
        using the node name.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),name=$(1) parent=$(2) dir=$(3))
  $(if $(call node-is-declared,$(1)),
    $(call Signal-Error,Node $(1) has already been declared.)
  ,
    $(if $(2),
      $(if $(call node-is-declared,$(2)),
        $(call Info,Declaring child node:$(1))
        $(eval $(1).name := $(1))
        $(eval $(1).var := $(call To-Shell-Var,$(1)))
        $(if $(3),
          $(call Info,Using $(3) as node directory name.)
          $(eval $(1).path := ${$(2).path}/$(3))
        ,
          $(eval $(1).path := ${$(2).path}/$(1))
        )
        $(call Path-To-UN,${$(1).path},$(1).node_un)
        $(eval $(1).parent := $(2))
        $(eval $(1).children := )
        $(eval $(2).children += $(1))
        $(eval nodes += $(1))
      ,
        $(call Signal-Error,Parent node $(2) has not been declared.)
      )
    ,
      $(call Signal-Error,The parent node has not been specified.)
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
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared,$(1)),
    $(if ${$(1).children},
      $(call Signal-Error,Child node $(1) has children -- NOT undeclaring.)
    ,
      $(eval ${$(1).parent}.children := \
        $(filter-out $(1),${${$(1).parent}.children}))
      $(foreach _a,${node_attributes},
        $(eval undefine $(1).${_a})
      )
      $(eval nodes := $(filter-out $(1),${nodes}))
    )
  ,
    $(call Signal-Error,Node $(1) is NOT declared -- NOT undeclaring.)
  )
  $(call Exit-Macro)
endef

$(call Add-Help-Section,node-mk-remove,Macros for creating and removing nodes.)

_macro := mk-node
define _help
${_macro}
  Create the node path if it doesn't already exist. The node must first be
  declared. A makefile segment is generated for the node.

  NOTE: If the parent node does not exist it too will be created.

  Parameters:
    1 = The node name.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared,$(1)),
    $(if $(call node-exists,$(1)),
      $(call Attention,The directory for node $(1) exists -- not creating.)
    ,
      $(call Run,mkdir -p ${$(1).path})
    )
  ,
    $(call Signal-Error,Node $(1) has not been declared.)
  )
  $(call Exit-Macro)
endef

_macro := rm-node
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
    2 = An optional prompt for Confirm.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared,$(1)),
    $(if $(call node-exists,$(1)),
      $(if $(2),
        $(eval _p := $(2))
      ,
        $(eval _p := Destroy node $(1)?)
      )
      $(if $(call Confirm,${_p},y),
        $(call Run,rm -rf ${$(1).path})
      )
    ,
      $(call Verbose,Node $(1) does not exist -- not removing.)
    )
  ,
    $(call Signal-Error,Node $(1) has not been declared.)
  )
  $(call Exit-Macro)
endef

_macro := mk-child-nodes
define _help
${_macro}
  This macro creates all of the node child nodes within an existing node.
  Parameters:
    1 = The name of the parent.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0))
  $(if $(call node-is-declared,$(1)),
    $(if $(call node-exists,$(1)),
      $(call Info,Creating child nodes in parent node $(1).)
      $(foreach _node,${$(1).children},
        $(call mk-node,${$(1).${_node}})
      )
    ,
      $(call Signal-Error,Parent node $(1) does not exist.)
    )
  ,
    $(call Signal-Error,Parent node $(1) has not been declare.)
  )
  $(call Exit-Macro)
endef

_macro := rm-child-nodes
define _help
${_macro}
  This macro removes the child nodes within a parent node.
  Parameters:
    1 = The name of the parent node.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0))
  $(if $(call node-is-declared,$(1)),
    $(if $(call node-exists,$(1)),
      $(call Info,Removing child nodes in parent $(1).)
      $(foreach _node,${$(1).children},
        $(call rm-node,${$(1).${_node}})
      )
    ,
      $(call Signal-Error,The parent node $(1) does not exist.)
    )
  ,
    $(call Signal-Error,Parent node $(1) has not been declare.)
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
$(call Display-Help-List,${SegID})
endef
${__h} := ${__help}
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
