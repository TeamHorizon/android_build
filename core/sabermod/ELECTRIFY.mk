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
  # ROM
  TARGET_SM_AND := 4.8
  # Kernel
  TARGET_SM_KERNEL := 4.9

  # Define Optimizations for ELECTRIFY to use
  export O3_OPTIMIZATIONS := true
  export ENABLE_SABERMOD_ARM_MODE:= true
  export ENABLE_PTHREAD := true
  export ENABLE_GRAPHITE := true
  export ENABLE_STRICT_ALIASING := true
endif 
