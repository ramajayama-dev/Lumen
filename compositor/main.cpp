#include "input/InputSubsystem.hpp"
#include "input/InputManager.hpp"

#include <iostream>

int main()
{
    InputSubsystem input;

    if (!input.initialize())
    {
        std::cerr << "Failed to initialize input subsystem\n";
        return 1;
    }

    input.getSeat().setKeyboardFocus(1);

    input.getKeyboard().setFocus(
        input.getSeat().getKeyboardFocus()
    );

    input.getSeat().setKeyboardFocus(2);

    input.getKeyboard().setFocus(
        input.getSeat().getKeyboardFocus()
    );

    InputManager inputManager;

    if (!inputManager.initialize(input.getKeyboard()))
    {
        std::cerr << "Failed to initialize libinput\n";
        return 1;
    }

    std::cout << "LUMEN input subsystem ready\n";

    inputManager.run();

    return 0;
}
