part of Gomoku;

class Channel {
  String          _name;
  Client          player1;
  Client          player2;
  Map             _spectateur;
  Plateau         _plateau;
  bool            _type;
  List            _fthree;
  List            _sthree;
  Map             reglesIsActiv;
  Map             _funcListIa;

  Channel(this._name, this._type) {
    this._spectateur = new Map<String, Client>();
    this._plateau = new Plateau();
    this.reglesIsActiv = new Map<String, bool>();
    this.reglesIsActiv['DOUBLE_THREE'] = false;
    this.reglesIsActiv['FIVE_BROCK'] = false;
  }

  void _pvp(Client client, int x, int y) {
    Client adversaire;
    int color = 0;
    if (this.player1.pseudo == client.pseudo) {
      color = 1;
      adversaire = this.player2;
    }
    else if (this.player2.pseudo == client.pseudo) {
      color = 2;
      adversaire = this.player1;
    }
    else
      throw new ClientCmdErreur("CLK", "ko", "Les spectateurs n'ont pas le droit de jouer");
    Pion pion = new Pion(x, y, color);
    if (!this._plateau.changeStateCase(pion))
      throw new ClientCmdErreur("CLK", "ko", "Pion déjà présent sur la case");
    printStd("Pion: $pion\n");
    if (this.reglesIsActiv["DOUBLE_THREE"] && this._isDoubleThree(pion))
      throw new ClientCmdErreur("CLK", "ko", "Double trois, impossible de posé un pion ici.");
    client.socket.write("CLK ok\n");
    client.actif = false;
    if (adversaire != null) {
      adversaire.socket.write("PION $pion\n");
      adversaire.actif = true;
    }
    this._spectateur.forEach((String pseudo, Client spectateur) => spectateur.socket.write("PION $pion\n"));
    this._checkHumanRegles(client, adversaire.socket, pion);
  }

  bool _horizontal(Pion pion, int decallage, int numList) {
    int op = 1;
    if (decallage < 0) {
      if (pion.x - 3 < 0 || pion.x + 1 > 18)
       return (false);
    }
    else {
      if (pion.x - 1 < 0 || pion.x + 3 > 18)
        return (false);
      op = -1;
    }
    Pion threeCase = new Pion(pion.x + decallage, pion.y, this._plateau.getStateCase(pion.x + decallage, pion.y));
    decallage += op;
    Pion secondCase = new Pion(pion.x + decallage, pion.y, this._plateau.getStateCase(pion.x + decallage, pion.y));
    decallage += op;
    Pion firstCase = new Pion(pion.x + decallage, pion.y, this._plateau.getStateCase(pion.x + decallage, pion.y));
    decallage += (op * 2);
    Pion badSideCase = new Pion(pion.x + decallage, pion.y, this._plateau.getStateCase(pion.x + decallage, pion.y));
    if (numList == 2)
      return (this._addThreeInSecondList(pion, badSideCase, firstCase, secondCase, threeCase));
    return (this._addThreeInFirstList(pion, badSideCase, firstCase, secondCase, threeCase));
  }

  bool _vertical(Pion pion, int decallage, int numList) {
    int op = 1;
    if (decallage < 0) {
      if (pion.y - 3 < 0 || pion.y + 1 > 18)
       return (false);
    }
    else {
      if (pion.y - 1 < 0 || pion.y + 3 > 18)
        return (false);
      op = -1;
    }
    Pion threeCase = new Pion(pion.x, pion.y + decallage, this._plateau.getStateCase(pion.x, pion.y + decallage));
    decallage += op;
    Pion secondCase = new Pion(pion.x, pion.y + decallage, this._plateau.getStateCase(pion.x, pion.y + decallage));
    decallage += op;
    Pion firstCase = new Pion(pion.x, pion.y + decallage, this._plateau.getStateCase(pion.x, pion.y + decallage));
    decallage += (op * 2);
    Pion badSideCase = new Pion(pion.x, pion.y + decallage, this._plateau.getStateCase(pion.x, pion.y + decallage));
    if (numList == 2)
      return (this._addThreeInSecondList(pion, badSideCase, firstCase, secondCase, threeCase));
    return (this._addThreeInFirstList(pion, badSideCase, firstCase, secondCase, threeCase));
  }

  bool _diagoOne(Pion pion, int decallage, int numList) {
    if (decallage < 0) {
      if ((pion.y - 3 < 0 || pion.y + 1 > 18) || (pion.x - 3 < 0 || pion.x + 1 > 18))
       return (false);
    }
    else {
      if ((pion.y - 1 < 0 || pion.y + 3 > 18) || (pion.x - 1 < 0 || pion.x + 3 > 18))
        return (false);
    }
    int op = 1;
    if (decallage > 0)
      op = -1;
    Pion threeCase = new Pion(pion.x + decallage, pion.y + decallage, this._plateau.getStateCase(pion.x + decallage, pion.y + decallage));
    decallage += op;
    Pion secondCase = new Pion(pion.x + decallage, pion.y + decallage, this._plateau.getStateCase(pion.x + decallage, pion.y + decallage));
    decallage += op;
    Pion firstCase = new Pion(pion.x + decallage, pion.y + decallage, this._plateau.getStateCase(pion.x + decallage, pion.y + decallage));
    decallage += (op * 2);
    Pion badSideCase = new Pion(pion.x + decallage, pion.y + decallage, this._plateau.getStateCase(pion.x + decallage, pion.y + decallage));
    if (numList == 2)
      return (this._addThreeInSecondList(pion, badSideCase, firstCase, secondCase, threeCase));
    return (this._addThreeInFirstList(pion, badSideCase, firstCase, secondCase, threeCase));
  }

