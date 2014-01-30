part of Gomoku;

class Plateau {
  List            _map;
  List            _clear;

  Plateau() {
    this._map = new List<int>(19);
    this._map.fillRange(0, 19, 0);
    this._clear = new List<Pion>();
  }

  int getStateCase(int x, int y) {
		int line = 0;
	  line = this._map[y];
    x = 19 - x;
    int state = line >> (x * 2);
    state = state & 3;
    return (state);
  }

  bool changeStateCase(Pion pion) {
    int etat = this.getStateCase(pion.x, pion.y);
    if (etat == 0) {
      int line = this._map[pion.y];
      int x = 19 - pion.x;
      int tmp = line + (pion.color << (x * 2));
      this._map[pion.y] = tmp;
      return (true);
    }
    return (false);
  }

  set clearCase(Pion pion) {
    int lastLine = this.getStateCase(pion.x, pion.y);
    int line = this._map[pion.y];
    int x = 19 - pion.x;
    int tmp = line - (lastLine << (x * 2));
    this._map[pion.y] = tmp;
  }

  List get clear => this._clear;
}