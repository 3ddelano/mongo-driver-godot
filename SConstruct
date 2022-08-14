#!python
import os
import atexit
from platform import platform


# Workaround for MinGW. See:
# http://www.scons.org/wiki/LongCmdLinesOnWin32
if os.name == "nt":
    import subprocess

    def my_sub_process(cmdline, env):
        # print "SPAWNED : " + cmdline
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        proc = subprocess.Popen(
            cmdline,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            startupinfo=startupinfo,
            shell=False,
            env=env,
        )
        data, err = proc.communicate()
        rv = proc.wait()
        if rv:
            print("=====")
            print(err.decode("utf-8"))
            print("=====")
        return rv

    def my_spawn(sh, escape, cmd, args, env):

        newargs = " ".join(args[1:])
        cmdline = cmd + " " + newargs

        rv = 0
        if len(cmdline) > 32000 and cmd.endswith("ar"):
            cmdline = cmd + " " + args[1] + " " + args[2] + " "
            for i in range(3, len(args)):
                rv = my_sub_process(cmdline + args[i], env)
                if rv:
                    break
        else:
            rv = my_sub_process(cmdline, env)

        return rv

opts = Variables([], ARGUMENTS)

# Gets the standard flags CC, CCX, etc.
env = DefaultEnvironment()

# Define our options
opts.Add(BoolVariable('use_mingw',
        'Use the MinGW compiler instead of MSVC - only effective on Windows', False))
opts.Add(BoolVariable('clean_obj', "Remove *.obj files?", 'no'))
opts.Add(EnumVariable('target', "Compilation target",
         'debug', ['d', 'debug', 'r', 'release']))
opts.Add(EnumVariable('platform', "Compilation platform",
         'windows', ['', 'windows', 'x11', 'linux', 'osx']))
opts.Add(EnumVariable('p', "Compilation target, alias for 'platform'",
         '', ['', 'windows', 'x11', 'linux', 'osx']))
opts.Add(BoolVariable('use_llvm', "Use the LLVM / Clang compiler", 'no'))
opts.Add(PathVariable('target_path',
         'The path where the lib is installed.', 'addons/mongo-driver-godot/bin/'))  # Keep the library in the root of the project as a godot bug workaround
opts.Add(PathVariable('target_name', 'The library name.',
         'libmongo-driver-godot', PathVariable.PathAccept))

# Local dependency paths, adapt them to your setup
GODOT_HEADERS_PATH = "thirdparty/godot-cpp/godot-headers/"
CPP_BINDINGS_PATH = "thirdparty/godot-cpp/"
CPP_LIBRARY = "libgodot-cpp"  # name of the compiled cpp headers
# Third party libs and files
MONGO_C_LIBPATH = "bin/mongo-c-driver/lib/"
MONGO_C_INCLUDE_PATH = "bin/mongo-c-driver/include/"
MONGO_CXX_LIBPATH = "bin/mongo-cxx-driver/lib/"
MONGO_CXX_INCLUDE_PATH = "bin/mongo-cxx-driver/include/"

# only support 64 at this time..
bits = 64

# Updates the environment with the option variables.
opts.Update(env)

# Process some arguments
if env['p'] != '':
    env['platform'] = env['p']

if env['platform'] == '':
    print("No valid target platform selected.")
    quit()
else:
    print("Compiling for " + env['platform'])

# Check our platform specifics
if env['platform'] == "osx":
    env['use_llvm'] = True
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

elif env['platform'] == 'windows':
    CPP_LIBRARY += '.windows'
    
    if env["use_mingw"]:
        # Don't Clone the environment. Because otherwise, SCons will pick up msvc stuff.
        env = Environment(ENV=os.environ, tools=['mingw'])
        
        env.Append(CCFLAGS=['-O3', '-Wwrite-strings'])
        env.Append(CXXFLAGS=['-std=c++17'])
        env.Append(LINKFLAGS=[
            '--static',
            '-Wl,--no-undefined',
            '-static-libgcc',
            '-static-libstdc++',
        ])

        env['SPAWN'] = my_spawn
        env.Replace(ARFLAGS=["q"])
    else:
        # This makes sure to keep the session environment variables on windows,
        # that way you can run scons in a vs 2017 prompt and it will find all the required tools
        env.Append(ENV=os.environ)
        opts.Update(env)

        env.Append(CCFLAGS=['-DWIN32', '-D_WIN32', '-D_WINDOWS',
                '-W3', '-GR', '-D_CRT_SECURE_NO_WARNINGS', '/std:c++17'])

        if env['target'] in ('debug', 'd'):
            env.Append(CCFLAGS="/D _SILENCE_ALL_CXX17_DEPRECATION_WARNINGS")
            env.Append(CCFLAGS=['-EHsc', '-D_DEBUG', '-MDd'])
        else:
            env.Append(CCFLAGS=['-O2', '-EHsc', '-DNDEBUG', '-MD'])
    
    env['target_path'] += 'win64/'

if env['target'] in ('debug', 'd'):
    CPP_LIBRARY += '.debug'
else:
    CPP_LIBRARY += '.release'

CPP_LIBRARY += '.' + str(bits)

if env['use_llvm']:
    env['CC'] = 'clang'
    env['CXX'] = 'clang++'

# make sure our binding library is properly includes
env.Append(CPPPATH=['.', GODOT_HEADERS_PATH, CPP_BINDINGS_PATH + 'include/',
           CPP_BINDINGS_PATH + 'include/core/', CPP_BINDINGS_PATH + 'include/gen/'])
env.Append(LIBPATH=['bin/godot-cpp'])
env.Append(LIBS=[CPP_LIBRARY])

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=['thirdparty/', 'src/'])
env.Append(CPPPATH=[MONGO_CXX_INCLUDE_PATH + 'bsoncxx/v_noabi/'])
env.Append(CPPPATH=[MONGO_CXX_INCLUDE_PATH + 'mongocxx/v_noabi/'])
env.Append(LIBPATH=[MONGO_CXX_LIBPATH])
env.Append(LIBS=['mongocxx', 'bsoncxx'])
env.Append(RPATH=env.Literal('\\$$ORIGIN'))

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
