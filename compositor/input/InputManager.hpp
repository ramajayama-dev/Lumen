#pragma once

#include <libinput.h>

class Keyboard;

class InputManager
{
public:
    InputManager();
    ~InputManager();

    bool initialize(Keyboard& keyboard);
    void run();

private:
    struct libinput* context;
    Keyboard* keyboard;
};
