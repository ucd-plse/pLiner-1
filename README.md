# pLiner

**pLiner** is a framework that helps programmers identify locations in the source of numerical code that are highly affected by compiler optimizations.  

Compiler optimizations can alter significantly the numerical results of scientific computing applications. When numerical results differ significantly between compilers, optimization levels, and floating-point hardware, these numerical inconsistencies can impact programming productivity. **pLiner** is a framework that helps programmers identify locations in the source code that are highly affected by compiler optimizations. **pLiner** uses a novel approach to identify such code locations by enhancing the floating-point precision of variables and expressions. Using a guided search to locate the most significant code regions, **pLiner** can report to users such locations at different granularities, file, function, and line of code.

# Getting Started

## Requirements to use pLiner
- pLiner is implemented as a clang tool. Installing clang/LLVM compiler is a prerequisite to use pLiner. So far, we have tested pLiner on clang/LLVM 9.0.1. Please follow the instructions below for building and installing clang/LLVM.
- pLiner uses [nlohmann::json](https://github.com/nlohmann/json) to parse json files in C/C++. Download file `json.hpp` from [https://github.com/nlohmann/json/blob/develop/single_include/nlohmann/json.hpp](https://github.com/nlohmann/json/blob/develop/single_include/nlohmann/json.hpp) (version 3.5.0) and place it in the directory `pLiner-sc20/clang-tool` before using pLiner.
- So far pLiner only supports C/C++.

## Building clang/LLVM and pLiner
  1. Building clang/LLVM 9.0.1:
  ```
  git clone https://github.com/llvm/llvm-project.git clang-llvm
  git checkout llvmorg-9.0.1
  cd ~/clang-llvm
  mkdir build && cd build
  cmake -G Ninja ../llvm -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" -DLLVM_BUILD_TESTS=ON
  ninja
  ninja check       # Test LLVM only.
  ninja clang-test  # Test Clang only.
  ninja install
  ```

  Note: Refer to https://clang.llvm.org/docs/LibASTMatchersTutorial.html in case you need instructions for installing `cmake` and/or `ninja`.
  
  2. Clone pLiner in the clang-tools-extra directory and build it:
  ```
  cd ../clang-tools-extra
  git clone https://github.com/ucd-plse/pLiner-sc20.git
  echo "add_subdirectory(pLiner-sc20/clang-tool)" >> CMakeLists.txt
  cd ../build
  ninja
  ```
  3. Export path to pLiner (this command may differ depending on shell):
  ```
  export PATH=/home/crubio/research/libraries/clang-llvm/build/bin:$PATH
  ```

## Using pLiner

### Example

We use a simple C program to show how to use pLiner.   

The C program `vtest.c` is generated by a floating-point random program generator, [Varity](https://www.osti.gov/biblio/1581779-varit).
It produces inconsistent result when compiled with `gcc -O3 -ffast-math` compared to `gcc -O0`. pLiner isolated a line of the code in the source (Line 25) as the origin of the compiler-induced inconsistency. pLiner also provided a transformated version of the program `vtest_trans.c` in which the isolated line of the code has been transformed to higher precision, and the transformed program `vtest_trans.c` produces consistent results between `gcc -O3 -ffast-math` and `gcc -O0`.

  1. go to `example` directory  
    `$ cd pLiner/example`  
  2. compile `vtest.c` with both `gcc -O3 -ffast-math` and `gcc -O0`, and compare the results  
    `make`  
    `vtest_O0` corresponds to the executable generated by compiling `vtest.c` with `gcc -O0`, and `vtest_O3` corresponds to the executable generated by compiling `vtest.c` with `gcc -O3 -ffast-math`.  
    `./cmp.sh vtest`  
    `vtest_O0` produces `1.7071999999999999e+208` when executed with the given input data while `vtest_O3` produces `-1.8508999968058596e-316`; the difference is very large.  
  3. run pLiner  
    `python pLiner/scripts/search.py vtest.c "--"`   
    The first argument `vtest.c` is the input program; the second argument `"--"` indicates that to compile the input program there are no header files/librares to specify in the compilation command. Additionally, if there are any such compilation options such as "-I $PATH-TO-HEADERS", specify them following "--" in the second argument, e.g., "-- -I $PATH-TO-HEADERS". 

   * pLiner found the root cause of the inconsistency (function `compute`, line 25):  
    ` compute :`  
    `    line 25`    

   * pLiner generated a transformed program `vtest_trans.c`:  
     compile `vtest_trans.c` with both `gcc -O3 -ffast-math` and `gcc -O0`, and compare the results  
     `make`  
     `./cmp.sh vtest_trans`  
     Both `vtest_trans_O0` and `vtest_trans_O3` produce `1.7071999999999999e+208`. The results are consistent with `vtest_O0`.  
### Use pLiner for your programs

You can follow the instructions as shown in the example to run pLiner for your own programs. Specifically, 

* Specify the compiler, compilation options that induce inconsistent results, and an error threshold in `run.sh`  
 In the example above, those are specified in `run.sh` as
 ```
 CC="/usr/bin/gcc"
 CFLAGS=" -O0 -g -std=c99"
 CFLAGS_trouble=" -O3 -ffast-math -g -std=c99"
 THRESHOLD=8 
 ```
 `CC` specifies the compiler; `CFLAGS` specifies the compilation options that are used to produce ground-truth results and `CFLAGS_trouble` specifies the compilation options that induce inconsistent results; lastly, `THRESHOLD` specifies the number of digits that are required to be same with the ground truth for consistency check.
 
* Specify your program file in the first argument, and the compilation options needed to compile the program in the second argument such as 
`python pLiner/scripts/search.py vtest.c "--"` in the example.

 ## License

pLiner is distributed under the terms of the Apache-2.0 with LLVM-exception license. All new contributions must be made under this license.
 
 See LICENSE and NOTICE for details.
 
 LLNL-CODE-812209
