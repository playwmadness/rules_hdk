def _init_hdk_impl(repo_ctx):
    hfs_path = repo_ctx.attr.hfs
    if not hfs_path:
        hfs_path = repo_ctx.os.environ["HFS"]
    if not hfs_path:
        fail("Unable to find HFS directory")

    houdini_version = repo_ctx.attr.houdini_version
    if not houdini_version:
        houdini_version = repo_ctx.os.environ["HOUDINI_VERSION"]
    if not houdini_version:
        fail("Unable to determine houdini version")

    # HDSO

    repo_ctx.symlink(hfs_path + "/toolkit", "toolkit")
    repo_ctx.symlink(hfs_path + "/dsolib", "dsolib")

    dsolibs = [
        "HoudiniUI",
        "HoudiniOPZ",
        "HoudiniOP3",
        "HoudiniOP2",
        "HoudiniOP1",
        "HoudiniSIM",
        "HoudiniGEO",
        "HoudiniPRM",
        "HoudiniUT",
        "hboost_system",
        "HAPI",
    ]
    dsolib_rules = ""
    for lib in dsolibs:
        dsolib_rules += """
cc_import(
    name = "{0}",
    shared_library = "dsolib/lib{0}.so",
    visibility = ["//visibility:public"],
)
""".format(lib)

    build_file_contents = dsolib_rules + """
cc_library(
    name = "toolkit",
    hdrs = glob([
        "toolkit/include/**/*.h",
        "toolkit/include/**/*.hpp",
        "toolkit/include/**/*.ipp",
        "toolkit/include/**/*.C",   # Some HDK headers are including .C files,
        "toolkit/include/**/*.cpp", # which is why I had to add these to the glob
    ]),
    includes = [
        "toolkit/include/",
        "toolkit/include/python3.9/",
    ],
    defines = [
        "VERSION=\\\"{}\\\"",
    ],
    visibility = ["//visibility:public"],
)
""".format(houdini_version)

    repo_ctx.file("BUILD", build_file_contents)

def init_hdk(hfs = "", houdini_version = ""):

    environ = []
    if not hfs:
        environ += ["HFS"]
    if not houdini_version:
        environ += ["HOUDINI_VERSION"]

    repository_rule(
        implementation = _init_hdk_impl,
        environ = environ,
        local = True,
        attrs = {
            "hfs": attr.string(),
            "houdini_version": attr.string(),
        },
    )(
        name = "hdk",
        hfs = hfs,
        houdini_version = houdini_version
    )
