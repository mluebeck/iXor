#include <iostream.h>
#include <fstream.h>
#include <stdio.h>
#include <string>
#include "playground.h"
#include "sound.h"

string toNum(int b) {
    char buffer[255];
    sprintf(buffer,"%d",b);
    return string(buffer);
} 

void wait(int i) {
    for (int j=0;j<1000*i;j++)
	;
}

playground::playground(string ffile,string p) {
    directory=p;
    setLevel(ffile);
    init();
}

playground::playground(string ffile,string p,Graphics *g) {
    directory=p;
    graph=g;
    setLevel(ffile);
    init();
}

int playground::levelLoaded() {
    return nothing_loaded;
}

void playground::levelLoaded(int e) {
    nothing_loaded=e;
}

int playground::convert(char v) {
    if (v=='F')
	return 1;
    if (v=='X')
	return 8;
    if (v=='C') 
	return 2;
    if (v=='m')
	return 3;
    if (v=='n')
	return 4;
    if (v=='o')
	return 5;
    if (v=='p')
	return 6;
    if (v=='M')
	return 7;
    if (v=='N')
	return 8;
    if (v=='H')
	return 9;
    if (v=='V')
	return 10;
    if (v=='P')
	return 11;
    if (v=='B')
	return 12;
    if (v=='S')
	return 13;
    if (v=='T')
	return 14;
    if (v=='a')
	return 15;
    if (v=='b')
	return 16;
    if (v=='E')
	return 17;
    if (v=='W')
	return 18;
    if (v=='_')
	return 0;
}

void playground::initReplay() {
    for (int i=0;i<MAX_STEP+1;i++) {
	replay[i]=-1;
    }
}

int playground::countMoves() {
    int i=0;
    while (replay[i]!=-1)
	i++;
    return i;
}

void playground::doReplay() {
    //cout << "doReplay" << endl;
    spieler[0][0]=0;
    spieler[0][1]=0;
    spieler[1][0]=0;
    spieler[1][1]=0;
    next_step=0;
    invisible=0;
    karten = 0;
    x_clipper=0;
    akt_spieler=0;
    y_clipper=0;
    ende_erreicht=0;
    groesse=32;
    anzahl=0;
    karten_flag=0;
    map_flag=0;
    masken_gefunden=0;
    death=0;
    x_wert=0;
    y_wert=0;
    x_wert_old=-1;
    y_wert_old=-1;
    anzahl_masken=0;
    gesammelte_masken=0;
    nothing_loaded=0;
    FILE *ffeld;
    //char a[level.length()];
    //for (int i=0;i<level.length();i++)
    //a[i]=level[i];
    //cout << a << endl;
    ffeld=fopen(level.c_str(),"r");
    if (!ffeld) {
	cout << "Level " << level << " konnte nicht geoeffnet werden !\n";
	nothing_loaded=1;
	exit(1);
    }
    char val,v;
    int k;
    if (fscanf(ffeld,"%c",&val)!=EOF) {
	while (val!='#')
	    ;
	// Ab hier ist val=='#'
       	fscanf(ffeld,"%c",&val);
	while (val!='#') 
	    val=(char)getc(ffeld);
	// Hier ist wieder val=="#"
	val=(char)getc(ffeld);
    }
    for (int i=0;i<32;i++) {
	for (int j=0;j<32;j++) {
	    if (fscanf(ffeld,"%d",&k)!= EOF ) {
		if (k<0 || k>31) {
		    fscanf(ffeld,"%c",&v);
		}  
		if (k<32 && k>=0) {		
		    spielfeld[i][j]=k;
		} else { 
		    spielfeld[i][j]=convert(v);
		}
		if (k==PLAYER_1 || v=='a') {
		    if (spieler[0][0]==0 && spieler[0][1]==0) {
			playerX(0,i);
			playerY(0,j);
		    }
		} else {
		    if (k==PLAYER_2 || v=='b') {
			if (spieler[1][0]==0 && spieler[1][1]==0) {
			    playerX(1,i);
			    playerY(1,j);
			}
		    } else {
			if (k==MASK || v=='M') {
			    anzahl_masken++;
			}
		    }
		}
	    } 
	}
    }

    for (int m=0;m<20;m++){
	beam_from[m][0]=-1;
	beam_from[m][1]=-1;
	beam_to[m][0]=-1;
	beam_to[m][1]=-1;
    }
    int xx=0,quit = 0;
    while (quit==0) {
	if (fscanf(ffeld,"%d",&k)!= EOF ) {
	    beam_from[xx][0]=k;
	    //cout << k << endl;
	    if (fscanf(ffeld,"%d",&k)!= EOF ) {
		beam_from[xx][1]=k;
		//cout << k << endl;
	    	if (fscanf(ffeld,"%d",&k)!= EOF ) {
		    beam_to[xx][0]=k;
		    //  cout << k << endl;
		    if (fscanf(ffeld,"%d",&k)!= EOF ) {
			beam_to[xx][1]=k;
			//cout << k << endl;
		    } else { 
			quit=1;
		    }
		} else { 
		    quit=1;
		}
	    } else { 
		quit=1;
	    }
	} else { 
	    quit=1;
	}
	xx++;
    }


    fclose(ffeld);
    x(playerX(0)-4);
    y(playerY(0)-4);
    showPlayer(0,0);
    showStatus(-1);
    Redraw();
    initPlayground();
    next_step=0;
}

void playground::replayNext() {
    if (next_step<MAX_STEP+1 && replay[next_step]!=-1) {
	if (replay[next_step]==UP) {
	    keyPressed(KEY_UP);
	    next_step++;
	} else if (replay[next_step]==DOWN) {
	    keyPressed(KEY_DOWN);
	     next_step++;
	} else if (replay[next_step]==LEFT) {
	    keyPressed(KEY_LEFT);
	     next_step++;
	} else if (replay[next_step]==RIGHT) {
	    keyPressed(KEY_RIGHT);
	     next_step++;
	} else if (replay[next_step]==PLAYER_CHANGED) {
	    keyPressed(KEY_TAB);
	    next_step++;
	}
  } else {
      next_step=-1;
  }
}

void playground::Paint() {
    graph->Paint();
}
 
void playground::keyPressed(int k) {
    
    if (ende_erreicht==1) {
	successScreen();
	return;
    }
    if (ende_erreicht==99) {
	failureScreen();
	return;
    }
    // nothing_loaded=1 : Zeige noch Startscreen an
    if (nothing_loaded==1) {
	return;
    }
    
    if (k==KEY_MAP) {
	map();
	showPlayer(player(),0);
	Redraw();
	return;
    }
    if (map_flag==0) { 
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
	if (k==KEY_TAB && death==0) { // TAB
	    changePlayer();
	    x(playerX(player())-4);
	    y(playerY(player())-4);
	    map_flag=0;
	    showStatus(0);
	    showPlayer(player(),0);
	    Redraw();
	    return;
	}
	if (k==KEY_SPACE) {
	    x(playerX(player())-4);
	    y(playerY(player())-4);
	    showPlayer(player(),-1);
	    Redraw();
	    return;
	}
    }
}

