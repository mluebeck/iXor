#include <qsound.h>
#include <string>

class Sound {
 private:
    QSound *l_sound;
 public:
    Sound(QString);
    ~Sound();
    void play();
};