  bool _diagoTwo(Pion pion, int decallage, int numList) {
    if (decallage < 0) {
      if ((pion.y - 3 < 0 || pion.y + 1 > 18) || (pion.x - 1 < 0 || pion.x + 3 > 18))
       return (false);
    }
    else {
      if ((pion.y - 1 < 0 || pion.y + 3 > 18) || (pion.x - 3 < 0 || pion.x + 1 > 18))
        return (false);
    }
    int op = 1;
    if (decallage > 0)
      op = -1;
    Pion threeCase = new Pion(pion.x - decallage, pion.y + decallage, this._plateau.getStateCase(pion.x - decallage, pion.y + decallage));
    decallage += op;
    Pion secondCase = new Pion(pion.x - decallage, pion.y + decallage, this._plateau.getStateCase(pion.x - decallage, pion.y + decallage));
    decallage += op;
    Pion firstCase = new Pion(pion.x - decallage, pion.y + decallage, this._plateau.getStateCase(pion.x - decallage, pion.y + decallage));
    decallage += (op * 2);
    Pion badSideCase = new Pion(pion.x - decallage, pion.y + decallage, this._plateau.getStateCase(pion.x - decallage, pion.y + decallage));
    if (numList == 2)
      return (this._addThreeInSecondList(pion, badSideCase, firstCase, secondCase, threeCase));
    return (this._addThreeInFirstList(pion, badSideCase, firstCase, secondCase, threeCase));
  }

  bool _addThreeInFirstList(Pion pion, Pion badSideCase, Pion firstCase, Pion secondCase, Pion threeCase) {
    this._fthree.clear();
    if (badSideCase.color == pion.color && firstCase.color == pion.color) {
      this._fthree.add(badSideCase);
      this._fthree.add(firstCase);
      return (true);
    }
    else if (firstCase.color == pion.color && secondCase.color == pion.color) {
      this._fthree.add(firstCase);
      this._fthree.add(secondCase);
      return (true);
    }
    else if (firstCase.color == 0 && secondCase.color == pion.color && threeCase.color == pion.color) {
      this._fthree.add(secondCase);
      this._fthree.add(threeCase);
      return (true);
    }
    else if (firstCase.color == pion.color && secondCase.color == 0 && threeCase.color == pion.color) {
      this._fthree.add(firstCase);
      this._fthree.add(threeCase);
      return (true);
    }
    else if (firstCase.color == 0 && secondCase.color == pion.color && badSideCase.color == pion.color) {
      this._fthree.add(secondCase);
      this._fthree.add(badSideCase);
      return (true);
    }
    return (false);
  }

  bool _addThreeInSecondList(Pion pion, Pion badSideCase, Pion firstCase, Pion secondCase, Pion threeCase) {
    this._sthree.clear();
    if (badSideCase.color == pion.color && firstCase.color == pion.color) {
      this._sthree.add(badSideCase);
      this._sthree.add(firstCase);
      return (true);
    }
    else if (firstCase.color == pion.color && secondCase.color == pion.color) {
      this._sthree.add(firstCase);
      this._sthree.add(secondCase);
      return (true);
    }
    else if (firstCase.color == 0 && secondCase.color == pion.color && threeCase.color == pion.color) {
      this._sthree.add(secondCase);
      this._sthree.add(threeCase);
      return (true);
    }
    else if (firstCase.color == pion.color && secondCase.color == 0 && threeCase.color == pion.color) {
      this._sthree.add(firstCase);
      this._sthree.add(threeCase);
      return (true);
    }
    else if (firstCase.color == 0 && secondCase.color == pion.color && badSideCase.color == pion.color) {
      this._sthree.add(secondCase);
      this._sthree.add(badSideCase);
      return (true);
    }
    return (false);
  }

  bool _checkHorizontalFreeThree(List three) {
    Pion first = three.first;
    Pion last = three.last;
    int diff = last.x - first.x;

    if (diff == 2) {
      if (last.x + 2 < 19 && first.x - 1 >= 0) {
        if (this._plateau.getStateCase(last.x + 1, last.y) == 0 && this._plateau.getStateCase(last.x + 2, last.y) == 0 && this._plateau.getStateCase(first.x - 1, first.y) == 0)
          return (true);
      }
      if (last.x + 1 < 19 && first.x - 2 >= 0) {
        if (this._plateau.getStateCase(last.x + 1, last.y) == 0 && this._plateau.getStateCase(first.x - 1, first.y) == 0 && this._plateau.getStateCase(first.x - 2, first.y) == 0)
          return (true);
      }
    }
    else if (diff == 3) {
      if (last.x + 1 < 19 && first.x - 1 >= 0)
        if (this._plateau.getStateCase(last.x + 1, last.y) == 0 && this._plateau.getStateCase(first.x - 1, first.y) == 0)
          return (true);
    }
    return (false);
  }

  bool _checkVerticalFreeThree(List three) {
    Pion first = three.first;
    Pion last = three.last;
    int diff = last.y - first.y;

    if (diff == 2) {
      if (last.y + 2 < 19 && first.y - 1 >= 0) {
        if (this._plateau.getStateCase(last.x, last.y + 1) == 0 && this._plateau.getStateCase(last.x, last.y + 2) == 0 && this._plateau.getStateCase(first.x, first.y - 1) == 0)
          return (true);
      }
      if (last.y + 1 < 19 && first.y - 2 >= 0) {
        if (this._plateau.getStateCase(last.x, last.y + 1) == 0 && this._plateau.getStateCase(first.x, first.y - 1) == 0 && this._plateau.getStateCase(first.x, first.y - 2) == 0)
          return (true);
      }
    }
    else if (diff == 3) {
      if (last.y + 1 < 19 && first.y - 1 >= 0)
        if (this._plateau.getStateCase(last.x, last.y + 1) == 0 && this._plateau.getStateCase(first.x, first.y - 1) == 0)
          return (true);
    }
    return (false);
  }