void playground::Redraw() {
    // enthaelt Logik fuer Spielende
    if (nothing_loaded==0) {
	showStatus(0);
	if (masken_gefunden==1) {
	    showStatus(1);
	    masken_gefunden=0;
	}
	
	if (karten_flag==1){
	    showStatus(2);
	    karten_flag=0;
	}
	//Erfolg!
	if (ende_erreicht==1) {
	    successScreen();
	}
	// Ein Spieler gekillt und ein Spieler schon tot : Failure!!
	if (ende_erreicht==98 && death==1) {
	    ende_erreicht=99;
	}
	// Misserfolg!!
	if (ende_erreicht==99) {
	    failureScreen();
	}
	// Ein Spieler gekillt: zeige Whoops! an 
	if (ende_erreicht==98) {
	    ende_erreicht=0;
	    deathScreen();
	    changePlayer();
	    x(playerX(player())-4);
	    y(playerY(player())-4);
	    map_flag=0;
	    death=1;
	    showStatus(0);
	    showPlayer(player(),0);
	    for (int k=0;k<500000000;k++)
		;
	    
	}  
    }
    Paint();
}

void playground::init() {
    invisible=0; // sichtbar!
    next_step=-1;
    karten = 0;
    x_clipper=0;
    akt_spieler=0;
    y_clipper=0;
    ende_erreicht=0;
    groesse=32;
    anzahl=0;
    karten_flag=0;
    map_flag=0;
    masken_gefunden=0;
    death=0;
    x_wert=0;
    y_wert=0;
    x_wert_old=-1;
    y_wert_old=-1;
    initReplay();
    ifstream f;
    string d=directory+"/.files";
    //char a[d.length()];
    //  for (int i=0;i<d.length();i++)
    //	a[i]=d[i];
    f.open(d.c_str(),ios::in);
    if (!f) {
	cout << directory + "/.files konnte nicht geoeffnet werden !\n";
	nothing_loaded=1;
    } else {
	char name[300];
	for (int i=0;i<24;i++) { 
	    f.getline(name,300);
	    names[i]=directory+"/"+name;
	}
	f.close();
	loader();
    }
}

void playground::greetingScreen() {
    if (graph->play_buffer->Load(directory+"/pics/xor.bmp")==FALSE) {
	cout << "Cannot load title screen! " << endl;
	return;
    }   
}

void playground::deathScreen() {
    graph->Rect(100,80,130,30);
    graph->Write(" Whoops ! ",100,100);
    Paint();
}

void playground::failureScreen() {
    graph->Rect(100,80,130,30);
    graph->Write(" You failed ! ",100,100);
    Paint();
}

void playground::successScreen() {
    graph->Rect(100,80,130,30);
    graph->Write(" You succeeded ! ",100,100);
    Paint();

}

unsigned short int playground::player() {
    return akt_spieler;
}

