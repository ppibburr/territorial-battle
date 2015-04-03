namespace BattleShip {
  using Gtk;

  public class Player : Object {
        public  Grid grid {

        get;
        set;

      }

        public  Game game {

        get;
        set;

      }

        public  bool ships_visible {

        get;
        set;

      }

        public  Ship[] ships {

        default = new Ship[5];
        set;
        get;

      }


     public signal void lost_game();

    public Player (Game game) {
      Object(game: game);
      this.ships_visible = true;
      this.grid = new Grid(this);

    }

     public  virtual void auto_layout() {
      ships[0] = new PatrolBoat();
      ships[1] = new Carrier();
      ships[2] = new Submarine();
      ships[3] = new Destroyer();
      ships[4] = new BattleShip();
      this.grid.clear();

      for (int i = 0; i <= 4; i++) {
        var ship = this.ships[i];
        layout(ship);
        ship.sunk.connect(() => {
          int c; c = 0;

          for (int x = 0; x <= 4; x++) {
            var cs = this.ships[x];
            if (cs.sunken) {
              c = c + 1;

            };

          };

          if (c == 5) {
            lost_game();

          };

        });

      };


    }

     public  virtual bool layout(Ship ship) {
      var x = Random.int_range(0, 9);
      var y = Random.int_range(0, 9);
      var q = Random.int_range(0, 500);
      int orient; orient = 0;
      if (q > 250) {
        orient = 1;

      };
      var cell = (Cell)this.grid.find_cell(x, y);
      Cell cc;
      Cell[] cells;
      cells = null;
      if (cell.has_ship()) {
        return (layout(ship));

      }
      else {
        if (orient == 0) {
          if (x + ship.length <= 9) {

            for (int i = x; i <= x + ship.length - 1; i++) {
              cc = grid.find_cell(i, y);
              if (cc.has_ship()) {
                return (layout(ship));

              }
              else {
                cells += cc;

              };

            };


          }
          else {
            return (layout(ship));

          };

        }
        else {
          if (y + ship.length <= 9) {

            for (int i = y; i <= y + ship.length - 1; i++) {
              cc = grid.find_cell(x, i);
              if (cc.has_ship()) {
                return (layout(ship));

              }
              else {
                cells += cc;

              };

            };


          }
          else {
            return (layout(ship));

          };

        };

      };

      for (int i = 0; i <= cells.length - 1; i++) {
        var c = cells[i];
        c.ship = ship;
        ship.cells = cells;
        if (this.ships_visible) {
          c.state = Cell.STATE_SHIP;

        }
        else {
          c.state = Cell.STATE_WATER;

        };
        c.render();

      };

      return (true);

    }

  }































  public class Targeter : Object {
    public int axis = 0;
    public int direction = 0;
    public bool axis_completed = false;
    public bool reversed = false;
    public bool flopped = false;
    public Cell[] hits;
    public int n_hits = 0;
        public  Computer computer {

        set;
        get;

      }

        public  Cell? first_hit {

        set;
        get;

      }

        public  Cell? last_hit {

        set;
        get;

      }

        public  Cell? last_guess {

        set;
        get;

      }










    public Targeter (Computer comp) {
      Object(computer: comp);

    }





















     public  virtual void hit_bound() {
      this.last_hit = this.first_hit;
      this.last_guess = null;
      reverse_direction();

    }

     public  virtual Cell? guess() {
      if (this.last_hit != null) {
        if (this.last_guess != null) {
          if (this.last_guess.state == Cell.STATE_MISS) {
            hit_bound();
            return (guess());

          };

        };
        var x = this.last_hit.x;
        var y = this.last_hit.y;
        if (this.axis == 0) {
          if (this.direction == 0) {
            x = x + 1;

          };
          if (this.direction == 1) {
            x = x - 1;

          };

        };
        if (this.axis == 1) {
          if (this.direction == 0) {
            y = y + 1;

          };
          if (this.direction == 1) {
            y = y - 1;

          };

        };
        if (x > 9) {
          hit_bound();
          return (guess());

        };
        if (x < 0) {
          hit_bound();
          return (guess());

        };
        if (y > 9) {
          hit_bound();
          return (guess());

        };
        if (y < 0) {
          hit_bound();
          return (guess());

        };
        return (this.computer.game.player.grid.find_cell(x, y));

      }
      else {
        return (null);

      };


      return null;
    }

     public  virtual void change_axis() {
      if (this.flopped) {
        this.last_hit = null;
        return;

      };
      this.flopped = true;
      if (this.axis == 1) {
        this.axis = 0;

      }
      else {
        this.axis = 1;

      };
      this.reversed = false;
      this.direction = 0;

    }

     public  virtual void reverse_direction() {
      if (this.reversed) {
        change_axis();
        return;

      };
      this.reversed = true;
      if (this.direction == 1) {
        this.direction = 0;

      }
      else {
        this.direction = 1;

      };

    }

  }

















































  public class Computer : Player {
        public  Targeter targeter {

        set;
        get;

      }




    public Computer (Game game) {
      Object(game: game);
      this.ships_visible = false;
      this.grid = new ComputerGrid(this);

    }









     public  virtual void target() {
      Cell cell;
      int x;
      int y;
      if (this.targeter != null) {
        cell = this.targeter.guess();
        if (cell == null) {
          this.targeter = null;
          target();
          return;

        };

      }
      else {
        x = Random.int_range(0, 9);
        y = Random.int_range(0, 9);
        cell = game.player.grid.find_cell(x, y);

      };
      if (this.targeter != null) {
        this.targeter.last_guess = cell;

      };
      if (cell.ship.sunken) {
        if (this.targeter != null) {
          this.targeter.hit_bound();

        };
        target();
        return;

      };
      if (cell.state == Cell.STATE_MISS) {
        if (this.targeter != null) {
          this.targeter.hit_bound();

        };
        target();
        return;

      };
      if (cell.state == Cell.STATE_HIT) {
        if (this.targeter != null) {
          this.targeter.hit_bound();

        };
        target();
        return;

      };
      cell.clicked();








      if (cell.state == Cell.STATE_HIT) {
        if (this.targeter == null) {
          this.targeter = new Targeter(this);


          this.targeter.first_hit = cell;

        };
        this.targeter.last_hit = cell;




        if (cell.ship.sunken) {
          this.targeter = null;

        };

      };

    }

  }


  public class Game : Object {
    public  ToolButton quit_button;
    public  ToolButton new_game_button;
    public  ToolButton redraw_button;
    public Statusbar status_bar;
    public uint context_id;
        public  Gtk.Window window {

        get;
        set;

      }

        public  Player player {

        get;
        set;

      }

        public  Computer computer {

        get;
        set;

      }

        public  bool active {

        set;
        get;

      }

        public  int wins {

        set;
        get;

      }

        public  int losts {

        set;
        get;

      }


     public signal void activate();

    public Game (Window win) {
      this.active = false;
      this.wins = 0;
      this.losts = 0;
      Object(window: win);
      this.computer = new Computer(this);
      this.player = new Player(this);
      draw();
      this.player.lost_game.connect(() => {
        message("You lost :(\n");
        this.losts = this.losts + 1;
        new_game();

      });
      this.computer.lost_game.connect(() => {
        message("You win!\n");
        this.wins = this.wins + 1;
        new_game();

      });
      activate.connect(() => {
        this.active = true;
        this.redraw_button.set_sensitive(false);

      });
      new_game();
      this.window.show_all();

    }

     public  virtual void message(string msg) {
      var dialog = new Gtk.MessageDialog(this.window, Gtk.DialogFlags.MODAL, Gtk.MessageType.WARNING, Gtk.ButtonsType.OK_CANCEL, msg);
      dialog.run();
      dialog.destroy();

    }

     public  virtual void new_game() {
      this.status_bar.push(this.context_id, @"Wins: $(this.wins) Losts: $(this.losts)");
      this.active = false;
      this.player.auto_layout();
      this.computer.auto_layout();
      this.redraw_button.set_sensitive(true);
      this.redraw_button.show();

    }

     public  virtual void draw() {
      var vb = new Gtk.VBox(false, 0);
      var tb = new Gtk.Toolbar();
      this.quit_button = new Gtk.ToolButton.from_stock(Gtk.Stock.QUIT);
      tb.add(this.quit_button);
      this.quit_button.clicked.connect(() => {
        Gtk.main_quit();

      });
      this.new_game_button = new Gtk.ToolButton.from_stock(Gtk.Stock.NEW);
      tb.add(this.new_game_button);
      this.new_game_button.clicked.connect(() => {
        this.player.lost_game();

      });
      this.redraw_button = new Gtk.ToolButton.from_stock(Gtk.Stock.REDO);
      tb.add(this.redraw_button);
      this.redraw_button.clicked.connect(() => {
        this.player.auto_layout();

      });
      vb.pack_start(tb, false, false, 2);
      var hb = new Gtk.HBox(false, 0);
      vb.pack_start(hb, true, true, 0);
      this.window.add(vb);
      this.player.grid.draw(hb);
      hb.pack_start(new HSeparator(), false, false, 14);
      this.status_bar = new Gtk.Statusbar();
      this.context_id = this.status_bar.get_context_id("battleship");
      vb.pack_start(this.status_bar, false, false, 0);
      this.computer.grid.draw(hb);

    }

  }


  public class Cell : Button {
        public  int x {

        set;
        get;

      }

        public  int y {

        set;
        get;

      }

        public  int state {

        set;
        get;

      }

        public  int ostate {

        set;
        get;

      }

        public  Ship? ship {

        set;
        get;

      }

    public const int STATE_HIT = 1;
    public const int STATE_MISS = 2;
    public const int STATE_SHIP = 3;
    public const int STATE_WATER = 0;
    public const int STATE_SUNK = 4;

    public Cell () {
      int st; st = 0;
      Object(state: st);
      set_size_request(40, 40);

    }

     public  virtual bool has_ship() {
      if (this.ship != null) {
        return (true);

      };
      return (false);

    }

     public  virtual void render() {
      var c = new Gdk.RGBA();
      if (this.state == Cell.STATE_WATER) {
        c.parse("rgb(0,0,255)");

      }
      else if (this.state == Cell.STATE_HIT) {
        c.parse("rgb(255,0,0)");

      }
      else if (this.state == Cell.STATE_MISS) {
        c.parse("rgb(255,255,255)");

      }
      else if (this.state == Cell.STATE_SHIP) {
        c.parse("rgb(0,255,0)");

      }
      else if (this.state == Cell.STATE_SUNK) {
        c.parse("rgb(128,25,66)");

      };
      override_background_color(0, c);

    }

  }


  public class Grid : Object {
        public  Player player {

        get;
        set;

      }

    public Box widget;

    public Grid (Player player) {
      Object(player: player);

    }

     public  virtual Cell add_cell() {
      var cell = new Cell();
      return (cell);

    }

     public  virtual void draw(Gtk.Box where) {
      this.widget = new Gtk.VBox(false, 0);

      for (int i = 0; i <= 9; i++) {
        var row = new Gtk.HBox(false, 0);

        for (int x = 0; x <= 9; x++) {
          var b = add_cell();
          b.x = x;
          b.y = i;
          b.render();
          b.enter_notify_event.connect(() => {
            b.ostate = b.state;
            b.state = Cell.STATE_MISS;
            b.render();
            return (false);

          });
          b.clicked.connect(() => {
            if (b.state == Cell.STATE_SUNK || b.ship.sunken) {

            }
            else {
              if (b.state != Cell.STATE_HIT) {
                if (b.has_ship()) {
                  b.state = Cell.STATE_HIT;
                  b.ostate = Cell.STATE_HIT;
                  b.ship.hit();

                }
                else {
                  b.state = Cell.STATE_MISS;
                  b.ostate = Cell.STATE_MISS;

                };
                b.render();

              };

            };

          });
          b.leave_notify_event.connect(() => {
            b.state = b.ostate;
            b.render();
            return (false);

          });
          row.pack_start(b, true, true, 0);

        };

        this.widget.pack_start(row, true, true, 0);

      };

      where.pack_start(this.widget, true, true, 0);

    }

     public  virtual void clear() {

      for (int y = 0; y <= 9; y++) {

        for (int x = 0; x <= 9; x++) {
          var cell = ((Cell)find_cell(x, y));
          cell.state = 0;
          cell.ostate = 0;
          cell.ship = null;
          cell.render();

        };


      };


    }

     public  virtual Cell? find_cell(int x, int y) {
      int r; r = 0;
      int c; c = 0;
      Widget? found = null;
      this.widget.foreach((row) => {
        if (r == y) {
          ((Box)row).foreach((cell) => {
            if (c == x) {
              found = cell;

            };
            if (c > x) {
              return;

            };
            c = c + 1;

          });

        };
        if (r > y) {
          return;

        };
        r = r + 1;

      });
      return ((Cell)found);

    }

  }


  public class ComputerGrid : Grid {

    public ComputerGrid (Player player) {
      Object(player: player);

    }

     public  override Cell add_cell() {
      var cell = new Cell();
      cell.clicked.connect(() => {
        if (!this.player.game.active) {
          this.player.game.activate();

        };
        this.player.game.computer.target();

      });
      return (cell);

    }

  }


  public class Ship : Object {
    public int length;
    public bool orient;
    public Cell?[] cells;
    public int n_cells = 0;
        public  bool sunken {

        get;
        set;

      }

        public  int hits {

        get;
        set;

      }

        public  Grid grid {

        get;
        set;

      }

        public  string name {

        get;
        set;

      }


     public signal void hit();

     public signal void sunk();

        construct {
      this.sunken = false;
      hit.connect(() => {
        if (this.sunken) {
          return;

        };
        this.hits = this.hits + 1;
        if (this.hits == this.length) {
          this.sunk();

        };

      });
      sunk.connect(() => {
        this.sunken = true;
        stdout.puts(@"$(this.name) sunk\n"); ;

        for (int i = 0; i <= this.cells.length - 1; i++) {
          this.cells[i].state = Cell.STATE_SUNK;
          this.cells[i].ostate = Cell.STATE_SUNK;
          this.cells[i].render();

        };


      });

    }

  }


  public class PatrolBoat : Ship {

        construct {
      this.length = 2;
      this.name = "PatrolBoat";

    }

  }


  public class Destroyer : Ship {

        construct {
      this.length = 3;
      this.name = "Destroyer";

    }

  }


  public class Submarine : Ship {

        construct {
      this.length = 4;
      this.name = "Submarine";

    }

  }


  public class Carrier : Ship {

        construct {
      this.length = 5;
      this.name = "Carrier";

    }

  }


  public class BattleShip : Ship {

        construct {
      this.length = 6;
      this.name = "BattleShip";

    }

  }


  public static void main(string[] args) {
    Gtk.init(ref args);
    var win = new Window();
    win.set_title("Territorial Battle");
    var game = new Game(win);
    win.destroy.connect(() => {
      Gtk.main_quit();

    });
    Gtk.main();

  }

}
