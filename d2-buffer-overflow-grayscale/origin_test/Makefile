CXX = g++
ARGS = -O2 -g
LIBS = -L/home/jcma/.local/lib -I/home/jcma/.local/include -lhardcloud -lMPF_VAI -lvai-c-ase -lpng
TARGET = gaussian
SRCS = main.cpp image.cpp
SRCS_FILES = $(foreach F, $(SRCS), $(F))

all:
	$(CXX) $(ARGS) $(SRCS_FILES) $(LIBS) -o $(TARGET)

clean:
	rm -rf $(TARGET)
