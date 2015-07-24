#include "graphics.h"

#define FISH         1
#define CHICKEN      2
#define MAP_1        3
#define MAP_2        4
#define MAP_3        5
#define MAP_4        6
#define MASK         7
#define BAD_MASK     8
#define H_WAVE       9
#define V_WAVE      10
#define PUPPET      11
#define BOMB        12
#define ACID        13
#define TRANSPORTER 14
#define PLAYER_1    15
#define PLAYER_2    16
#define EXIT        17
#define WALL        18
#define SPACE        0
#define MAX_STEP   999
#define WAITING   1000

#define UP 0
#define DOWN 1
#define RIGHT 2
#define LEFT 3 
#define PLAYER_CHANGED 4

#define KEY_UP 4115
#define KEY_DOWN 4117
#define KEY_MAP 77
#define KEY_SPACE 32
#define KEY_LEFT 4114
#define KEY_RIGHT 4116
#define KEY_TAB 4097

#define STATUS_X 350

void wait(int);


class playground {
 public:
    int x_wert,y_wert,x_wert_old,y_wert_old;
    unsigned short int nothing_loaded;    // =1:Zeige Startlevel, sonst Begruessungsschirm
    unsigned short int karten_flag;       // =1: eine Karte wurde gefunden, also aktualisiere Status-Bereich
    unsigned short int akt_spieler;       // 0:Spieler 1,  1:Spieler 2
    unsigned short int ende_erreicht;     // =1: Spiel erfolgreich zu ende !!
    int anzahl;                           // Anzahl zurückgelegter Felder (max. 1000)
    unsigned short int anzahl_masken;     // Gesamtzahl der Masken, die gesammelt werden muessen
    unsigned short int invisible;         // Hat man eine bad Mask gesammelt, wird es unsichtbar...
    unsigned short int karten;            // wie viele kartenteile hat man gesammelt ? 
    unsigned short int gesammelte_masken; // wie viele Masken hat man gesammelt?
    unsigned short int map_flag;          // =1: es soll karte und nicht spielfeld angezeigt werden
    unsigned short int masken_gefunden;   // flag, dass man maske gefunden hat
    unsigned short int death;             // =1:Ein Spieler ist nur noch uebrig !!!
    short int replay[MAX_STEP+1];         // Spielzuege werden hier gespeichert
    int next_step;                        // anzahl Spielschritte
    int groesse;                          // Spielfeldgroesse=32x32
    int spieler[2][2];                    // spieler[0][0]:1.Spieler, Pos. X, [0][1] : Y
    int spielfeld[32][32];                // Das Spielfeld
    int beam_from[20][2];                 // Transporterstartkoordinaten
    int beam_to[20][2];                   // Transporterzeilkoordinaten
    int x_clipper, y_clipper;             // Teilausschnitt, der angezeigt werden soll
    string names[24];                    // Die Dateinamen der bitmaps            
    string level;                        // Die Level-Datei (z.B. level01.xor)
    string level_name;                   // Der offizielle Level-Name (z.B. "The Decoder")
    string directory;                    // der Pfad zum Arbeitsverzeichnis
    Sprite sprites[24];                  // die spiefiguren
    Sprite bomben[8][3];                 // bombe explodiert..
    Sprite acid[8][3];                   // Saeure aetzt...
    Sprite play_buffer;                  // das Spielfeld
    Sprite background;                   //
    Graphics *graph;                     // Objekt, das playground mit Xorwindow-Fenster verknuepft
 public:
    playground(string,string);                  
    playground(string,string,Graphics *);
    ~playground();

    int countMoves();
    int convert(char);
    void beamMeUp();
    void badMask();
    void initPlayground();
    void replayNext();
    void Redraw();
    void Paint();
    void getLevelname();
    void setLevel(string);
    void init();
    void showMap();
    void map();
    void loader();
    void show(int);
    void showPlayer(int,int);
    void showPlayer(int,int,int,int);
    void showStatus(int);
    void zeigen();
    void flash();
    int  levelLoaded();
    void levelLoaded(int );
    void saveMoves(string );
    void loadMoves(string );
    void animation(int);
    void greetingScreen();
    void failureScreen();
    void successScreen();
    void deathScreen();
    // Die Spieler auf dem Bildschirm um eins verschieben
    void movePlayerDown(int);
    void movePlayerRight(int);
    void movePlayerUp(int);
    void movePlayerLeft(int);
    
    void movePlayer(int,int,int); 

    int chickenRun(int,int,int,unsigned short int);
    void fishFall(int,int,int);
    void dollsThrow(int,int,int);
    void bombExplode(int,int);
    void acidCorrosive(int,int);
    int x();
    int y();
    void x(int);
    void y(int);
    int playerX(int);
    int playerY(int);
    int coordX(int);
    int coordY(int);
    // Koordinaten aendern
    void incPlayerX(int);
    void incPlayerY(int);
    void decPlayerX(int);
    void decPlayerY(int);
        
    void playerX(int,int);
    void playerY(int,int);
    unsigned short int player();
    void changePlayer();
    void initReplay();
    void doReplay();
    void keyPressed(int );

};
