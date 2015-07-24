#include <qstring.h>
#include <qpainter.h>
#include <qfont.h>
#include <qpixmap.h>
#include "graphics.h"

Sprite::Sprite() {
    sp=new QPixmap;
}

Sprite::Sprite(int i, int j) {
    sp = new QPixmap(i,j);
}

Sprite::Sprite(string name) {
    sp = new QPixmap(name.c_str());
}

bool Sprite::Load(string name) {
    return sp->load(name.c_str());
}

Sprite::~Sprite() {
    delete(sp);
}

Graphics::Graphics() {
    play_buffer=new Sprite;
   widget=new QWidget;
}

Graphics::Graphics(QWidget *w,Sprite *p) {
    play_buffer = p;
    widget = w;
}

Graphics::~Graphics() {}

void Graphics::Paint() {
    bitBlt( widget,0, 0, play_buffer->sp,0,0, play_buffer->sp->width(), play_buffer->sp->height() );
}

void Graphics::Paint(Sprite *s, int ziel_x, int ziel_y, int quell_x, int quell_y, int quell_breite, int quell_hoehe) {
    bitBlt(play_buffer->sp,ziel_x,ziel_y,s->sp,quell_x,quell_y,quell_breite,quell_hoehe);
};

void Graphics::Rect(int x,int y,int h, int w) {
    bitBlt(play_buffer->sp,x,y,play_buffer->sp,x,y,h,w,Qt::NotOrROP);
}

void Graphics::RectRed(int x,int y,int h,int w) {
    QPixmap *red = new QPixmap(100,30);
    red->fill(Qt::red);
    bitBlt(play_buffer->sp,x,y,red,0,0,h,w);
}

void Graphics::Write(string s,int x,int y) {
	QPainter painter;
	painter.begin(play_buffer->sp);
	painter.setFont( QFont( "times",24 ) );
	painter.drawText(x,y,s.c_str());
	painter.end();
}

void Graphics::Clear() {
    play_buffer->sp->fill(Qt::white);
}