void playground::changePlayer() {

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

int playground::x() { // Rueckgabe x-wert des Ausschnitts
    return x_clipper;
};

int playground::y() { // Rueckgabe y-wert des Ausschnitts
    return y_clipper;
};


void playground::x(int x) { //Gebe x-wert des Ausschnitts ein
    if (x>24) x_clipper=24;
    else
	if (x<0) x_clipper=0;
	else x_clipper=x;
};

void playground::y(int y) { // Gebe y-wert des Ausscnitts ein
    if (y>24) y_clipper=24;
    else
	if (y<0) y_clipper=0;
	else y_clipper=y;
};

// Rechnet die Spielkoordinaten in Bildschirmkoordinaten um
int playground::coordX(int x) {
    int i=x-x_clipper;
    if (i>7 || i<0)
	i=-1;
    return i;
}

// Rechnet die Spielkoordinaten in Bildschirmkoordinaten um
int playground::coordY(int y) {
    int i=y-y_clipper;
     if (i>7 || i<0)
	i=-1;
    return i;
}

void playground::incPlayerX(int i) {
    spieler[i][0]++;
}

void playground::incPlayerY(int i) {
    spieler[i][1]++;
}

void playground::decPlayerX(int i) {
    spieler[i][0]--;
}

void playground::decPlayerY(int i) {
    spieler[i][1]--;
}

int playground::playerX(int i) { // Wo ist Spieler 0,1 x-wert
    return spieler[i][0];
};

int playground::playerY(int i) { // wo ist Spieler 0,1 y-wert
    return spieler[i][1];
};

void playground::playerX(int i,int x) { // Gebe x-wert von Spieler i ein
    spieler[i][0]=x;
}

void playground::playerY(int i,int y) { 
    // Gebe y-wert von Spieler i ein
    spieler[i][1]=y;
}

void playground::badMask() {
    if (invisible==0) {
     	sprites[18].Load(names[0]); //new Sprite(names[0]); 
	invisible = 1;
    } else {
	sprites[18].Load(names[18]);
	invisible = 0;
    }
    Paint();
}

void playground::movePlayerDown(int i) { 
    // Bewege Spieler i eins nach unten - geht das?
    if (anzahl>MAX_STEP) {
	ende_erreicht=99;
	return;
    }
    int k=spielfeld[playerX(i)+1][playerY(i)];
    if (k==BAD_MASK) {
	badMask();
	movePlayer(i,DOWN,0);
	return;
    }	//invisible = !invisible;
    if (k==MASK) { 
	movePlayer(i,DOWN,0);
	masken_gefunden=1;
	gesammelte_masken++;
	return;
    }
    if (k==EXIT) {
	if (anzahl_masken==gesammelte_masken) {
	    ende_erreicht=1;
	    movePlayer(i,DOWN,0);
	}
	return;
    }
    if (k==MAP_1) {
	movePlayer(i,DOWN,0);
	karten = karten | 1;
	karten_flag=1;
	return;
    }
    if (k==MAP_2) { 
	karten_flag=1;
	movePlayer(i,DOWN,0);
	karten = karten | 2;
	return;
    }
    if (k==MAP_3) { 
	karten_flag=1;
	movePlayer(i,DOWN,0);
	karten = karten | 4;
       	return;
    }
    if (k==MAP_4) { 
	karten_flag=1;
	movePlayer(i,DOWN,0);
	karten = karten | 8;
       	return;
    }
    if (k==PUPPET) {
	if ((playerX(i)+2)<32) {
	    int l = spielfeld[playerX(i)+2][playerY(i)];
	    if (l==H_WAVE || l==SPACE) {
		dollsThrow(playerX(i)+1,playerY(i),DOWN);
	  	movePlayer(i,DOWN,0);
		return;
	    }
	}
    }
    

    if (k==H_WAVE || k==SPACE) { 
	movePlayer(i,DOWN,0);
	return;
    }

    if (k==TRANSPORTER) {
	beamMeUp();
	//movePlayer(i,DOWN,0);
	return;
    }

    // Chicken Run : pruefe, ob du chicken nach unten verschieben kannst
    if (k==CHICKEN || k==ACID) {
	if ((playerX(i)+2) <=31) {
	    int l=spielfeld[playerX(i)+2][playerY(i)];
	    if (l==H_WAVE || l==SPACE) {
		movePlayer(i,DOWN,k);
		spielfeld[playerX(i)+1][playerY(i)]=k;
		if ((playerY(i)+1)>0) {
		    chickenRun(k,playerX(i)+1,playerY(i),0);
		    show(-1);
		}
	    }
	}
	return;
    }
};

void playground::movePlayerRight(int i) {
    // Bewege Spieler i eins nach rechts
    // Dabei koennen keine chicken befreit werden!!
    if (anzahl>MAX_STEP) {
	ende_erreicht=99;
	return;
    }
    int k=spielfeld[playerX(i)][playerY(i)+1];
    if (k==BAD_MASK) {
	badMask();
	movePlayer(i,RIGHT,0);
	return;
    }
    if (k==EXIT) {
	if (anzahl_masken==gesammelte_masken) {
	    movePlayer(i,RIGHT,0);
	    ende_erreicht=1;
	}
	
    }
  
    if (k==MASK) {
	masken_gefunden=1;
	movePlayer(i,RIGHT,0);
	gesammelte_masken++;
	return;
    }
    if (k==MAP_1) {
	karten_flag=1;
	movePlayer(i,RIGHT,0);
	karten = karten | 1;
       	return;
    }
    if (k==MAP_2) { 
	karten_flag=1;
	movePlayer(i,RIGHT,0);
	karten = karten | 2;
	return;
    }
    if (k==MAP_3) { 
	karten_flag=1;
	movePlayer(i,RIGHT,0);
	karten = karten | 4;
	return;
    }
    if (k==MAP_4) { 
	karten_flag=1;
	movePlayer(i,RIGHT,0);
	karten = karten | 8;
	return;
    }

    if (k==PUPPET) {
	if ((playerY(i)+2) < 32) {
	    int l = spielfeld[playerX(i)][playerY(i)+2];
	    if (l==V_WAVE || l==SPACE) {
		
		//spielfeld[playerX(i)][playerY(i)]=0;
		//spielfeld[playerX(i)][playerY(i)+1]=PLAYER_1+i;
		
		
		dollsThrow(playerX(i),playerY(i)+1,RIGHT);
		movePlayer(i,RIGHT,0);
	    }
	}
	return;
    }
    

    // Fish fall : Pruefe, ob du fish nach links verschieben kannst
    if (k==FISH || k==BOMB) {
	if ((playerY(i)+2) <=31) {
	    int l = spielfeld[playerX(i)][playerY(i)+2];
	    if (l==V_WAVE || l==SPACE) {
		movePlayer(i,RIGHT,k);
		//spielfeld[playerX(i)][playerY(i)]=SPACE;
		//spielfeld[playerX(i)][playerY(i)+1]=PLAYER_1+i;
		spielfeld[playerX(i)][playerY(i)+1]=k;
		//show_spieler(graph->play_buffer,player(),playerX(i),playerY(i)+1);

		if ((playerY(i)+1)<=31) {
		    fishFall(k,playerX(i),playerY(i)+1);
		    show(-1);
		}
	    }
	}
    }

    if (k==V_WAVE || k==SPACE) { 
	movePlayer(i,RIGHT,0);
    }

    if (k==TRANSPORTER) {
	beamMeUp();
	//movePlayer(i,RIGHT,0);
	return;
    }


};


void playground::movePlayerUp(int i) {	
    // Bewege Spieler eins nach oben 
    if (anzahl>MAX_STEP) {
	ende_erreicht=99;
	return;
    }
    int k=spielfeld[playerX(i)-1][playerY(i)];
    if (k==BAD_MASK) { 	
	badMask();
	movePlayer(i,UP,0);
	return;
    }
    if (k==EXIT) {
	if (anzahl_masken==gesammelte_masken) {
	    movePlayer(i,UP,0);
	    ende_erreicht=1;
	}
	return;
    }
 
    if (k==MASK) { 
	masken_gefunden=1;
	movePlayer(i,UP,0);
	gesammelte_masken++;
	return;
    }
    if (k==MAP_1) {
	karten_flag=1;
	movePlayer(i,UP,0);
	karten = karten | 1;
	return;
    }
    if (k==MAP_2) { 
	karten_flag=1;
	movePlayer(i,UP,0);
	karten = karten | 2;
	return;
    }
    if (k==MAP_3) { 
	karten_flag=1;
	movePlayer(i,UP,0);
	karten = karten | 4;
	return;
    }
    if (k==MAP_4) { 
	karten_flag=1;
        movePlayer(i,UP,0);
	karten = karten | 8;
      	return;
    }
    if (k==PUPPET) {
	if ((playerX(i)-2)>0) {
	    int l = spielfeld[playerX(i)-2][playerY(i)];
	    if (l==H_WAVE || l==SPACE) {
		dollsThrow(playerX(i)-1,playerY(i),UP);
		movePlayer(i,UP,0);
		return;
	    }
	}
    }

    if (k==SPACE || k==H_WAVE) { 
	movePlayer(i,UP,0);
	return;
    }

    if (k==TRANSPORTER) {
	beamMeUp();
	//movePlayer(i,UP,0);
	return;
    }

    // Chicken Run : Pruefe, ob du chicken nach oben verschieben kannst
    if (k==CHICKEN || k==ACID) {
	if ((playerX(i)-2) >=0) {
	    int l = spielfeld[playerX(i)-2][playerY(i)];
	    if (l==H_WAVE || l==SPACE) {
		movePlayer(i,UP,k);
		spielfeld[playerX(i)-1][playerY(i)]=k;
		if ((playerY(i)-1)>0) {
		    chickenRun(k,playerX(i)-1,playerY(i),0);
		    show(-1);
		}
	    }
	}
	return;
    }
};

void playground::movePlayerLeft(int i) { 
    // bewege Spieler eins nach links
    if (anzahl>MAX_STEP) {
	ende_erreicht=99;
	return;
    }
    int k=spielfeld[playerX(i)][playerY(i)-1];
    if (k== BAD_MASK) { 
	badMask();
	movePlayer(i,LEFT,0);
	return;
    }
    if (k==EXIT) {
	if (anzahl_masken==gesammelte_masken) {
	    ende_erreicht=1;
	    movePlayer(i,LEFT,0);
	}
	return;
    }
    if (k==MASK) { 
	masken_gefunden=1;
	movePlayer(i,LEFT,0);
	gesammelte_masken++;
	return;
    }
    if (k==MAP_1) {
	karten_flag=1;
	movePlayer(i,LEFT,0);
	karten = karten | 1;
	return;
    }
    if (k==MAP_2) { 
	karten_flag=1;
	movePlayer(i,LEFT,0);
	karten = karten | 2;
     	return;
    }
    if (k==MAP_3) { 
	karten_flag=1;
	movePlayer(i,LEFT,0);
	karten = karten | 4;
	return;
    }
    if (k==MAP_4) { 
	karten_flag=1;
	movePlayer(i,LEFT,0);
	karten = karten | 8;
       	return;
    }
    // Fish fall : Pruefe, ob du fish nach links verschieben kannst
    if (k==FISH || k==BOMB) {
	if ((playerY(i)-2) >=0) {
	    int l = spielfeld[playerX(i)][playerY(i)-2];
	    if (l==V_WAVE || l==SPACE) {
		movePlayer(i,LEFT,k);
		spielfeld[playerX(i)][playerY(i)-1]=k;
		if ((playerY(i)-1)>0) {
		    fishFall(k,playerX(i),playerY(i)-1);
		    show(-1);
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
		movePlayer(i,LEFT,0);
	    }
	}
	return;
    }
 
    if (k==SPACE || k==V_WAVE) {
	movePlayer(i,LEFT,0);
	return;
    }    

    if (k==TRANSPORTER) {
	beamMeUp();
	//movePlayer(i,LEFT,0);
	return;
    }
    
};

// Bewegt den Spieler nach rechts,links,oben,unten 
// aendert dabei koordinate des Spielers!
void playground::movePlayer(int i,int dir,int b) {
    int l;
    if (dir==RIGHT) {
        // Spielfigur bewegen
	spielfeld[playerX(i)][playerY(i)]=SPACE;
	spielfeld[playerX(i)][playerY(i)+1]=PLAYER_1+i;
	incPlayerY(i);
	showPlayer(player(),playerX(i),playerY(i),b);
   	// pruefe,ob du ein fish befreit hast...
	l=spielfeld[playerX(i)-1][playerY(i)-1];
	if (l==FISH || l==BOMB){
	    fishFall(l,playerX(i)-1,playerY(i)-1);
	}
	replay[anzahl]=RIGHT;
	anzahl++;
    } else if (dir==UP) {
	// Altes Spielfeld mit SPACE loeschen
	spielfeld[playerX(i)][playerY(i)]=SPACE;
	spielfeld[playerX(i)-1][playerY(i)]=PLAYER_1+i;
	if (b>0)
	    spielfeld[playerX(i)-2][playerY(i)]=b;
	decPlayerX(i);
	showPlayer(player(),playerX(i),playerY(i),b);

	// pruefe,ob du ein chicken befreit hast...
	l=spielfeld[playerX(i)+1][playerY(i)+1];
	if (l==CHICKEN || l==ACID){
	    chickenRun(l,playerX(i)+1,playerY(i)+1,0);
	}
	replay[anzahl]=UP;
	anzahl++;
    } else if (dir==LEFT) {
	// Altes Feld mit SPACE loeschen
	spielfeld[playerX(i)][playerY(i)]=SPACE;
	// Spielfigur einen nach links bewegen
	spielfeld[playerX(i)][playerY(i)-1]=PLAYER_1+i;
	//NEW
	decPlayerY(i);
	showPlayer(player(),playerX(i),playerY(i),b);
 	// pruefe,ob du ein fish befreit hast...
	l=spielfeld[playerX(i)-1][playerY(i)+1];
	if (l==BOMB || l==FISH){
	    fishFall(l,playerX(i)-1,playerY(i)+1);
	}
        // Whoops! den Spieler hat's gekillt...
	if (playerY(i)+2<32) {
	    l=spielfeld[playerX(i)][playerY(i)+2];
	    if (l==CHICKEN || l==ACID) {
		chickenRun(l,playerX(i),playerY(i)+2,0);
		//ende_erreicht=98;
	    }
	} 
	//dec_spieler_y(i);
	replay[anzahl]=LEFT;
	anzahl++;
    } else if (dir==DOWN) {
	// Spielfigur bewegen
	spielfeld[playerX(i)][playerY(i)]=SPACE;
	spielfeld[playerX(i)+1][playerY(i)]=PLAYER_1+i;
	incPlayerX(i);
	showPlayer(player(),playerX(i),playerY(i),b);
 	// CHICKEN oder ACID befreit ?
	l=spielfeld[playerX(i)-1][playerY(i)+1];
	if (l==CHICKEN || l==ACID){
	    chickenRun(l,playerX(i)-1,playerY(i)+1,0);
	}
        // Whoops! den Spieler hat's gekillt...
	if (playerX(i)-2>=0) {
	    l=spielfeld[playerX(i)-2][playerY(i)];
	    if (l==FISH || l==BOMB) {
		fishFall(l,playerX(i)-2,playerY(i));
		//ende_erreicht=98;
	    }
	}
	replay[anzahl]=DOWN;
	anzahl++;
    }
}

int playground::chickenRun(int k,int x,int y, unsigned short int saeure_wurde_bewegt) { //k=CHICKEN, ACID
    int l,n, j=1, quit=0, last_chicken=1;
    
    // Pruefe, ob Chicken das letzte/rechteste in der Reihe ist!
    // last_chicken=1: JA, es ist das letzte!
    if (y+1<32) {
	n=spielfeld[x][y+1];
	if (n==CHICKEN || n==ACID) {
	    last_chicken=0;
	}
    }

    while (quit!=-1) {
	l = spielfeld[x][y-j];
	if (l==SPACE || l==V_WAVE || l==BOMB || l==ACID || ((l==PLAYER_1 || l==PLAYER_2) && j>1)) {

	    // haben wir einen Spieler gekillt?
 	    if (((l==PLAYER_1) || (l==PLAYER_2))) {
		 if (ende_erreicht==98 && death==1) {
		     ende_erreicht=99;
		 } else {
		     ende_erreicht=98;
		     //death=1;
		     if ((l==PLAYER_1 && player()==1) || (l==PLAYER_2 && player()==0)) {
			 changePlayer();
		     }
		 }
	    }

	    // Der direkte Nachbar ist eine Bombe/Saeure: Tue nichts
	    if ((l==BOMB || l==ACID) && j==1) {
		quit=-1;
	    } else {
		// Keine Bombe und keine Saeure: bewege Figur um eins nach links
		if (l!=BOMB && l!=ACID) {
		    spielfeld[x][y-j]=k;
		    spielfeld[x][y-j+1]=SPACE;
		} else {
		    // Bombe oder Saeure: Figur wird vernichtet und deshalb nicht neu eingetragen
		    spielfeld[x][y-j+1]=SPACE;
		}
		
		// Bombe getroffen ?
		if (l==BOMB && j>1) {
		    show(0);
		    bombExplode(x,y-j);
		    quit=-1;
		}
		
		//Saeure getroffen?
		
		if (l==ACID && j>1) {
		    //cout << "SAEURE GETROFFEN!:" <<  spielfeld[x][y-j] << endl;
		  spielfeld[x][y-j]=SPACE;
		  //show(0);
		  acidCorrosive(x,y-j);
		  quit=-1;
		}
		
		// Hat Chicken/Acid ein Fish/Bombe befreit ? schaue ein Feld ueber dem leeren Feld nach...
		// Und ist das Chicken das Letzte in der Chicken-Reihe ?
		// Wichtig, sonst flutscht Fisch dazwischen....
		if (x-1>=0) {
		    if (last_chicken==1) {
			int m=spielfeld[x-1][y-j+1];
			if (m==BOMB || m==FISH) {
			    fishFall(m,x-1,y-j+1);
			}
		    }
		}
		show(0);
		Paint();
		//wait(500000);
	    }
	    j++;
	} else {
	    quit=-1;
	}
    }
    l=spielfeld[x][y+1];
    if (l==CHICKEN || l==ACID) { 
	chickenRun(l,x,y+1,0);
    }
}

void playground::fishFall(int k,int x,int y) {
    int l,n, j=1, quit=0, last_fish=1;
    
    // Pruefe, ob Fish das letzte/rechteste in der Reihe ist!
    // last_fish=1: JA, es ist das letzte!
    if (x>0) {
	n=spielfeld[x-1][y];
	if (n==FISH || n==BOMB) {
	    last_fish=0;
	}
    }

    while (quit!=-1) {
	//cout << "coord_x:" << coordX(x+j) << endl;
	//cout << "coord_y:" << coordY(y) << endl;
	l = spielfeld[x+j][y];
	if (l==SPACE || l==H_WAVE || l==BOMB || l==ACID || ((l==PLAYER_1 || l==PLAYER_2) && (j>1))) {
	    //cout << "FISHFALL" << endl;
	    if ((l==PLAYER_1) || (l==PLAYER_2)) {
		//cout << ">>>>" << ende_erreicht << ":" << death << endl;
		 if (ende_erreicht==98 && death==1) {
		     ende_erreicht=99;
		 } else {
		     ende_erreicht=98;
		     //death=1;
		     //cout << ">>>>l:" << l << ",player():" << player() << endl;
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
		spielfeld[x+j][y]=k;
		spielfeld[x+j-1][y]=SPACE;
		} else {
		    spielfeld[x+j-1][y]=SPACE;
		}
	    }

	    if (l==BOMB && j>1) {
		show(0);
		bombExplode(x+j,y);
		//spielfeld[x+j][y]=SPACE;
	       
		quit=-1;
	    }
	    if (l==ACID && j>1) {
		show(0);
		acidCorrosive(x+j,y);
		quit=-1;
	    }
	    
	    /*
	    n = spielfeld[x+j-2][y];
	    if (n==FISH || n==BOMB) {
		fishFall(n,x+j-2,y);
		}*/


            // Sind mehrere fische uebereinander gestapelt?
	    /*if (x+j-2>=0) {
		//if (spielfeld[x+j-2][y]==BOMB) {
		    //fishFall(BOMB,x+j-2,y);
		    //} else 
		    if (spielfeld[x+j-2][y]==k) {
			fishFall(k,x+j-2,y);
		    }
		    }*/
	    // Hat fish ein chicken/acid befreit ? Schaue ein Feld rechts vom leeren Feld nach...
	    if (y+1<=31) {
		if (last_fish==1) {
		    int m=spielfeld[x+j-1][y+1];
		    if (m==CHICKEN || m==ACID) {
			chickenRun(m,x+j-1,y+1,0);
		    }
		}
	    }
	
	    
	    j++;
	    //wait(WAITING);
	    show(0);
	    //cout << graph->play_buffer << ":" << widget << endl;
	    Paint();
	} else {
	    quit=-1;
	}
    }
    //cout << "Fishfall ende ..." << endl;
    
    l = spielfeld[x-1][y];
    if (l==FISH || l==BOMB) {
	fishFall(l,x-1,y);
    }
    
    //cout << "E N D E  E R R E I C H T :" << ende_erreicht << endl;

}

void playground::dollsThrow(int x,int y,int direction) {
    int l, j=1;
    if (direction==RIGHT) {
	//cout << "RIGHT" << endl;
	while (j!=-1) {
	    l = spielfeld[x][y+j];
	    if (l==SPACE) { // || l==V_WAVE) {
		spielfeld[x][y+j]=PUPPET;
		spielfeld[x][y+j-1]=SPACE;
		// Wurde ein Fisch befreit?
		if ((x-1>0) && (j>1)){
		    int m=spielfeld[x-1][y+j-1];
		    if (m==FISH || m==BOMB) {
			fishFall(m,x-1,y+j-1);
		    }
		}
		j++;
		//wait(WAITING);
		show(0);
		Paint();
	    } else {
		j=-1;
	    }
	    
	    //cout << l << ":" << y+j << endl;
	}
	return;
    }
    
    if (direction==LEFT) {
	while (j!=-1) {
	    l = spielfeld[x][y-j];
	    if (l==SPACE) { // || l==V_WAVE) {
		spielfeld[x][y-j]=PUPPET;
		spielfeld[x][y-j+1]=SPACE;
		// Wurde ein Fisch befreit?
		if ((x-1>0) && (j>1)) {
		    int m=spielfeld[x-1][y-j+1];
		    if (m==BOMB || m==FISH) {
			fishFall(m,x-1,y-j+1);
		    }
		}
		j++;
		//wait(WAITING);
		show(0);
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
		// Wurde ein Chicken befreit?
		if ((y+1<=31) && (j>1)){
		    int m=spielfeld[x-j+1][y+1];
		    if (m==ACID || m==CHICKEN) {
			chickenRun(m,x-j+1,y+1,0);
			   
		
		    }
		}
		j++;
		//wait(WAITING);
		show(0);
		Paint();
	    } else {
		j=-1;
	    }
	}
	return;
    }
 
    if (direction==DOWN) {
	while (j!=-1) {
	    //cout << "DOLL:" << j << endl;
	    l = spielfeld[x+j][y];
	    if (l==SPACE) { // || l==H_WAVE) {
		spielfeld[x+j][y]=PUPPET;
		spielfeld[x+j-1][y]=SPACE;
		// Wurde ein Chicken befreit?
		if ((y+1<=31) && (j>1)) {
		    int m=spielfeld[x+j-1][y+1];
		    if (m==CHICKEN || m==ACID) {
			chickenRun(m,x+j-1,y+1,0);
			   
		
		    }
		}
		j++;
		//wait(WAITING);
		show(0);
		Paint();
	    } else {
		//cout << spielfeld[x+j-1][y] << endl;
                //spielfeld[x+j-1][y]=PUPPET;
		j=-1;
	    } 
	}
	return;
    }
}

void playground::acidCorrosive(int x, int y) {
    flash();
    int i, mitte=-1, oben=-1, unten=-1, mitte_y=-1;
    mitte_y = coordY(y)*40;
    if (mitte_y>=0) {
	  mitte = coordX(x)*40;
	   oben = coordX(x-1)*40;
	  unten = coordX(x+1)*40;
	  //cout << "MITTE:" << mitte << "OBEN:" << oben << "UNTEN:" << unten << endl; 
    
    }
    if (spielfeld[x-1][y]==PLAYER_1 || spielfeld[x-1][y]==PLAYER_2 || 
	spielfeld[x+1][y]==PLAYER_1 || spielfeld[x+1][y]==PLAYER_2) {
	if (ende_erreicht==98 && death==1) {
	    ende_erreicht=99;
	} else {
	    ende_erreicht=98;
	    //	    changePlayer();
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
		graph->Paint(&acid[i][0],mitte_y,mitte,0,0,40,40);
		Paint();	
	    }
	    //wait(10000);
	    if (oben>=0) {
		spielfeld[x-1][y]=SPACE;
		graph->Paint(&acid[i][1],mitte_y,oben,0,0,40,40);
		Paint();	
	    }
	    //wait(10000);
	    if (unten>=0) {
		spielfeld[x+1][y]=SPACE;
		graph->Paint(&acid[i][2],mitte_y,unten,0,0,40,40);
		Paint();	
	    }
	    //wait(10000);
	}
	
    }
    spielfeld[x][y]=SPACE;
    if (x-1>=0) {
	spielfeld[x-1][y]=SPACE;
	if (x-2>=0) {
	    // Ueber der Saeure ein Fisch oder Bombe  ?
	    int m=spielfeld[x-2][y];
	    if (m==FISH || m==BOMB) {
		fishFall(m,x-2,y);
	    }
	    // diagonal zur Saeure ein Chicken oder Saeure ?
	    if (y+1<=31) {
		m=spielfeld[x-1][y+1];
		//cout << "m" << m << x-1 << "," << y+1 << endl;
		if (m==CHICKEN || m==ACID) {
		    chickenRun(m,x-1,y+1,0);
		        
		
		}
		m=spielfeld[x][y+1];
		//cout << "m" << m << x << "," << y+1 << endl;
		if (m==CHICKEN || m==ACID) {
		    chickenRun(m,x,y+1,0);
		    
		
		}
		
	    }
	}
    }
    // Das Feld unter der Saeure ansehen
    if (x+1<=31) {
	spielfeld[x+1][y]=SPACE;
	// Diagonal unter der Saeure ein Chicken/Saeure?
	if (y+1<=31) {
	    int m=spielfeld[x+1][y+1];
	    if (m==CHICKEN || m==ACID) {
		chickenRun(m,x+1,y+1,0);    
		
	    } 
	}
    }
} 

void playground::bombExplode(int x,int y) {
    flash();
    Sound bomb("/home/mario/xor/sounds/bomb.wav");
    bomb.play();
    int i, mitte=-1, rechts=-1, links=-1, mitte_x=-1;
    mitte_x = coordX(x)*40;
    if (mitte_x>=0) {
	  mitte = coordY(y)*40;
	  links = coordY(y-1)*40;
	 rechts = coordY(y+1)*40;
    }



    if (spielfeld[x][y-1]==PLAYER_1 || spielfeld[x][y-1]==PLAYER_2 || 
	spielfeld[x][y+1]==PLAYER_1 || spielfeld[x][y+1]==PLAYER_2) {
	if (ende_erreicht==98 && death==1) {
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
		graph->Paint(&bomben[i][0],mitte,mitte_x,0,0,40,40);
		Paint();
  	    }
	    //wait(1000000);
	    if (links>=0) {
		spielfeld[x][y-1]=SPACE;
		graph->Paint(&bomben[i][1],links,mitte_x,0,0,40,40);
		Paint();
   	    }
	    //wait(1000000);
	    if (rechts>=0) {
		spielfeld[x][y+1]=SPACE;
		graph->Paint(&bomben[i][2],rechts,mitte_x,0,0,40,40);
		Paint();
	    }
	}
    }
    // Bombe explodiert...und spielfeld bereinigen
    spielfeld[x][y]=SPACE;
    // Links neben der Bombe
    if (y-1>=0) {
	spielfeld[x][y-1]=SPACE;
	// Ueber dem freien Feld was frei ?
	if (x-1>=0) {
	    int m=spielfeld[x-1][y-1];
	    if (m==FISH || m==BOMB) {
		fishFall(m,x-1,y-1);
	    }
	    m=spielfeld[x-1][y];
	     if (m==FISH || m==BOMB) {
		fishFall(m,x-1,y);
	    }
	}
    }
    // Rechts neben der Bombe 
    if (y+1<32) {
	spielfeld[x][y+1]=SPACE;
       
     // Ueber dem freien Feld was frei ?
	if (x-1>=0) {
	    int m=spielfeld[x-1][y+1];
	    if (m==FISH || m==BOMB) {
		fishFall(m,x-1,y+1);
	    }
	}
	// Rechts neben dem nun freien Feld der Bombe: ein chicken/acid befreit?
	if (y+2>=0) {
	    int m=spielfeld[x][y+2];
	    if (m==CHICKEN || m==ACID) {
		chickenRun(m,x,y+2,0);
	    }
	}
    }
    
}

