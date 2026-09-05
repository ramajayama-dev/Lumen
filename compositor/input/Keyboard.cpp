#include "Keyboard.hpp"

#include <iostream>
#include <chrono>

Keyboard::Keyboard()
    : initialized(false),
      keyHeld(false),
      running(false),
      repeatingKey(0),
      focusedClient(-1)
{
}

Keyboard::~Keyboard()
{
    running = false;

    if (repeatThread.joinable())
        repeatThread.join();
}

bool Keyboard::initialize()
{
    initialized = true;

    running = true;
    repeatThread = std::thread(&Keyboard::repeatLoop, this);

    std::cout << "Keyboard initialized\n";

    return true;
}

void Keyboard::setFocus(int clientId)
{
    focusedClient = clientId;

    std::cout << "Keyboard focus set to client: "
              << focusedClient
              << '\n';
}

void Keyboard::processEvent(struct libinput_event* event)
{
    if (event == nullptr)
        return;

    if (libinput_event_get_type(event) !=
        LIBINPUT_EVENT_KEYBOARD_KEY)
    {
        return;
    }

    auto* keyboardEvent =
        libinput_event_get_keyboard_event(event);

    uint32_t key =
        libinput_event_keyboard_get_key(keyboardEvent);

    auto state =
        libinput_event_keyboard_get_key_state(keyboardEvent);

    if (focusedClient == -1)
    {
        std::cout << "No keyboard focus\n";
        return;
    }

    if (state == LIBINPUT_KEY_STATE_PRESSED)
    {
        std::cout << "Key pressed: "
                  << key
                  << " -> Client "
                  << focusedClient
                  << '\n';

        repeatingKey = key;
        keyHeld = true;
    }
    else if (state == LIBINPUT_KEY_STATE_RELEASED)
    {
        std::cout << "Key released: "
                  << key
                  << " -> Client "
                  << focusedClient
                  << '\n';

        if (key == repeatingKey)
        {
            keyHeld = false;
        }
    }
}

void Keyboard::repeatLoop()
{
    while (running)
    {
        if (keyHeld)
        {
            std::this_thread::sleep_for(
                std::chrono::milliseconds(500)
            );

            if (!keyHeld || !running)
                continue;

            while (keyHeld && running)
            {
                std::cout << "Key repeat: "
                          << repeatingKey
                          << " -> Client "
                          << focusedClient
                          << '\n';

                std::this_thread::sleep_for(
                    std::chrono::milliseconds(50)
                );
            }
        }
        else
        {
            std::this_thread::sleep_for(
                std::chrono::milliseconds(10)
            );
        }
    }
}
