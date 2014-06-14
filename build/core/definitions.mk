# 
# Copyright (C) 2014 Trevor Drake
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

##
## Custom Build System Definitons
## Called from build/core/definitions.mk
## Use this file to 
## 1. Add additonal global helper functions 
## 2. Override existing functions defined by definitions.mk
##

## Stash the old expand-required-modules recipe before
## defining a new one.
define expand-required-modules-old=$(value expand-required-modules)
endef

## The new expand-required-modules filters out any
## Packages defined by PRODUCT_PACKAGES_FILTER
define expand-required-modules
$(call expand-required-modules-old,$(1),$(2))\
$(eval $(1) := $(filter-out $(PRODUCT_PACKAGES_FILTER),$($(1))))
endef
