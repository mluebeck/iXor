#include <iostream.h>
#include <fstream.h>
#include <stdio.h>
#include <qapplication.h>
#include <qevent.h>
#include <qstringlist.h>
#include <qtextview.h>
#include <qpopupmenu.h>
#include <qpainter.h>
#include <qmenubar.h>
#include <qtoolbar.h>
#include <qtoolbutton.h>
#include <qspinbox.h>
#include <qtooltip.h>
#include <qrect.h>
#include <qpoint.h>
#include <qcolordialog.h>   
#include <qfiledialog.h>
#include <qtoolbutton.h>
#include <qcursor.h>
#include <qimage.h>
#include <qstrlist.h>
#include <qpopupmenu.h>
#include <qintdict.h>
#include <qmessagebox.h>
#include <qstring.h>
#include <qradiobutton.h>
#include <qinputdialog.h>
#include <qlayout.h>
#include <qlabel.h>
#include <qvbox.h>
#include <qdir.h>
#include <qpushbutton.h>
#include <qfiledialog.h>
#include "xorwindow.h"

QString path() {
    QDir fl;
    return fl.currentDirPath();
}


XorWindowCanvas::XorWindowCanvas( QWidget *parent, const char *name ) : QWidget( parent, name), 
									pen( Qt::black, 1 ), 
									mousePressed( FALSE ),
									buffer( 455, 320 )
{
    	
	
  setFocusPolicy(QWidget::StrongFocus);
  if ((qApp->argc() > 0) && !buffer.sp->load(path())) //qApp->argv()[1]))
      buffer.sp->fill( colorGroup().base() );
  setBackgroundMode( QWidget::PaletteBase );
#ifndef QT_NO_CURSOR
  setCursor( Qt::crossCursor );
#endif

  //cout << qApp->argv()[1] << endl;

  //  xor_play = new playground("level/level01.xor",qApp->argv()[1], new Graphics(this,&buffer));
   xor_play = new playground("level/level01.xor",(string) path(), new Graphics(this,&buffer));
  
  if (xor_play->levelLoaded()==1) {
      xor_play->x(xor_play->playerX(0)-4);
      xor_play->y(xor_play->playerY(0)-4);
      xor_play->showPlayer(0,0);
      xor_play->showStatus(-1);
  } else {
      xor_play->levelLoaded(1);
      xor_play->greetingScreen();
  }
}

void XorWindowCanvas::init() {
    xor_play->init();    
    xor_play->levelLoaded(0);
    xor_play->showStatus(-1);
    xor_play->x(xor_play->playerX(0)-4);
    xor_play->y(xor_play->playerY(0)-4);
    xor_play->showPlayer(0,0);
    Redraw();
    xor_play->initPlayground();
    
}

void XorWindowCanvas::focusInEvent( QFocusEvent *e) {
    xor_play->Paint();    
}

void XorWindowCanvas::focusOutEvent( QFocusEvent *e) {}

void XorWindowCanvas::mousePressEvent( QMouseEvent *e ) {
    //cout << "Mouse pressed! x:" << e->pos().x() << "  y:" << e->pos().y() << endl;
    x = e->pos().x();
    y = e->pos().y();
}

void XorWindowCanvas::mouseReleaseEvent( QMouseEvent *e ) {
    if (mousePressed=true) {
       	Redraw();
    }
}

void XorWindowCanvas::Redraw() {
    xor_play->Redraw();
}

void XorWindowCanvas::keyPressEvent(QKeyEvent *e) {
    //cout << "KEY PRESSED:" << e->key() << endl;
    bool pressed=FALSE;
    int k=e->key();
    if (replay_on==FALSE)
	xor_play->keyPressed(k);
}

void XorWindowCanvas::mouseMoveEvent( QMouseEvent *e ) {
}

void XorWindowCanvas::resizeEvent( QResizeEvent *e ) {
}

void XorWindowCanvas::paintEvent( QPaintEvent *e ) {
    Redraw();
}

void XorWindowCanvas::closeEvent( QCloseEvent *e) {
    QWidget::closeEvent(e);
}

