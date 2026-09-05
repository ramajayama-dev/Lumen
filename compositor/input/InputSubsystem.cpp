#include "InputSubsystem.hpp"

InputSubsystem::InputSubsystem()
{
}

bool InputSubsystem::initialize()
{
    seat.initialize();

    if (!keyboard.initialize())
        return false;

    return true;
}

Keyboard& InputSubsystem::getKeyboard()
{
    return keyboard;
}

Seat& InputSubsystem::getSeat()
{
    return seat;
}