void playground::map() {
    if (map_flag==0) {
	showMap();
	map_flag=1;
    } else {
	map_flag=0;
    }    
}

void playground::initPlayground() {
    int i,j,k;
    for (i=0;i<groesse;i++) {
	for (j=0;j<groesse;j++) {
	    k=spielfeld[i][j];
	    if (k==CHICKEN || k==ACID) {
		chickenRun(k,i,j,0);
	    }
	    if (k==FISH || k==BOMB) {
		fishFall(k,i,j);
	    }
	}
    }
}

void playground::showPlayer(int spieler,int b) {  
//Zeige Spielfeld mit spieler i innerhalb an
    if (map_flag==1) 
	return;
    //x_old(x());
    //y_old(y());
    // Spielfigur out of range testen und spielfeld nachführen!!
    if (x()==playerX(spieler)) {
	//animation(surface);
	x(x()-1);
    }
    if (y()==playerY(spieler)) {
	//animation(surface);
	y(y()-1);
    } 
    if (x()+7==playerX(spieler)) {
	//animation(surface);
	x(x()+1);
    }
    if (y()+7==playerY(spieler)) {
	//animation(surface);
	y(y()+1);
    }
    show(b);
};

void playground::flash() {
    return;
    graph->play_buffer->sp->fill(Qt::white);
    Redraw();
    /*
    show(0);
    showStatus(-1);
    Redraw();*/
}

