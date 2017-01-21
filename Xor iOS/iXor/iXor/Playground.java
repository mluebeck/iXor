package xor;
import java.io.*;
import java.awt.*;
import java.awt.Toolkit.*;

public class Playground {
    static final byte FISH=         1;
    static final byte CHICKEN=      2;
    static final byte MAP_1=        3;
    static final byte MAP_2=        4;
    static final byte MAP_3=        5;
    static final byte MAP_4=        6;
    static final byte MASK=         7;
    static final byte BAD_MASK=     8;
    static final byte H_WAVE=       9;
    static final byte V_WAVE=      10;
    static final byte PUPPET=      11;
    static final byte BOMB=        12;
    static final byte ACID=        13;
    static final byte TRANSPORTER= 14;
    static final byte PLAYER_1=    15;
    static final byte PLAYER_2=    16;
    static final byte EXIT=        17;
    static final byte WALL=        18;
    static final byte SPACE=        0;
    public static
           final short MAX_STEP=   999;
    static final short WAITING=   1000;

    static final byte UP=           0;
    static final byte DOWN=         1;

    static final byte RIGHT=        2;

    static final byte LEFT=         3;
    static final byte PLAYER_CHANGED= 4;

    static final short KEY_UP=    38;
    static final short KEY_DOWN=  40;
    static final short KEY_MAP=   77;
    static final short KEY_SPACE= 32;
    static final short KEY_LEFT=  37;
    static final short KEY_RIGHT= 39;
    static final short KEY_CHANGE=   67;
    static final short KEY_REPLAY = 82;
    static final short STATUS_X=   350;

    int x_wert;               // screen co-ordinates of the player
    int y_wert;
    int x_wert_old;           // old screen co-ordinates
    int y_wert_old;
    byte nothing_loaded;      // =1:show start level, else greeting screen
    boolean karten_flag;      // =1: a map has been collected, so update the status display
    byte akt_spieler;         // =0:player 1,  1:player 2
    byte ende_erreicht;       // =0: start
                              // =1: all masks collected !
                              // =99: one player is dead and one has just been killed
                              //      OR >1000 moves: You failed !
                              // =98: one player is dead and the other alive
    short anzahl;             // How many moves have you done ?
    short anzahl_masken;      // Number of masks available in a level
    boolean invisible;        // have you collected a 'bad mask' all walls becomes invisible
    byte karten;              // how many map parts have you collected ?
    short gesammelte_masken;  // how many masks have you collected ?
    boolean map_flag;         // =1: show map and not the playground
    boolean masken_gefunden;  // you have found a mask
    boolean death;                                      // =1: only one player left !
    public byte replay[]= new byte[MAX_STEP+1];         // stores all moves to enable replay
    public int next_step;                               // number of moves ( max. 1000)
    byte groesse;                                       // playground dimensions (=32x32)
    byte spieler[][]   = new byte[2][2];                // spieler[0][0]: 1. player, Pos. X, spieler[0][1] : Y
    byte spielfeld[][] = new byte[32][32];              // the playground
    byte beam_from[][] = new byte[20][2];               // transporter start co-ordinates
    byte beam_to[][]   = new byte[20][2];               // transporter target co-ordinates
    byte x_clipper, y_clipper;                          // the part of the playground, which should be shown
    String names[] = new String[25];                    // Die file names of the bitmaps
    String level;                        // the level file name(e.g. level01.xor)
    public String level_name;            // the 'official' level name (e.g. "The Decoder")
    String directory;                    // the path to the xor directory
    Image sprites[]  = new Image[25];                  // all images
    Image bomben[][] = new Image[8][3];                // bomb explosion animation
    Image acid[][]   = new Image[8][3];                // acid corrosion animation
    public Image play_buffer;                          // the playground image
    public Graphics graph_offline,graph_online;        // these objects connects the playground with the window
    Frame frame;                                       // the frame where the playground will be shown
    MediaTracker mtracker;                             // Observer for all loaded images
    byte level_geschafft;                              // how many level have you completed ??

