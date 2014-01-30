part of Gomoku;

class SquareMap extends Square {
  List  _map;

  SquareMap(this._map, Square square)
    : super(square.x, square.y, square.width, square.height);

  List get map => this._map;
}