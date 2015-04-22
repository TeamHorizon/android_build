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

# O3 optimzations
# To turn on set "O3_OPTIMIZATIONS := true" in device makefile.
# To disable -O3 optimizations on thumb set "DISABLE_O3_OPTIMIZATIONS_THUMB := true" in device makefile.
# DISABLE_O3_OPTIMIZATIONS_THUMB should be dependent on "O3_OPTIMIZATIONS := true", otherwise it's useless.
# LOCAL_O3_OPTIMIZATIONS_MODE is for other flag configurations to use, not for device configurations.
# Big thanks to Joe Maples for the arm mode to replace thumb mode, and Sebastian Jena for the unveiling the arm thumb mode.
ifeq ($(strip $(O3_OPTIMIZATIONS)),true)
  ifneq ($(strip $(LOCAL_ARM_MODE))-$(strip $(DISABLE_O3_OPTIMIZATIONS_THUMB)),thumb-true)
    include $(BUILD_SYSTEM)/O3.mk
  else
    LOCAL_O3_OPTIMIZATIONS_MODE := off
  endif
else
  LOCAL_O3_OPTIMIZATIONS_MODE := off
endif

# Extra sabermod variables
include $(BUILD_SYSTEM)/extra.mk

# posix thread (pthread) support
ifeq ($(strip $(ENABLE_PTHREAD)),true)
  include $(BUILD_SYSTEM)/pthread.mk
endif

# Do not use graphite on host modules or the clang compiler.
# Also do not bother using on darwin.
ifeq ($(HOST_OS),linux)
  ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
    ifneq ($(strip $(LOCAL_CLANG)),true)

      # If it gets this far enable graphite by default from here on out.
      include $(BUILD_SYSTEM)/graphite.mk
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

# BUGFIX for AOSP
# Turn all strict-aliasing warnings into errors.
# strict-aliasing has a long well known history of breaking code when allowed to pass with warnings.
# AOSP has blindly turned on strict-aliasing in various places locally thourout the source.
# This causes warnings and should be dealt with, by turning strict-aliasing off to fix the warnings,
# until AOSP gets around to fixing the warnings locally in the code.

# Warnings and errors are turned on by default if strict-aliasing if set in LOCAL_CFLAGS.
# GCC can handle a warning level of 3 and clang a level of 2.

ifneq ($(filter -fstrict-aliasing,$(LOCAL_CFLAGS)),)
  ifneq ($(strip $(LOCAL_CLANG)),true)
    LOCAL_CFLAGS += -Wstrict-aliasing=3 -Werror=strict-aliasing
  else
    LOCAL_CFLAGS += -Wstrict-aliasing=2 -Werror=strict-aliasing
  endif
  ifeq (1,$(words $(filter $(LOCAL_DISABLE_STRICT_ALIASING),$(LOCAL_MODULE))))
    LOCAL_CFLAGS += -fno-strict-aliasing
  endif
endif

#end SaberMod
