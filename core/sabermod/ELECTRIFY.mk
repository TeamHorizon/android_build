#
# Copyright (C) 2015 Team Horizon & SaberMod
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
ifeq ($(strip $(ELECTRIFY)),true)
  ########################
  ##       DEFINE       ##
  ##  CUSTOM TOOLCHAINS ##
  ##        HERE        ##
  ########################
  export TARGET_SM_AND := SM-4.9
  export TARGET_SM_KERNEL := 4.8

  # Define Optimizations for ELECTRIFY to use
  export TARGET_ARCH := arm
  export O3_OPTIMIZATIONS := false
  export ENABLE_SABERMOD_ARM_MODE:= true
  export ENABLE_TUNE := true
  export ENABLE_PTHREAD := true
  export ENABLE_EXTRA := true
  export ENABLE_GRAPHITE := true
  export ENABLE_STRICT_ALIASING := false
  export USE_LEGACY_GCC := false
  export USE_LEGACY_NDK := false
else
  ifeq ($(strip $(ELECTRIFY)),false)
    ########################
    ##       DEFINE       ##
    ##  STABLE TOOLCHAINS ##
    ##        HERE        ##
    ########################
    export TARGET_SM_AND := 4.8
    export TARGET_SM_KERNEL := 4.8
  
    # Remove optimizations
    export TARGET_ARCH := arm
    export O3_OPTIMIZATIONS := false
    export ENABLE_SABERMOD_ARM_MODE:= false
    export ENABLE_TUNE := false
    export ENABLE_PTHREAD := false
    export ENABLE_EXTRA := false
    export ENABLE_GRAPHITE := false
    export ENABLE_STRICT_ALIASING := false
    export USE_LEGACY_GCC := true
    export USE_LEGACY_NDK := true
  else
    ifeq ($(strip $(ELECTRIFY)),)
      # Unset Variables
      export TARGET_SM_AND := 4.8
      export TARGET_SM_KERNEL := 4.8
      export TARGET_ARCH := arm
      export O3_OPTIMIZATIONS := 
      export ENABLE_SABERMOD_ARM_MODE:=
      export ENABLE_TUNE := true
      export ENABLE_PTHREAD := true
      export ENABLE_EXTRA := 
      export ENABLE_GRAPHITE :=
      export ENABLE_STRICT_ALIASING :=
      export USE_LEGACY_GCC :=
      export USE_LEGACY_NDK :=
    endif
  endif
endif 
