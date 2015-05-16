  ifdef LOCAL_CFLAGS
    LOCAL_CFLAGS += -Wno-error
  else
    LOCAL_CFLAGS := -Wno-error
  endif
  ifdef LOCAL_CPPFLAGS
    LOCAL_CPPFLAGS += -Wno-error
  else
    LOCAL_CPPFLAGS := -Wno-error
  endif
  ifdef LOCAL_LDFLAGS
    LOCAL_LDFLAGS += -Wno-error
  else
    LOCAL_LDFLAGS := -Wno-error
  endif


