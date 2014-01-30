part of Gomoku;

class ClientCmdErreur {
  final String  _msg;
  final String  _type;
  final String  _functionName;

  const ClientCmdErreur(this._functionName,[ this._type = "", this._msg = ""]);

  String toString() {
    String data = this._functionName;
    if (this._type != "")
      data += " ${this._type}";
    if (this._msg != "")
      data += " ${this._msg}";
    return (data);
  }
}

class IaCmdErreur {
  final String  _functionName;
  final String  _msg;

  const IaCmdErreur(this._functionName, this._msg);

  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.write(this._functionName);
    sb.write(" ");
    sb.write(this._msg);
    return (sb.toString());
  }
}

class ReglesErreur {
  final String  _msg;

  const ReglesErreur(this._msg);

  String toString() => "${this._msg}";
}

class CommandeErreur {
  final String  _msg;

  const CommandeErreur(this._msg);

  String toString() => "${this._msg}";
}