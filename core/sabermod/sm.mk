##########################################################################
# Copyright (C) 2014-2015 The SaberMod Project
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
##########################################################################

# SaberMod Arm Mode 
include $(BUILD_SYSTEM)/sabermod/arm.mk

# Disable -Werror
include $(BUILD_SYSTEM)/sabermod/werror.mk

# Tune based on CPU
ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
  ifeq ($(strip $(ENABLE_TUNE)),true)
    include $(BUILD_SYSTEM)/sabermod/tune.mk
  endif
endif

# O3 Optimizations
include $(BUILD_SYSTEM)/sabermod/O3.mk

# Extra sabermod variables
ifeq ($(strip $(ENABLE_EXTRA)),true)
  include $(BUILD_SYSTEM)/sabermod/extra.mk
endif

# posix thread (pthread) support
ifneq (1,$(words $(filter $(LOCAL_DISABLE_PTHREAD),$(LOCAL_MODULE))))
  ifeq ($(strip $(ENABLE_PTHREAD)),true)
    ifdef LOCAL_CFLAGS
      LOCAL_CFLAGS += -pthread
    else
      LOCAL_CFLAGS := -pthread
    endif
  endif
endif

# Do not use graphite on host modules or the clang compiler.
# Also do not bother using on darwin.
ifeq ($(HOST_OS),linux)
ifeq ($(strip $(ENABLE_GRAPHITE)),true)
  ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
    ifneq ($(strip $(LOCAL_CLANG)),true)
      ifeq ($(strip $(LOCAL_O3_OPTIMIZATIONS_MODE)),on)

        # If it gets this far enable graphite by default from here on out.
        ifneq (1,$(words $(filter $(LOCAL_DISABLE_GRAPHITE),$(LOCAL_MODULE))))
          ifdef LOCAL_CFLAGS
            LOCAL_CFLAGS += $(GRAPHITE_FLAGS)
          else
            LOCAL_CFLAGS := $(GRAPHITE_FLAGS)
          endif
          ifdef LOCAL_LDFLAGS
            LOCAL_LDFLAGS += $(GRAPHITE_FLAGS)
          else
            LOCAL_LDFLAGS := $(GRAPHITE_FLAGS)
          endif
        endif
      endif
    endif
  endif
endif
endif

# General flags for gcc 4.9 to allow compilation to complete.
# Many of these are device specific and should be set in device make files.
# See vendor or device trees for more info.  Add more sections below and to vendor/name/configs/sm.mk if need be.

# modules that need -Wno-error=maybe-uninitialized
ifdef MAYBE_UNINITIALIZED
  ifeq (1,$(words $(filter $(MAYBE_UNINITIALIZED),$(LOCAL_MODULE))))
    ifdef LOCAL_CFLAGS
      LOCAL_CFLAGS += -Wno-error=maybe-uninitialized
    else
      LOCAL_CFLAGS := -Wno-error=maybe-uninitialized
    endif
  endif
endif

# Disable Strict because it is not currently in use
#include $(BUILD_SYSTEM)/sabermod/strict.mk
#end SaberMod
