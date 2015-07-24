import xor.*;
import java.awt.*;
import java.io.*;
import java.awt.event.*;
import java.awt.image.*;
import java.awt.Toolkit.*;

class FileFilter implements FilenameFilter {
    public boolean accept(File f, String s) {
	if (s.endsWith(".xor"))
	    return true;
	else if (s.endsWith(".XOR"))
	    return true;
	else
	    return false;
    }
}

public class Xorwindow extends Frame implements ActionListener {
    public void actionPerformed( ActionEvent e ) {
	if (e.getActionCommand().equals("Exit"))  {
	    System.exit(0);
	}

	if (e.getActionCommand().equals("Start"))  {
	    replay_mode=true;
	    system_status=5;
	    repaint();
	}

	if (e.getActionCommand().equals("Load"))  {
	    FileDialog d = new FileDialog(this, "Open moves file",FileDialog.LOAD);
	    d.setDirectory(directory+"/moves");
	    d.setFile("*.moves");
	    d.show();
	    String f=d.getDirectory();
	    String g=d.getFile();
	    //System.out.println(f);
	    //System.out.println(g);
	    if (f!=null && g!=null) {
	       	xor_play.loadMoves(new String(f+g));
		setTitle("REPLAY MODE (Press 'Esc' to quit):"+xor_play.level_name);
		//System.out.println("Titel gesetzt");
		replay_mode=true;
		system_status=5;
		repaint();
	    }

	}

	if (e.getActionCommand().equals("Save"))  {
	    FileDialog d = new FileDialog(this, "Save moves file",FileDialog.SAVE);
	    d.setDirectory(directory+"/moves");
	    d.setFile("*.moves");
	    d.show();
	    String f=d.getDirectory();
	    String g=d.getFile();
	    if (f!=null && g!=null) {
		xor_play.saveMoves(new String(f+g));
	    }
	}

	if (e.getActionCommand().equals("Run/Restart"))  {
	    system_status=3;
	    repaint();
	}

	for (int h=0;h<dateiliste.length;h++) {
	    if (e.getActionCommand().equals(dateiliste[h])) {
		leveldatei="level/"+dateiliste[h];
		xor_play.setDirectory(directory);
		xor_play.setLevel(leveldatei);
		system_status=3;
		repaint();
	    }
	}

    }

public boolean getReplay() {
	return replay_mode;
    }

    public Xorwindow() {
	replay_mode=false;
	bool_replay=false;
	byte i;
	Menu menu;
      	MenuItem menuitem[];
	setTitle("Welcome to Xor !");
	MenuBar mbar = new MenuBar();
	leveldatei="level/level01.xor";
	directory=System.getProperty("user.dir");
	if (directory==null)
	    return;
	File dateien = new File(directory+"/level");

	dateiliste = dateien.list(new FileFilter());

	// Game entry ----------------------------------------------------------------------------
	menu = new Menu("Game");
	menuitem  = new MenuItem[]{new MenuItem("Run/Restart", new MenuShortcut((int)'R')),
					   new MenuItem("Exit",new MenuShortcut((int) 'X'))};

	for (i=0;i<menuitem.length;i++) {
	    menuitem[i].addActionListener(this);
	    menu.add(menuitem[i]);
	}
	mbar.add(menu);

	// Level entry ----------------------------------------------------------------------------
	menu = new Menu("Level");

	menuitem = new MenuItem[dateiliste.length];
	for (int h=0;h<dateiliste.length;h++)
	    menuitem[h]= new MenuItem(dateiliste[h],null);
	for (i=0;i<menuitem.length;i++) {
	    menuitem[i].addActionListener(this);
	    menu.add(menuitem[i]);
	}
	mbar.add(menu);

	// Help entry ----------------------------------------------------------------------------

	//menu = new Menu("Help");
	//menuitem = new MenuItem[]{new MenuItem("Content", null),
	//		          new MenuItem("About Xor", null)};

	for (i=0;i<menuitem.length;i++) {
	    menuitem[i].addActionListener(this);
	    menu.add(menuitem[i]);
	}
	mbar.add(menu);

	// Replay entry ----------------------------------------------------------------------------

	menu = new Menu("Replay");
	menuitem = new MenuItem[]{new MenuItem("Start",new MenuShortcut((int) 'R')),
				  new MenuItem("Load", new MenuShortcut((int) 'L')),
				  new MenuItem("Save", new MenuShortcut((int) 'S')),
	};

	for (i=0;i<menuitem.length;i++) {
	    menuitem[i].addActionListener(this);
	    menu.add(menuitem[i]);
	}
	menu.addActionListener(this);
	mbar.add(menu);

        setMenuBar(mbar);
	frame = this;

	// Listeners
	addWindowListener(new WindowAdapter() {
		public void windowClosing ( WindowEvent e) {
		    System.exit(0);
		}
	    });

	addKeyListener(new KeyAdapter() {
		public void keyPressed( KeyEvent e) {
		    key_pressed=e.getKeyCode();
		    //System.out.println(key_pressed);
		    if (replay_mode==true) {
			if (key_pressed==27)
			    endReplay();
			if (system_status==0) {
			    system_status=6;
			}
		    } else {
			system_status=2;
		    }
		    repaint();
		}
	    });

	xor_play = new Playground(leveldatei,directory,this, null);
	setSize(465,375);
    	show();
	xor_play.play_buffer = createImage(465,400);
        xor_play.graph_offline = xor_play.play_buffer.getGraphics();
	xor_play.init();
	system_status=1;
	repaint();
    }

