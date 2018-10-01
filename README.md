## 0. Purpose 

This document contains step-by-step instructions to proceed with a (hopefully) successful installation of the SIESTA (Spanish Initiative for Electronic Simulations with Thousands of Atoms) software on Linux (tested with Ubuntu 18.04) using the Intel Compilers and Intel MPI implementation for parallelism. 

To achieve a parallel build of SIESTA you should ﬁrst determine which type of parallelism you need. It is advised to use MPI for calculations with a moderate number of cores. For hundreds of threads, hybrid parallelism using both MPI and OpenMP may be required.

## 1. Install prerequisite software

We assume you are running the commands below as root by doing something like that: `sudo su`.

```
apt install libreadline-dev m4 -y
```

## 2. Create required installation folder

*Note: In what follows, we assume that your user has write permission to the following install directories (that's why we use chown/chmod below). Additionally, your user must be in the sudoers file.*

```
SIESTA_DIR=/opt/siesta
mkdir $SIESTA_DIR
```

We also assume that you have previouly installed and configured Intel Compilers and Tools correctly, i.e., that ifort, icc etc... are in your PATH by doing something like this in your `/etc/bash.bashrc` file or directly via bash:

```
source /opt/intel/parallel_studio_xe_2019/psxevars.sh > /dev/null 2>&1
```

Ensure that Intel environment variables are correctly setup with: 

```
which mpicc 
which mpiifort 
which mpirun
```

## 3. Install siesta from source

```
cd $SIESTA_DIR
wget https://launchpad.net/siesta/4.1/4.1-b3/+download/siesta-4.1-b3.tar.gz
tar xzf ./siesta-4.1-b3.tar.gz && rm ./siesta-4.1-b3.tar.gz
```

#### 3.1. Install siesta library dependencies from source

We need to prepare the build environment for using Intel compilers:
```
export CC=icc
export CXX=icpc
export CFLAGS='-O3 -xHost -ip -no-prec-div -static-intel'
export CXXFLAGS='-O3 -xHost -ip -no-prec-div -static-intel'
export F77=ifort
export FC=ifort
export F90=ifort
export FFLAGS='-O3 -xHost -ip -no-prec-div -static-intel'
export CPP='icc -E'
export CXXCPP='icpc -E'
```

Now build netcdf with Intel compilers (be patient, grab a coffee):

```
cd $SIESTA_DIR/siesta-4.1-b3/Docs 
wget https://zlib.net/zlib-1.2.11.tar.gz
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.18/src/hdf5-1.8.18.tar.bz2
wget -O netcdf-c-4.4.1.1.tar.gz https://github.com/Unidata/netcdf-c/archive/v4.4.1.1.tar.gz
wget -O netcdf-fortran-4.4.4.tar.gz https://github.com/Unidata/netcdf-fortran/archive/v4.4.4.tar.gz
(./install_netcdf4.bash 2>&1) | tee install_netcdf4.log
```

If anything goes wrong in this step you can check the `install_netcdf4.log` log file.

#### 3.2. Create your custom 'arch.make' file for GCC + MPI build 

First create a custom target arch directory:

```
mkdir $SIESTA_DIR/siesta-4.1-b3/ObjIntel && cd $SIESTA_DIR/siesta-4.1-b3/ObjIntel
wget -O arch.make https://raw.githubusercontent.com/bgeneto/siesta4.1-intel/master/intel-mpi-arch.make
```

#### 3.3. Build siesta executable 

```
cd $SIESTA_DIR/siesta-4.1-b3/ObjIntel
sh ../Src/obj_setup.sh
make OBJDIR=ObjIntel
```

## 5. Test siesta

Let's copy siesta `Test` directory to our home (where we have all necessary permissions): 

```
mkdir $HOME/siesta/
cp -r $SIESTA_DIR/siesta-4.1-b3/Tests/ $HOME/siesta/Tests/
```

Now create a symbolic link to siesta executable 

```
cd $HOME/siesta
ln -s $SIESTA_DIR/siesta-4.1-b3/ObjIntel/siesta
```

Finally run some test job:

```
cd $HOME/siesta/Tests/h2o_dos/
make
```

We should see the following message:
```
===> SIESTA finished successfully
```

Pain attention to the number of threads used. If you requested only two threads (-np 2) and the job is consuming all your threads then you have a configuration problem in your libraries (common while mixing Intel compilers with GCC).
