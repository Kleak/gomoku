part of Gomoku;

class Pion extends Pos {
  int  _color;

  Pion(x, y, [this._color = -1]) : super(x, y);

  int get color => this._color;

  String toString() => "${this.x} ${this.y} ${this.color}";
}