    void init() {
	key_pressed=-1;
	xor_play.init();
	xor_play.levelLoaded((byte) 0);
	xor_play.showStatus(-1);
	xor_play.x((byte) (xor_play.playerX((byte) 0)-4));
	xor_play.y((byte) (xor_play.playerY((byte) 0)-4));
	xor_play.showPlayer((byte) 0,(byte) 0);
	xor_play.initPlayground();
	//System.out.println("X,Y:"+xor_play.playerX((byte) 0)+" "+xor_play.playerY((byte) 0));
    }

    public void update( Graphics g ) {
	paint(g);
    }

    public void paint( Graphics g ) {
	xor_play.graph_online=g;
	if (system_status==0) { // Alles anzeigen
	    if (xor_play.play_buffer!=null)
		g.drawImage(xor_play.play_buffer,5,50,null);
	} else if (system_status==1) { // 1 =  Start: lade Level x
	    if (xor_play.levelLoaded()==1) {
		 system_status=3; // 3 = init aufrufen und titel setzen
	    } else {
		xor_play.levelLoaded((byte) 1);
		xor_play.greetingScreen();
		system_status=0; // 0 = Alles anzeigen !
	    }
	} else if (system_status==2) { // 2 = Key gedrueckt
	    xor_play.keyPressing(key_pressed);
	    system_status=0;    // 4 = Alles Anzeigen !
	} else if (system_status==3) {
	    system_status=0;
	    init();
	    setTitle("Xor: "+xor_play.level_name);
	} else if (system_status==5) { // 5 = Start Replay
	    system_status=0;
	    doReplay();
	} else if (system_status==6) {
	    system_status=0;
	    if (xor_play.replayNext()==false) {
	    	endReplay();
	    }
	    if ( xor_play.play_buffer != null ) {
		g.drawImage(xor_play.play_buffer, 5, 50,null);
	    }
	}
    }

    public void doReplay() {
	setTitle("REPLAY MODE (Press 'Esc' to quit):"+xor_play.level_name);// REPLAY MODE (Press 'Esc' to quit)");
	xor_play.next_step=0;
	xor_play.doReplay();
	xor_play.levelLoaded((byte) 0);
	xor_play.showStatus(-1);
	xor_play.x((byte) (xor_play.playerX((byte) 0)-4));
	xor_play.y((byte) (xor_play.playerY((byte) 0)-4));
	xor_play.showPlayer((byte) 0,(byte) 0);
	xor_play.initPlayground();
	if (xor_play.countMoves()==0)
	    return;
	replay_mode=true;
      	repaint();
    }

    public void endReplay() {
	bool_replay=false;
	replay_mode=false;
	setTitle("Xor: "+xor_play.level_name);
	if (xor_play.next_step!=-1) {
	    for (int i=xor_play.next_step;i<xor_play.MAX_STEP+1;i++)
		xor_play.replay[i]=-1;
	}
    }

	    public static void main(String args[]) {
		//	System.out.println(System.getProperty("user.dir"));
		new Xorwindow().show();
    }

    boolean bool_replay;
    int system_status,key_pressed;
    public Graphics graph;
    String[] dateiliste;
    String leveldatei;
    String directory;
    private Frame frame;
    public  boolean replay_mode;
    private Playground xor_play;

}
