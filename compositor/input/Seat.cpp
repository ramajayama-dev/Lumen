#include "Seat.hpp"

Seat::Seat()
    : keyboardAttached(false),
      keyboardFocus(-1)
{
}

void Seat::initialize()
{
    keyboardAttached = true;
}

void Seat::setKeyboardFocus(int clientId)
{
    keyboardFocus = clientId;
}

int Seat::getKeyboardFocus() const
{
    return keyboardFocus;
}
