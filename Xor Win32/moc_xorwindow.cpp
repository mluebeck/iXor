/****************************************************************************
** XorWindowCanvas meta object code from reading C++ file 'xorwindow.h'
**
** Created: Mon May 26 16:33:49 2003
**      by: The Qt MOC ($Id: //depot/qt/main/src/moc/moc.y#178 $)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#define Q_MOC_XorWindowCanvas
#if !defined(Q_MOC_OUTPUT_REVISION)
#define Q_MOC_OUTPUT_REVISION 8
#elif Q_MOC_OUTPUT_REVISION != 8
#error "Moc format conflict - please regenerate all moc files"
#endif

#include "xorwindow.h"
#include <qmetaobject.h>
#include <qapplication.h>

#if defined(Q_SPARCWORKS_FUNCP_BUG)
#define Q_AMPERSAND
#else
#define Q_AMPERSAND &
#endif


const char *XorWindowCanvas::className() const
{
    return "XorWindowCanvas";
}

QMetaObject *XorWindowCanvas::metaObj = 0;

void XorWindowCanvas::initMetaObject()
{
    if ( metaObj )
	return;
    if ( strcmp(QWidget::className(), "QWidget") != 0 )
	badSuperclassWarning("XorWindowCanvas","QWidget");
    (void) staticMetaObject();
}

#ifndef QT_NO_TRANSLATION
QString XorWindowCanvas::tr(const char* s)
{
    return ((QNonBaseApplication*)qApp)->translate("XorWindowCanvas",s);
}

#endif // QT_NO_TRANSLATION
QMetaObject* XorWindowCanvas::staticMetaObject()
{
    if ( metaObj )
	return metaObj;
    (void) QWidget::staticMetaObject();
#ifndef QT_NO_PROPERTIES
#endif // QT_NO_PROPERTIES
    QMetaData::Access *slot_tbl_access = 0;
    metaObj = QMetaObject::new_metaobject(
	"XorWindowCanvas", "QWidget",
	0, 0,
	0, 0,
#ifndef QT_NO_PROPERTIES
	0, 0,
	0, 0,
#endif // QT_NO_PROPERTIES
	0, 0 );
    metaObj->set_slot_access( slot_tbl_access );
#ifndef QT_NO_PROPERTIES
#endif // QT_NO_PROPERTIES
    return metaObj;
}


const char *XorWindow::className() const
{
    return "XorWindow";
}

QMetaObject *XorWindow::metaObj = 0;

void XorWindow::initMetaObject()
{
    if ( metaObj )
	return;
    if ( strcmp(QMainWindow::className(), "QMainWindow") != 0 )
	badSuperclassWarning("XorWindow","QMainWindow");
    (void) staticMetaObject();
}

#ifndef QT_NO_TRANSLATION
QString XorWindow::tr(const char* s)
{
    return ((QNonBaseApplication*)qApp)->translate("XorWindow",s);
}

#endif // QT_NO_TRANSLATION
QMetaObject* XorWindow::staticMetaObject()
{
    if ( metaObj )
	return metaObj;
    (void) QMainWindow::staticMetaObject();
#ifndef QT_NO_PROPERTIES
#endif // QT_NO_PROPERTIES
    typedef void(XorWindow::*m1_t0)();
    typedef void(XorWindow::*m1_t1)();
    typedef void(XorWindow::*m1_t2)();
    typedef void(XorWindow::*m1_t3)();
    typedef void(XorWindow::*m1_t4)();
    typedef void(XorWindow::*m1_t5)();
    typedef void(XorWindow::*m1_t6)(int);
    typedef void(XorWindow::*m1_t7)();
    typedef void(XorWindow::*m1_t8)();
    m1_t0 v1_0 = Q_AMPERSAND XorWindow::replayUntil;
    m1_t1 v1_1 = Q_AMPERSAND XorWindow::endReplay;
    m1_t2 v1_2 = Q_AMPERSAND XorWindow::draw;
    m1_t3 v1_3 = Q_AMPERSAND XorWindow::init;
    m1_t4 v1_4 = Q_AMPERSAND XorWindow::quit;
    m1_t5 v1_5 = Q_AMPERSAND XorWindow::doReplay;
    m1_t6 v1_6 = Q_AMPERSAND XorWindow::setLevel;
    m1_t7 v1_7 = Q_AMPERSAND XorWindow::save;
    m1_t8 v1_8 = Q_AMPERSAND XorWindow::load;
    QMetaData *slot_tbl = QMetaObject::new_metadata(9);
    QMetaData::Access *slot_tbl_access = QMetaObject::new_metaaccess(9);
    slot_tbl[0].name = "replayUntil()";
    slot_tbl[0].ptr = *((QMember*)&v1_0);
    slot_tbl_access[0] = QMetaData::Public;
    slot_tbl[1].name = "endReplay()";
    slot_tbl[1].ptr = *((QMember*)&v1_1);
    slot_tbl_access[1] = QMetaData::Public;
    slot_tbl[2].name = "draw()";
    slot_tbl[2].ptr = *((QMember*)&v1_2);
    slot_tbl_access[2] = QMetaData::Public;
    slot_tbl[3].name = "init()";
    slot_tbl[3].ptr = *((QMember*)&v1_3);
    slot_tbl_access[3] = QMetaData::Public;
    slot_tbl[4].name = "quit()";
    slot_tbl[4].ptr = *((QMember*)&v1_4);
    slot_tbl_access[4] = QMetaData::Public;
    slot_tbl[5].name = "doReplay()";
    slot_tbl[5].ptr = *((QMember*)&v1_5);
    slot_tbl_access[5] = QMetaData::Public;
    slot_tbl[6].name = "setLevel(int)";
    slot_tbl[6].ptr = *((QMember*)&v1_6);
    slot_tbl_access[6] = QMetaData::Public;
    slot_tbl[7].name = "save()";
    slot_tbl[7].ptr = *((QMember*)&v1_7);
    slot_tbl_access[7] = QMetaData::Public;
    slot_tbl[8].name = "load()";
    slot_tbl[8].ptr = *((QMember*)&v1_8);
    slot_tbl_access[8] = QMetaData::Public;
    metaObj = QMetaObject::new_metaobject(
	"XorWindow", "QMainWindow",
	slot_tbl, 9,
	0, 0,
#ifndef QT_NO_PROPERTIES
	0, 0,
	0, 0,
#endif // QT_NO_PROPERTIES
	0, 0 );
    metaObj->set_slot_access( slot_tbl_access );
#ifndef QT_NO_PROPERTIES
#endif // QT_NO_PROPERTIES
    return metaObj;
}
