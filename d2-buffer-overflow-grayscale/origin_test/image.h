//===----- image.h - load image files -------------------------------------===//
//
// Copyright (c) 2017 Ciro Ceissler
//
// See LICENSE for details.
//
//===----------------------------------------------------------------------===//
//
// Class to load image file, only supports png format.
//
//===----------------------------------------------------------------------===//

#ifndef IMAGE_H_
#define IMAGE_H_

#include <png.h>
#include <stdlib.h>
#include <iostream>

class Image {
 private:
  png_byte color_type;
  png_byte bit_depth;

  void map_to_array();

 public:
  Image() {}

  explicit Image(const std::string& filename) {
    std::cout << "[image] loading file: " << filename << std::endl;

    this->read_png_file(filename);
  }

  unsigned int* array_in;
  unsigned int* array_out;

  void map_back();

  ~Image() {}

  int width;
  int height;
  png_bytep *row_pointers;

  void read_png_file(const std::string& filename);
  void write_png_file(const std::string& filename);
  void compare(const std::string& filename);
};

#endif  // IMAGE_H_

