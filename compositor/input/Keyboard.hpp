#pragma once

#include <cstdint>
#include <atomic>
#include <thread>

#include <libinput.h>

class Keyboard
{
public:
    Keyboard();
    ~Keyboard();

    bool initialize();

    void processEvent(struct libinput_event* event);

    void setFocus(int clientId);

private:
    void repeatLoop();

    bool initialized;

    std::atomic<bool> keyHeld;
    std::atomic<bool> running;

    uint32_t repeatingKey;
    int focusedClient;

    std::thread repeatThread;
};