void playground::showPlayer(int spieler, int spieler_x, int spieler_y,int b) {  
//Zeige Spielfeld mit spieler i innerhalb an
    if (map_flag==1) 
	return;
    // Spielfigur out of range testen und spielfeld nachführen!!
    if (x()==spieler_x) {
	x(x()-1);
    }
    if (y()==spieler_y) {
	y(y()-1);
    } 
    if (x()+7==spieler_x) {
	x(x()+1);
    }
    if (y()+7==spieler_y) {
	y(y()+1);
    }
    show(b);
};

void playground::show(int b) {  //Zeige Spielfeld an
    int x_offset=x();
    int y_offset=y();
    // Angezeigt soll ein 8x8-Teilfeld werden;
    // Oben links ist 0,0
    // Unten rechts ist 24x24 (+8 ergibt dann 32x32)
  
    if (x_wert_old==-1 && y_wert_old==-1) {
	x_wert_old=(playerX(player())-x())*40;
	y_wert_old=(playerY(player())-y())*40;
    } else {
	x_wert_old=x_wert;
	y_wert_old=y_wert;
    }
    x_wert=(playerX(player())-x())*40;
    y_wert=(playerY(player())-y())*40;
    //cout << "Spieler alt x,y:" << x_wert_old << "," << y_wert_old << " x:" << x() << " y:" << y() << endl;
    //cout << "Spieler     x,y:" << x_wert << "," << y_wert << endl;
   
    if (x_offset+8>groesse)
	x_offset=groesse-8;
    if (y_offset+8>groesse)
	y_offset=groesse-8;
    if (x_offset<0)
	x_offset=0;
    if (y_offset<0) 
	y_offset=0;
    int k;
    //cout << "TEMP:"; 
 
    animation(b);

    for (int i=0;i<8;i++) {
	for (int j=0;j<8;j++) {
	    k = spielfeld[i+x_offset][j+y_offset];
	    //cout << k << ":";
	    graph->Paint(&sprites[k],j*40,i*40,0,0,40,40);
	}
	//cout << endl;
    }
    //cout << "TEMP:";
}

