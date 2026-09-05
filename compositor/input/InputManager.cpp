#include "InputManager.hpp"

#include "Keyboard.hpp"

#include <libudev.h>

#include <fcntl.h>
#include <unistd.h>

#include <iostream>

static int openRestricted(
    const char* path,
    int flags,
    void* /*userData*/)
{
    int fd = open(path, flags);

    if (fd < 0)
    {
        std::cerr << "Failed to open input device: "
                  << path << '\n';
    }

    return fd;
}

static void closeRestricted(
    int fd,
    void* /*userData*/)
{
    close(fd);
}

static const struct libinput_interface interface =
{
    .open_restricted = openRestricted,
    .close_restricted = closeRestricted
};

InputManager::InputManager()
    : context(nullptr),
      keyboard(nullptr)
{
}

InputManager::~InputManager()
{
    if (context != nullptr)
    {
        libinput_unref(context);
        context = nullptr;
    }
}

bool InputManager::initialize(Keyboard& keyboard)
{
    this->keyboard = &keyboard;

    struct udev* udev = udev_new();

    if (udev == nullptr)
    {
        std::cerr << "Failed to create udev context\n";
        return false;
    }

    context = libinput_udev_create_context(
        &interface,
        nullptr,
        udev
    );

    if (context == nullptr)
    {
        std::cerr << "Failed to create libinput context\n";
        udev_unref(udev);
        return false;
    }

    if (libinput_udev_assign_seat(context, "seat0") != 0)
    {
        std::cerr << "Failed to assign libinput seat\n";

        libinput_unref(context);
        context = nullptr;

        udev_unref(udev);
        return false;
    }

    udev_unref(udev);

    std::cout << "Libinput initialized\n";

    return true;
}

void InputManager::run()
{
    if (context == nullptr || keyboard == nullptr)
        return;

    std::cout << "LUMEN listening for keyboard events...\n";

    while (true)
    {
        if (libinput_dispatch(context) != 0)
        {
            std::cerr << "libinput dispatch failed\n";
            break;
        }

        struct libinput_event* event;

        while ((event = libinput_get_event(context)) != nullptr)
        {
            keyboard->processEvent(event);

            libinput_event_destroy(event);
        }

        usleep(10000);
    }
}
