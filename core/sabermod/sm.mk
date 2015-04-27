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
# ARM mode is known to generate better native 32bit instructions on arm targets,
# instead of the default thumb mode which only generates 16bit code.
# The code produced is slightly larger, but graphite should shirnk it up when -O3 is enabled.
# This will disable the clang compiler when possible.
# And allow more optimizations to take place throughout GCC on target ARM modules.
# Clang is very limited with options, so kill it with fire.
# The LOCAL_ARM_COMPILERS_WHITELIST and LOCAL_ARM64_COMPILERS_WHITELIST will disable SaberMod ARM Mode for specified modules.
# All libLLVM's gets added to the WhiteList automatically.

# ARM
ifeq ($(strip $(TARGET_ARCH)),arm)
  ifeq ($(strip $(ENABLE_SABERMOD_ARM_MODE)),true)
    ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
      ifneq (1,$(words $(filter libLLVM% $(LOCAL_ARM_COMPILERS_WHITELIST),$(LOCAL_MODULE))))
        ifneq ($(filter arm thumb,$(LOCAL_ARM_MODE)),)
          LOCAL_TMP_ARM_MODE := $(filter arm thumb,$(LOCAL_ARM_MODE))
          LOCAL_ARM_MODE := $(LOCAL_TMP_ARM_MODE)
          ifeq ($(strip $(LOCAL_ARM_MODE)),arm)
            ifdef LOCAL_CFLAGS
              LOCAL_CFLAGS += -marm
            else
              LOCAL_CFLAGS := -marm
            endif
          endif
          ifeq ($(strip $(LOCAL_ARM_MODE)),thumb)
            ifdef LOCAL_CFLAGS
              LOCAL_CFLAGS += -mthumb-interwork
            else
              LOCAL_CFLAGS := -mthumb-interwork
            endif
          endif
        else

          # Set to arm mode
          LOCAL_ARM_MODE := arm
          ifdef LOCAL_CFLAGS
            LOCAL_CFLAGS += -marm
          else
            LOCAL_CFLAGS := -marm
          endif
        endif
        ifeq ($(strip $(LOCAL_CLANG)),true)
            LOCAL_CLANG := false
        endif
      else

        # Set the normal arm default back to thumb mode if LOCAL_ARM_MODE is not set.
        # This is needed for the DISABLE_O3_OPTIMIZATIONS_THUMB function to work.
        ifndef LOCAL_ARM_MODE
          LOCAL_ARM_MODE := thumb
        endif
        ifeq ($(strip $(LOCAL_ARM_MODE)),arm)
          ifdef LOCAL_CFLAGS
            LOCAL_CFLAGS += -marm
          else
            LOCAL_CFLAGS := -marm
          endif
        endif
        ifeq ($(strip $(LOCAL_ARM_MODE)),thumb)
          ifdef LOCAL_CFLAGS
            LOCAL_CFLAGS += -mthumb-interwork
          else
            LOCAL_CFLAGS := -mthumb-interwork
          endif
        endif
      endif
    endif
  endif

  # This is needed for the DISABLE_O3_OPTIMIZATIONS_THUMB function to work on arm devices.
  ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
    ifndef LOCAL_ARM_MODE

      # Still set the default LOCAL_ARM_MODE to thumb in case ENABLE_SABERMOD_ARM_MODE is not set.
      LOCAL_ARM_MODE := thumb
    endif
    ifdef LOCAL_CFLAGS
      LOCAL_CFLAGS += -mthumb-interwork
    else
      LOCAL_CFLAGS := -mthumb-interwork
    endif
  endif
endif

# ARM64
ifeq ($(strip $(TARGET_ARCH)),arm64)
  ifeq ($(strip $(ENABLE_SABERMOD_ARM_MODE)),true)
    ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
      ifneq (1,$(words $(filter libLLVM% $(LOCAL_ARM64_COMPILERS_WHITELIST),$(LOCAL_MODULE))))
        ifneq ($(filter arm arm64 thumb,$(LOCAL_ARM_MODE)),)
          LOCAL_TMP_ARM_MODE := $(filter arm arm64 thumb,$(LOCAL_ARM_MODE))
          LOCAL_ARM_MODE := $(LOCAL_TMP_ARM_MODE)
        else

          # Set to arm64 mode
          LOCAL_ARM_MODE := arm64
        endif
        ifeq ($(strip $(LOCAL_CLANG)),true)
          LOCAL_CLANG := false
        endif
      endif
    endif
  endif
endif

# O3 optimzations
# LOCAL_O3_OPTIMIZATIONS_MODE is for other flag configurations to use, not for device configurations.
# Big thanks to Joe Maples for the arm mode to replace thumb mode, and Sebastian Jena for the unveiling the arm thumb mode.
ifeq ($(strip $(O3_OPTIMIZATIONS)),true)
  ifneq ($(strip $(LOCAL_ARM_MODE))-$(strip $(DISABLE_O3_OPTIMIZATIONS_THUMB)),thumb-true)
    ifneq (1,$(words $(filter $(LOCAL_DISABLE_O3),$(LOCAL_MODULE))))
      ifdef LOCAL_CFLAGS
        LOCAL_CFLAGS += $(O3_FLAGS) -g
      else
        LOCAL_CFLAGS := $(O3_FLAGS) -g
      endif
      LOCAL_O3_OPTIMIZATIONS_MODE := on
    else
      LOCAL_O3_OPTIMIZATIONS_MODE := off
      ifdef LOCAL_CFLAGS
        LOCAL_CFLAGS += -O2 -g
      else
        LOCAL_CFLAGS := -O2 -g
      endif
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

ifeq ($(strip $(ENABLE_STRICT_ALIASING)),true)
  # BUGFIX for AOSP
  # Turn all strict-aliasing warnings into errors.
  # strict-aliasing has a long well known history of breaking code when allowed to pass with warnings.
  # AOSP has blindly turned on strict-aliasing in various places locally throughout the source.
  # This causes warnings and should be dealt with, by turning strict-aliasing off to fix the warnings,
  # until AOSP gets around to fixing the warnings locally in the code.

  # Warnings and errors are turned on by default if strict-aliasing is set in LOCAL_CFLAGS.  Also check for arm mode strict-aliasing.
  # GCC can handle a warning level of 3 and clang a level of 2.

  ifeq ($(strip $(LOCAL_ARM_MODE),arm)
  arm_objects_cflags := $($(LOCAL_2ND_ARCH_VAR_PREFIX)$(my_prefix)$(arm_objects_mode)_CFLAGS)
    ifneq ($(strip $(LOCAL_CLANG)),true)
      ifneq ($(filter -fstrict-aliasing,$(arm_objects_cflags)),)
        ifdef LOCAL_CFLAGS
          LOCAL_CFLAGS += -Wstrict-aliasing=3 -Werror=strict-aliasing
        else
          LOCAL_CFLAGS := -Wstrict-aliasing=3 -Werror=strict-aliasing
        endif
      endif
    else
      arm_objects_cflags := $(call $(LOCAL_2ND_ARCH_VAR_PREFIX)convert-to-$(my_host)clang-flags,$(arm_objects_cflags))
      ifneq ($(filter -fstrict-aliasing,$(arm_objects_cflags)),)
        ifdef LOCAL_CFLAGS
          LOCAL_CFLAGS += -Wstrict-aliasing=2 -Werror=strict-aliasing
        else
          LOCAL_CFLAGS := -Wstrict-aliasing=2 -Werror=strict-aliasing
        endif
      endif
    endif
  endif
endif

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
