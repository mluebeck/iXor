#include <qpixmap.h>
#include <qwidget.h>
#include <qstring.h>

class Sprite {
 public:
    QPixmap *sp;
 public:
    Sprite();
    Sprite(int,int);
    Sprite(QString);
    bool Load(QString);
    ~Sprite();
};

class Graphics {
    //private:
 public:
    Sprite *play_buffer; // Der Grafibereich
    QWidget *widget; // Das Fenster, das die Graphik enthaelt
 public:
    Graphics();
    Graphics(QWidget *,Sprite *);
    ~Graphics();
    void Paint();
    void Paint(Sprite *, int, int, int,int,int,int); 
    void Rect(int ,int ,int , int );
    void RectRed(int,int,int,int);
    void Write(QString,int,int );
    void Clear();
};