  bool _checkDiagOneFreeThree(List three) {
    Pion first = three.first;
    Pion last = three.last;
    int diff = last.y - first.y;

    if (diff == 2) {
      if (first.x - 1 >= 0 && first.y - 1 >= 0 && last.x + 2 < 19 && last.y + 2 < 19) {
        if (this._plateau.getStateCase(last.x + 1, last.y + 1) == 0 && this._plateau.getStateCase(last.x + 2, last.y + 2) == 0 && this._plateau.getStateCase(first.x - 1, first.y - 1) == 0)
          return (true);
      }
      if (first.x - 2 >= 0 && first.y - 2 >= 0 && last.x + 1 < 19 && last.y + 1 < 19) {
        if (this._plateau.getStateCase(last.x + 1, last.y + 1) == 0 && this._plateau.getStateCase(first.x - 1, first.y - 1) == 0 && this._plateau.getStateCase(first.x - 2, first.y - 2) == 0)
          return (true);
      }
    }
    else if (diff == 3) {
      if (first.x - 1 >= 0 && first.y - 1 >= 0 && last.x + 1 < 19 && last.y + 1 < 19)
        if (this._plateau.getStateCase(last.x + 1, last.y + 1) == 0 && this._plateau.getStateCase(first.x - 1, first.y - 1) == 0)
          return (true);
    }
    return (false);
  }

  bool _checkDiagTwoFreeThree(List three) {
    Pion first = three.first;
    Pion last = three.last;
    int diff = last.y - first.y;

    if (diff == 2) {
      if (last.x - 1 >= 0 && last.y + 1 < 19 && first.x + 2 < 19 && first.y - 2 >= 0) {
        if (this._plateau.getStateCase(last.x - 1, last.y + 1) == 0 && this._plateau.getStateCase(first.x + 1, first.y - 1) == 0 && this._plateau.getStateCase(first.x + 2, first.y - 2) == 0)
          return (true);
      }
      if (last.x - 2 >= 0 && last.y + 2 < 19 && first.x + 1 < 19 && first.y - 1 >= 0) {
        if (this._plateau.getStateCase(last.x - 1, last.y + 1) == 0 && this._plateau.getStateCase(last.x - 2, last.y + 2) == 0 && this._plateau.getStateCase(first.x + 1, first.y - 1) == 0)
          return (true);
      }
    }
    else if (diff == 3) {
      if (last.x - 1 >= 0 && last.y + 1 < 19 && first.x + 1 < 19 && first.y - 1 >= 0)
        if (this._plateau.getStateCase(last.x - 1, last.y + 1) == 0 && this._plateau.getStateCase(first.x + 1, first.y - 1) == 0)
          return (true);
    }
    return (false);
  }

  bool _checkSecondThree() {

  }

  void _sortListPion(List three, [bool onY = false]) {
    if (onY)
      three.sort((Pion p1, Pion p2) => p1.y.compareTo(p2.y));
    else
      three.sort((Pion p1, Pion p2) => p1.x.compareTo(p2.x));
  }