XorWindow::XorWindow( QWidget *parent, const char *name ) : QMainWindow( parent, name ) {
    canvas = new XorWindowCanvas( this );
    setCentralWidget(canvas);
    setCaption("Welcome to Xor!");
    file();
    popup_file  = new QPopupMenu(this);
    popup_level = new QPopupMenu(this);
    popup_replay  = new QPopupMenu(this);
    bool_replay=FALSE;

     //qApp->argv()[1];

    menubar = new QMenuBar(this);
    menubar->insertItem("&Spiel",popup_file);
    menubar->insertItem("&Level",popup_level);
    menubar->insertItem("&Wiedergabe",popup_replay);
    QPixmap replay_start(path()+"/pics/replay_start.bmp");
    replay_index=menubar->insertItem(replay_start,this,SLOT(doReplay()));
    
    popup_replay->insertItem("Wiedergabe &laden",this,SLOT(load()));
   popup_replay->insertItem("W&iedergabe speichern",this,SLOT(save()));
    
    popup_file->insertItem("&Starten",this,SLOT(init()));
    popup_file->insertItem("&Beenden",this,SLOT(quit()));
// Level Nr auslesen
  int level_nr=1;
  char c[100];
  ifstream file_in;
  file_in.open(".level-nr",ios::out);
  file_in.getline(c,100);
  file_in.close();
  sscanf(c,"%i",&level_nr);

  //cout << "CHAR:" << c << "LEVEL NR:" << level_nr <<endl;

// Level Nr auslesen ende

    int i=0;
    for (QStringList::Iterator it = dateien.begin(); it != dateien.end(); ++it) {
        i++;
	if (i<=level_nr) 
	    popup_level->insertItem((*it).latin1(),this,SLOT(setLevel(int)));
    } 
    //popup_help->insertItem("Über Xor!");
    //popup_help->insertItem("Anleitung");
    menubar->show();
}

void XorWindow::draw() {
    canvas->Redraw();
}

void XorWindow::save() {
    QString fileName=QFileDialog::getSaveFileName("newfile.moves","Moves files (*.moves)", this);
    if (!fileName.isNull()) {
	canvas->xor_play->saveMoves((string) fileName);
    }
}

void XorWindow::load() {
    QDir fl;
    QString path=fl.currentDirPath(); //qApp->argv()[1];
    QString fileName=QFileDialog::getOpenFileName(path+"/moves","Moves files (*.moves)", this);
    if (!fileName.isEmpty()) {
   	init();
	canvas->xor_play->loadMoves((string) fileName);
	string a("Xor : ");
	a=a+canvas->xor_play->level_name;
  	setCaption(QString(a.c_str()));

    }
}


void XorWindow::init() {
    canvas->init();
    string a("Xor : ");
    a=a+canvas->xor_play->level_name;
    setCaption(QString(a.c_str()));
}

void XorWindow::quit() {
    close(FALSE);
}

void XorWindow::doReplay() {
    if (canvas->xor_play->countMoves()==0) {
	return;
    }
    canvas->replay_on=TRUE;
    if (bool_replay==FALSE) {
	QPixmap replay_next(path()+"/pics/replay.bmp");
	menubar->changeItem(replay_index,replay_next);
	QPixmap replay_stop(path()+"/pics/replay_stop.bmp");
	replay_stop_item=menubar->insertItem(replay_stop,this,SLOT(endReplay()));
	QPixmap replay_minus(path()+"/pics/replay_minus.bmp");
	replay_minus_item=menubar->insertItem(replay_minus,this,SLOT(replayUntil()));
	string a("Xor : ");
	a=a+canvas->xor_play->level_name+"  REPLAY MODE ON";
	setCaption(QString(a.c_str()));
	canvas->xor_play->doReplay();
	bool_replay=TRUE;
    } else {
	canvas->xor_play->replayNext();
	if (canvas->xor_play->next_step==-1) {
	    endReplay();
	}
    }
}

void XorWindow::endReplay() {
    string a("Xor : ");
    a=a+canvas->xor_play->level_name;
    setCaption(QString(a.c_str()));
    QPixmap replay(path()+"/pics/replay_start.bmp");
    menubar->changeItem(replay_index,replay);
    menubar->removeItem(replay_stop_item);
    menubar->removeItem(replay_minus_item);
    bool_replay=FALSE;
    canvas->replay_on=FALSE;
    if (canvas->xor_play->next_step!=-1) {
	for (int i=canvas->xor_play->next_step;i<MAX_STEP+1;i++) {
	    canvas->xor_play->replay[i]=-1;
	}
    }
}

void XorWindow::replayUntil() {
    //doReplay();
    for (int i=0;i<canvas->xor_play->countMoves()-1;i++)
	doReplay();
    endReplay();
}

void XorWindow::setLevel(int i) {
    string a("level/");
    a=a+ ((string) popup_level->text(i));
    canvas->xor_play->setLevel(a);
    init();
}

void XorWindow::file() {
    QDir d(path()+"/level");
    int anzahl_dateien=0;
    d.setFilter( QDir::Files | QDir::Hidden | QDir::NoSymLinks );
    d.setSorting(QDir::Name);
    const QFileInfoList *list = d.entryInfoList();
    QFileInfoListIterator it( *list ), it2(*list);      // create list iterator
    QFileInfo *fi;                          // pointer for traversing
    while ( (fi=it.current()) ) {           // for each file...
	dateien << fi->fileName().data();
	++it;                               // goto next list element
    }
}

void XorWindow::resizeEvent(QResizeEvent *e) {
    //cout << "RESIZE" << endl;
}
