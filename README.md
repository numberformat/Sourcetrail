# Sourcetrail

*__Important Note:__ This project was archived by the original autors and maintainers of Sourcetrail by the end of 2021. If you want to know more about this decision, read more on our [blog](https://web.archive.org/web/20211119200517/https://www.sourcetrail.com/blog/).*

Sourcetrail is a free and open-source cross-platform source explorer that helps you get productive on unfamiliar source code.

Windows: [![Build status](https://ci.appveyor.com/api/projects/status/0c258a2opn3loyc2/branch/master?svg=true)](https://ci.appveyor.com/project/mlangkabel/sourcetrail/branch/master)

Linux: [![Build Status](https://travis-ci.org/CoatiSoftware/Sourcetrail.svg?branch=master)](https://travis-ci.org/CoatiSoftware/Sourcetrail)

__Links__
* [Download](https://github.com/CoatiSoftware/Sourcetrail/releases)
* [Quick Start Guide](DOCUMENTATION.md#getting-started)
* [Documentation](DOCUMENTATION.md)
* [Changelog](CHANGELOG.md)

!["Sourcetrail User Interface"](docs/readme/user_interface.png "Sourcetrail User Interface")

Sourcetrail is:
* free
* working offline
* operating on Windows, macOS and Linux
* supporting C, C++, Java and Python
* offering an SDK ([SourcetrailDB](https://github.com/CoatiSoftware/SourcetrailDB)) to write custom language extensions

## Sourcetrail on Patreon

The open-source development and regular software releases are made possible entirely by the support of [these awesome patrons](SPONSORS.md)!

## Using Sourcetrail

To setup Sourcetrail on your machine, you can either download the respective build for your operating system from our list of [Releases](https://github.com/CoatiSoftware/Sourcetrail/releases) and install it on your machine, or use one of the following package managers:

* Use the [Chocolatey package](https://chocolatey.org/packages/sourcetrail) with `choco install sourcetrail`

After your installation is complete, follow our [Quick Start Guide](DOCUMENTATION.md#getting-started) to get to know Sourcetrail.

## How to Report Issues

You can post all your feature requests and bug reports on our [issue tracker](https://github.com/CoatiSoftware/Sourcetrail/issues).

### Reporting

Use the following template:

* platform version:
* Sourcetrail version:
* description of the problem:
* steps to reproduce the problem:

### Supporting

If you want to support a certain feature request or you have the same bug that another user already reported, please let us know:
* post a comment with "+1" to the issue
* or send an email to support@sourcetrail.com with the issue ID

## How to Contribute

* Please read and follow the steps in [CONTRIBUTING.md](CONTRIBUTING.md) file.
* You may want to look out for issues labeled [good first issue](https://github.com/CoatiSoftware/Sourcetrail/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22) to find some initial tasks to tackle.
* If you are looking for more information about Sourcetrail software development, please refer to our [wiki](https://github.com/CoatiSoftware/Sourcetrail/wiki).

# How to Build

Building Sourcetrail requires several dependencies to be in place on your machine. However, our CMake based setup allows to disable indexing support for specific languages which reduces the number of dependencies to a minimum.

## Building the Base Application

### Required Tools

* __CMake v3.12 (required for Windows, Linux and MacOS)__
    * __Reason__: Used to generate a build configuration for your build system
    * __Download__: https://cmake.org/download

* __Git (required for Windows, Linux and MacOS)__
    * __Reason__: Used for version control and to automatically generate the Sourcetrail version number from commits and tags
    * __Download__: https://git-scm.com/download
    * __Remarks__: Make sure `git` is added to your `PATH` environment variable before running CMake

* __Visual Studio (required for Windows)__
    * __Reason__: Used for building Sourcetrail
    * __Download__: https://visualstudio.microsoft.com/downloads/

* __ccache (optional for Linux and MacOS)__
    * __Reason__: Used to speed up rebuilds if found in `PATH`
    * __Download__: https://ccache.dev/download.html

### Required dependencies

* __Boost 1.67__
    * __Reason__: Used for file system access and interprocess communication
    * __Prebuilt Download for Windows__: https://sourceforge.net/projects/boost/files/boost-binaries/
    * __Building for Unix__:
        ```
        $ ./bootstrap.sh --with-libraries=filesystem,program_options,system,date_time
        $ ./b2 --link=static --variant=release --threading=multi --runtime-link=static --cxxflags=-fPIC
        ```

* __Qt 5.12.3__
    * __Reason__: Used for rendering the GUI and for starting additional (indexer) processes.
    * __Prebuilt Download__: http://download.qt.io/official_releases/qt/

### New: Fetching Boost and Qt with Conan (recommended)

Instead of installing Boost and Qt manually, you can now pull them in with [Conan 2](https://conan.io/). The `conanfile.py` in the repository declares the minimal dependency set (Boost filesystem/system/program_options/date_time and Qt Widgets/Network/PrintSupport/Svg/WinExtras on Windows) and pins them to `boost/1.84.0` and `qt/5.15.9`.

1. Install Conan 2 (`pip install conan`).
2. Detect a default profile once: `conan profile detect --force`.
3. From the repository root run (adjust build type and output folder as you prefer):
    ```
    conan install . --output-folder=build/Release --build=missing -s build_type=Release
    ```
    This step downloads Boost and Qt, configures the `CMakeDeps` + `CMakeToolchain` files and keeps the resulting toolchain in `<output-folder>/<build_type>/generators/conan_toolchain.cmake` (for the command above that is `build/Release/build/Release/generators/conan_toolchain.cmake`).
4. Configure CMake pointing to the generated toolchain file. Example for Unix:
    ```
    cmake -S . -B build/Release -DCMAKE_TOOLCHAIN_FILE=build/Release/build/Release/generators/conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
    ```
    On Windows configure the generator that you need while still passing `-DCMAKE_TOOLCHAIN_FILE`.
5. Build with your usual workflow (`cmake --build build/Release --target Sourcetrail`, Visual Studio, etc.).

All optional dependencies described below can stay disabled until you need the respective language package.

#### macOS 15+ prerequisites

Apple's current Command Line Tools ship most C++ standard library headers inside the SDK instead of the traditional `/usr/include/c++` folder. Before running `conan install` on macOS 14/15 make sure to expose those headers and pass your current deployment target, otherwise packages such as Boost, libpq or Qt will fail to build:

```
export SDKROOT=$(xcrun --show-sdk-path)
export CPLUS_INCLUDE_PATH="$SDKROOT/usr/include/c++/v1"
conan install . --output-folder=build/Release --build=missing -s build_type=Release -s os.version=$(sw_vers -productVersion | cut -d. -f1-2)
```

Setting `os.version` (or updating the default Conan profile with that setting) propagates a matching `MACOSX_DEPLOYMENT_TARGET`, which avoids `-Wunguarded-availability` build failures for dependencies such as libpq and Qt.

The provided `conanfile.py` toggles off Qt features that would otherwise pull MySQL/PostgreSQL/ODBC/OpenAL into the build. If you need those plugins later simply flip the corresponding `qt/*:with_` options when running `conan install`.

### Building

#### On Windows
* To set up your build environment run:
    ```
    $ git clone https://github.com/CoatiSoftware/Sourcetrail.git
    $ cd Sourcetrail
    $ mkdir -p build/win64
    $ cd build/win64
    $ conan install ../.. --build=missing -s build_type=Release
    $ cmake -G "Visual Studio 15 2017 Win64" -DCMAKE_TOOLCHAIN_FILE=Release/generators/conan_toolchain.cmake ../..
    ```
    _Hint: If you are using the CMake GUI, we recommend that you activate advanced mode. Also you may be required to add some of the defines via the "Add Entry" button._

* After generating the build configuration, just open the Sourcetrail.sln file that was generated by CMake and build the Sourcetrail project.

#### On Unix

* To set up your build environment run:
    ```
    $ cd Sourcetrail
    $ mkdir -p build/Release
    $ cd build/Release
    $ conan install ../.. --build=missing -s build_type=Release
    $ cmake -DCMAKE_BUILD_TYPE="Release" -DCMAKE_TOOLCHAIN_FILE=Release/generators/conan_toolchain.cmake ../..
    ```
* Now start the build with:
    ```
    $ make Sourcetrail
    ```

### Running

* Run Sourcetrail from within the build directory. During execution Sourcetrail needs resources from `bin/app/data` and `bin/app/user`. CMake creates symlinks within the build directory that make these directories accessible.

_If you prefer to provide Boost and Qt manually, skip the `conan install` step and continue passing `-DBOOST_ROOT` and `-DQt5_DIR` the way the project was configured previously._


## Enable C/C++ Language Support

### Required dependencies

* __LLVM/Clang 11.0.0__
    * __Reason__: Used for running the preprocessor on the indexed source code, building and traversing an Abstract Syntax Tree and generating error messages.
    * __Building__: Make sure to check out the correct tag: `git checkout llvmorg-11.0.0`
    * __Building for Windows__: Follow [these steps](https://clang.llvm.org/get_started.html) to build the project. Run the cmake command exactly as described.
    * __Building for Unix__: Follow this [installation guide](http://clang.llvm.org/docs/LibASTMatchersTutorial.html) to build the project. Make sure to build with `-DLLVM_ENABLE_RTTI=ON`.

### Building

* Run CMake with these additional options:
    ```
    -DClang_DIR=<path/to/llvm_build>/lib/cmake/clang
    -DBUILD_CXX_LANGUAGE_PACKAGE=ON
    ```
* Build Sourcetrail as described [above](#building).

## Enable Java Language Support

### Required dependencies

* __JDK 1.8__
    * __Reason__: Used to build the Java indexer and make it callable from the C++ code via JNI.
    * __Remarks__: Make sure that `<jdk_root>/bin` is available in your `PATH` environment variable and that the `JAVA_HOME` environment variable is set:
        ```
        JAVA_HOME=<path/to/Java>/jdk1.x.x_xxx
        ```

* __Maven__
    * __REASON__: Used within Sourcetrail's automated tests.
    * __Remarks__:  Make sure `.../apache-maven-x.x.x/bin` is available in your `PATH` environment variable and that both `M2_HOME` and `MAVEN_HOME` environment variables are set:
        ```
        M2_HOME=.../apache-maven-x.x.x
        MAVEN_HOME=.../apache-maven-x.x.x
        ```

### Building

* Run CMake with these additional options:
    ```
    -DBUILD_JAVA_LANGUAGE_PACKAGE=ON
    ```
* Build Sourcetrail as described [above](#building).

## Enable Python Language Support

### Required Tools

* __7z (required for Windows)__
    * __REASON__: Used to extract the prebuilt SourcetrailPythonIndexer which is downloaded automatically during build execution.

### Building

* Run CMake with these additional options:
    ```
    -DBUILD_PYTHON_LANGUAGE_PACKAGE=ON
    ```
* Build Sourcetrail as described [above](#building).


## Creating the deployment Package

### Windows

#### Required Tools

* __Visual Studio (required for Windows)__
    * __Reason__: Used for building the Sourcetrail Windows installer.
    * __Remarks__: Make sure to install the `.Net desktop development` workload.
    * __Download__: https://visualstudio.microsoft.com/downloads/

* __Wix 3.11__
    * __Reason__: Used to build the `sourcetrail.msi` Windows installer.
    * __Remarks__: Make sure to add `<path/to>/WiX Toolset v3.11/bin` to your `PATH` environment variable.
    * __Download__: https://wixtoolset.org/releases/

* __Wix extension for Visual Studio__
    * __Reason__: Used to run Wix from the Visual Studio build environment.
    * __Download__: https://marketplace.visualstudio.com/items?itemName=WixToolset.WixToolsetVisualStudio2017Extension

* __JRE__
    * __Reason__: Used for indexing the java sample project that ships with the package.

* __WinRAR__
    * __Reason__: Used for creating the final zip files for the installer and the portable package.
    * __Remarks__: Make sure to add `<path/to>/WinRAR` to your `PATH` environment variable.

#### Building

* Run `./script/deploy_windows.sh` from your Developer Command Prompt for Visual Studio. The script which will generate a 64bit build and packages it into a portable `.zip` file and a Wix-based Windows installer, each.

### macOS

After building, run the `bundle_install.sh` script within the build directory which will create a `Sourcetrail.app` bundle and generate a `Sourcetrail_<version>.dmg` container.

### Linux

Run `./setup/Linux/createPackages.sh` from the main directory, which creates both a `.tar.gz` and a `.AppImage` package in the main directory. Packaging depends on [linuxdeployqt](https://github.com/probonopd/linuxdeployqt).


# How to Run the Tests

The automated test suite of Sourcetrail is powered by [Catch2](https://github.com/catchorg/Catch2). To run the tests, simply execute the `Sourcetrail_test` binary. Before executing, please make sure to set the working directory to `./bin/test`.


# License

Sourcetrail is licensed under the [GNU General Public License Version 3](LICENSE.txt).

# Trademark

The "Sourcetrail" name is a trademark owned by Coati Software and is not included within the assets licensed under the GNU GPLv3.