void playground::showStatus(int wert) {
    if (wert==0 || wert==-1) {
	int k=15;
	if (akt_spieler==1) {
	    k=16;
	}
	// Der Spieler hat gewechselt
   	graph->Paint(&sprites[k],STATUS_X,130,0,0,80,80);
 	graph->RectRed(STATUS_X,180,80,30);
	string schritte=toNum(anzahl);
	//schritte.sprintf("%d",anzahl);
	
	graph->Write(schritte,STATUS_X,200);
    }
    if (wert==1 || wert==-1) { // Maskenzaehler
	graph->Paint(&sprites[7],STATUS_X,220,0,0,80,80);
 	graph->RectRed(STATUS_X,270,80,24);
	string masks=toNum(gesammelte_masken);
	string masken=toNum(anzahl_masken);
	masks=masks+"/"+masken;
	graph->Write(masks,STATUS_X,290);
    }
    if (wert==2 || wert==-1) { // Kartenzaehler
	graph->Paint(&sprites[3],STATUS_X,50,0,0,80,80);
	if ((karten & 1) == 0) {
	    graph->Rect(STATUS_X,50,20,20);
	}
	if ((karten & 2) == 0) {
	    graph->Rect(STATUS_X+20,50,20,20);
	}
	if ((karten & 4) == 0) {
	    graph->Rect(STATUS_X,70,20,20);
	}
	if ((karten & 8) == 0) {
	    graph->Rect(STATUS_X+20,70,20,20);
	}	  
    }
    //if (wert==-1)
    //bitBlt(play_buffer.sp,320,0,sprites[23].sp,0,0,400,400);
 
}


