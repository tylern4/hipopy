from distutils.core import Extension, setup

from Cython.Build import cythonize

import pkgconfig

lz4 = pkgconfig.parse("liblz4")
extra_compile_args = ["-std=c++17", "-Wno-all"]
include_dirs = ['src/hipocpp/include', 'src/hipocpp/include/hipo'] + lz4['include_dirs']
library_dirs = lz4['library_dirs']
libraries = lz4['libraries']

hipo = Extension('hipopy',
                 define_macros=[("__LZ4__", "TRUE")],
                 sources=['src/hipocpp/src/utils.cpp',
                          'src/hipocpp/src/wrapper.cpp',
                          'src/hipocpp/src/text.cpp',
                          'src/hipocpp/src/logging.cpp',
                          'src/hipocpp/src/node.cpp',
                          'src/hipocpp/src/data.cpp',
                          'src/hipocpp/src/reader.cpp',
                          'src/hipocpp/src/event.cpp',
                          'src/hipocpp/src/record.cpp',
                          'src/hipocpp/src/dictionary.cpp',
                          'src/hipocpp/src/writer.cpp',
                          'hipopy.pyx'],
                 include_dirs=include_dirs,
                 library_dirs=library_dirs,
                 libraries=libraries,
                 extra_compile_args=extra_compile_args,
                 language='c++17'
                 )


setup(name='hipopy',
      version='1.0',
      description='Python module to load hipofiles for the clas12',
      ext_modules=cythonize(hipo)
      )
