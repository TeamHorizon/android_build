# Copyright (C) 2015 The SaberMod Project
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

# SABERMOD_ARM_MODE for arm and arm64
# ARM mode is known to generate better native 32bit instructions on arm targets,
# instead of the default thumb mode which only generates 16bit code.
# The code produced is slightly larger, but graphite should shirnk it up when -O3 is enabled.
# This will disable the clang compiler when possible.
# And allow more optimizations to take place throughout GCC on target ARM modules.
# Clang is very limited with options, so kill it with fire.
# The LOCAL_ARM_COMPILERS_WHITELIST and LOCAL_ARM64_COMPILERS_WHITELIST will disable SaberMod ARM Mode for specified modules.
# All libLLVM's gets added to the WhiteList automatically.
# Big thanks to Joe Maples for the arm mode to replace thumb mode, and Sebastian Jena for the unveiling the arm thumb mode.

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
