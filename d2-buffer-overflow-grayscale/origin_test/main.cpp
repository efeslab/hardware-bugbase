#include <iostream>
#include <math.h>
#include <time.h>
#include <hardcloud/hardcloud_app.h>

#include "image.h"

int main(int argc, char *argv[])
{
  std::string file_input("input.png");
  std::string file_output("output.png");

  Image image(file_input);

  unsigned int size   = image.height*image.width;
  unsigned int height = image.height;
  unsigned int width  = image.width;

  unsigned int* image_in  = image.array_in;
  unsigned int* image_out = image.array_out;

  HardcloudApp app;

  unsigned int *out_buf = (unsigned int*)app.alloc_buffer(size*sizeof(unsigned int));
  unsigned int *in_buf = (unsigned int*)app.alloc_buffer(size*sizeof(unsigned int));

  memcpy(in_buf, image_in, size*sizeof(unsigned int));

  printf("allocation done\n");

  struct timespec ts1, ts2;
  timespec_get(&ts1, TIME_UTC);
    app.run();
  timespec_get(&ts2, TIME_UTC);

  double t = (ts2.tv_sec*1000000 + ts2.tv_nsec/1000) - (ts1.tv_sec*1000000 + ts1.tv_nsec/1000);

  printf("time: %lf ms\n", t/1000);
  printf("throughput: %lf fig/s\n", 1.0/(t/1000000));

  memcpy(image_out, out_buf, size*sizeof(unsigned int));

  image.map_back();

  image.write_png_file(file_output);
  app.delete_buffer(in_buf);
  app.delete_buffer(out_buf);

  return 0;
}