  bool _makeThree(Pion pion) {
    //  trois detecter horizontal gauche ou horizontal droit
    if (this._horizontal(pion, -3, 1) || this._horizontal(pion, 3, 1)) {
      this._fthree.add(pion);
      this._sortListPion(this._fthree);
      if (this._checkHorizontalFreeThree(this._fthree)) {
        for (Pion tmpPion in this._fthree) {
          if (this._vertical(tmpPion, -3, 2) || this._vertical(tmpPion, 3, 2)) {
            this._sthree.add(tmpPion);
            printStd("first three: ${this._fthree}\n");
            printStd("second three: ${this._sthree}\n");
            this._sortListPion(this._sthree, true);
            if (this._checkVerticalFreeThree(this._sthree))
              return (true);
          }
          if (this._diagoOne(tmpPion, 3, 2) || this._diagoOne(tmpPion, -3, 2)) {
            this._sthree.add(tmpPion);
            printStd("first three: ${this._fthree}\n");
            printStd("second three: ${this._sthree}\n");
            this._sortListPion(this._sthree, true);
            if (this._checkDiagOneFreeThree(this._sthree))
              return (true);
          }
          if (this._diagoTwo(tmpPion, 3, 2) || this._diagoTwo(tmpPion, -3, 2)) {
            this._sthree.add(tmpPion);
            printStd("first three: ${this._fthree}\n");
            printStd("second three: ${this._sthree}\n");
            this._sortListPion(this._sthree, true);
            if (this._checkDiagTwoFreeThree(this._sthree))
              return (true);
          }
        }
      }
    }
    //  trois detecter vertical haut ou vertical bas
    if (this._vertical(pion, -3, 1) || this._vertical(pion, 3, 1)) {
      this._fthree.add(pion);
      this._sortListPion(this._fthree, true);
      if (this._checkVerticalFreeThree(this._fthree)) {
        for (Pion tmpPion in this._fthree) {
          if (this._horizontal(tmpPion, -3, 2) || this._horizontal(tmpPion, 3, 2)) {
            this._sthree.add(tmpPion);
            printStd("first three: ${this._fthree}\n");
            printStd("second three: ${this._sthree}\n");
            this._sortListPion(this._sthree);
            if (this._checkHorizontalFreeThree(this._sthree))
              return (true);
          }
          if (this._diagoOne(tmpPion, 3, 2) || this._diagoOne(tmpPion, -3, 2)) {
            this._sthree.add(tmpPion);
            printStd("first three: ${this._fthree}\n");
            printStd("second three: ${this._sthree}\n");
            this._sortListPion(this._sthree, true);
            if (this._checkDiagOneFreeThree(this._sthree))
              return (true);
          }
          if (this._diagoTwo(tmpPion, 3, 2) || this._diagoTwo(tmpPion, -3, 2)) {
            this._sthree.add(tmpPion);
            printStd("first three: ${this._fthree}\n");
            printStd("second three: ${this._sthree}\n");
            this._sortListPion(this._sthree, true);
            if (this._checkDiagTwoFreeThree(this._sthree))
              return (true);
          }
        }
      }
    }
    //  trois detecter diago haut-gauche bas-droit en commancant par le bas ou diago haut-gauche bas-droit en commancant par le haut
    if (this._diagoOne(pion, 3, 1) || this._diagoOne(pion, -3, 1)) {
      this._fthree.add(pion);
      this._sortListPion(this._fthree, true);
      if (this._checkDiagOneFreeThree(this._fthree)) {
        for (Pion tmpPion in this._fthree) {
          if (this._vertical(tmpPion, -3, 2) || this._vertical(tmpPion, 3, 2)) {
            this._sthree.add(tmpPion);
            printStd("first three: ${this._fthree}\n");
            printStd("second three: ${this._sthree}\n");
            this._sortListPion(this._sthree, true);
            if (this._checkVerticalFreeThree(this._sthree))
              return (true);
          }
          if (this._horizontal(tmpPion, 3, 2) || this._horizontal(tmpPion, -3, 2)) {
            this._sthree.add(tmpPion);
            printStd("first three: ${this._fthree}\n");
            printStd("second three: ${this._sthree}\n");
            this._sortListPion(this._sthree);
            if (this._checkHorizontalFreeThree(this._sthree))
              return (true);
          }
          if (this._diagoTwo(tmpPion, 3, 2) || this._diagoTwo(tmpPion, -3, 2)) {
            this._sthree.add(tmpPion);
            printStd("first three: ${this._fthree}\n");
            printStd("second three: ${this._sthree}\n");
            this._sortListPion(this._sthree, true);
            if (this._checkDiagTwoFreeThree(this._sthree))
              return (true);
          }
        }
      }
    }
    //  trois detecter diago bas-gauche haut-droit en commancant par le bas ou diago bas-gauche haut-droit en commancant par le haut
    if (this._diagoTwo(pion, 3, 1) || this._diagoTwo(pion, -3, 1)) {
      this._fthree.add(pion);
      this._sortListPion(this._fthree, true);
      if (this._checkDiagTwoFreeThree(this._fthree)) {
        for (Pion tmpPion in this._fthree) {
          if (this._vertical(tmpPion, -3, 2) || this._vertical(tmpPion, 3, 2)) {
            this._sthree.add(tmpPion);
            printStd("first three: ${this._fthree}\n");
            printStd("second three: ${this._sthree}\n");
            this._sortListPion(this._sthree, true);
            if (this._checkVerticalFreeThree(this._sthree))
              return (true);
          }
          if (this._diagoOne(tmpPion, 3, 2) || this._diagoOne(tmpPion, -3, 2)) {
            this._sthree.add(tmpPion);
            printStd("first three: ${this._fthree}\n");
            printStd("second three: ${this._sthree}\n");
            this._sortListPion(this._sthree, true);
            if (this._checkDiagOneFreeThree(this._sthree))
              return (true);
          }
          if (this._horizontal(tmpPion, 3, 2) || this._horizontal(tmpPion, -3, 2)) {
            this._sthree.add(tmpPion);
            printStd("first three: ${this._fthree}\n");
            printStd("second three: ${this._sthree}\n");
            this._sortListPion(this._sthree);
            if (this._checkHorizontalFreeThree(this._sthree))
              return (true);
          }
        }
      }
    }
    return (false);
  }

  //  false pas de double trois
  //  true double trois present une foi que le pion est pose
  bool _isDoubleThree(Pion pion) {
    this._fthree = new List<Pion>();
    this._sthree = new List<Pion>();
    if (!this._makeThree(pion)) {
      return (false);
    }
    this._plateau.clearCase = pion;
    return (true);
  }

  void posePion(Client client, int x, int y) {
    if (!this._type)
     this._pvp(client, x, y);
    else
      printStd("Type de parti inconnu !");
  }

  List _eatHorizontal(Pion pion) {
    List lPion = new List<Pion>();
    int adversaire = 0;
    if (pion.color == 1)
      adversaire = 2;
    else if (pion.color == 2)
      adversaire = 1;
    if (pion.x - 3 >= 0) {
      if (this._plateau.getStateCase(pion.x - 1, pion.y) == adversaire
          && this._plateau.getStateCase(pion.x - 2, pion.y) == adversaire
          && this._plateau.getStateCase(pion.x - 3, pion.y) == pion.color) {
        lPion.add(new Pion(pion.x - 1, pion.y, adversaire));
        lPion.add(new Pion(pion.x - 2, pion.y, adversaire));
      }
    }
    if (pion.x + 3 < 19) {
      if (this._plateau.getStateCase(pion.x + 1, pion.y) == adversaire
          && this._plateau.getStateCase(pion.x + 2, pion.y) == adversaire
          && this._plateau.getStateCase(pion.x + 3, pion.y) == pion.color) {
        lPion.add(new Pion(pion.x + 1, pion.y, adversaire));
        lPion.add(new Pion(pion.x + 2, pion.y, adversaire));
      }
    }
    return (lPion);
  }

