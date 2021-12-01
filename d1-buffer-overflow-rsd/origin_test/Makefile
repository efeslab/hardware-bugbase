CXX = g++
ARGS = -O2
LIBS = -I/home/jcma/.local/include -L/home/jcma/.local/lib -lhardcloud -lMPF_VAI -lvai-c-ase
TARGET = reed_solomon_decoder
SRCS = main.cpp
SRCS_FILES = $(foreach F, $(SRCS), $(F))

all:
	$(CXX) $(ARGS) $(SRCS_FILES) $(LIBS) -o $(TARGET)

clean:
	rm -rf $(TARGET)
