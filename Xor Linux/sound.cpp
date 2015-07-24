#include "sound.h"

Sound::Sound(string s_item) {
    if (QSound::available()==TRUE) {
	cout << "Sound works!" << endl;
    } 
    if (QSound::available()==FALSE) {
	cout << "No Sound available :-( !!" << endl;
    }
    l_sound = new QSound("/home/mario/xor/sounds/bomb.wav");
}

Sound::~Sound() {
    delete(l_sound);
}

void Sound::play() {
    cout << "PLAY:";
    l_sound->play();
    cout << "PLAY END.";
}