  List _eatVertical(Pion pion) {
    List lPion = new List<Pion>();
    int adversaire = 0;
    if (pion.color == 1)
      adversaire = 2;
    else if (pion.color == 2)
      adversaire = 1;
    if (pion.y - 3 >= 0) {
      if (this._plateau.getStateCase(pion.x, pion.y - 1) == adversaire
          && this._plateau.getStateCase(pion.x, pion.y - 2) == adversaire
          && this._plateau.getStateCase(pion.x, pion.y - 3) == pion.color) {
        lPion.add(new Pion(pion.x, pion.y - 1, adversaire));
        lPion.add(new Pion(pion.x, pion.y - 2, adversaire));
      }
    }
    if (pion.y + 3 < 19) {
      if (this._plateau.getStateCase(pion.x, pion.y + 1) == adversaire
          && this._plateau.getStateCase(pion.x, pion.y + 2) == adversaire
          && this._plateau.getStateCase(pion.x, pion.y + 3) == pion.color) {
        lPion.add(new Pion(pion.x, pion.y + 1, adversaire));
        lPion.add(new Pion(pion.x, pion.y + 2, adversaire));
      }
    }
    return (lPion);
  }

  List _eatDiagOne(Pion pion) {
    List lPion = new List<Pion>();
    int adversaire = 0;
    if (pion.color == 1)
      adversaire = 2;
    else if (pion.color == 2)
      adversaire = 1;
    if (pion.y - 3 >= 0 && pion.x - 3 >= 0) {
      if (this._plateau.getStateCase(pion.x - 1, pion.y - 1) == adversaire
          && this._plateau.getStateCase(pion.x - 2, pion.y - 2) == adversaire
          && this._plateau.getStateCase(pion.x - 3, pion.y - 3) == pion.color) {
        lPion.add(new Pion(pion.x - 1, pion.y - 1, adversaire));
        lPion.add(new Pion(pion.x - 2, pion.y - 2, adversaire));
      }
    }
    if (pion.y + 3 < 19 && pion.x + 3 < 19) {
      if (this._plateau.getStateCase(pion.x + 1, pion.y + 1) == adversaire
          && this._plateau.getStateCase(pion.x + 2, pion.y + 2) == adversaire
          && this._plateau.getStateCase(pion.x + 3, pion.y + 3) == pion.color) {
        lPion.add(new Pion(pion.x + 1, pion.y + 1, adversaire));
        lPion.add(new Pion(pion.x + 2, pion.y + 2, adversaire));
      }
    }
    return (lPion);
  }

  List _eatDiagTwo(Pion pion) {
    List lPion = new List<Pion>();
    int adversaire = 0;
    if (pion.color == 1)
      adversaire = 2;
    else if (pion.color == 2)
      adversaire = 1;
    if (pion.y - 3 >= 0 && pion.x + 3 < 19) {
      if (this._plateau.getStateCase(pion.x + 1, pion.y - 1) == adversaire
          && this._plateau.getStateCase(pion.x + 2, pion.y - 2) == adversaire
          && this._plateau.getStateCase(pion.x + 3, pion.y - 3) == pion.color) {
        lPion.add(new Pion(pion.x + 1, pion.y - 1, adversaire));
        lPion.add(new Pion(pion.x + 2, pion.y - 2, adversaire));
      }
    }
    if (pion.y + 3 < 19 && pion.x - 3 >= 0) {
      if (this._plateau.getStateCase(pion.x - 1, pion.y + 1) == adversaire
          && this._plateau.getStateCase(pion.x - 2, pion.y + 2) == adversaire
          && this._plateau.getStateCase(pion.x - 3, pion.y + 3) == pion.color) {
        lPion.add(new Pion(pion.x - 1, pion.y + 1, adversaire));
        lPion.add(new Pion(pion.x - 2, pion.y + 2, adversaire));
      }
    }
    return (lPion);
  }


  List _eatPion(Pion pion) {
    List lPion = new List<Pion>();
    lPion.addAll(this._eatHorizontal(pion));
    lPion.addAll(this._eatVertical(pion));
    lPion.addAll(this._eatDiagOne(pion));
    lPion.addAll(this._eatDiagTwo(pion));
    return (lPion);
  }

  bool _checkFiveBrokenHorizontal(List lPion, int adversaire) {
    for (Pion pion in lPion) {
      if (pion.x - 2 < 19) {
        if (this._plateau.getStateCase(pion.x - 2, pion.y) == adversaire
            && this._plateau.getStateCase(pion.x - 1, pion.y) == pion.color
            && this._plateau.getStateCase(pion.x + 1, pion.y) == 0)
          return (true);
      }
      if (pion.x - 1 >= 0 && pion.y + 2 < 19) {
        if (this._plateau.getStateCase(pion.x - 1, pion.y) == adversaire
           && this._plateau.getStateCase(pion.x + 1, pion.y) == pion.color
            && this._plateau.getStateCase(pion.x + 2, pion.y) == 0)
          return (true);
      }
      if (pion.x + 1 < 19 && pion.x >= 0) {
        if (this._plateau.getStateCase(pion.x + 1, pion.y) == adversaire
            && this._plateau.getStateCase(pion.x - 1, pion.y) == pion.color
            && this._plateau.getStateCase(pion.x - 2, pion.y) == 0)
          return (true);
      }
      if (pion.x + 2 < 19 && pion.y - 1 >= 0) {
        if (this._plateau.getStateCase(pion.x + 2, pion.y) == adversaire
            && this._plateau.getStateCase(pion.x + 1, pion.y) == pion.color
            && this._plateau.getStateCase(pion.x - 1, pion.y) == 0)
          return (true);
      }
    }
    return (false);
  }

