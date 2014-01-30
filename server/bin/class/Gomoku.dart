library Gomoku;

import "dart:io";
import "dart:async";
import "dart:math";

import 'package:args/args.dart';

part './Client.dart';
part './Plateau.dart';
part './Channel.dart';
part './Erreur.dart';
part './Position.dart';
part './SquareMap.dart';
part './Pion.dart';
part './Square.dart';
part './Utils.dart';

class Gomoku {
  String            _address;
  int               _port;
  Map               _func_map;
  Map               _clients;
  Map               _channels;

  Gomoku(List<String> args) {
    ArgResults results = this._initArgs(args);
    this._clients = new Map<String, Client>();
    this._channels = new Map<String, Channel>();
    this._initCommand();
    this._address = results["address"];
    try {
      if (results["help"] == false) {
        this._port = int.parse(results["port"]);
        Future<ServerSocket> ss = ServerSocket.bind(this._address, this._port);
        ss.then(this._serverOnCreate);
      }
      else {
        printStd("Usage: dart ./bin/main.dart [-a address] [-p port]\n");
      }
    }
    catch (e) {
      printErr("Le port doit etre un nombre\n");
    }
  }

  void _initCommand() {
    this._func_map = new Map<String, Function>();
    this._func_map["WELCOME"] = this._welcome;
    this._func_map["LOGIN"] = this._login;
    this._func_map["JOIN"] = this._join;
    this._func_map["RJOIN"] = this._rjoin;
    this._func_map["CLK"] = this._click;
    this._func_map["LOGOUT"] = this._logout;
    this._func_map["RULE"] = this._rules;
  }

  ArgResults _initArgs(List<String> args) {
    Random rand = new Random();
    ArgParser parser = new ArgParser();
    parser.addOption('address', defaultsTo: '127.0.0.1', abbr: "a");
    parser.addOption("port", defaultsTo: (rand.nextInt(200) + 4000).toString() , abbr: "p");
    parser.addFlag("help", abbr: "h", defaultsTo: false);
    return (parser.parse(args));
  }

  void _welcome(Socket socket, String data) {
    if (data == "ImPanda") {
      socket.write("WELCOME\n");
    }
    else {
      socket.write("KICK\n");
      socket.close();
    }
  }

  void _login(Socket socket, String data) {
    List tab = data.split(" ");
    if (tab.length != 1)
      throw new ClientCmdErreur("LOGIN", "ko", "Nombre de paramètre incorrecte");
    Client client = this._getClientByLogin(tab[0]);
    if (client == null)
      this._clients[tab[0]] = new Client(socket, tab[0], 0);
    else if (client.socket.remoteAddress.address == socket.remoteAddress.address)
      this._clients[client.pseudo] = new Client(socket, client.pseudo, client.pionMange);
    else
      throw new ClientCmdErreur("RETRY", "ko", " Pseudo deja utiliser");
  }

  void _join(Socket socket, String data) {
    List tab = data.split(" ");
    if (tab.length != 3)
      throw new ClientCmdErreur("JOIN", "ko", "Nombre de paramètre incorrecte");
    Client client = this._getClientByLogin(tab[0]);
    if (client == null || client.socket.remoteAddress.address != socket.remoteAddress.address)
      throw new ClientCmdErreur("JOIN", "ko", "Pas connecté");
    client.pionMange = 0;
    Channel channel = this._getChannelByName(tab[1]);
    bool type = this._getTypeByString(tab[2]);
    if (channel == null) {
      this._channels[tab[1]] = new Channel(tab[1], type);
      channel = this._channels[tab[1]];
    }
    if (channel.type != type)
      throw new ClientCmdErreur("JOIN", "ko", "Le channel existe déjà dans un autre mode de jeux");
    channel.addPlayer = client;
  }

  void _rjoin(Socket socket, String data) {
    List tab = data.split(" ");
    Client client = this._getClientByLogin(tab[0]);
    if (client == null || client.socket.remoteAddress.address != socket.remoteAddress.address)
      throw new ClientCmdErreur("RJOIN", "ko", "Pas connecté");
    printStd("rjoin ${data}\n");
  }

