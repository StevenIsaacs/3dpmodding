#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# <purpose for this segment>
#----------------------------------------------------------------------------
# The prefix $(call This-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call This-Segment-Basename)SegId
$(call Enter-Segment)
# -----

define tmp-fnc
$(if $(1),
  $(call Debug,tmp-fnc: Positive case)
  $(call Info,tmp-fnc: Affirmative)
  $(call Info,tmp-fnc: Yes)
,
  $(call Debug,tmp-fnc: Negative case)
  $(call Info,tmp-fnc: Negative)
  $(call Info,tmp-fnc: No)
)
endef

$(call tmp-fnc,y)
$(call tmp-fnc)
$(call Signal-Error,\
  A test message.)

define tmp-g
$(eval
tmp-goal:
> echo Temporary goal
)
endef

$(call tmp-g)

_a_ := a
_A_ := A
$(call Info,_a_ = ${_a_} _A_ = ${_A_})

$(call gen-command-goal,test-goal,> @echo test goal.)
$(call gen-command-goal,test-goal-2,> @echo test goal 2.,Gen test-goal-2?)


# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

Macros, goals and recipes to test ModFW makefile segments.

Command line goals:
  help-${Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