  bool _checkFiveBrokenVertical(List lPion, int adversaire) {
    for (Pion pion in lPion) {
      if (pion.y - 2 >= 0) {
        if (this._plateau.getStateCase(pion.x, pion.y - 2) == adversaire
            && this._plateau.getStateCase(pion.x, pion.y - 1) == pion.color
            && this._plateau.getStateCase(pion.x, pion.y + 1) == 0)
          return (true);
      }
      if (pion.y - 1 >= 0 && pion.y + 2 < 19) {
        if (this._plateau.getStateCase(pion.x, pion.y - 1) == adversaire
            && this._plateau.getStateCase(pion.x, pion.y + 1) == pion.color
            && this._plateau.getStateCase(pion.x, pion.y + 2) == 0)
          return (true);
      }
      if (pion.y - 2 >= 0 && pion.y + 1 < 19)
        if (this._plateau.getStateCase(pion.x, pion.y + 1) == adversaire
            && this._plateau.getStateCase(pion.x, pion.y - 1) == pion.color
            && this._plateau.getStateCase(pion.x, pion.y - 2) == 0)
          return (true);
      if (pion.y + 2 < 19 && pion.y - 1 >= 0)
        if (this._plateau.getStateCase(pion.x, pion.y + 2) == adversaire
            && this._plateau.getStateCase(pion.x, pion.y + 1) == pion.color
            && this._plateau.getStateCase(pion.x, pion.y - 1) == 0)
          return (true);
    }
    return (false);
  }

  bool _checkFiveBrokenDiagOne(List lPion, int adversaire) {
    for (Pion pion in lPion) {
      if (pion.x - 2 >= 0 && pion.y - 2 >= 0 && pion.x + 1 < 19 && pion.y + 1 < 19) {
        if (this._plateau.getStateCase(pion.x - 2, pion.y - 2) == adversaire
            && this._plateau.getStateCase(pion.x - 1, pion.y - 1) == pion.color
            && this._plateau.getStateCase(pion.x + 1, pion.y + 1) == 0)
          return (true);
      }
      if (pion.x + 2 < 19 && pion.y + 2 < 19 && pion.x - 1 >= 0 && pion.y - 1 >= 0) {
        if (this._plateau.getStateCase(pion.x - 1, pion.y - 1) == adversaire
            && this._plateau.getStateCase(pion.x + 1, pion.y + 1) == pion.color
            && this._plateau.getStateCase(pion.x + 2, pion.y + 2) == 0)
          return (true);
      }
      if (pion.x + 1 < 19 && pion.y + 1 < 19 && pion.y - 2 >= 0 && pion.x - 2 >= 0) {
        if (this._plateau.getStateCase(pion.x + 1, pion.y + 1) == adversaire
            && this._plateau.getStateCase(pion.x - 1, pion.y - 1) == pion.color
            && this._plateau.getStateCase(pion.x - 2, pion.y - 2) == 0)
          return (true);
      }
      if (pion.x + 2 < 19 && pion.y + 2 < 19 && pion.x - 1 >= 0 && pion.y - 1 >= 0) {
        if (this._plateau.getStateCase(pion.x + 2, pion.y + 2) == adversaire
            && this._plateau.getStateCase(pion.x + 1, pion.y + 1) == pion.color
            && this._plateau.getStateCase(pion.x - 1, pion.y - 1) == 0)
          return (true);
      }
    }
    return (false);
  }

  bool _checkFiveBrokenDiagTwo(List lPion, int adversaire) {
    for (Pion pion in lPion) {
      if (pion.x + 2 < 19 && pion.y - 2 >= 0 && pion.x - 1 >= 0 && pion.y + 2 < 19) {
        if (this._plateau.getStateCase(pion.x + 2, pion.y - 2) == adversaire
            && this._plateau.getStateCase(pion.x + 1, pion.y - 1) == pion.color
            && this._plateau.getStateCase(pion.x - 1, pion.y + 1) == 0)
          return (true);
      }
      if (pion.x + 1 < 19 && pion.y - 1 >= 0 && pion.x - 2 >= 0 && pion.y + 2 < 19) {
        if (this._plateau.getStateCase(pion.x + 1, pion.y - 1) == adversaire
            && this._plateau.getStateCase(pion.x - 1, pion.y + 1) == pion.color
            && this._plateau.getStateCase(pion.x - 2, pion.y + 2) == 0)
          return (true);
      }
      if (pion.x - 1 >= 0 && pion.y + 1 < 19 && pion.x + 2 < 19 && pion.y - 2 >= 0) {
        if (this._plateau.getStateCase(pion.x - 1, pion.y + 1) == adversaire
            && this._plateau.getStateCase(pion.x + 1, pion.y - 1) == pion.color
            && this._plateau.getStateCase(pion.x + 2, pion.y - 2) == 0)
          return (true);
      }
      if (pion.x - 2 >= 0 && pion.y + 2 < 19 && pion.x + 1 < 19 && pion.y - 1 >= 0) {
        if (this._plateau.getStateCase(pion.x - 2, pion.y + 2) == adversaire
            && this._plateau.getStateCase(pion.x - 1, pion.y + 1) == pion.color
            && this._plateau.getStateCase(pion.x + 1, pion.y - 1) == 0)
          return (true);
      }
    }
    return (false);
  }