  void _click(Socket socket, String data) {
    List tab = data.split(" ");
    if (tab.length != 3)
      throw new ClientCmdErreur("CLK", "ko", "Nombre de paramètre incorrecte");
    Client client = this._getClientByLogin(tab[0]);
    if (client == null || client.socket.remoteAddress.address != socket.remoteAddress.address)
      throw new ClientCmdErreur("CLK", "ko", "Pas connecté");
    if (!client.actif)
      throw new ClientCmdErreur("CLK", "ko", "Ce n'est pas votre tour");
    Channel channel = this._getChannelByName(client.channel);
    if (channel == null)
      throw new ClientCmdErreur("CLK", "ko", "Vous etes dans aucun salon");
    int x = int.parse(tab[1]) - 1;
    if (x >= 19)
      throw new ClientCmdErreur("CLK", "ko", "x trop grand, case irréelle");
    int y = int.parse(tab[2]) - 1;
    if (y >= 19)
      throw new ClientCmdErreur("CLK", "ko", "y trop grand, case irréelle");
    channel.posePion(client, x, y);
  }

  void _rules(Socket socket, String data) {
    List tab = data.split(" ");
    if (tab.length != 3)
      throw new ClientCmdErreur("RULE", "ko", "Nombre de paramètre incorrecte");
    Client client = this._getClientByLogin(tab[0]);
    if (client == null || client.socket.remoteAddress.address != socket.remoteAddress.address)
      throw new ClientCmdErreur("RULE", "ko", "Pas connecté");
    Channel channel = this._getChannelByName(client.channel);
    if (channel == null)
      throw new ClientCmdErreur("RULE", "ko", "Vous etes dans aucun salon");
    String ruleName = tab[1];
    int boolean = int.parse(tab[2], onError: (s) => -1);
    if (boolean == -1)
      throw new ClientCmdErreur("RULE", "ko", "Un nombre est attendu");
    if (!channel.reglesIsActiv.containsKey(ruleName))
      throw new ClientCmdErreur("RULE", "ko", "La regle n'existe pas");
    channel.reglesIsActiv[ruleName] = boolean == 1 ? true : false;
    if (!channel.type) {
      Client adversaire = channel.player1;
      if (client.pseudo != adversaire.pseudo)
        adversaire = channel.player2;
      adversaire.socket.write("RULE $data\n");
    }
  }

  void _logout(Socket socket, String data) {
    List tab = data.split(" ");
    Client client = this._getClientByLogin(tab[0]);
    if (client == null || client.socket.remoteAddress.address != socket.remoteAddress.address)
      throw new ClientCmdErreur("JOIN", "ko", "Pas connecté");
    this._clients.remove(client.pseudo);
    Channel channel = this._getChannelByName(client.channel);
    if (channel != null)
      channel.delPlayer = client;
  }

  void _serveCmd(Socket socket, String cmd, String sdata) {
    try {
      if (!this._func_map.containsKey(cmd))
        throw new CommandeErreur("La commande ${cmd} est introuvable");
      if (sdata.contains(" "))
        this._func_map[cmd](socket, sdata.substring(cmd.length + 1, sdata.length));
      else
        this._func_map[cmd](socket, "");
    }
    on ClientCmdErreur catch (e) {
      try {
        socket.write("${e}\n");
        printErr("Client Erreur: ${e}\n");
      }
      catch (e) {
        printErr("Erreur l'hors de l'ecriture sur le socket\n");
      }
    }
    on CommandeErreur catch (e) {
      printErr("Commande Erreur: ${e}\n");
    }
    catch (e) {
      printErr("${e}\n");
    }
  }

  void _serverListen(Socket socket) {
    printStd("Ip Client ${socket.remoteAddress.address}\n");
    socket.listen((List<int> data) {
      String sdata = new String.fromCharCodes(data);
      List tabsData = sdata.split("\n");
      tabsData.forEach((String item) {
        item = item.substring(0, item.length);
        if (item != "") {
          printStd("Data: ${item}\n");
          item = cleanData(item);
          String cmd = item.split(" ")[0];
          this._serveCmd(socket, cmd, item);
        }
      });
    }, onDone: () {
      printErr("Un client c'est deconnecté\n");
      socket.close();
    }, onError: (e) {
      printErr("Erreur: ${e}\n");
    }, cancelOnError: false);
  }

  void _serverOnCreate(ServerSocket server) {
    stdout.write("Server listen on ${this._address}:${this._port}\n");
    server.listen(this._serverListen, onError: (e) {
      printErr("Error: impossible d'écouter\n");
    }, onDone: () {
      stdout.write("Ecoute terminé\n");
    }, cancelOnError: false);
  }

  bool _getTypeByString(String type) {
    if (type == "0") {
      return (false);
    }
    else if (type == "1") {
      return (true);
    }
    else {
      throw new ClientCmdErreur("JOIN", "ko", "Type incorrecte");
    }
  }

  Channel _getChannelByName(String name) => this._channels[name];
  Client _getClientByLogin(String pseudo) => this._clients[pseudo];
}