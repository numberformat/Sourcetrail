from conan import ConanFile
from conan.tools.cmake import CMake, cmake_layout
from conan.errors import ConanException


class SourcetrailConan(ConanFile):
    name = "sourcetrail"
    version = "0.0.0"
    settings = "os", "arch", "compiler", "build_type"
    generators = ("CMakeDeps", "CMakeToolchain")
    default_options = {
        "boost/*:shared": False,
        "qt/*:shared": True,
        "qt/*:qtsvg": True,
        "qt/*:qtbase": True,
        "qt/*:essential_modules": False,
        "qt/*:qtmultimedia": False,
        "qt/*:with_mysql": False,
        "qt/*:with_pq": False,
        "qt/*:with_odbc": False,
        "qt/*:with_openal": False,
        "qt/*:with_gssapi": False,
        "qt/*:with_atspi": False,
    }

    def layout(self):
        cmake_layout(self)

    def requirements(self):
        self.requires("boost/1.84.0")
        self.requires("qt/5.15.9")

    def config_options(self):
        if self.settings.os == "Windows":
            qt_opts = self.options["qt"]
            try:
                qt_opts.qtwinextras = True
            except ConanException:
                self.output.warning("Qt recipe does not expose qtwinextras option; skipping.")

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