  int _fiveWinHorizontal() {
    List lPion = new List<Pion>();
    int adversaire = 1;
    Pion pion = null;
    for (int y = 0; y < 19; y++) {
      for (int x = 0; x < 19; x++) {
        int color = this._plateau.getStateCase(x, y);
        if (color != 0) {
          if (pion == null) {
            pion = new Pion(x, y, color);
            lPion.add(new Pion(x, y, color));
          }
          else {
            if (color == pion.color) {
              lPion.add(new Pion(x, y, color));
            }
            else {
              pion = new Pion(x, y, color);;
              lPion.clear();
              lPion.add(new Pion(x, y, color));
            }
          }
        }
        else {
          pion = null;
          lPion.clear();
        }
        if (lPion.length == 5) {
          printStd("list pion: $lPion\n");
          int adversaire = 1;
          if (pion.color == 2)
            adversaire = 2;
          if (this.reglesIsActiv["FIVE_BROCK"]) {
            if (this._checkFiveBrokenVertical(lPion, adversaire)
                || this._checkFiveBrokenDiagOne(lPion, adversaire)
                || this._checkFiveBrokenDiagTwo(lPion, adversaire)) {
              return (-1);
            }
            else {
              printStd("$color Vous avez gagné grace a la horizontal et votre 5 n'est pas cassant!\n");
              return (pion.color);
            }
          }
          else {
            printStd("$color Vous avez gagné grace a la horizontal\n");
            return (pion.color);
          }
        }
      }
      lPion.clear();
    }
    return (-1);
  }

  int _fiveWinVertical() {
    List lPion = new List<Pion>();
    Pion pion = null;
    for (int x = 0; x < 19; x++) {
      for (int y = 0; y < 19; y++) {
        int color = this._plateau.getStateCase(x, y);
        if (color != 0) {
          if (pion == null) {
            pion = new Pion(x, y, color);
            lPion.add(pion);
          }
          else {
            if (color == pion.color) {
              lPion.add(new Pion(x, y, color));
            }
            else {
              pion = new Pion(x, y, color);
              lPion.clear();
              lPion.add(pion);
            }
          }
        }
        else {
          pion = null;
          lPion.clear();
        }
        if (lPion.length == 5) {
          printStd("list pion: $lPion\n");
          int adversaire = 1;
          if (pion.color == 2)
            adversaire = 2;
          if (this.reglesIsActiv["FIVE_BROCK"]) {
            if (this._checkFiveBrokenHorizontal(lPion, adversaire)
                || this._checkFiveBrokenDiagOne(lPion, adversaire)
                || this._checkFiveBrokenDiagTwo(lPion, adversaire)) {
              return (-1);
            }
            else {
              printStd("$color Vous avez gagné grace a la vertical et votre 5 n'est pas cassant!\n");
              return (pion.color);
            }
          }
          else {
            printStd("$color Vous avez gagné grace a la vertical!\n");
            return (pion.color);
          }
        }
      }
      lPion.clear();
    }
    return (-1);
  }

  int _fiveWinDiagOne() {
    List lPion = new List<Pion>();
    Pion pion = null;
    for (int x = 0; x < 19; x++) {
      for (int y = 0; y < 19; y++) {
        for (int j = 0; j < 5; j++) {
          if (j + x < 19 && j + y < 19) {
            int color = this._plateau.getStateCase(j + x, j + y);
            if (color != 0) {
              if (pion == null) {
                pion = new Pion(x + j, y + j, color);
                lPion.add(pion);
              }
              else {
                if (color == pion.color){
                  lPion.add(new Pion(x + j, y + j, color));
                }
                else {
                  pion = new Pion(x + j, y + j, color);
                  lPion.clear();
                  lPion.add(pion);
                }
              }
            }
            else {
              pion = null;
              lPion.clear();
            }
            if (lPion.length == 5) {
              printStd("list pion: $lPion\n");
              int adversaire = 1;
              if (pion.color == 2)
                adversaire = 2;
              if (this.reglesIsActiv["FIVE_BROCK"]) {
                if (this._checkFiveBrokenHorizontal(lPion, adversaire)
                    || this._checkFiveBrokenVertical(lPion, adversaire)
                      || this._checkFiveBrokenDiagTwo(lPion, adversaire)) {
                  return (-1);
                }
                else {
                  printStd("$color Vous avez gagné grace a la diagonale une et votre 5 n'est pas cassant!\n");
                  return (pion.color);
                }
              }
              else {
                printStd("$color Vous avez gagné grace a la diagonale une!\n");
                return (pion.color);
              }
            }
          }
          else
            lPion.clear();
        }
        lPion.clear();
      }
      lPion.clear();
    }
    return (-1);
  }
  //
  //  list pion: [6 9 1, 10 6 1, 9 7 1, 8 8 1, 7 9 1]
  //  1 Vous avez gagné grace a la diagonale deux
  int _fiveWinDiagTwo() {
    List lPion = new List<Pion>();
    Pion pion = null;
    for (int x = 0; x < 19; x++) {
      for (int y = 0; y < 19; y++) {
        for (int j = 0; j < 5; j++) {
          if (x - j >= 0 && y + j < 19) {
            int color = this._plateau.getStateCase(x - j, y + j);
            if (color != 0) {
              if (pion == null) {
                pion = new Pion(x - j, y + j, color);
                lPion.add(pion);
              }
              else {
                if (color == pion.color) {
                  lPion.add(new Pion(x - j, y + j, color));
                }
                else {
                  pion = new Pion(x - j, y + j, color);
                  lPion.clear();
                  lPion.add(pion);
                }
              }
            }
            else {
              pion = null;
              lPion.clear();
            }
            if (lPion.length == 5) {
              printStd("list pion: $lPion\n");
              int adversaire = 1;
              if (pion.color == 2)
                adversaire = 2;
              if (this.reglesIsActiv["FIVE_BROCK"]) {
                if (this._checkFiveBrokenHorizontal(lPion, adversaire)
                    || this._checkFiveBrokenVertical(lPion, adversaire)
                      || this._checkFiveBrokenDiagOne(lPion, adversaire)) {
                  return (-1);
                }
                else {
                  printStd("$color Vous avez gagné grace a la diagonale deux et votre 5 n'est pas cassant!\n");
                  return (pion.color);
                }
              }
              else {
                printStd("$color Vous avez gagné grace a la diagonale deux\n");
                return (pion.color);
              }
            }
          }
          else
            lPion.clear();
        }
        lPion.clear();
      }
      lPion.clear();
    }
    return (-1);
  }

