from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from Cython.Build import cythonize
import os

os.environ['CC'] = os.environ['CXX'] = 'g++'
os.environ['CFLAGS'] = os.environ['CXXFLAGS'] = '--std=c++11 -W -Wall -O3'

setup(
    name='c4fast',
    ext_modules=cythonize(Extension(
        'c4fast',
        sources=['c4fast.pyx'],  # the Cython source and
        language='gcc',
    )),
    cmdclass = {'build_ext': build_ext}
)
