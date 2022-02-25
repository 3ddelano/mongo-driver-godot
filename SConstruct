#!python
import os
import atexit

opts = Variables([], ARGUMENTS)

# Gets the standard flags CC, CCX, etc.
env = DefaultEnvironment()

# Define our options
opts.Add(BoolVariable('clean_obj', "Remove *.obj files?", 'no'))
opts.Add(EnumVariable('target', "Compilation target",
         'release', ['d', 'debug', 'r', 'release']))
opts.Add(EnumVariable('platform', "Compilation platform",
         'windows', ['', 'windows', 'x11', 'linux', 'osx']))
opts.Add(EnumVariable('p', "Compilation target, alias for 'platform'",
         '', ['', 'windows', 'x11', 'linux', 'osx']))
opts.Add(BoolVariable('use_llvm', "Use the LLVM / Clang compiler", 'no'))
opts.Add(PathVariable('target_path',
         'The path where the lib is installed.', 'project/addons/mongo-godot-driver/bin/'))  # Keep the library in the root of the project as a godot bug workaround
opts.Add(PathVariable('target_name', 'The library name.',
         'libmongo-godot-driver', PathVariable.PathAccept))

# Local dependency paths, adapt them to your setup
GODOT_HEADERS_PATH = "thirdparty/godot-cpp/godot-headers/"
CPP_BINDINGS_PATH = "thirdparty/godot-cpp/"
CPP_LIBRARY = "libgodot-cpp"  # name of the compiled cpp headers
# Third party libs and files
MONGO_C_LIBPATH = "bin/mongo-c-driver/lib/"
MONGO_C_INCLUDE_PATH = "bin/mongo-c-driver/include/"
MONGO_CXX_LIBPATH = "bin/mongo-cxx-driver/lib/"
MONGO_CXX_INCLUDE_PATH = "bin/mongo-cxx-driver/include/"
BOOST_INCLUDE_PATH = "D:/Program Files/boost_1_78_0"

# only support 64 at this time..
bits = 64

# Updates the environment with the option variables.
opts.Update(env)

# Process some arguments
if env['use_llvm']:
    env['CC'] = 'clang'
    env['CXX'] = 'clang++'

if env['p'] != '':
    env['platform'] = env['p']

if env['platform'] == '':
    print("No valid target platform selected.")
    quit()
else:
    print("Compiling for " + env['platform'])

# Check our platform specifics
if env['platform'] == "osx":
    env['target_path'] += 'osx/'
    CPP_LIBRARY += '.osx'
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS=['-g', '-O2', '-arch', 'x86_64',
                   '-arch', 'arm64', '-std=c++17'])
        env.Append(LINKFLAGS=['-arch', 'x86_64', '-arch', 'arm64'])
    else:
        env.Append(CCFLAGS=['-g', '-O3', '-arch', 'x86_64',
                   '-arch', 'arm64', '-std=c++17'])
        env.Append(LINKFLAGS=['-arch', 'x86_64', '-arch', 'arm64'])

elif env['platform'] in ('x11', 'linux'):
    env['target_path'] += 'x11/'
    CPP_LIBRARY += '.linux'
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS=['-fPIC', '-g3', '-Og', '-std=c++17'])
    else:
        env.Append(CCFLAGS=['-fPIC', '-g', '-O3', '-std=c++17'])
elif env['platform'] == "windows":
    env['target_path'] += 'win64/'
    CPP_LIBRARY += '.windows'
    # This makes sure to keep the session environment variables on windows,
    # that way you can run scons in a vs 2017 prompt and it will find all the required tools
    env.Append(ENV=os.environ)

    env.Append(CCFLAGS=['-DWIN32', '-D_WIN32', '-D_WINDOWS',
               '-W3', '-GR', '-D_CRT_SECURE_NO_WARNINGS', '/std:c++17'])

    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS=['-EHsc', '-D_DEBUG', '-MDd'])
    else:
        env.Append(CCFLAGS=['-O2', '-EHsc', '-DNDEBUG', '-MD'])
    # Set the correct Discord GameSDK library
if env['target'] in ('debug', 'd'):
    CPP_LIBRARY += '.debug'
else:
    CPP_LIBRARY += '.release'

if env['platform'] == 'osx':
    CPP_LIBRARY += '.universal'
else:
    CPP_LIBRARY += '.' + str(bits)

# make sure our binding library is properly includes
env.Append(CPPPATH=['.', GODOT_HEADERS_PATH, CPP_BINDINGS_PATH + 'include/',
           CPP_BINDINGS_PATH + 'include/core/', CPP_BINDINGS_PATH + 'include/gen/'])
env.Append(LIBPATH=[CPP_BINDINGS_PATH + 'bin/', MONGO_CXX_LIBPATH])
env.Append(LIBS=[CPP_LIBRARY, MONGO_CXX_LIBPATH + '*.lib'])

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=['thirdparty/', 'src/'])
env.Append(CPPPATH=[BOOST_INCLUDE_PATH])
env.Append(CPPPATH=[MONGO_CXX_INCLUDE_PATH + 'bsoncxx/v_noabi/'])
env.Append(CPPPATH=[MONGO_CXX_INCLUDE_PATH + 'mongocxx/v_noabi/'])

sources = [Glob('src/*.cpp')]

library = env.SharedLibrary(
    target=env['target_path'] + env['target_name'], source=sources)

Default(library)

# Generates help for the -h scons option.
Help(opts.GenerateHelpText(env))

if env['clean_obj']:
    def remove_objs():
        print("Removing *.obj files")
        # Delete .obj files in /src
        for file in os.listdir('src/'):
            if file.endswith(".obj") or file.endswith(".os"):
                os.remove(os.path.join('src/', file))

    atexit.register(remove_objs)