  int fiveWin() {
    int h = this._fiveWinHorizontal();
    if (h != -1)
      return (h);
    int v = this._fiveWinVertical();
    if (v != -1)
      return (v);
    int diago = this._fiveWinDiagOne();
    if (diago != -1)
      return (diago);
    int diagt = this._fiveWinDiagTwo();
    if (diagt != -1)
      return (diagt);
    return (-1);
  }

  void _checkHumanRegles(Client client, IOSink adversaire, Pion pion) {
    //  Manger des pions
    List<Pion> lPion = this._eatPion(pion);
    printStd("$pion\n");

    printStd("PVP- List des pion a manger: $lPion\n");
    lPion.forEach((Pion pion) {
      printStd("MANGEZ !! ${pion.x} ${pion.y}\n");
      this._broadcast(client, adversaire, "CLEAR ${pion.x}:${pion.y}\n");
      print("color case: ${this._plateau.getStateCase(pion.x, pion.y)}");
      this._plateau.clearCase = pion;
      print("color case: ${this._plateau.getStateCase(pion.x, pion.y)}");
      client.pionMange = client.pionMange + 1;
    });
    //  si 10 pion mange alors tu as gagne
    if (client.pionMange >= 10) {
      client.socket.write("WIN\n");
      adversaire.write("LOOSE\n");
      this._spectateur.forEach((String name, Client client) {
        client.socket.write("WIN ${pion.color}\n");
      });
    }
    //  5 gagnants
    if (this.fiveWin() == 1 || this.fiveWin() == 2) {
      client.socket.write("WIN ${pion.color}\n");
      adversaire.write("LOOSE ${pion.color}\n");
      this._spectateur.forEach((String name, Client client) {
        client.socket.write("WIN ${pion.color}\n");
      });
    }
    else {
      printStd("a l'autre joueur\n");
      adversaire.write("YOURTURN\n");
    }
  }

  void _dumpMap(IOSink client) {
    String dataToSend = "DUMPMAP ";
    for (int y = 0; y < 19; y++) {
      for (int x = 0; x < 19; x++) {
        dataToSend += "${this._plateau.getStateCase(x, y)}";
        if (x != 18 || y != 18) {
          dataToSend += " ";
        }
      }
    }
    dataToSend += "\n";
    client.write(dataToSend);
  }

  void _broadcast(Client client, IOSink adversaire, String data) {
    client.socket.write(data);
    adversaire.write(data);
    this._spectateur.forEach((String name, Client client) {
      client.socket.write(data);
    });
  }

  void _startGame() {
    if (this.player1 != null && this.player2 != null) {
      this.player1.socket.write("START ${this.player1.actif == true ? "1" : "0"}\n");
      this.player2.socket.write("START ${this.player2.actif == true ? "1" : "0"}\n");
    }
  }

  //  GETTERS
  bool get type => this._type;

  //  SETTERS
  set addPlayer(Client client) {
    if (this.player1 == null) {
      this.player1 = client;
      client.channel = this._name;
      client.actif = true;
      client.socket.write("JOIN ok 1\n");
      this._dumpMap(client.socket);
      if (this.type)
        this.player1.socket.write("START ${this.player1.actif == true ? "1" : "0"}\n");
    }
    else if (this.player1.pseudo == client.pseudo && this.player1.socket.remoteAddress.address == client.socket.remoteAddress.address) {
      this.player1 = client;
      client.channel = this._name;
      this._dumpMap(client.socket);
      client.socket.write("JOIN ok 1\n");
      if (this.type)
        this.player1.socket.write("START ${this.player1.actif == true ? "1" : "0"}\n");
      else if (this.player2 != null)
        this._startGame();
    }
    else if (this.player2 == null && this._type == false) {
      this.player2 = client;
      client.channel = this._name;
      client.actif = false;
      client.socket.write("JOIN ok 2\n");
      this._dumpMap(client.socket);
      this._startGame();
    }
    else if (this.player2.pseudo == client.pseudo && this._type == false && this.player2.socket.remoteAddress.address == client.socket.remoteAddress.address) {
      this.player2 = client;
      client.channel = this._name;
      client.socket.write("JOIN ok 2\n");
      this._dumpMap(client.socket);
      this._startGame();
    }
    else {
      this.addSpectateur = client;
      client.socket.write("JOIN ok 3\n");
      client.actif = false;
      this._dumpMap(client.socket);
    }
  }

  set delPlayer(Client client) {
    if (client.pseudo == this.player1.pseudo) {
      this.player1 = null;
      client.socket.close();
      printStd("Joueur 1 déconnecté ${client.pseudo}\n");
    }
    else if (client.pseudo == this.player2.pseudo) {
      this.player2 = null;
      client.socket.close();
      printStd("Joueur 2 déconnecté ${client.pseudo}\n");
    }
    else {
      if (this._spectateur.containsKey(client.pseudo)) {
        this._spectateur.remove(client.pseudo);
        client.socket.close();
        printStd("Un spectateur c'est déconnecté ${client.pseudo}\n");
      }
    }
  }

  set addSpectateur(Client value) => this._spectateur[value.pseudo] = value;
}