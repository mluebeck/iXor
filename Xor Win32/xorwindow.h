#ifndef XORWINDOW_H
#define XORWINDOW_H

#include <qmainwindow.h>
#include <qpen.h>
#include <qpoint.h>
#include <qpixmap.h>
#include <qwidget.h>
#include <qstring.h>
#include <qmenubar.h>
#include <qtoolbutton.h>
#include <qpointarray.h>
#include <qtextview.h>
#include <qdir.h>
#include "playground.h"


class QMouseEvent;
class QResizeEvent;
class QPaintEvent;
class QToolButton;
class QSpinBox;
class QMenuBar;
//class Koerper;

class XorWindowCanvas : public QWidget {
    Q_OBJECT
      friend class XorWindow;
public:
    XorWindowCanvas( QWidget *parent = 0, const char *name = 0 );
 protected:
    //void enterEvent(QEvent *e);
    //void leaveEvent(QEvent *e);
    void init();
    void keyPressEvent(QKeyEvent *e);
    void mousePressEvent( QMouseEvent *e );
    void mouseReleaseEvent( QMouseEvent *e );
    void mouseMoveEvent( QMouseEvent *e );
    void resizeEvent( QResizeEvent *e );
    void paintEvent( QPaintEvent *e );
    void closeEvent( QCloseEvent *e );
    void focusInEvent( QFocusEvent *e);
    void focusOutEvent( QFocusEvent *e);
    //void Clear();
    void Redraw();
    
    bool replay_on;
    QPen pen;
    bool mousePressed;
    int x,y,kindex;
    playground *xor_play;
    Sprite buffer;
    //QPixmap background;
    
};

class XorWindow : public QMainWindow {
    Q_OBJECT
public:
    XorWindow( QWidget *parent = 0, const char *name = 0 );
    void file();
	void keyPressEvent(QKeyEvent *e);
protected:
    void resizeEvent(QResizeEvent *e);
    bool bool_replay;
    XorWindowCanvas* canvas;
    QMenuBar *menubar; 
    QPopupMenu *popup_file, *popup_level, *popup_replay;
    QStringList dateien;
    int replay_stop_item, replay_minus_item;
    int replay_index;
public slots:
    void replayUntil();
    void endReplay();
    void draw();
    void init();
	void quit();
    void doReplay();
    
    void setLevel(int);
    void save();
    void load();
};
#endif
