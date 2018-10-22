from distutils.core import Extension, setup

from Cython.Build import cythonize


extra_compile_args = ["-std=c++11", "-Wno-all"]
include_dirs = ['src/hipocpp/include', 'src/hipocpp/include/hipo', 'lz4/lib', '/site/12gev_phys/2.2/Linux_CentOS7.2.1511-x86_64-gcc4.8.5/root/6.12.06/include']
library_dirs = ['lz4/lib', '/site/12gev_phys/2.2/Linux_CentOS7.2.1511-x86_64-gcc4.8.5/root/6.12.06/lib']
libraries = ['lz4','Core','RIO','Net','Hist','Tree','TreePlayer','Rint','Postscript','Matrix','Physics','MathCore']

hipo = Extension('hipopy',
                 define_macros=[("__LZ4__", "TRUE")],
                 sources=['src/hipocpp/src/utils.cpp',
                          'src/hipocpp/src/wrapper.cpp',
                          'src/hipocpp/src/text.cpp',
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
                 language='c++11'
                 )


setup(name='hipopy',
      version='1.0',
      description='Python module to load hipofiles for the clas12',
      ext_modules=cythonize(hipo)
      )