//********************************************
void playground::getLevelname() {
    //cout << "____LEVEL::" << level << endl;
    int k,i=0;
    char val;
    char levels[200];

    char a[level.length()];
    for (int i=0;i<level.length();i++)
	a[i]=level[i];
    FILE *ffeld;
    ffeld=fopen(level.c_str(),"r");
    if (!ffeld) {
	cout << "Level " << level << " konnte nicht geoeffnet werden !\n";
	cout << "Offenbar ist dies eine Spielzüge-Datei für einen nichtexistierenden Level!\n"; 
	nothing_loaded=1;
	return; //exit(1);
    }
    if (fscanf(ffeld,"%c",&val)!=EOF) {
	while (val!='#')
	    ;
	// Ab hier ist val=='#'
	fscanf(ffeld,"%c",&val);
	levels[0]=val;
	while (val!='#') {
	    val=(char)getc(ffeld);
	    levels[++i]=val;
	}
	levels[i]='\0';
	fclose(ffeld);
	level_name=(string)levels;
    } 
    //cout << "LEVEL ENDE____" << endl;
}

void playground::setLevel(string i) {
    //cout << "SETLEVEL: VON " << level;
    if (i.find(directory,0)==-1)
	level=directory+"/"+i;
    else
	level = i;
    //cout << " NACH " << level << endl;
}

void playground::saveMoves(string name) {
    ofstream file_out;
    int i=0;
    
    char a[name.length()];
    for (int i=0;i<name.length();i++)
	a[i]=name[i];
    //const  char *na=&a;
    file_out.open(a,ios::out);
    if (!file_out) {
	cout << "cannot open output file " << name << name;
    } else {
	file_out << "#" << level << "#" << endl;
	while (i<=MAX_STEP && replay[i]!=-1) {
	    file_out << replay[i] << endl;
	    i++;
	}
	file_out.close();
    }
}

void playground::loadMoves(string name) {
    FILE *ffeld;
    char levels[200];
    //name = directory+name;
    // const char *na=name;

    //char a[name.length()];
    //for (int i=0;i<name.length();i++)
//	a[i]=name[i];

    //cout << "DIRECTORY:" << directory << endl;
    //cout << "NA" << a << endl;
    ffeld=fopen(name.c_str(),"r");
    if (!ffeld) {
	cout << " Cannot open file " << level << endl;;
	nothing_loaded=1;
	exit(1);
    }
    char val;
    int k,i=0,quit=1;

    // Den Namen des Levels herausfinden...
    if (fscanf(ffeld,"%c",&val)!=EOF) {
	while (val!='#')
	    ;
	// Ab hier ist val=='#'
  	fscanf(ffeld,"%c",&val);
	levels[0]=val;
     	while (val!='#') {
	    val=(char)getc(ffeld);
	    levels[++i]=val;
	}
	// Hier ist wieder val=="#"
	val=(char)getc(ffeld);
	levels[i]='\0';
    }

    setLevel((string)levels);
    
    //cout << "LEVEL......" << level << endl;

    //level = (string)levels;
    getLevelname();
    i=0;
    while (i<=MAX_STEP) {
	if (fscanf(ffeld,"%d",&k)!= EOF ) {
	    replay[i]=k;
	    i++;
	} else {
	    i=MAX_STEP+1;
	}
    }
    fclose(ffeld);
    showStatus(-1);
    doReplay();
}

void playground::beamMeUp() {
    //cout << "BEAM ME UP!";
    //cout << "POSITION:" << playerX(player()) << "," << playerY(player()) << endl;
    int i=0,q=0;
    while (beam_from[i][0]!=-1 && beam_from[i][1]!=-1 && q==0) {
	//cout << beam_from[i][0] << "," <<  beam_from[i][1] << endl;
	//cout << beam_to[i][0] << "," <<  beam_to[i][1] << endl;
	
	if ((beam_from[i][0]==playerX(player())) && (beam_from[i][1]==playerY(player()))) {
	    
	    //spielfeld[playerX(player())][playerY(player())]=SPACE;
	    //if 
	    //cout << "SPACE?" << spielfeld[beam_to[i][0]][beam_to[i][1]] << endl; // {
	    
	    if ( spielfeld[beam_to[i][0]][beam_to[i][1]]==SPACE)  {
		
		spielfeld[beam_to[i][0]][beam_to[i][1]]=PLAYER_1+player();
		spielfeld[beam_from[i][0]][beam_from[i][1]]=SPACE;
		playerX(player(),beam_to[i][0]);
		playerY(player(),beam_to[i][1]);
		//cout << "ZIEL:" << beam_to[i][0] << "," << beam_to[i][0] << endl;
		//showPlayer(player(),playerX(player()),playerY(player()),0);
	
		x(playerX(player())-4);
		y(playerY(player())-4);
		showPlayer(player(),-1);
		//showPlayer(player(),0);
		Paint();
		q=-1;
		} else {
		    //   q=-1;
		}
	}
	//cout << i << endl;
	i++;
    }
}

