cmake_minimum_required (VERSION 2.8)


#IF(WIN32)
	INCLUDE_DIRECTORIES(
		${CMAKE_SOURCE_DIR}/
		${CMAKE_SOURCE_DIR}/kernel/
	)
#ENDIF (WIN32)


project (FMMTL)

include_directories(include)

# SPECIFY SOURCE FILES
file(GLOB_RECURSE SOURCES_REC RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
	"fmmtl/*.h" 
	"fmmtl/*.hpp" 
	"fmmtl/*.cuh" 
	"kernel/*.cu"
	"kernel/*.hpp"
	"unit_tests/compiles.cpp"
)


SET(EXEC_NAME FMMTL)



# CUDA
find_package(CUDA)
enable_language(CUDA)
SET(CUDA_SEPARABLE_COMPILATION on)
LIST(APPEND CUDA_NVCC_FLAGS -gencode arch=compute_60,code=sm_60)
LIST(APPEND CUDA_NVCC_FLAGS "--disable-warnings")

# Define nvcc compile flags   TODO: Detect and generate appropriate sm_XX
# NVCCFLAGS := -arch=sm_35 -O3 --compiler-options "$(CXXFLAGS)" -Xcompiler -Wno-unused-parameter #-Xptxas="-v"


	#LIST(APPEND CUDA_NVCC_FLAGS --compiler-options -fno-strict-aliasing -lineinfo -use_fast_math -Xptxas -dlcm=cg)
	set(CUDA_64_BIT_DEVICE_CODE ON)
	#add_definitions(-m64)
	#LIST (APPEND CMAKE_CXX_FLAGS -m64)
	#LIST(APPEND CMAKE_CXX_FLAGS "-std=c++0x -O3 -ffast-math -Wall")
	#LIST(APPEND CMAKE_CXX_FLAGS "-stdlib=libstdc++ -lstdc++")
	#set(CUDA_64_BIT_DEVICE_CODE ON)

# WITH CUDA:
CUDA_ADD_EXECUTABLE(${EXEC_NAME} ${SOURCES_REC})
# WITHOUT CUDA:
#add_executable(${EXEC_NAME} ${SOURCES})


# MAKE VS SHOW FILES IN DIRECTORY STRUCTURE
foreach(source IN LISTS SOURCES_REC)
    get_filename_component(source_path "${source}" PATH)
    string(REPLACE "/" "\\" source_path_msvc "${source_path}")
    source_group("${source_path_msvc}" FILES "${source}")
endforeach()


# COMPILE FLAGS
SET(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS}") # -stdlib=libc++ -O3" )

# LINK FLAGS
SET(CMAKE_EXE_LINKER_FLAGS  "${CMAKE_EXE_LINKER_FLAGS}")

# LINK
TARGET_LINK_LIBRARIES(${EXEC_NAME} ${EXTRA_LIBS} ${CUDA_LIB})