    // load the number of finished levels (stored in '.level-nr'
    void loadLevelFinished() {
        RandomAccessFile lev = null;
        try {
            lev = new RandomAccessFile(".level-nr","r");
        } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
        }
        try {
            level_geschafft=(byte) readInteger(lev);
            //System.out.println(level_geschafft);
        } catch (IOException e) {
            //System.err.println(e);
            System.exit(0);
        }
    }

    // and save it...
    void saveLevelFinished() {
        RandomAccessFile lev = null;
        try {
            lev = new RandomAccessFile(".level-nr","w");
        } catch (IOException e) {
            System.err.println(e);
            //System.out.println("doReplay.216");
            System.exit(0);
        }
        try {
            String s="";
            s.valueOf(level_geschafft);
            lev.writeChars(s);
            //System.out.println(level_geschafft);
        } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
        }
    }

    // busy waiting...
    void wait(int i) {
        for (int j=0;j<1000*i;j++)
            ;
    }

    // Constructor to set level file name and directory path
    // (there all data files/directories (pictures, sounds,..) can be found)
    public Playground(String ffile,String p) {
        directory=p;
        setLevel(ffile);
        init();
    }

    // set directory path
    public void setDirectory(String a) {
        directory=a;
    }

    public Playground(String ffile,String p, Frame fr, Image img) {
        directory=p;
        loadLevelFinished();
            frame=fr;
        mtracker = new MediaTracker(fr);
        setLevel(ffile);


    }

    public void setGraphicsOffline(Graphics g) {
    }

    public void setGraphicsOnline(Graphics g) {
        if (graph_online==null)
          graph_online=g;
    }

    public void setImage(Image img) {
    }

    // start level or greeting screen ?
    public int levelLoaded() {
        return nothing_loaded;
    }

    // Set above status
    public void levelLoaded(byte e) {
        nothing_loaded=e;
    }

    // Convert chars of level file into numbers
    byte convert(char v) {
        if (v=='F')
            return 1;
        else if (v=='X')
            return 8;
        else if (v=='C')
            return 2;
        else if (v=='m')
            return 3;
        else if (v=='n')
            return 4;
        else	if (v=='o')
            return 5;
        else 	if (v=='p')
            return 6;
        else	if (v=='M')
            return 7;
        else 	if (v=='N')
            return 8;
        else 	if (v=='H')
            return 9;
        else 	if (v=='V')
            return 10;
        else	if (v=='P')
            return 11;
        else	if (v=='B')
            return 12;
        else	if (v=='S')
            return 13;
        else	if (v=='T')
            return 14;
        else	if (v=='a')
            return 15;
        else	if (v=='b')
            return 16;
        else if (v=='E')
            return 17;
        else if (v=='W')
            return 18;
        else if (v=='_')
            return 0;
        return -1;
    }

    // fill/erase replay array with -1
    void initReplay() {
        for (int i=0;i<MAX_STEP+1;i++) {
            replay[i]=-1;
        }
    }

    // How many moves in the replay array ?
    public int countMoves() {
        int i=0;
        while (replay[i]!=-1)
        i++;
        return i;
    }

    // Read an Integer value (representated in the file by a char array)
    public int readInteger(RandomAccessFile file) throws IOException {
        String val="";
        byte k=0;
        boolean quit=false;
        while (k<33 || k>127) {
            k= file.readByte();
            //System.out.println(k);
        }
        // k>=32 && k<128
        val=val+(char)k;
        while (k>32 && k<128) {
            k= file.readByte();
            //System.out.println(k);
            if (k>32 && k<128)
            val=val+(char)k;
            }
        return Integer.parseInt(val);
        }

        public void loadMoves(String name) {
        //System.out.println("OPEN :"+name);
        char[] levels=new char[200];
        RandomAccessFile ffile=null;
        try {
            ffile = new RandomAccessFile(name,"r");
        } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
        }

            byte val=0;
        byte v=0;
        byte k=0;
        short i=0;
        try {
            val = ffile.readByte();
        } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
        }

        while (val!=(char)'#') {
            try {
            val = ffile.readByte();
            } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
            }
        }
        // From here, val=='#'
        try {
            val = ffile.readByte();
        } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
        }
        while (val!=(char)'#')
        {
            if (val!=0) {
            levels[i++]=(char) val;
            }
            try {
            val = ffile.readByte();
            //levels[i++]= (char) val;
            } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
            }
        }
        while (val==(char)'#') {
            try {
            val=ffile.readByte();
            } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
            }
        }
            // Here again: val!="#"
        String g=new String(levels);
        //System.out.println("String1:"+g);
        setLevel(g);
        //System.out.println("String1.5:"+g);
        //getLevelname(); // level_name = the level title name
        //System.out.println("String2:"+g);
        loader();
        //System.out.println("String3:"+g);
        levelLoaded((byte) 0);
        showStatus(-1);
        x((byte) (playerX((byte) 0)-4));
        y((byte) (playerY((byte) 0)-4));
        showPlayer((byte) 0,(byte) 0);
        initPlayground();

        i=0;
        while (i<=MAX_STEP) {
            try {
            k=(byte)readInteger(ffile);
            } catch (IOException e) {
            //System.err.println(e);
            k=-1;
            }
            if (k!=-1) {
            replay[i]=k;
            i++;
            } else {
            i=MAX_STEP+1;
            }
            //System.out.println( k+".");
        }

        try {
            ffile.close();
        } catch (IOException e) {
            System.exit(0);
        }
        /*
        loader();
        System.out.println("String3:"+g);
        levelLoaded((byte) 0);
        showStatus(-1);
        x((byte) (playerX((byte) 0)-4));
        y((byte) (playerY((byte) 0)-4));
        showPlayer((byte) 0,(byte) 0);
        initPlayground();
        */
        showStatus(-1);
        doReplay();
    }

    // Open the level file

    public void loadAll() {
        char levels[] = new char[200];
        byte val=0,v=0,k=0,i=0;

        RandomAccessFile ffile = null;
        try {
            ffile = new RandomAccessFile(level,"r");
        } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
        }

        try {
            val = ffile.readByte();
        } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
        }

        while (val!=(char)'#') {
            try {
            val = ffile.readByte();
            } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
            }
        }
        // From here, val=='#'
        try {
            val = ffile.readByte();
        } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
        }
        while (val!=(char)'#')
        {
            if (val!=0)
            levels[i++]=(char) val;
            try {
            val = ffile.readByte();
            } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
            }

        }
        level_name=new String(levels);
        while (val==(char)'#') {
            try {
            val=ffile.readByte();
            } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
            }
        }
            // Here again: val!="#"

        for (i=0;i<32;i++) {
            for (byte j=0;j<32;j++) {
            try {
                k = ffile.readByte();
            } catch (IOException e) {
                System.err.println(e);
                System.exit(0);
            }
            while (k<31) {
                try {
                k=ffile.readByte();
                } catch (IOException e) {
                System.err.println(e);
                System.exit(0);
                }
            }
            spielfeld[i][j]=(byte) convert((char) k);
            if (k==(char)'a') {
                if (spieler[0][0]==0 && spieler[0][1]==0) {
                playerX((byte)0,i);
                playerY((byte)0,j);
                //System.out.println("PLAYER_X:"+i+"PLAYER_Y:"+j);
                }
            } else {
                if (k==(char)'b') {
                if (spieler[1][0]==0 && spieler[1][1]==0) {
                    playerX((byte)1,i);
                    playerY((byte)1,j);
                }
                } else {
                if (k==(char)'M') {
                    anzahl_masken++;
                }
                }
            }
            }
        }

        // load transporter co-ordinates
        for (int m=0;m<20;m++){
            beam_from[m][0]=-1;
            beam_from[m][1]=-1;
            beam_to[m][0]=-1;
            beam_to[m][1]=-1;
        }
        int kl=0;
        byte x=0,quit = 0;
        while (quit==0) {
            try {
            kl=readInteger(ffile);
            } catch (IOException e) {
            //System.err.println(e);
            kl=-1;
            }
            if (kl==-1) {
            quit=1;
            } else {
            beam_from[x][0]=(byte)kl;
            try {
                kl=readInteger(ffile);
            } catch (IOException e) {
                //System.err.println(e);
                kl=-1;
            }
            if (kl==-1) {
                quit=1;
            } else {
                beam_from[x][1]=(byte)kl;
                try {
                kl=readInteger(ffile);
                } catch (IOException e) {
                //System.err.println(e);
                kl=-1;
                }
                if (kl==-1) {
                quit=1;
                } else {
                beam_to[x][0]=(byte)kl;
                try {
                    kl=(byte)readInteger(ffile);
                } catch (IOException e) {
                    //System.err.println(e);
                    kl=-1;
                }

                if (kl==-1) {
                    quit=1;
                } else {
                    beam_to[x][1]=(byte)kl;
                }
                }
            }
            }
            x++;
        }

        // closing the file ....
        try {
            ffile.close();
        } catch (IOException e) {
            System.exit(0);
        }
        //System.out.println("Fertig.");

    }


    public void doReplay() {
        //System.out.println("doReplay....1");
        spieler[0][0]=0;
        spieler[0][1]=0;
        spieler[1][0]=0;
        spieler[1][1]=0;
        anzahl_masken=0;
        gesammelte_masken=0;
        nothing_loaded=0;

        invisible=false;
        next_step=0;
        karten = 0;
        x_clipper=0;
        akt_spieler=0;
        y_clipper=0;
        ende_erreicht=0;
        groesse=32;
        anzahl=0;
        karten_flag=false;
        map_flag=false;
        masken_gefunden=false;
        death=false;
        x_wert=0;
        y_wert=0;
        x_wert_old=-1;
        y_wert_old=-1;
        next_step=0;

        loadAll();

        //	showStatus(-1);
        //	x((byte)(playerX((byte)0)-4));
        //	y((byte)(playerY((byte)0)-4));
        //	showPlayer((byte)0,(byte)0);
        //Redraw();
        //	initPlayground();
        //	next_step=0;
        //	Redraw();
    }

    public boolean replayNext() {
        if (next_step<MAX_STEP+1 && next_step>=0 && replay[next_step]!=-1 ) {
            if (replay[next_step]==UP) {
            keyPressing(KEY_UP);
            next_step++;
            } else if (replay[next_step]==DOWN) {
            keyPressing(KEY_DOWN);
            next_step++;
            } else if (replay[next_step]==LEFT) {
            keyPressing(KEY_LEFT);
            next_step++;
            } else if (replay[next_step]==RIGHT) {
            keyPressing(KEY_RIGHT);
            next_step++;
            } else if (replay[next_step]==PLAYER_CHANGED) {
            keyPressing(KEY_CHANGE);
            next_step++;
            }
        } else {
            next_step=-1;
            return false;
        }
        return true;
    }

    void Paint() {
        graph_online.drawImage(play_buffer, 5, 50, frame);
    }

    public void keyPressing(int k) {
        //System.out.println("KeyPressing:"+k);

        if (ende_erreicht==1) {
            successScreen();
            return;
        }
        if (ende_erreicht==99) {
            failureScreen();
            return;
        }
        // nothing_loaded=1 : show the greeting screen
        if (nothing_loaded==1) {
            return;
        }

        if (k==KEY_MAP) {
            map();
            showPlayer(player(),(byte)0);
            Redraw();
            return;
        }

        if (map_flag==false) {
            if (k==KEY_UP) {  //UP-Arrow
                if (playerX(player())>0) {
                    movePlayerUp(player());
                    Redraw();
                    return;
                }
            }
            if (k==KEY_DOWN) {  //DOWN-Arrow
                if (playerX(player())<groesse) {
                    movePlayerDown(player());
                    Redraw();
                    return;
                }
            }
            if (k==KEY_RIGHT) { // RIGHT Arrow
                if (playerY(player())<groesse) {
                    movePlayerRight(player());
                    Redraw();
                    return;
                }
            }
            if (k==KEY_LEFT) { // LEFT Arrow
                if (playerY(player())>0) {
                    movePlayerLeft(player());
                    Redraw();
                    return;
                }
            }
            if (ende_erreicht==99) {
                failureScreen();
                nothing_loaded=1;
                Redraw();
                return;
            }
            if (k==KEY_CHANGE && death==false) { // Change Player
                changePlayer();
                x((byte)(playerX((byte)(player()))-4));
                y((byte)(playerY((byte)(player()))-4));
                map_flag=false;
                showStatus(0);
                showPlayer(player(),(byte)0);
                Redraw();
                return;
            }
            if (k==KEY_SPACE) {
                x((byte)(playerX((byte)(player()))-4));
                y((byte)(playerY((byte)(player()))-4));
                showPlayer(player(),(byte)-1);
                Redraw();
                return;
            }
        }
    }

    void Redraw() {
        // contains game ending logic
        if (nothing_loaded==0) {
            showStatus(0);
            if (masken_gefunden==true) {
                showStatus(1);
                masken_gefunden=false;
            }

            if (karten_flag==true) {
                showStatus(2);
                karten_flag=false;
            }
            //Success !
            if (ende_erreicht==1) {
                successScreen();
            }
            // one player killed and one player dead : Failure!!
            if (ende_erreicht==98 && death==true) {
                ende_erreicht=99;
            }
            // Failure!!
            if (ende_erreicht==99) {
                failureScreen();
            }
            // a player killed: show 'Whoops!'
            if (ende_erreicht==98) {
                ende_erreicht=0;
                deathScreen();
                changePlayer();
                x((byte)(playerX(player())-4));
                y((byte)(playerY(player())-4));
                map_flag=false;
                death=true;
                showStatus(0);
                showPlayer(player(),(byte)0);
            }
        }
        Paint();
    }

    public void init() {
       	invisible=false; // all walls visible!
        next_step=-1;

        karten = 0;
        x_clipper=0;
        akt_spieler=0;
        y_clipper=0;
        ende_erreicht=0;
        groesse=32;
        anzahl=0;
        karten_flag=false;
        map_flag=false;
        masken_gefunden=false;
        death=false;
        x_wert=0;
        y_wert=0;
        x_wert_old=-1;
        y_wert_old=-1;
       	initReplay();
        //********************************************
        //****  Load file names from .files  **********
        //********************************************
        RandomAccessFile ffile=null;
        String d=directory+"/.files", name=null;
        int i=0;
        try {
            ffile = new RandomAccessFile(d,"r");
        } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
        }
        for (i=0;i<25;i++) {
            try {
            name=ffile.readLine();
            } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
            }
            names[i]=directory+"/"+name;
        }

        loader();
        loadImages();
    }

    public void greetingScreen() {
        //while (
        graph_offline.drawImage(sprites[24],0,0,frame)//==false)
            ;
        Paint();
    }
    
    // A player has been killed, only a second player left
    void deathScreen() {
        graph_offline.clearRect(100,80,130,30);
        graph_offline.setColor(Color.black);
        graph_offline.drawString(" Whoops ! ",100,100);
        waitCursor();
        Paint();
        wait(100000);
        activeCursor();
    }


    void waitCursor() {
        if (frame!=null) {
            frame.setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
        }
    }

    void activeCursor() {
        if (frame!=null) {
            frame.setCursor(null);
        }
    }

    // All two players killed!
    void failureScreen() {
        graph_offline.clearRect(100,80,130,30);
        graph_offline.setColor(Color.black);
        graph_offline.drawString(" You failed ! ",100,100);
        waitCursor();
        Paint();
        wait(100000);
        activeCursor();
        greetingScreen();
    }

    // The puzzle has been solved....
    void successScreen() {
        graph_offline.clearRect(100,80,130,30);
        graph_offline.setColor(Color.black);
        graph_offline.drawString(" You succeeded ! ",100,100);
        Paint();
        waitCursor();
        wait(100000);
        activeCursor();
    }

    // The actual player
    byte player() {
        return akt_spieler;
    }

    // Swap the players
    void changePlayer() {
        if (anzahl>MAX_STEP) {
            ende_erreicht=99;
            return;
        }
        if (akt_spieler==0) {
            akt_spieler=1;
        } else {
            akt_spieler=0;
        }
        x_wert_old=-1;
        y_wert_old=-1;
        replay[anzahl]=PLAYER_CHANGED;
        anzahl++;
    }

    // Returns the x value of the clipping area
    public int x() {
        return x_clipper;
    }

    // Returns the y value of the clipping area
    public int y() {
        return y_clipper;
    }

    // sets the x value
    public void x(byte x) {
        if (x>24) {
            x_clipper=24;
        } else {
            if (x<0) {
            x_clipper=0;
            } else {
            x_clipper=x;
            }
        }
    }

    // sets the y value
    public void y(byte y) {
        if (y>24) {
            y_clipper=24;
        } else {
            if (y<0) {
            y_clipper=0;
            } else {
            y_clipper=y;
            }
        }
    }

    // player x co-ordinates --> screen x co-ordinates
    byte coordX(byte x) {
        byte i=(byte)(x-x_clipper);
        if (i>7 || i<0)
            i=-1;
        return i;
    }

    // player y co-ordinates --> screen y co-ordinates
    byte coordY(byte y) {
        byte i=(byte) (y-y_clipper);
        if (i>7 || i<0)
            i=-1;
        return i;
    }

    void incPlayerX(byte i) {
        spieler[i][0]++;
    }

    void incPlayerY(byte i) {
        spieler[i][1]++;
    }

    void decPlayerX(byte i) {
        spieler[i][0]--;
    }

    void decPlayerY(byte i) {
        spieler[i][1]--;
    }

    // Where is player i ? (returns x co-ordinate)
    public byte playerX(byte i) {
        return spieler[i][0];
    }

    // Where is player i ? (returns y co-ordinate)
    public byte playerY(byte i) {
        return spieler[i][1];
    }

    // Sets player i x co-ordinate
    void playerX(byte i,byte x) {
        spieler[i][0]=x;
    }

    // Sets player i y co-ordinate
    void playerY(byte i,byte y) {
        spieler[i][1]=y;
    }

    void badMask() {
        if (invisible==false) {
            sprites[18] = Toolkit.getDefaultToolkit().getImage(names[0]);
            //Load(names[0]); //new Sprite(names[0]);
            invisible = true;
        } else {
            sprites[18] = Toolkit.getDefaultToolkit().getImage(names[18]);
            //.Load(names[18]);
            invisible = false;
        }
        Paint();
    }

    // can we move the player down ?
    void movePlayerDown(byte i) {
        if (anzahl>MAX_STEP) {
            ende_erreicht=99;
            return;
        }
        byte k=spielfeld[playerX(i)+1][playerY(i)];
        if (k==BAD_MASK) {
            badMask();
            movePlayer(i,DOWN,(byte)0);
            return;
        }	//invisible = !invisible;
        if (k==MASK) {
            movePlayer(i,DOWN,(byte)0);
            masken_gefunden=true;
            gesammelte_masken++;
            return;
        }
        if (k==EXIT) {
            if (anzahl_masken==gesammelte_masken) {
            ende_erreicht=1;
            movePlayer(i,DOWN,(byte)0);
            }
            return;
        }
        if (k==MAP_1) {
            movePlayer(i,DOWN,(byte)0);
            karten = (byte) (karten | 1);
            karten_flag=true;
            return;
        }
        if (k==MAP_2) {
            karten_flag=true;
            movePlayer(i,DOWN,(byte)0);
            karten = (byte) (karten | 2);
            return;
        }
        if (k==MAP_3) {
            karten_flag=true;
            movePlayer(i,DOWN,(byte)0);
            karten = (byte) (karten | 4);
            return;
        }
        if (k==MAP_4) {
            karten_flag=true;
            movePlayer(i,DOWN,(byte)0);
            karten = (byte) (karten | 8);
            return;
        }
        if (k==PUPPET) {
            if ((playerX(i)+2)<32) {
            int l = spielfeld[playerX(i)+2][playerY(i)];
            if (l==H_WAVE || l==SPACE) {
                dollsThrow(playerX(i)+1,playerY(i),DOWN);
                movePlayer(i,DOWN,(byte)0);
                return;
            }
            }
        }


        if (k==H_WAVE || k==SPACE) {
            movePlayer(i,DOWN,(byte)0);
            return;
        }

        if (k==TRANSPORTER) {
            beamMeUp();
            return;
        }

        // Chicken Run : can the player move a chicken down ?
        if (k==CHICKEN || k==ACID) {
            if ((playerX(i)+2) <=31) {
            int l=spielfeld[playerX(i)+2][playerY(i)];
            if (l==H_WAVE || l==SPACE) {
                movePlayer(i,DOWN,k);
                spielfeld[playerX(i)+1][playerY(i)]=k;
                if ((playerY(i)+1)>0) {
                chickenRun(k,(byte)(playerX(i)+1),playerY(i),(byte) 0);
                show((byte)-1);
                }
            }
            }
            return;
        }
    }
    
    // Can we move the player right ?
    void movePlayerRight(byte i) {
        // There, no chicken can be released !
        if (anzahl>MAX_STEP) {
            ende_erreicht=99;
            return;
        }
        byte k=spielfeld[playerX(i)][playerY(i)+1];
        if (k==BAD_MASK) {
            badMask();
            movePlayer(i,RIGHT,(byte)0);
            return;
        }
        if (k==EXIT) {
            if (anzahl_masken==gesammelte_masken) {
            movePlayer(i,RIGHT,(byte)0);
            ende_erreicht=1;
            }

        }
        if (k==MASK) {
            masken_gefunden=true;
            movePlayer(i,RIGHT,(byte)0);
            gesammelte_masken++;
            return;
        }
        if (k==MAP_1) {
            karten_flag=true;
            movePlayer(i,RIGHT,(byte)0);
            karten = (byte)(karten | 1);
            return;
        }
        if (k==MAP_2) {
            karten_flag=true;
            movePlayer(i,RIGHT,(byte)0);
            karten = (byte)(karten | 2);
            return;
        }
        if (k==MAP_3) {
            karten_flag=true;
            movePlayer(i,RIGHT,(byte)0);
            karten = (byte)( karten | 4);
            return;
        }
        if (k==MAP_4) {
            karten_flag=true;
            movePlayer(i,RIGHT,(byte)0);
            karten = (byte)(karten | 8);
            return;
        }
        if (k==PUPPET) {
            if ((playerY(i)+2) < 32) {
            int l = spielfeld[playerX(i)][playerY(i)+2];
            if (l==V_WAVE || l==SPACE) {
                dollsThrow(playerX(i),playerY(i)+1,RIGHT);
                movePlayer(i,RIGHT,(byte)0);
            }
            }
            return;
        }
        // Fish fall : Check, if you can move a fish to the left
        if (k==FISH || k==BOMB) {
            if ((playerY(i)+2) <=31) {
            int l = spielfeld[playerX(i)][playerY(i)+2];
            if (l==V_WAVE || l==SPACE) {
                movePlayer(i,RIGHT,k);
                spielfeld[playerX(i)][playerY(i)+1]=k;
                if ((playerY(i)+1)<=31) {
                fishFall(k,playerX(i),(byte)(playerY(i)+1));
                show((byte)-1);
                }
            }
            }
        }

        if (k==V_WAVE || k==SPACE) {
            movePlayer(i,RIGHT,(byte)0);
        }

        if (k==TRANSPORTER) {
            beamMeUp();
            return;
        }
    }

    // can we move the player up ?
    void movePlayerUp(byte i) {
        if (anzahl>MAX_STEP) {
            ende_erreicht=99;
            return;
        }
        byte k=spielfeld[playerX(i)-1][playerY(i)];
        if (k==BAD_MASK) {
            badMask();
            movePlayer(i,UP,(byte)0);
            return;
        }
        if (k==EXIT) {
            if (anzahl_masken==gesammelte_masken) {
            movePlayer(i,UP,(byte)0);
            ende_erreicht=1;
            }
            return;
        }

        if (k==MASK) {
            masken_gefunden=true;
            movePlayer(i,UP,(byte)0);
            gesammelte_masken++;
            return;
        }
        if (k==MAP_1) {
            karten_flag=true;
            movePlayer(i,UP,(byte)0);
            karten = (byte) (karten | 1);
            return;
        }
        if (k==MAP_2) {
            karten_flag=true;
            movePlayer(i,UP,(byte)0);
            karten = (byte)(karten | 2);
            return;
        }
        if (k==MAP_3) {
            karten_flag=true;
            movePlayer(i,UP,(byte)0);
            karten = (byte)(karten | 4);
            return;
        }
        if (k==MAP_4) {
            karten_flag=true;
            movePlayer(i,UP,(byte)0);
            karten = (byte)(karten | 8);
            return;
        }
        if (k==PUPPET) {
            if ((playerX(i)-2)>0) {
            int l = spielfeld[playerX(i)-2][playerY(i)];
            if (l==H_WAVE || l==SPACE) {
                dollsThrow(playerX(i)-1,playerY(i),UP);
                movePlayer(i,UP,(byte)0);
                return;
            }
            }
        }
        if (k==SPACE || k==H_WAVE) {
            movePlayer(i,UP,(byte)0);
            return;
        }

        if (k==TRANSPORTER) {
            beamMeUp();
            return;
        }

        // Chicken Run : Check, if you can move a chicken to the top
        if (k==CHICKEN || k==ACID) {
            if ((playerX(i)-2) >=0) {
            int l = spielfeld[playerX(i)-2][playerY(i)];
            if (l==H_WAVE || l==SPACE) {
                movePlayer(i,UP,k);
                spielfeld[playerX(i)-1][playerY(i)]=k;
                if ((playerY(i)-1)>0) {
                chickenRun(k,(byte)(playerX(i)-1),playerY(i),(byte)0);
                show((byte)-1);
                }
            }
            }
            return;
        }
    }

    // Can we move a player to the left ?
    void movePlayerLeft(byte i) {
        if (anzahl>MAX_STEP) {
            ende_erreicht=99;
            return;
        }
        byte k=spielfeld[playerX(i)][playerY(i)-1];
        if (k== BAD_MASK) {
            badMask();
            movePlayer(i,LEFT,(byte)0);
            return;
        }
        if (k==EXIT) {
            if (anzahl_masken==gesammelte_masken) {
            ende_erreicht=1;
            movePlayer(i,LEFT,(byte)0);
            }
            return;
        }
        if (k==MASK) {
            masken_gefunden=true;
            movePlayer(i,LEFT,(byte)0);
            gesammelte_masken++;
            return;
        }
        if (k==MAP_1) {
            karten_flag=true;
            movePlayer(i,LEFT,(byte)0);
            karten = (byte)(karten | 1);
            return;
        }
        if (k==MAP_2) {
            karten_flag=true;
            movePlayer(i,LEFT,(byte)0);
            karten = (byte)(karten | 2);
            return;
        }
        if (k==MAP_3) {
            karten_flag=true;
            movePlayer(i,LEFT,(byte)0);
            karten = (byte)(karten | 4);
            return;
        }
        if (k==MAP_4) {
            karten_flag=true;
            movePlayer(i,LEFT,(byte)0);
            karten = (byte)(karten | 8);
            return;
        }
        // Fish fall : Check, if you can move the fish to the left
        if (k==FISH || k==BOMB) {
            if ((playerY(i)-2) >=0) {
            byte l = spielfeld[playerX(i)][playerY(i)-2];
            if (l==V_WAVE || l==SPACE) {
                movePlayer(i,LEFT,(byte)k);
                spielfeld[playerX(i)][playerY(i)-1]=(byte)k;
                if ((playerY(i)-1)>0) {
                fishFall(k,playerX(i),(byte)(playerY(i)-1));
                show((byte)-1);
                }
            }
            }
            return;
        }

        if (k==PUPPET) {
            if ((playerY(i)-2)>0) {
            int l = spielfeld[playerX(i)][playerY(i)-2];
            if (l==V_WAVE || l==SPACE) {
                dollsThrow(playerX(i),playerY(i)-1,LEFT);
                movePlayer(i,LEFT,(byte)0);
            }
            }
            return;
        }

        if (k==SPACE || k==V_WAVE) {
            movePlayer(i,LEFT,(byte)0);
            return;
        }

        if (k==TRANSPORTER) {
            beamMeUp();
            return;
        }
    }

    // Move the player to the left, right, top, bottom
    // and change the co-ordinates of the player
    void movePlayer(byte i,byte dir,byte b) {
        byte l;
        if (dir==RIGHT) {
            // moving player
            spielfeld[playerX(i)][playerY(i)]=SPACE;
            spielfeld[playerX(i)][(byte)(playerY(i)+1)]=(byte)(PLAYER_1+i);
            incPlayerY(i);
            showPlayer(player(),playerX(i),playerY(i),b);
            // released a fish ?
            l=spielfeld[playerX(i)-1][playerY(i)-1];
            if (l==FISH || l==BOMB){
            fishFall(l,(byte)(playerX(i)-1),(byte)(playerY(i)-1));
            }
            replay[anzahl]=RIGHT;
            anzahl++;
        } else if (dir==UP) {
            spielfeld[playerX(i)][playerY(i)]=SPACE;
            spielfeld[(byte)(playerX(i)-1)][playerY(i)]=(byte)(PLAYER_1+i);
            if (b>0)
            spielfeld[playerX(i)-2][playerY(i)]=b;
            decPlayerX(i);
            showPlayer(player(),playerX(i),playerY(i),b);

            // check, if you have released a chicken
            l=spielfeld[playerX(i)+1][playerY(i)+1];
            if (l==CHICKEN || l==ACID){
                chickenRun(l,(byte)(playerX(i)+1),(byte)(playerY(i)+1),(byte)0);
            }
            replay[anzahl]=UP;
            anzahl++;
        } else if (dir==LEFT) {
            spielfeld[playerX(i)][playerY(i)]=SPACE;
            spielfeld[playerX(i)][playerY(i)-1]=(byte)(PLAYER_1+i);
            decPlayerY(i);
            showPlayer(player(),playerX(i),playerY(i),b);
            // check, if you have released a fish
            l=spielfeld[playerX(i)-1][playerY(i)+1];
            if (l==BOMB || l==FISH){
                fishFall(l,(byte)(playerX(i)-1),(byte)(playerY(i)+1));
            }
            // Whoops! killed a player !
            if (playerY(i)+2<32) {
                l=spielfeld[playerX(i)][playerY(i)+2];
                if (l==CHICKEN || l==ACID) {
                    chickenRun(l,playerX(i),(byte)(playerY(i)+2),(byte)0);
                }
            }
            replay[anzahl]=LEFT;
            anzahl++;
        } else if (dir==DOWN) {
            spielfeld[playerX(i)][playerY(i)]=SPACE;
            spielfeld[(byte)(playerX(i)+1)][playerY(i)]=(byte)(PLAYER_1+i);
            incPlayerX(i);
            showPlayer(player(),playerX(i),playerY(i),b);
            // released CHICKEN or ACID ?
            l=spielfeld[playerX(i)-1][playerY(i)+1];
            if (l==CHICKEN || l==ACID){
            chickenRun(l,(byte)(playerX(i)-1),(byte)(playerY(i)+1),(byte)0);
            }
            // Whoops! killed a player !
            if (playerX(i)-2>=0) {
            l=spielfeld[playerX(i)-2][playerY(i)];
            if (l==FISH || l==BOMB) {
                fishFall(l,(byte)(playerX(i)-2),playerY(i));
            }
            }
            replay[anzahl]=DOWN;
            anzahl++;
        }
    }

    void chickenRun(byte k,byte x,byte y,byte saeure_wurde_bewegt) { //k=CHICKEN or ACID, x,y: co-ordinates,
        byte l,n, j=1, quit=0, last_chicken=1;
        // is chicken the leftmost / rightmost ?
        // last_chicken=1: YES, it is the last!
        if (y+1<32) {
            n=spielfeld[x][y+1];
            if (n==CHICKEN || n==ACID) {
            last_chicken=0;
            }
        }
        while (quit!=-1) {
            l = spielfeld[x][y-j];
            if (l==SPACE || l==V_WAVE || l==BOMB || l==ACID || ((l==PLAYER_1 || l==PLAYER_2) && j>1)) {
            // have we killed a player?
            if (((l==PLAYER_1) || (l==PLAYER_2))) {
                if (ende_erreicht==98 && death==true) {
                ende_erreicht=99;
                } else {
                ende_erreicht=98;
                if ((l==PLAYER_1 && player()==1) || (l==PLAYER_2 && player()==0)) {
                    changePlayer();
                }
                }
            }

            // the direct neighbour is a Bomb/Acid: Do nothing
            if ((l==BOMB || l==ACID) && j==1) {
                quit=-1;
            } else {
                // No bomb and no acid: move player to the left
                if (l!=BOMB && l!=ACID) {
                spielfeld[x][y-j]=k;
                spielfeld[x][y-j+1]=SPACE;
                } else {
                // bomb or acid : remove it
                spielfeld[x][y-j+1]=SPACE;
                }
                // Hit a bomb ?
                if (l==BOMB && j>1) {
                show((byte)0);
                bombExplode(x,(byte)(y-j));
                quit=-1;
                }
                //Hit an acid ?
                if (l==ACID && j>1) {
                spielfeld[x][y-j]=SPACE;
                acidCorrosive(x,(byte)(y-j));
                quit=-1;
                }

                // has the moving chicken / acid released a fish/bomb ? look at the field above the empty field...
                // and is the chicken the last in the chicken queue ?
                // Important! Otherwise a fish will slip between it....
                if (x-1>=0) {
                if (last_chicken==1) {
                    byte m=spielfeld[x-1][y-j+1];
                    if (m==BOMB || m==FISH) {
                    fishFall(m,(byte)(x-1),(byte)(y-j+1));
                    }
                }
                }
                show((byte)0);
                Paint();
            }
            j++;
            } else {
            quit=-1;
            }
        }
        l=spielfeld[x][y+1];
        if (l==CHICKEN || l==ACID) {
            chickenRun(l,x,(byte)(y+1),(byte)0);
        }
    }

    void fishFall(byte k,byte x,byte y) {
        byte l,n, j=1, quit=0, last_fish=1;
        // check, if fish is the last/rightmost in the queue !
        // last_fish=1: yes, it is the last one!
        if (x>0) {
            n=spielfeld[x-1][y];
            if (n==FISH || n==BOMB) {
            last_fish=0;
            }
        }
        while (quit!=-1) {
            l = spielfeld[x+j][y];
            if (l==SPACE || l==H_WAVE || l==BOMB || l==ACID || ((l==PLAYER_1 || l==PLAYER_2) && (j>1))) {
            if ((l==PLAYER_1) || (l==PLAYER_2)) {
                if (ende_erreicht==98 && death==true) {
                ende_erreicht=99;
                } else {
                ende_erreicht=98;
                spielfeld[x+j][y]=SPACE;
                if ((l==PLAYER_1 && player()==1) || (l==PLAYER_2 && player()==0)) {
                    changePlayer();
                }
                }
            }
            if ((l==BOMB || l==ACID) && j==1) {
                quit=-1;
            } else {
                if (l!=BOMB && l!=ACID) {
                spielfeld[x+j][y]=(byte)k;
                spielfeld[x+j-1][y]=SPACE;
                } else {
                spielfeld[x+j-1][y]=SPACE;
                }
            }

            if (l==BOMB && j>1) {
                show((byte)0);
                bombExplode((byte)(x+j),y);
                quit=-1;
            }
            if (l==ACID && j>1) {
                show((byte)0);
                acidCorrosive((byte)(x+j),(byte)y);
                quit=-1;
            }
            // has the fish released a chicken/acid ? look at the field right beside the empty field...
            if (y+1<=31) {
                if (last_fish==1) {
                byte m=spielfeld[x+j-1][y+1];
                if (m==CHICKEN || m==ACID) {
                    chickenRun(m,(byte)(x+j-1),(byte)(y+1),(byte)0);
                }
                }
            }
            j++;
            show((byte)0);
            Paint();
            } else {
            quit=-1;
            }
        }
        l = spielfeld[x-1][y];
        if (l==FISH || l==BOMB) {
            fishFall(l,(byte)(x-1),y);
        }
    }

    void dollsThrow(int x,int y,int direction) {
        int l, j=1;
        if (direction==RIGHT) {
            while (j!=-1) {
            l = spielfeld[x][y+j];
            if (l==SPACE) { // || l==V_WAVE) {
                spielfeld[x][y+j]=PUPPET;
                spielfeld[x][y+j-1]=SPACE;
                // released a fish ?
                if ((x-1>0) && (j>1)){
                byte m=spielfeld[x-1][y+j-1];
                if (m==FISH || m==BOMB) {
                    fishFall(m,(byte)(x-1),(byte)(y+j-1));
                }
                }
                j++;
                show((byte)0);
                Paint();
            } else {
                j=-1;
            }
            }
            return;
        }
        if (direction==LEFT) {
            while (j!=-1) {
            l = spielfeld[x][y-j];
            if (l==SPACE) { // || l==V_WAVE) {
                spielfeld[x][y-j]=PUPPET;
                spielfeld[x][y-j+1]=SPACE;
                // released a fish?
                if ((x-1>0) && (j>1)) {
                byte m=spielfeld[x-1][y-j+1];
                if (m==BOMB || m==FISH) {
                    fishFall(m,(byte)(x-1),(byte)(y-j+1));
                }
                }
                j++;
                show((byte)0);
                Paint();
            } else {
                j=-1;
            }
            }
            return;
        }

        if (direction==UP) {
            while (j!=-1) {
            l = spielfeld[x-j][y];
            if (l==SPACE){// || l==H_WAVE) {
                spielfeld[x-j][y]=PUPPET;
                spielfeld[x-j+1][y]=SPACE;
                // released a chicken?
                if ((y+1<=31) && (j>1)){
                byte m=spielfeld[x-j+1][y+1];
                if (m==ACID || m==CHICKEN) {
                    chickenRun(m,(byte)(x-j+1),(byte)(y+1),(byte)0);
                    }
                }
                j++;
                show((byte)0);
                Paint();
            } else {
                j=-1;
            }
            }
            return;
        }

        if (direction==DOWN) {
            while (j!=-1) {
            l = spielfeld[x+j][y];
            if (l==SPACE) { // || l==H_WAVE) {
                spielfeld[x+j][y]=PUPPET;
                spielfeld[x+j-1][y]=SPACE;
                // released a chicken?
                if ((y+1<=31) && (j>1)) {
                byte m=spielfeld[x+j-1][y+1];
                if (m==CHICKEN || m==ACID) {
                    chickenRun(m,(byte)(x+j-1),(byte)(y+1),(byte)0);
                }
                }
                j++;
                show((byte)0);
                Paint();
            } else {
                j=-1;
            }
            }
            return;
        }
    }

    void acidCorrosive(byte x, byte y) {
        flash();
        byte i;
        int mitte=-1, oben=-1, unten=-1, mitte_y=-1;
        mitte_y = coordY(y)*40;
        if (mitte_y>=0) {
            mitte = coordX(x)*40;
            oben = coordX((byte)(x-1))*40;
            unten = coordX((byte)(x+1))*40;

        }
        if (spielfeld[x-1][y]==PLAYER_1 || spielfeld[x-1][y]==PLAYER_2 ||
            spielfeld[x+1][y]==PLAYER_1 || spielfeld[x+1][y]==PLAYER_2) {
            if (ende_erreicht==98 && death==true) {
                ende_erreicht=99;
            } else {
                ende_erreicht=98;
            }
            }

        if (spielfeld[x-1][y]==BAD_MASK) {
            badMask();
        }

        if (spielfeld[x+1][y]==BAD_MASK) {
            badMask();
        }

        if (mitte_y>=0) {
            for (i=0;i<8;i++) {
            if (mitte>=0) {
                spielfeld[x][y]=SPACE;
                graph_offline.drawImage(acid[i][0],mitte_y,mitte,frame);
                Paint();
            }
            if (oben>=0) {
                spielfeld[x-1][y]=SPACE;
                graph_offline.drawImage(acid[i][1],mitte_y,oben,frame);
                Paint();
            }
            if (unten>=0) {
                spielfeld[x+1][y]=SPACE;
                graph_offline.drawImage(acid[i][2],mitte_y,unten,frame);
                Paint();
            }
            }
        }
        spielfeld[x][y]=SPACE;
        if (x-1>=0) {
            spielfeld[x-1][y]=SPACE;
            if (x-2>=0) {
            // above the acid a fish / bomb ?
            byte m=spielfeld[x-2][y];
            if (m==FISH || m==BOMB) {
                fishFall(m,(byte)(x-2),y);
            }
            // diagonal to the acid a chicken / acid ?
            if (y+1<=31) {
                m=spielfeld[x-1][y+1];
                if (m==CHICKEN || m==ACID) {
                chickenRun(m,(byte)(x-1),(byte)(y+1),(byte)0);
                }
                m=spielfeld[x][y+1];
                if (m==CHICKEN || m==ACID) {
                chickenRun(m,x,(byte)(y+1),(byte)0);
                }
            }
            }
        }
        // look at the field under the acid
        if (x+1<=31) {
            spielfeld[x+1][y]=SPACE;
            // Diagonal under the acid a chicken / acid ?
            if (y+1<=31) {
            byte m=spielfeld[x+1][y+1];
            if (m==CHICKEN || m==ACID) {
                chickenRun(m,(byte)(x+1),(byte)(y+1),(byte)0);
            }
            }
        }
    }

    void bombExplode(byte x,byte y) {
        flash();
        //Sound bomb("/home/mario/xor/sounds/bomb.wav");
        //bomb.play();
        byte i;
        int mitte=-1, rechts=-1, links=-1, mitte_x=-1;
        mitte_x = coordX(x)*40;
        if (mitte_x>=0) {
            mitte = coordY(y)*40;
            links = coordY((byte)(y-1))*40;
            rechts = coordY((byte)(y+1))*40;
        }
        if (spielfeld[x][y-1]==PLAYER_1 || spielfeld[x][y-1]==PLAYER_2 || spielfeld[x][y+1]==PLAYER_1 || spielfeld[x][y+1]==PLAYER_2) {
            if (ende_erreicht==98 && death==true) {
            ende_erreicht=99;
            } else {
            ende_erreicht=98;
            }
        }
        if (spielfeld[x][y-1]==BAD_MASK) {
            badMask();
        }

        if (spielfeld[x][y+1]==BAD_MASK) {
            badMask();
        }


        if (mitte_x>=0) {
            for (i=0;i<8;i++) {
            if (mitte>=0) {
                spielfeld[x][y]=SPACE;
                //while (
                graph_offline.drawImage(bomben[i][0],mitte,mitte_x,frame)//==false)
                ;
                Paint();
            }
            if (links>=0) {
                spielfeld[x][y-1]=SPACE;
                //while (
                graph_offline.drawImage(bomben[i][1],links,mitte_x,frame)//==false)
                ;
                Paint();
            }
            if (rechts>=0) {
                spielfeld[x][y+1]=SPACE;
                //while (
                graph_offline.drawImage(bomben[i][2],rechts,mitte_x,frame)//==false)
                ;
                Paint();
            }
            }
        }
        // the bomb explodes... clear the area
        spielfeld[x][y]=SPACE;
        // left to the bomb
        if (y-1>=0) {
            spielfeld[x][y-1]=SPACE;
            // above the free area all free ?
            if (x-1>=0) {
            byte m=spielfeld[x-1][y-1];
            if (m==FISH || m==BOMB) {
                fishFall(m,(byte)(x-1),(byte)(y-1));
            }
            m=spielfeld[x-1][y];
            if (m==FISH || m==BOMB) {
                fishFall(m,(byte)(x-1),y);
            }
            }
        }
        // right beside the bomb
        if (y+1<32) {
            spielfeld[x][y+1]=SPACE;

            // Over the free field something free ?
            if (x-1>=0) {
            byte m=spielfeld[x-1][y+1];
            if (m==FISH || m==BOMB) {
                fishFall(m,(byte)(x-1),(byte)(y+1));
            }
            }
            // released a chicken / acid right beside the now free field ?
            if (y+2>=0) {
            byte m=spielfeld[x][y+2];
            if (m==CHICKEN || m==ACID) {
                chickenRun(m,x,(byte)(y+2),(byte)0);
            }
            }
        }

    }

    void map() {
        if (map_flag==false) {
            showMap();
            map_flag=true;
        } else {
            map_flag=false;
        }
    }

    // Check at the beginning, if a chicken/acid/fish/bomb can fall / move
    public void initPlayground() {
        byte i,j,k;
        for (i=0;i<groesse;i++) {
            for (j=0;j<groesse;j++) {
            k=spielfeld[i][j];
            if (k==CHICKEN || k==ACID) {
                chickenRun(k,i,j,(byte)0);
            }
            if (k==FISH || k==BOMB) {
                fishFall(k,i,j);
            }
            }
        }
    }

    // show playground with player i inside
    public void showPlayer(byte spieler,byte b) {
        if (map_flag==true)
            return;
        // test player "out of range" and move the visible playground area!!
        if (x()==playerX(spieler)) {
            //animation(surface);
            x((byte)(x()-1));
        }
        if (y()==playerY(spieler)) {
            //animation(surface);
            y((byte)(y()-1));
        }
        if (x()+7==playerX(spieler)) {
            //animation(surface);
            x((byte)(x()+1));
        }
        if (y()+7==playerY(spieler)) {
            //animation(surface);
            y((byte)(y()+1));
        }
        show(b);
    }

    // Some flash action
    void flash() {
        return;
        //graph->play_buffer->sp->fill(Qt::white);
        //Paint();
        /*
          show((byte)0);
          showStatus(-1);
          Paint();*/
    }

    // show playground with player i inside
    void showPlayer(int spieler, int spieler_x, int spieler_y,int b) {
        if (map_flag==true)
            return;
        // test, if player is out of range and move the visible playground area!
        if (x()==spieler_x) {
            x((byte)(x()-1));
        }
        if (y()==spieler_y) {
            y((byte)(y()-1));
        }
        if (x()+7==spieler_x) {
            x((byte)(x()+1));
        }
        if (y()+7==spieler_y) {
            y((byte)(y()+1));
        }
        show((byte)b);
    }

    // show the playground
    void show(byte b) {
        int x_offset=x();
        int y_offset=y();
        // show an 8x8-part of the playground;
        // upper left is 0,0
        // bottom right is 24x24 (+8 results in 32x32)
        if (x_wert_old==-1 && y_wert_old==-1) {
            x_wert_old=(playerX(player())-x())*40;
            y_wert_old=(playerY(player())-y())*40;
        } else {
            x_wert_old=x_wert;
            y_wert_old=y_wert;
        }
        x_wert=(playerX(player())-x())*40;
        y_wert=(playerY(player())-y())*40;
        if (x_offset+8>groesse)
            x_offset=groesse-8;
        if (y_offset+8>groesse)
            y_offset=groesse-8;
        if (x_offset<0)
            x_offset=0;
        if (y_offset<0)
            y_offset=0;
        byte k;
        animation(b);
        for (int i=0;i<8;i++) {
            for (int j=0;j<8;j++) {
            k = spielfeld[i+x_offset][j+y_offset];
            //System.out.print("["+i+x_offset+"]["+j+y_offset+"]:"+k+"|");
            //while (
            graph_offline.drawImage(sprites[k],j*40,i*40,frame)//==false)
                ;
            }
            //System.out.println();
        }
        //System.out.println();
        Paint();
    }

    // update the left status display
    // -1 : draw red rectangle, player symbol, mask counter, map counter and draw all
    //  0 : draw player symbol
    //  1 : draw mask counter
    //  2 : draw map counter
    public void showStatus(int wert) {

        if (wert==-1) {
            //while (
            graph_offline.drawImage(sprites[23],320,0,frame)//==false)
            ;
        }
        if (wert==0 || wert==-1) { // Spieler 1 oder 2 : k=15,16
            int k=15;
            if (akt_spieler==1) {
            k=16;
            }
            // player has been changed, show status icons
            //while (
            graph_offline.drawImage(sprites[k],STATUS_X,130,frame)//==false)
            ;
            graph_offline.setColor(Color.red);
            graph_offline.fillRect(STATUS_X,180,80,30);
            String schritte=String.valueOf(anzahl);
            graph_offline.setColor(Color.black);
            graph_offline.drawString(schritte,STATUS_X+10,200);
        }
        if (wert==1 || wert==-1) { // masks counter
            //while (
            graph_offline.drawImage(sprites[7],STATUS_X,220,frame)//==false)
            ;
            graph_offline.setColor(Color.red);
            graph_offline.fillRect(STATUS_X,270,80,24);
            String masks=String.valueOf(gesammelte_masken);
            String masken=String.valueOf(anzahl_masken);
            masks=masks+"/"+masken;
            graph_offline.setColor(Color.black);
            graph_offline.drawString(masks,STATUS_X+10,290);

        }
        if (wert==2 || wert==-1) { // map counter
            graph_offline.setColor(Color.red);
            //while (
            graph_offline.drawImage(sprites[3],STATUS_X,50,frame)//==false)
            ;
            if ((karten & 1) == 0) {
            graph_offline.fillRect(STATUS_X,50,20,20);
            }
            if ((karten & 2) == 0) {
            graph_offline.fillRect(STATUS_X+20,50,20,20);
            }
            if ((karten & 4) == 0) {
            graph_offline.fillRect(STATUS_X,70,20,20);
            }
            if ((karten & 8) == 0) {
            graph_offline.fillRect(STATUS_X+20,70,20,20);
            }
        }
        if (wert==-1) {
            Paint();
        }
    }

    public void setLevel(String i) {
        //if (i.indexOf(directory,0)==-1) {
	  	//  level=directory+"/"+i;
		//} else {
		    level = i;
		//}
        //System.out.println("setLevel:"+level);
    }

    public void saveMoves(String name) {
        RandomAccessFile file_out=null;
        try {
            file_out = new RandomAccessFile(name,"rw");
        } catch (IOException e) {
            System.err.println(e);
            return;
        }

        try {
            file_out.writeByte((byte)'#');
        } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
        }

        try {
            for (int l=0;l<level.length();l++) {
            file_out.writeByte((byte) level.charAt(l));
            }
        } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
        }

        try {
            file_out.writeByte((byte)'#');
            file_out.writeByte(10);
        } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
        }

        int i=0;
        while (i<=MAX_STEP && replay[i]!=-1) {
            try {
            file_out.writeByte(replay[i]+48);
            file_out.writeByte(10);
            } catch (IOException e) {
            System.err.println(e);
            System.exit(0);
            }

            i++;
        }
        try {
            file_out.close();
        } catch (IOException e) {}
    }

    void beamMeUp() {
        int i=0,q=0;
        while (beam_from[i][0]!=-1 && beam_from[i][1]!=-1 && q==0) {
            if ((beam_from[i][0]==playerX(player())) && (beam_from[i][1]==playerY(player()))) {
            if ( spielfeld[beam_to[i][0]][beam_to[i][1]]==SPACE)  {
                spielfeld[beam_to[i][0]][beam_to[i][1]]=(byte)(PLAYER_1+player());
                spielfeld[beam_from[i][0]][beam_from[i][1]]=SPACE;
                playerX(player(),beam_to[i][0]);
                playerY(player(),beam_to[i][1]);
                x((byte)(playerX(player())-4));
                y((byte)(playerY(player())-4));
                showPlayer((byte)(player()),(byte)(-1));
                //showPlayer(player(),0);
                Paint();
                q=-1;
            } else {
                //   q=-1;
            }
            }
            i++;
        }
    }

    void loader() { // load a playground
        spieler[0][0]=0;
        spieler[0][1]=0;
        spieler[1][0]=0;
        spieler[1][1]=0;
        anzahl_masken=0;
        gesammelte_masken=0;
        nothing_loaded=0;
            //getLevelname();
        loadAll();
        }

        void loadImages() {
        // Load all Images....
        for (byte i=0;i<25;i++) {
            sprites[i] = Toolkit.getDefaultToolkit().getImage(names[i]);
            mtracker.addImage(sprites[i],0);
        }
        String name,name_l,name_r,temp;
        byte i;
        temp = names[12].substring(0,names[12].indexOf('.',0));
        for (i=0;i<8;i++) {

            name = temp + "_"+String.valueOf(i+1)+".gif";
            name_l = temp + "_"+String.valueOf(i+1)+"_left.gif";
            name_r = temp + "_"+String.valueOf(i+1)+"_right.gif";
            bomben[i][0] = Toolkit.getDefaultToolkit().getImage(name);
            mtracker.addImage(bomben[i][0],0);
            bomben[i][1] = Toolkit.getDefaultToolkit().getImage(name_l);
            mtracker.addImage(bomben[i][1],0);
            bomben[i][2] = Toolkit.getDefaultToolkit().getImage(name_r);
            mtracker.addImage(bomben[i][2],0);
        }
        temp = names[13].substring(0,names[13].indexOf('.',0));
        for (i=0;i<8;i++) {
            name = temp+"_"+String.valueOf(i+1)+".gif";
            name_l = temp+"_"+String.valueOf(i+1)+"_up.gif";
            name_r = temp+"_"+String.valueOf(i+1)+"_down.gif";
            acid[i][0] = Toolkit.getDefaultToolkit().getImage(name);
            mtracker.addImage(acid[i][0],0);
            acid[i][1] = Toolkit.getDefaultToolkit().getImage(name_l);
            mtracker.addImage(acid[i][1],0);
            acid[i][2] = Toolkit.getDefaultToolkit().getImage(name_r);
            mtracker.addImage(acid[i][2],0);
        }
        try {
            mtracker.checkAll(true);
            mtracker.waitForID(0);
        } catch (InterruptedException e) {
            System.out.println("Error while loading pictures...");
            System.exit(0);
        }


    }

    void animation(int b) {
        if (b==-1) {
            return;
        }
        int i,k=0;
        if (x_wert<x_wert_old) {
            for (i=x_wert_old;i!=x_wert;i=i-2) {
            // move player smoothly from old to new position
            graph_offline.drawImage(sprites[15+player()],y_wert_old,i,frame);
            if (b!=0) {
                graph_offline.drawImage(sprites[b],y_wert_old,i-40,frame);
            }
            // Show it
            Paint();
            // delete old position
            graph_offline.drawImage(sprites[0],y_wert_old,i,frame);
            }
            return;
        }
        if (x_wert>x_wert_old) {
            for (i=x_wert_old;i!=x_wert;i=i+2) {
            graph_offline.drawImage(sprites[15+player()],y_wert_old,i,frame);
            if (b!=0) {
                graph_offline.drawImage(  sprites[b],y_wert_old,i+40,frame);
            }
            Paint();
            graph_offline.drawImage( sprites[0],y_wert_old,i,frame);
            if (b!=0) {
                graph_offline.drawImage( sprites[b],y_wert_old,i+40,frame);
            }
            }
            return;
        }
        if (y_wert<y_wert_old) {
            for (i=y_wert_old;i!=y_wert;i=i-2) {
            graph_offline.drawImage( sprites[15+player()],i,x_wert_old,frame);
            if (b!=0) {
                graph_offline.drawImage( sprites[b],i-40,x_wert_old,frame);
            }
            Paint();
            graph_offline.drawImage( sprites[0],i,x_wert_old,frame);
            if (b!=0) {
                graph_offline.drawImage(  sprites[0],i-40,x_wert_old,frame);
            }
            }
            return;
        }
        if (y_wert>y_wert_old) {
            for (i=y_wert_old;i!=y_wert;i=i+2) {
            graph_offline.drawImage( sprites[15+player()],i,x_wert_old,frame);
            if (b!=0) {
                graph_offline.drawImage(  sprites[b],i+40,x_wert_old,frame);
                }
            Paint();
            graph_offline.drawImage( sprites[0],i,x_wert_old,frame);
            if (b!=0) {
                graph_offline.drawImage(  sprites[0],i+40,x_wert_old,frame);
            }
            }
            return;
        }
    }

    // draw the map
    void showMap() {
        int sp=0;
        for (int i=0;i<32;i++) {
            for (int j=0;j<32;j++) {
            sp=spielfeld[i][j];
            if (i<16 && j<16 && ((karten & 1) == 0))
                sp=22;
            if (i<16 && j>=16 && ((karten & 2) == 0))
                sp=22;
            if (i>=16 && j<16 && ((karten & 4) == 0))
                sp=22;
            if (i>=16 && j>=16 && ((karten & 8) == 0))
                sp=22;
            //while (
            graph_offline.drawImage(sprites[sp],j*10,i*10,10,10,frame)//==false)
                ;
            }
        }
    }

    // stdout playground
    public void zeigen() {
        for (int i=0;i<32;i++) {
            for (int j=0;j<32;j++) {
            System.out.print(spielfeld[i][j]+",");
            }
            System.out.println();

        }
    }
}
