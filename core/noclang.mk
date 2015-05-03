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
#

# Disable Clang for a list of modules toallow compatibility with GCC
# flags that cause errors with the Clang compiler frontend such as
# -mcpu=cortex_a15 and graphite optimization flags
 
DISABLE_CLANG := \
	art \
        libart \
        libandroidruntime \
        libdalvik
 
ifneq (1,$(words $(filter $(DISABLE_CLANG),$(LOCAL_MODULE))))
 export WITHOUT_CLANG=true
# export WITHOUT_TARGET_CLANG=true
# export WITHOUT_HOST_CLANG=true
# export LOCAL_CLANG=false
endif
