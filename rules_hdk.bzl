load("@com_github_google_rules_install//installer:def.bzl", "installer")
_thirdpartydefs = [
    "FBX_ENABLED=1",
    "OPENCL_ENABLED=1",
    "OPENVDB_ENABLED=1",
]
_hdefines = [
    "DLLEXPORT=\"\"",
    "_GNU_SOURCE",
    "LINUX",
    "AMD64",
    "SIZEOF_VOID_P=8",
    "EIGEN_MALLOC_ALREADY_ALIGNED=0",
    "_SILENCE_ALL_CXX17_DEPRECATION_WARNINGS=1",
    "SESI_LITTLE_ENDIAN",
    "ENABLE_THREADS",
    "USE_PTHREADS",
    "ENABLE_UI_THREADS",
    "GCC3",
    "GCC4",
    "USE_PYTHON3=1",
] + _thirdpartydefs

_cxxopts = [
    "-D_GLIBCXX_USE_CXX11_ABI=0",
    "-std=c++17"
]

_wflags = [
    "-Wall",
    "-W",
    "-Wno-parentheses",
    "-Wno-sign-compare",
    "-Wno-reorder",
    "-Wno-uninitialized",
    "-Wunused",
    "-Wno-unused-parameter",
    "-Wno-deprecated",
    "-fno-strict-aliasing",
]

_syslinkopts = [
    "-L/usr/X11R6/lib64",
    "-L/usr/X11R6/lib",
    "-lGL",
    "-lX11",
    "-lXext",
    "-lXi",
    "-ldl",
    "-lpthread",
]

_hdk_toolkit = [
    "@hdk//:toolkit",
]

def hdk_dso(name, 
            copts = [], 
            deps = [],
            defines = [],
            features = [],
            **kwargs):

    native.cc_binary(
        name = name,
        copts = _cxxopts + _wflags + copts,
        deps = _hdk_toolkit + deps,
        defines = ["MAKING_DSO"] + _hdefines + defines,
        features = ["-default_compile_flags"] + features,
        linkshared = True,
        **kwargs
    )

    installer(
        name = "install_%s" % name,
        data = [":%s" % name],
        executable = False,
    )

def hdk_app(name, 
            copts = [], 
            deps = [],
            defines = [],
            features = [],
            link_with_engine = False,
            **kwargs):

    hlibs = [ 
        "@hdk//:HoudiniUI",
        "@hdk//:HoudiniOPZ",
        "@hdk//:HoudiniOP3",
        "@hdk//:HoudiniOP2",
        "@hdk//:HoudiniOP1",
        "@hdk//:HoudiniSIM",
        "@hdk//:HoudiniGEO",
        "@hdk//:HoudiniPRM",
        "@hdk//:HoudiniUT",
        "@hdk//:hboost_system",
    ]

    if link_with_engine:
        hlibs += [ "@hdk//:HAPI" ]

    native.cc_binary(
        name = name,
        copts = _cxxopts + _wflags + copts,
        deps = _hdk_toolkit + hlibs + deps,
        defines = _hdefines + defines,
        features = ["-default_compile_flags"] + features,
        **kwargs
    )

    installer(
        name = "install_%s" % name,
        data = [":%s" % name],
    )
