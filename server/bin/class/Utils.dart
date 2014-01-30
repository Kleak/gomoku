part of Gomoku;

bool DEBUG = false;

void printStd(String data) {
  if (DEBUG)
    stdout.write(data);
}

void printErr(String data) {
  stderr.write("$data");
}

int getSizeNbByBites(int tmp) {
  int sizeNb = 0;
  while (tmp != 0) {
    tmp = tmp >> 2;
    sizeNb++;
  }
  return (sizeNb);
}

String cleanData(String data) {
  while (data.contains("  "))
    data = data.replaceAll("  ", " ");
  if (data.startsWith(" ")) {
    data = data.substring(1, data.length);
  }
  if (data.endsWith(" ")) {
    data = data.substring(0, data.length - 1);
  }
  return (data);
}