void playground::loader() { // Lade ein Spielfeld
    spieler[0][0]=0;
    spieler[0][1]=0;
    spieler[1][0]=0;
    spieler[1][1]=0;
    anzahl_masken=0;
    gesammelte_masken=0;
    nothing_loaded=0;
    getLevelname();
    FILE *ffeld;
    ffeld=fopen(level.c_str(),"r");
    if (!ffeld) {
	cout << "Level " << level << " konnte nicht geoeffnet werden !\n";
	nothing_loaded=1;
	return ; //exit(1);
    }
    char val;
    int k;
    char v;
    if (fscanf(ffeld,"%c",&val)!=EOF) {
	while (val!='#') {
	    ;//cout << val;
	}
	// Ab hier ist val=='#'
       	fscanf(ffeld,"%c",&val);
	while (val!='#') { 
	    val=(char)getc(ffeld);
	    //cout << val;
	}
	// Hier ist wieder val=="#"
	val=(char)getc(ffeld);
    }
    for (int i=0;i<32;i++) {
	for (int j=0;j<32;j++) {
	    if (fscanf(ffeld,"%d",&k)!= EOF ) {
		if (k<0 || k>31) {
		    fscanf(ffeld,"%c",&v);
		}
		if (k<32 && k>=0) {		
		    spielfeld[i][j]=k;
		} else { 
		    spielfeld[i][j]=convert(v);
		}
		
		
		if (k==PLAYER_1 || v=='a') {
		    if (spieler[0][0]==0 && spieler[0][1]==0) {
			playerX(0,i);
			playerY(0,j);
		    }
		} else {
		    if (k==PLAYER_2 || v=='b') {
			if (spieler[1][0]==0 && spieler[1][1]==0) {
			    playerX(1,i);
			    playerY(1,j);
			}
		    } else {
			if (k==MASK || v=='M') {
			    anzahl_masken++;
			}
		    }
		}
	    } 
	}
    }
    for (int m=0;m<20;m++){
	beam_from[m][0]=-1;
	beam_from[m][1]=-1;
	beam_to[m][0]=-1;
	beam_to[m][1]=-1;
    }
    int x=0,quit = 0;
    while (quit==0) {
	if (fscanf(ffeld,"%d",&k)!= EOF ) {
	    beam_from[x][0]=k;
	    //cout << k << endl;
	    if (fscanf(ffeld,"%d",&k)!= EOF ) {
		beam_from[x][1]=k;
		//cout << k << endl;
	    	if (fscanf(ffeld,"%d",&k)!= EOF ) {
		    beam_to[x][0]=k;
		    //  cout << k << endl;
		    if (fscanf(ffeld,"%d",&k)!= EOF ) {
			beam_to[x][1]=k;
			//cout << k << endl;
		    } else { 
			quit=1;
		    }
		} else { 
		    quit=1;
		}
	    } else { 
		quit=1;
	    }
	} else { 
	    quit=1;
	}
	x++;
    }

    fclose(ffeld);


    for (int i=0;i<24;i++) {
	//cout << names[i] << endl;
	sprites[i].Load(names[i]); 
    }
    string name,name_l,name_r,temp;
    int i;
    temp = names[12].substr(0,names[12].find('.'));
    for (i=0;i<8;i++) {
	
	  name = temp + "_"+toNum(i+1)+".bmp";
	name_l = temp + "_"+toNum(i+1)+"_left.bmp";
	name_r = temp + "_"+toNum(i+1)+"_right.bmp";
	bomben[i][0].Load(name);
	bomben[i][1].Load(name_l);
	bomben[i][2].Load(name_r);
    }
    temp = names[13].substr(0,names[13].find('.'));
    for (i=0;i<8;i++) {
	name = temp+"_"+toNum(i+1)+".bmp";
	name_l = temp+"_"+toNum(i+1)+"_up.bmp";
	name_r = temp+"_"+toNum(i+1)+"_down.bmp";
	acid[i][0].Load(name);
	acid[i][1].Load(name_l);
	acid[i][2].Load(name_r);
    }
    graph->Paint(&sprites[23],320,0,0,0,400,400);
    //cout << "loader ende..." << endl;
}

playground::~playground() {
    for (int i=0;i<24;i++) {
	//delete(sprites[i].sp);
    }
    for (int i=0;i<9;i++) {
	//delete(animation_bomben[i]);
    }
    
}

void playground::animation(int b) { //, int dir) {
    if (b==-1)
	return;
    int i,k=0;
    if (x_wert<x_wert_old) {
	//cout << "---UP---" << b << endl;
       
	//cout << ":::" << spielfeld[playerX(player())-1][playerY(player())] << endl;

	for (i=x_wert_old;i!=x_wert;i=i-2) {
	    // spielfigur an alter position um i verschieben
	    graph->Paint(&sprites[15+player()],y_wert_old,i,0,0,40,40);
	    if (b!=0) {
		graph->Paint(&sprites[b],y_wert_old,i-40,0,0,40,40);
	    }
            // Anzeigen
	    Paint();
	    // alte Position loeschen , aber nicht anzeigen
	    graph->Paint(&sprites[0],y_wert_old,i,0,0,40,40);
	} 
	return;
    } 
    if (x_wert>x_wert_old) {
	for (i=x_wert_old;i!=x_wert;i=i+2) {
	    graph->Paint(&sprites[15+player()],y_wert_old,i,0,0,40,40);
	    if (b!=0) {
		graph->Paint(&sprites[b],y_wert_old,i+40,0,0,40,40);
	    }
	    Paint();
	    graph->Paint(&sprites[0],y_wert_old,i,0,0,40,40);
	    if (b!=0) {
		graph->Paint(&sprites[b],y_wert_old,i+40,0,0,40,40);
	    }
       	} 
	return;
    }
    if (y_wert<y_wert_old) {
	for (i=y_wert_old;i!=y_wert;i=i-2) {
	    graph->Paint(&sprites[15+player()],i,x_wert_old,0,0,40,40);
	    if (b!=0) {
		graph->Paint(&sprites[b],i-40,x_wert_old,0,0,40,40);
	    }
	    Paint();
	    graph->Paint(&sprites[0],i,x_wert_old,0,0,40,40);
	    if (b!=0) {
		graph->Paint(&sprites[0],i-40,x_wert_old,0,0,40,40);
	    }
	}
	return;
    } 
    if (y_wert>y_wert_old) {
	//cout << "---RIGHT---" << endl;
	//cout << ":::" << spielfeld[playerX(player())][playerY(player())+1] << endl;
	for (i=y_wert_old;i!=y_wert;i=i+2) {
	    graph->Paint(&sprites[15+player()],i,x_wert_old,0,0,40,40);
	    if (b!=0) {
		graph->Paint(&sprites[b],i+40,x_wert_old,0,0,40,40);
	    }
	    Paint();
	    graph->Paint(&sprites[0],i,x_wert_old,0,0,40,40);
	    if (b!=0) {
		graph->Paint(&sprites[0],i+40,x_wert_old,0,0,40,40);
	    }
       	}
	return;
    }
}
       
void playground::showMap() { //Karte zeichnen
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
	    graph->Paint(&sprites[sp],j*10,i*10,0,0,40,40);    
	}
    }
}

void playground::zeigen() { //Spielfeld auf stdout zeigen
    cout << endl;
    cout << endl;
    for (int i=0;i<32;i++) {
	for (int j=0;j<32;j++) {
	    cout << spielfeld[i][j] << ",";
	}
	cout << endl;
    }    
}
