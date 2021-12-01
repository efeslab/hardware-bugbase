CXX = g++
ARGS = -O2
LIBS = -L../../common/libvai/lib -I../../common/libvai/include -lhardcloud -lMPF_VAI -lvai-c-ase
TARGET = reed_solomon_decoder
SRCS = main.cpp
SRCS_FILES = $(foreach F, $(SRCS), $(F))

all:
	$(CXX) $(ARGS) $(SRCS_FILES) $(LIBS) -o $(TARGET)

clean:
	rm -rf $(TARGET)
