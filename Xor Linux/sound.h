#include <qsound.h>
#include <string>

class Sound {
 private:
    QSound *l_sound;
 public:
    Sound(string);
    ~Sound();
    void play();
};
