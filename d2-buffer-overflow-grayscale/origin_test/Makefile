CXX = g++
ARGS = -O2 -g
LIBS = -L../../common/libvai/lib -I../../common/libvai/include -lhardcloud -lMPF_VAI -lvai-c-ase -lpng
TARGET = grayscale
SRCS = main.cpp image.cpp
SRCS_FILES = $(foreach F, $(SRCS), $(F))

all:
	$(CXX) $(ARGS) $(SRCS_FILES) $(LIBS) -o $(TARGET)

clean:
	rm -rf $(TARGET)
