#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Manage multiple ModFW products using git, branches, and tags.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----

#+
# For all products.
#-
# The directory containing the products repo.
# NOTE: This is ignored in .gitignore.
$(call Overridable,DEFAULT_PRODUCTS_DIR,${Seg})
# Where product specific kit and mod configuration repo is maintained.
$(call Overridable,DEFAULT_PRODUCTS_PATH,${WorkingPath}/${DEFAULT_PRODUCTS_DIR})

repo_classes += PRODUCT
containers += PRODUCT

$(call Sticky,PRODUCT)
$(call Sticky,PRODUCTS_DIR,${DEFAULT_PRODUCTS_DIR})
$(call Sticky,PRODUCTS_PATH,${DEFAULT_PRODUCTS_PATH})

$(call Sticky,PRODUCT_SERVER,git@github.com:)
$(call Sticky,PRODUCT_ACCOUNT,StevenIsaacs)
$(call Sticky,PRODUCT_REPO,${PRODUCT})

_req := $(call Require,\
  PRODUCT\
  PRODUCTS_DIR \
  PRODUCTS_PATH \
  PRODUCT_SERVER \
  PRODUCT_ACCOUNT \
  PRODUCT_REPO)

ifneq (${_req},)
  $(call Signal-Error,Missing sticky variables:${_req})
else
  product_url := ${PRODUCT_SERVER}$(PRODUCT_ACCOUNT)/${PRODUCT_REPO}
  $(call Verbose,Product url is:${product_url})
  ifneq (${NEW_PRODUCT},)
    $(call new-repo,PRODUCT,$(NEW_PRODUCT),$(BASIS_PRODUCT))
  else
    $(call activate-repo,PRODUCT)
    # If the product exists then route stick variables to the product and
    # load the kits.
    ifneq ($(call repo-is-setup,${PRODUCT}),)
      $(call Attention,Pointing STICKY_PATH to the active product.)
      $(eval STICKY_PATH := ${${PRODUCT}_repo_path}/sticky)
      $(call Use-Segment,kits)
    else
      $(call Signal-Error,The PRODUCT repo ${PRODUCT} is not setup.)
    endif
  endif
endif

# To remove all products.
ifneq ($(call Is-Goal,remove-${Seg}),)

  $(call Info,Removing all products in: ${PRODUCTS_PATH})
  $(call Warn,This cannot be undone!)
  ifeq ($(call Confirm,Remove all ${Seg} -- cannot be undone?,y),y)

remove-${Seg}:
> rm -rf ${PRODUCTS_PATH}

  else
    $(call Info,Not removing ${Seg}.)
 endif

endif

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help-${Seg}
Make segment: ${Seg}.mk

A ModFW product is mostly intended to contain variable definitions needed to
configure mod builds and to create product specific packages using the output
of mod builds. Each product is maintained in a separate git repo.

Although several products can exist side by side only one can be active at one
time. The active product is indicated by the value of the PRODUCT variable, The
"activate" goal is provided for switching between products. Different products
can use different versions of the same kits and mods. Kit versions and
dependencies are typically specified in the product makefile segment. Kit repos
are switched to the product specified branches when the product is activated.
Once activated, branches are no longer automatically switched but can be
manually switched using the branching macros. If the active branch of a repo
is not the same as the original branch when the product was activated a
warning is issued.

It is possible for products to be dependent upon the output of other products. However, it is recommended this be avoided because of introducing the risk of
disk thrashing as a result of switching branches of products and kits.

This segment uses git to help manage ModFW products. If the product repo doesn't
exist then it must first be created using the NEW_PRODUCT option. The product
is either created or cloned depending upon the value of PRODUCT_REPO (below).

Sticky variables are stored in the product subdirectory thus allowing each product to have unique values for sticky variables. This segment (${Seg}) changes STICKY_PATH to point to the product specific sticky variables which are also maintained in the repo.

When a product repo is created, a product makefile segment is generated and stored in the product subdirectory. The developer modifies this file as needed. The product makefile segment is typically used to override kit and mod variables. Product specific variables, goals and recipes can also be added. This is also used to define the repos and branches for the various kits used in the product.

A new product can be based upon an existing product by specifying the
existing product using the BASIS_PRODUCT command line variable. In this case
the existing product files are copied to the new product. The product
specific segment is renamed for the new product and all product references
in the new product are changed to reference the new product. For reference
the basis product makefile segment is copied to the new product but not used.

Required sticky variables:
  PRODUCT = ${PRODUCT}
    The name of the active product. This is used to create or switch to the
    product specific repo in the products directory. This variable is stored
    in the default sticky directory.
    DEFAULT_STICKY_PATH = ${DEFAULT_STICKY_PATH}
  PRODUCT_SERVER = ${PRODUCTS_SERVER}
    The git server where product repos are hosted. If the protocol is https
    then this needs to end with a forward slash (/). If the protocol is ssh
    then this needs to end with a colon (:).
  PRODUCT_ACCOUNT = ${PRODUCTS_ACCOUNT}
    The user account on the git server.
  PRODUCT_REPO=${PRODUCT_REPO}
    Default: PRODUCT_REPO = ${PRODUCT}
    The repo to clone for the active product. NOTE: This can be different
    than the local repo name making it possible to have multiple copies of a
    product repo.
  PRODUCT_BRANCH=${PRODUCT_BRANCH}
    Default: DEFAULT_BRANCH = ${DEFAULT_BRANCH}
    Branch in the active product repo to install. This becomes part of the
    directory name for the product.

Sticky variables for other products:
  <product>_REPO = (Defined when a product is activated)
    Default: LOCAL_REPO = ${LOCAL_REPO}
    The repo to clone for the selected product.
  <product>_BRANCH = (Defined when a product is activated)
    Default: DEFAULT_BRANCH = ${DEFAULT_BRANCH}
    The branch in the selected product to install. This is used as part of the
    directory name for the selected version of the product.

Optional sticky variables:
  PRODUCTS_DIR = ${PRODUCTS_DIR}
    The name of the directory where products are stored. This is used as part
    of the definition of PRODUCTS_PATH.
  PRODUCTS_PATH = ${PRODUCTS_PATH}
  Default: DEFAULT_PRODUCTS_PATH = ${DEFAULT_PRODUCTS_PATH}
    Where the product specific configurations are stored. This is the location
    of the collection of product git repos.

Defines:
  product_url = ${product_url}
  The URL produced by combining PRODUCT_SERVER, PRODUCT_ACCOUNT, and PRODUCT.

Changes:
  STICKY_PATH = ${STICKY_PATH}
    Changed to point to the active product repo directory.

Command line variables:
  NEW_PRODUCT = ${NEW_PRODUCT}
    The name of a new product to create. If this is not empty then a new
    product is declared and the "create-new" goal will create the new
    product.
    This creates new sticky variables for the new product:
      <NEW_PRODUCT>_REPO
      <NEW_PRODUCT>_BRANCH
    These are not defined unless the variable NEW_PRODUCT is defined on the
    command line.
  BASIS_PRODUCT = ${BASIS_PRODUCT}
    When defined and creating a new product using "create-new" the new
    product is initialized by copying files from the basis product to the new
    product. e.g. make NEW_PRODUCT=<new> BASIS_PRODUCT=<existing> create-new

Command line goals:
  show-${Seg}
    Display a list of products in the products directory.
  activate-product
    Activate the product (${PRODUCT}). This is available only when the
    product hasn't been installed.
  remove-products
    Remove all product repositories. WARNING: Use with care. This is potentially
    destructive. As a precaution the dev is prompted to confirm before
    proceeding.
  help-<product>
    Display the help message for a product.
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
