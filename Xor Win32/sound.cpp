#include <iostream.h>
#include "sound.h"

Sound::Sound(QString s_item) {
    if (QSound::available()==TRUE) {
	cout << "Sound works!" << endl;
    } 
    if (QSound::available()==FALSE) {
	cout << "No Sound available :-( !!" << endl;
    }
    l_sound = new QSound(s_item);
}

Sound::~Sound() {
    delete(l_sound);
}

void Sound::play() {
    cout << "PLAY:";
    l_sound->play();
    cout << "PLAY END.";
}
