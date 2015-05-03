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
#
# Find OS
  UNAME := $(shell uname -s)
ifeq ($(strip $(UNAME)),Linux)
    # Graphite flags and friends
    GRAPHITE_FLAGS := \
      -fgraphite \
      -fgraphite-identity \
      -floop-flatten \
      -floop-parallelize-all \
      -ftree-loop-linear \
      -floop-interchange \
      -floop-strip-mine \
      -floop-block
endif

    # Legacy gcc doesn't understand this flag
    ifneq ($(strip $(USE_LEGACY_GCC)),true)
      GRAPHITE_FLAGS += \
        -Wno-error=maybe-uninitialized
    endif

    # Force disable some modules that are not compatible with graphite flags.
    # Add more modules if needed for devices in BoardConfig.mk
    # LOCAL_DISABLE_GRAPHITE +=
    LOCAL_DISABLE_GRAPHITE := \
      libunwind \
      libFFTEm \
      libicui18n \
      libskia \
      libvpx \
      libmedia_jni \
      libstagefright_mp3dec \
      mdnsd \
      libwebrtc_spl \
      third_party_WebKit_Source_core_webcore_svg_gyp \
      libjni_filtershow_filters \
      libavformat \
      libavcodec \
      skia_skia_library_gyp

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
##### DONE
