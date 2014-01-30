part of Gomoku;

class Square extends Pos {
  int   _width;
  int   _height;

  Square(x, y, this._width, this._height)
    : super(x, y);

  int get width => this._width;
  int get height => this._height;
}