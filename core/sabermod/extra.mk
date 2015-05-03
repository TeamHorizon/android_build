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

# Extra SaberMod C flags for gcc and clang
# Seperated by arch, clang and host

ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
  ifneq ($(strip $(LOCAL_CLANG)),true)
    ifdef EXTRA_SABERMOD_GCC_CFLAGS
      ifneq (1,$(words $(filter $(LOCAL_DISABLE_SABERMOD_GCC_CFLAGS),$(LOCAL_MODULE))))
        ifdef LOCAL_CFLAGS
          LOCAL_CFLAGS += $(EXTRA_SABERMOD_GCC_CFLAGS)
        else
          LOCAL_CFLAGS := $(EXTRA_SABERMOD_GCC_CFLAGS)
        endif
      endif
    endif
    ifneq ($(strip $(LOCAL_O3_OPTIMIZATIONS_MODE)),off)
      ifdef LOCAL_CFLAGS
        LOCAL_CFLAGS += $(EXTRA_SABERMOD_GCC_O3_CFLAGS)
      else
        LOCAL_CFLAGS := $(EXTRA_SABERMOD_GCC_O3_CFLAGS) 
      endif
    endif
  endif
endif

ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
  ifeq ($(strip $(LOCAL_CLANG)),true)
    ifneq (1,$(words $(filter $(LOCAL_DISABLE_SABERMOD_CLANG_VECTORIZE_CFLAGS),$(LOCAL_MODULE))))
      ifdef LOCAL_CFLAGS
        LOCAL_CFLAGS += $(LOCAL_SABERMOD_CLANG_VECTORIZE_CFLAGS)
      else
        LOCAL_CFLAGS := $(LOCAL_SABERMOD_CLANG_VECTORIZE_CFLAGS)
      endif
    endif
  endif
endif

ifeq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
  ifneq ($(strip $(LOCAL_CLANG)),true)
    ifdef LOCAL_CFLAGS
      LOCAL_CFLAGS += $(EXTRA_SABERMOD_HOST_GCC_CFLAGS)
    else
      LOCAL_CFLAGS := $(EXTRA_SABERMOD_HOST_GCC_CFLAGS)
    endif
    ifeq ($(strip $(LOCAL_O3_OPTIMIZATIONS_MODE)),on)
      LOCAL_CFLAGS += $(EXTRA_SABERMOD_HOST_GCC_O3_CFLAGS)
    endif
  endif
endif
