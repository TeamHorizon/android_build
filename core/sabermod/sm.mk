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

# SABERMOD_ARM_MODE for arm and arm64
# To enable this feature set "SABERMOD_ARM_MODE := true" in device make file.
# This will disable the clang compiler when possible.
# This will also set "LOCAL_ARM_MODE := $(TARGET_ARCH) to default instead of thumb.
# ARM mode is known to generate better native 32bit instructions,
# instead of the default thumb mode which only generates 16bit code.
# The code produced is slightly larger, but graphite should shirnk it up when -O3 is enabled.
# This will allow more optimizations to take place throughout GCC on target ARM modules.
# Clang is very limited with options, so kill it with fire.
# The LOCAL_COMPILERS_WHITELIST will allow modules that absolutely have to be complied with thumb instructions,
# or the clang compiler, to skip replacing the default overrides.
# All libLLVM's gets added to the WhiteList automatically.

ifeq ($(strip $(ENABLE_SABERMOD_ARM_MODE)),true)
  ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
    ifneq ($(filter arm arm64,$(TARGET_ARCH)),)
      ifneq (1,$(words $(filter libLLVM% $(LOCAL_COMPILERS_WHITELIST),$(LOCAL_MODULE))))
        ifneq ($(filter arm arm64 thumb,$(LOCAL_ARM_MODE)),)
          LOCAL_TMP_ARM_MODE := $(filter arm arm64 thumb,$(LOCAL_ARM_MODE))
          LOCAL_ARM_MODE := $(LOCAL_TMP_ARM_MODE)
          ifeq ($(strip $(LOCAL_CLANG)),true)
            LOCAL_CLANG := false
          endif
        else

          # LOCAL_ARM_MODE won't get forced on arm64, because the default LOCAL_ARM_MODE should be a 32bit arm instruction.
          # Normally the default is thumb mode even for arm64, which is a normal 32bit arm instruction set.
          # So here it gets set to arm.
          LOCAL_TMP_ARCH := $(filter arm,$(TARGET_ARCH)$(TARGET_2ND_ARCH))
          LOCAL_ARM_MODE := $(LOCAL_TMP_ARCH)
          ifeq ($(strip $(LOCAL_CLANG)),true)
            LOCAL_CLANG := false
          endif
        endif
      else

        # Set the normal android default back to thumb mode if LOCAL_ARM_MODE is not set.
        # This is needed for the DISABLE_O3_OPTIMIZATIONS_THUMB function to work.
        ifndef LOCAL_ARM_MODE
          LOCAL_ARM_MODE := thumb
        endif
      endif
    endif
  endif
endif

# This is needed for the DISABLE_O3_OPTIMIZATIONS_THUMB function to work on arm devices.
ifneq ($(filter arm arm64,$(TARGET_ARCH)),)
  ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
    ifndef LOCAL_ARM_MODE
      # Still set the default LOCAL_ARM_MODE to thumb in case ENABLE_SABERMOD_ARM_MODE is not set.
      LOCAL_ARM_MODE := thumb
    endif
  endif
endif

# O3 optimzations
# To turn on set "O3_OPTIMIZATIONS := true" in device makefile.
# To disable -O3 optimizations on thumb set "DISABLE_O3_OPTIMIZATIONS_THUMB := true" in device makefile.
# DISABLE_O3_OPTIMIZATIONS_THUMB should be dependent on "O3_OPTIMIZATIONS := true", otherwise it's useless.
# LOCAL_O3_OPTIMIZATIONS_MODE is for other flag configurations to use, not for device configurations.
# Big thanks to Joe Maples for the arm mode to replace thumb mode, and Sebastian Jena for the unveiling the arm thumb mode.
ifeq ($(strip $(O3_OPTIMIZATIONS)),true)
  ifneq ($(strip $(LOCAL_ARM_MODE))-$(strip $(DISABLE_O3_OPTIMIZATIONS_THUMB)),thumb-true)
    ifneq (1,$(words $(filter $(LOCAL_DISABLE_O3),$(LOCAL_MODULE))))
      ifdef LOCAL_CFLAGS
        LOCAL_CFLAGS += $(O3_FLAGS)
      else
        LOCAL_CFLAGS := $(O3_FLAGS)
      endif
      LOCAL_O3_OPTIMIZATIONS_MODE := on
    else
      LOCAL_O3_OPTIMIZATIONS_MODE := off
    endif
  else
    LOCAL_O3_OPTIMIZATIONS_MODE := off
  endif
else
  LOCAL_O3_OPTIMIZATIONS_MODE := off
endif

# Extra sabermod variables
include $(BUILD_SYSTEM)/sabermod/extra.mk

# posix thread (pthread) support
ifneq (1,$(words $(filter $(LOCAL_DISABLE_PTHREAD),$(LOCAL_MODULE))))
  ifdef LOCAL_CFLAGS
    LOCAL_CFLAGS += -pthread
  else
    LOCAL_CFLAGS := -pthread
  endif
endif

# Do not use graphite on host modules or the clang compiler.
# Also do not bother using on darwin.
ifeq ($(HOST_OS),linux)
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
# AOSP has blindly turned on strict-aliasing in various places locally throughout the source.
# This causes warnings and should be dealt with, by turning strict-aliasing off to fix the warnings,
# until AOSP gets around to fixing the warnings locally in the code.

# Warnings and errors are turned on by default if strict-aliasing is set in LOCAL_CFLAGS.
# GCC can handle a warning level of 3 and clang a level of 2.

ifneq ($(filter -fstrict-aliasing,$(LOCAL_CFLAGS)),)
  ifneq ($(strip $(LOCAL_CLANG)),true)
    LOCAL_CFLAGS += -Wstrict-aliasing=3 -Werror=strict-aliasing
  else
    LOCAL_CFLAGS += -Wstrict-aliasing=2 -Werror=strict-aliasing
  endif
endif
ifeq (1,$(words $(filter $(LOCAL_DISABLE_STRICT_ALIASING),$(LOCAL_MODULE))))
  LOCAL_CFLAGS += -fno-strict-aliasing
endif

#end SaberMod
