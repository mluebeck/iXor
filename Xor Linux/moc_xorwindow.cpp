/****************************************************************************
** XorWindowCanvas meta object code from reading C++ file 'xorwindow.h'
**
** Created: Sat May 24 22:29:12 2003
**      by: The Qt MOC ($Id:  qt/moc_yacc.cpp   3.0.3   edited Mar 18 10:45 $)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#undef QT_NO_COMPAT
#include "xorwindow.h"
#include <qmetaobject.h>
#include <qapplication.h>

#include <private/qucomextra_p.h>
#if !defined(Q_MOC_OUTPUT_REVISION) || (Q_MOC_OUTPUT_REVISION != 19)
#error "This file was generated using the moc from 3.0.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

const char *XorWindowCanvas::className() const
{
    return "XorWindowCanvas";
}

QMetaObject *XorWindowCanvas::metaObj = 0;
static QMetaObjectCleanUp cleanUp_XorWindowCanvas;

#ifndef QT_NO_TRANSLATION
QString XorWindowCanvas::tr( const char *s, const char *c )
{
    if ( qApp )
	return qApp->translate( "XorWindowCanvas", s, c, QApplication::DefaultCodec );
    else
	return QString::fromLatin1( s );
}
#ifndef QT_NO_TRANSLATION_UTF8
QString XorWindowCanvas::trUtf8( const char *s, const char *c )
{
    if ( qApp )
	return qApp->translate( "XorWindowCanvas", s, c, QApplication::UnicodeUTF8 );
    else
	return QString::fromUtf8( s );
}
#endif // QT_NO_TRANSLATION_UTF8

#endif // QT_NO_TRANSLATION

QMetaObject* XorWindowCanvas::staticMetaObject()
{
    if ( metaObj )
	return metaObj;
    QMetaObject* parentObject = QWidget::staticMetaObject();
    metaObj = QMetaObject::new_metaobject(
	"XorWindowCanvas", parentObject,
	0, 0,
	0, 0,
#ifndef QT_NO_PROPERTIES
	0, 0,
	0, 0,
#endif // QT_NO_PROPERTIES
	0, 0 );
    cleanUp_XorWindowCanvas.setMetaObject( metaObj );
    return metaObj;
}

void* XorWindowCanvas::qt_cast( const char* clname )
{
    if ( !qstrcmp( clname, "XorWindowCanvas" ) ) return (XorWindowCanvas*)this;
    return QWidget::qt_cast( clname );
}

bool XorWindowCanvas::qt_invoke( int _id, QUObject* _o )
{
    return QWidget::qt_invoke(_id,_o);
}

bool XorWindowCanvas::qt_emit( int _id, QUObject* _o )
{
    return QWidget::qt_emit(_id,_o);
}
#ifndef QT_NO_PROPERTIES

bool XorWindowCanvas::qt_property( int _id, int _f, QVariant* _v)
{
    return QWidget::qt_property( _id, _f, _v);
}
#endif // QT_NO_PROPERTIES


const char *XorWindow::className() const
{
    return "XorWindow";
}

QMetaObject *XorWindow::metaObj = 0;
static QMetaObjectCleanUp cleanUp_XorWindow;

#ifndef QT_NO_TRANSLATION
QString XorWindow::tr( const char *s, const char *c )
{
    if ( qApp )
	return qApp->translate( "XorWindow", s, c, QApplication::DefaultCodec );
    else
	return QString::fromLatin1( s );
}
#ifndef QT_NO_TRANSLATION_UTF8
QString XorWindow::trUtf8( const char *s, const char *c )
{
    if ( qApp )
	return qApp->translate( "XorWindow", s, c, QApplication::UnicodeUTF8 );
    else
	return QString::fromUtf8( s );
}
#endif // QT_NO_TRANSLATION_UTF8

#endif // QT_NO_TRANSLATION

QMetaObject* XorWindow::staticMetaObject()
{
    if ( metaObj )
	return metaObj;
    QMetaObject* parentObject = QMainWindow::staticMetaObject();
    static const QUMethod slot_0 = {"replayUntil", 0, 0 };
    static const QUMethod slot_1 = {"endReplay", 0, 0 };
    static const QUMethod slot_2 = {"draw", 0, 0 };
    static const QUMethod slot_3 = {"init", 0, 0 };
    static const QUMethod slot_4 = {"quit", 0, 0 };
    static const QUMethod slot_5 = {"doReplay", 0, 0 };
    static const QUParameter param_slot_6[] = {
	{ 0, &static_QUType_int, 0, QUParameter::In }
    };
    static const QUMethod slot_6 = {"setLevel", 1, param_slot_6 };
    static const QUMethod slot_7 = {"save", 0, 0 };
    static const QUMethod slot_8 = {"load", 0, 0 };
    static const QMetaData slot_tbl[] = {
	{ "replayUntil()", &slot_0, QMetaData::Public },
	{ "endReplay()", &slot_1, QMetaData::Public },
	{ "draw()", &slot_2, QMetaData::Public },
	{ "init()", &slot_3, QMetaData::Public },
	{ "quit()", &slot_4, QMetaData::Public },
	{ "doReplay()", &slot_5, QMetaData::Public },
	{ "setLevel(int)", &slot_6, QMetaData::Public },
	{ "save()", &slot_7, QMetaData::Public },
	{ "load()", &slot_8, QMetaData::Public }
    };
    metaObj = QMetaObject::new_metaobject(
	"XorWindow", parentObject,
	slot_tbl, 9,
	0, 0,
#ifndef QT_NO_PROPERTIES
	0, 0,
	0, 0,
#endif // QT_NO_PROPERTIES
	0, 0 );
    cleanUp_XorWindow.setMetaObject( metaObj );
    return metaObj;
}

void* XorWindow::qt_cast( const char* clname )
{
    if ( !qstrcmp( clname, "XorWindow" ) ) return (XorWindow*)this;
    return QMainWindow::qt_cast( clname );
}

bool XorWindow::qt_invoke( int _id, QUObject* _o )
{
    switch ( _id - staticMetaObject()->slotOffset() ) {
    case 0: replayUntil(); break;
    case 1: endReplay(); break;
    case 2: draw(); break;
    case 3: init(); break;
    case 4: quit(); break;
    case 5: doReplay(); break;
    case 6: setLevel(static_QUType_int.get(_o+1)); break;
    case 7: save(); break;
    case 8: load(); break;
    default:
	return QMainWindow::qt_invoke( _id, _o );
    }
    return TRUE;
}

bool XorWindow::qt_emit( int _id, QUObject* _o )
{
    return QMainWindow::qt_emit(_id,_o);
}
#ifndef QT_NO_PROPERTIES

bool XorWindow::qt_property( int _id, int _f, QVariant* _v)
{
    return QMainWindow::qt_property( _id, _f, _v);
}
#endif // QT_NO_PROPERTIES
