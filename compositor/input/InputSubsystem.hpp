#pragma once

#include "Keyboard.hpp"
#include "Seat.hpp"

class InputSubsystem
{
public:
    InputSubsystem();

    bool initialize();

    Keyboard& getKeyboard();
    Seat& getSeat();

private:
    Keyboard keyboard;
    Seat seat;
};
