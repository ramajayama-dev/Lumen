#pragma once

class Seat
{
public:
    Seat();

    void initialize();

    void setKeyboardFocus(int clientId);

    int getKeyboardFocus() const;

private:
    bool keyboardAttached;
    int keyboardFocus;
};
