#include <stdio.h>
#include <qdir.h>


#include <qapplication.h>
#include <iostream.h>
#include "xorwindow.h"
int main( int argc, char **argv ){
    if (argc==1) {

	QDir fl;
	//cout << "No working directory specified!" << endl;
	//cout << "Taking " << fl.currentDirPath() << endl;
		
    }
    QApplication xorapp( argc, argv );
    XorWindow xorwindow;
    xorwindow.resize( 455, 350 );
    xorwindow.setGeometry(100,100,455,350);
    xorapp.setMainWidget( &xorwindow );
    if ( QApplication::desktop()->width() > 550
	 && QApplication::desktop()->height() > 366 )
	xorwindow.show();
    else
	xorwindow.showMaximized();
    return xorapp.exec();
}

