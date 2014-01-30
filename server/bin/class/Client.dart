part of Gomoku;

class Client {
  String    _pseudo;
  Socket    _socket;
  bool      _actif;
  int       _num_players;
  int       _pion_mange;
  String    _channel;

  Client(this._socket, this._pseudo, this._pion_mange, [this._actif = false]);

  Socket get socket => this._socket;
  bool get actif => this._actif;
  String get channel => this._channel;
  int get num => this._num_players;
  String get pseudo => this._pseudo;
  int get pionMange => this._pion_mange;

  set actif(bool value) => this._actif = value;
  set pseudo(String value) => this._pseudo = value;
  set channel(String value) =>this._channel = value;
  set pionMange(int value) => this._pion_mange = value;
}