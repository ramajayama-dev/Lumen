# LUMEN Keyboard Input Subsystem

> Keyboard input subsystem for the LUMEN Wayland compositor.

---

## Table of Contents

- [Overview](#overview)
- [Purpose](#purpose)
- [Keyboard Input Architecture](#keyboard-input-architecture)
- [Complete Input Flow](#complete-input-flow)
- [Linux Input System](#linux-input-system)
- [Linux Input Subsystem](#linux-input-subsystem)
- [evdev](#evdev)
- [Input Device Nodes](#input-device-nodes)
- [libinput](#libinput)
- [Why LUMEN Uses libinput](#why-lumen-uses-libinput)
- [Keyboard Event Flow](#keyboard-event-flow)
- [LUMEN Input Architecture](#lumen-input-architecture)
- [Project Structure](#project-structure)
- [InputSubsystem](#inputsubsystem)
- [InputManager](#inputmanager)
- [Keyboard](#keyboard)
- [Seat](#seat)
- [Keyboard Event Processing](#keyboard-event-processing)
- [Key Press Handling](#key-press-handling)
- [Key Release Handling](#key-release-handling)
- [Keyboard Focus](#keyboard-focus)
- [Focus Switching](#focus-switching)
- [Event Routing](#event-routing)
- [Basic Key Repeat](#basic-key-repeat)
- [Initialization Flow](#initialization-flow)
- [Runtime Event Loop](#runtime-event-loop)
- [Build System](#build-system)
- [Running LUMEN](#running-lumen)
- [Permissions](#permissions)
- [Testing](#testing)
- [Test Results](#test-results)
- [Debugging](#debugging)
- [Current Implementation](#current-implementation)
- [Current Limitations](#current-limitations)
- [Future Wayland Integration](#future-wayland-integration)
- [Future xkbcommon Integration](#future-xkbcommon-integration)
- [Production Architecture](#production-architecture)
- [Development Notes](#development-notes)
- [Conclusion](#conclusion)

---

# Overview

The LUMEN Keyboard Input Subsystem is responsible for receiving
keyboard events from the Linux operating system and preparing those
events for delivery to the currently focused application.

The current implementation establishes the foundation required for
keyboard input inside the LUMEN compositor.

The subsystem currently supports:

- Keyboard initialization
- Linux input device access through libinput
- Keyboard event detection
- Key press detection
- Key release detection
- Keyboard focus
- Focus switching
- Basic keyboard event routing
- Basic key-repeat
- Runtime event processing
- Keyboard input testing

The current implementation is a **foundation implementation**.

It is not yet the final Wayland keyboard protocol implementation.

---

# Purpose

The purpose of this subsystem is to provide a clear path between the
physical keyboard and the application that currently owns keyboard
focus.

The desired high-level flow is:

```text
Physical Keyboard
       |
       v
Linux Kernel
       |
       v
Linux Input Subsystem
       |
       v
evdev
       |
       v
libinput
       |
       v
LUMEN InputManager
       |
       v
LUMEN Keyboard
       |
       v
LUMEN Seat
       |
       v
Keyboard Focus
       |
       v
Focused Wayland Client
```

The input subsystem separates:

1. Device input
2. Keyboard event processing
3. Seat state
4. Keyboard focus
5. Event routing
6. Future Wayland client delivery

This separation makes the input system easier to extend later.

---

# Keyboard Input Architecture

The current LUMEN input architecture is:

```text
                     LUMEN
                       |
                       v
              +----------------+
              | InputSubsystem |
              +-------+--------+
                      |
             +--------+--------+
             |                 |
             v                 v
      +------------+     +----------+
      |  Keyboard  |     |   Seat   |
      +------------+     +----------+
             ^                 |
             |                 |
             |                 v
      +------------+     Keyboard Focus
      | InputManager|           |
      +------+-----+            |
             |                  |
             v                  v
          libinput        Focused Client
```

`InputManager` receives events from libinput.

`Keyboard` processes keyboard-specific events.

`Seat` stores keyboard state such as the current keyboard focus.

The combination provides the foundation for routing keyboard input to
the correct client.

---

# Complete Input Flow

The complete current input path is:

```text
1. User presses a physical key
            |
            v
2. Keyboard hardware generates an input signal
            |
            v
3. Linux kernel receives the hardware input
            |
            v
4. Linux input subsystem processes the event
            |
            v
5. evdev exposes the event to userspace
            |
            v
6. libinput reads and processes the event
            |
            v
7. LUMEN InputManager dispatches the event
            |
            v
8. InputManager obtains the libinput event
            |
            v
9. Keyboard::processEvent() receives the event
            |
            v
10. Keyboard determines press/release state
            |
            v
11. Keyboard checks keyboard focus
            |
            v
12. Event is associated with focused client
```

Current implementation:

```text
Keyboard
   ↓
Linux Kernel
   ↓
evdev
   ↓
libinput
   ↓
InputManager
   ↓
Keyboard
   ↓
Seat
   ↓
Focused Client ID
```

Future implementation:

```text
Keyboard
   ↓
Linux Kernel
   ↓
evdev
   ↓
libinput
   ↓
InputManager
   ↓
Keyboard
   ↓
Seat
   ↓
xkbcommon
   ↓
wl_keyboard
   ↓
Wayland Client
```

---

# Linux Input System

LUMEN does not communicate directly with keyboard hardware.

Linux provides an input subsystem that abstracts hardware devices.

The kernel is responsible for handling hardware-level input and
exposing input events to userspace.

The simplified architecture is:

```text
Physical Keyboard
       |
       v
Keyboard Driver
       |
       v
Linux Input Core
       |
       v
Input Event Handler
       |
       v
evdev
       |
       v
/dev/input/event*
```

The Linux input subsystem allows userspace applications and libraries
to consume standardized input events.

---

# Linux Input Subsystem

The Linux input subsystem handles different types of input devices.

Examples include:

- Keyboards
- Mice
- Touchpads
- Touchscreens
- Game controllers
- Other input devices

Keyboard events are represented using Linux input event types.

Common event types include:

```text
EV_KEY
EV_REL
EV_ABS
EV_SYN
```

For keyboard input, the most important event type is:

```text
EV_KEY
```

A synchronization event is represented by:

```text
EV_SYN
```

This allows input events to be grouped into logical event packets.

---

# evdev

evdev is the Linux userspace input event interface.

Keyboard devices are exposed through device nodes such as:

```text
/dev/input/event0
/dev/input/event1
/dev/input/event2
```

The exact device number depends on the system.

LUMEN does not currently implement its own low-level evdev event
parser.

Instead, LUMEN uses libinput, which provides a higher-level interface
for compositor input handling.

The simplified relationship is:

```text
Linux Input Subsystem
        |
        v
      evdev
        |
        v
    /dev/input/*
        |
        v
     libinput
        |
        v
      LUMEN
```

---

# Input Device Nodes

Linux input devices can be inspected using:

```bash
ls /dev/input/
```

Example:

```text
event0
event1
event2
event3
...
```

The devices can also be inspected using:

```bash
cat /proc/bus/input/devices
```

This provides information about registered input devices.

---

# libinput

libinput is a userspace input library commonly used by Wayland
compositors.

LUMEN uses libinput as the primary input interface.

libinput provides functionality such as:

- Input device discovery
- Device initialization
- Device management
- Keyboard events
- Pointer events
- Touchpad events
- Touch events
- Device hotplug handling
- Input event processing

For LUMEN keyboard input, libinput converts Linux input events into
libinput events that can be consumed by the compositor.

---

# Why LUMEN Uses libinput

Directly reading `/dev/input/event*` would require LUMEN to handle many
low-level responsibilities itself.

Using libinput gives the compositor a higher-level input abstraction.

The desired architecture is:

```text
Linux Kernel
     |
     v
   evdev
     |
     v
 libinput
     |
     v
  LUMEN
```

Instead of:

```text
Linux Kernel
     |
     v
   evdev
     |
     v
LUMEN custom input parser
     |
     v
LUMEN custom device handling
     |
     v
LUMEN custom input management
```

libinput therefore reduces the amount of low-level device-management
logic that the compositor needs to implement.

---

# Keyboard Event Flow

When LUMEN is running, the `InputManager` continuously checks for
input events.

The basic flow is:

```text
libinput_dispatch()
        |
        v
libinput_get_event()
        |
        v
Check event type
        |
        v
LIBINPUT_EVENT_KEYBOARD_KEY
        |
        v
Get keyboard event
        |
        v
Get key code
        |
        v
Get key state
        |
        v
Keyboard::processEvent()
```

---

# LUMEN Input Architecture

The current implementation contains four main components:

```text
InputSubsystem
InputManager
Keyboard
Seat
```

Their responsibilities are separated.

```text
+----------------+
| InputSubsystem |
+-------+--------+
        |
        +----------------+
        |                |
        v                v
   +---------+       +--------+
   | Keyboard|       |  Seat  |
   +---------+       +--------+

InputManager
     |
     v
 libinput
```

---

# Project Structure

The current input subsystem is located at:

```text
compositor/input/
```

Current structure:

```text
compositor/
└── input/
    ├── InputManager.cpp
    ├── InputManager.hpp
    ├── InputSubsystem.cpp
    ├── InputSubsystem.hpp
    ├── Keyboard.cpp
    ├── Keyboard.hpp
    ├── Seat.cpp
    └── Seat.hpp
```

---

# InputSubsystem

Files:

```text
InputSubsystem.hpp
InputSubsystem.cpp
```

`InputSubsystem` is the high-level container for the keyboard input
foundation.

It owns:

```text
Keyboard
Seat
```

Its responsibility is to initialize these components and expose them
to the compositor.

The structure is:

```text
InputSubsystem
├── Keyboard
└── Seat
```

Initialization flow:

```text
InputSubsystem::initialize()
        |
        +----> Seat::initialize()
        |
        +----> Keyboard::initialize()
```

---

# InputManager

Files:

```text
InputManager.hpp
InputManager.cpp
```

`InputManager` is responsible for connecting LUMEN to libinput.

It manages:

- libinput context
- udev context
- libinput seat assignment
- event dispatch
- event retrieval
- forwarding keyboard events

The initialization sequence is:

```text
Create udev context
        |
        v
Create libinput context
        |
        v
Assign libinput to seat0
        |
        v
Input system ready
```

---

# InputManager Initialization

The current implementation creates a udev context:

```cpp
struct udev* udev = udev_new();
```

Then it creates the libinput context:

```cpp
context = libinput_udev_create_context(
    &interface,
    nullptr,
    udev
);
```

The libinput context is assigned to:

```text
seat0
```

using:

```cpp
libinput_udev_assign_seat(context, "seat0")
```

Once initialization succeeds:

```text
Libinput initialized
```

is printed.

---

# Restricted Device Access

The current learning implementation provides libinput with callbacks
for opening and closing input device file descriptors.

The open callback uses:

```cpp
open()
```

The close callback uses:

```cpp
close()
```

This is sufficient for the current development environment.

Production compositor device access should eventually use an
appropriate seat-management mechanism such as libseat/logind rather
than relying on manually granted device permissions.

---

# Keyboard

Files:

```text
Keyboard.hpp
Keyboard.cpp
```

The `Keyboard` class is responsible for keyboard-specific processing.

Current responsibilities:

```text
Keyboard
├── Initialization
├── Event processing
├── Key press detection
├── Key release detection
├── Keyboard focus
└── Basic key repeat
```

---

# Keyboard State

The current keyboard module maintains state including:

```text
initialized
keyHeld
running
repeatingKey
focusedClient
repeatThread
```

The important concepts are:

### initialized

Indicates whether the keyboard subsystem has been initialized.

### keyHeld

Tracks whether a key is currently being held for basic repeat.

### repeatingKey

Stores the key currently being repeated.

### focusedClient

Stores the client currently receiving keyboard focus.

### repeatThread

Runs the current basic key-repeat mechanism.

---

# Keyboard Event Processing

Keyboard events are processed through:

```cpp
Keyboard::processEvent()
```

The first check verifies that the event is not null.

Then LUMEN checks whether the event type is:

```cpp
LIBINPUT_EVENT_KEYBOARD_KEY
```

Non-keyboard events are ignored by the keyboard module.

---

# Key Code

The Linux/libinput keyboard event provides a key code.

The current implementation obtains it using:

```cpp
libinput_event_keyboard_get_key()
```

The key code is currently printed directly.

For example:

```text
Key pressed: 30
```

The current system does not yet convert this physical key code into a
human-readable keyboard symbol.

For example:

```text
30
```

has not yet been converted into:

```text
a
```

That conversion belongs to the future xkbcommon integration.

---

# Key Press Handling

A key press is detected using:

```cpp
LIBINPUT_KEY_STATE_PRESSED
```

When the event is received, LUMEN checks whether a keyboard focus
exists.

If no focus exists:

```text
No keyboard focus
```

is reported.

If a focus exists, LUMEN reports:

```text
Key pressed: <key> -> Client <client>
```

Example:

```text
Key pressed: 42 -> Client 2
```

This means:

```text
Key 42
   |
   v
Keyboard
   |
   v
Focused Client = 2
```

---

# Key Release Handling

A key release is detected using:

```cpp
LIBINPUT_KEY_STATE_RELEASED
```

The event is reported as:

```text
Key released: <key> -> Client <client>
```

Example:

```text
Key released: 42 -> Client 2
```

When the released key matches the currently repeating key, the repeat
state is stopped.

---

# Keyboard Focus

Keyboard focus determines which client receives keyboard input.

The current `Seat` stores keyboard focus as a client ID.

The initial state is:

```text
keyboardFocus = -1
```

This means:

```text
No keyboard focus
```

A focus can be assigned:

```cpp
input.getSeat().setKeyboardFocus(1);
```

The current focus can be read using:

```cpp
input.getSeat().getKeyboardFocus();
```

The keyboard receives the focus using:

```cpp
input.getKeyboard().setFocus(
    input.getSeat().getKeyboardFocus()
);
```

---

# Seat

Files:

```text
Seat.hpp
Seat.cpp
```

The `Seat` represents the input seat used by the compositor.

The current foundation stores:

```text
keyboardAttached
keyboardFocus
```

The seat provides:

```cpp
initialize()
```

```cpp
hasKeyboard()
```

```cpp
setKeyboardFocus()
```

```cpp
getKeyboardFocus()
```

---

# Seat Initialization

During input subsystem initialization:

```cpp
seat.initialize();
```

The current foundation marks the keyboard as attached.

This provides a simple abstraction that can later be expanded to
support real seat/device state.

---

# Focus Switching

Keyboard focus can be changed.

The current test performs:

```cpp
input.getSeat().setKeyboardFocus(1);

input.getKeyboard().setFocus(
    input.getSeat().getKeyboardFocus()
);
```

Then changes the focus:

```cpp
input.getSeat().setKeyboardFocus(2);

input.getKeyboard().setFocus(
    input.getSeat().getKeyboardFocus()
);
```

The runtime output confirms:

```text
Keyboard focus set to client: 1
Keyboard focus set to client: 2
```

After switching focus, keyboard events are associated with Client 2.

Example:

```text
Key pressed: 42 -> Client 2
Key released: 42 -> Client 2
```

---

# Event Routing

The current routing model is:

```text
             Keyboard Event
                    |
                    v
               Keyboard
                    |
                    v
            Current Focus
                    |
                    v
             Focused Client
```

Example:

```text
Key pressed: 42 -> Client 2
```

This confirms that the keyboard module uses the current focus when
processing the event.

Important:

The current client ID is only a **foundation/test representation**.

It is not yet an actual Wayland client object.

---

# Basic Key Repeat

LUMEN currently implements a basic learning-level keyboard repeat
system.

The current behavior is:

```text
Key Press
    |
    v
Wait 500 ms
    |
    v
Start Repeat
    |
    v
Repeat every 50 ms
    |
    v
Key Release
    |
    v
Stop Repeat
```

---

# Key Repeat Implementation

The current implementation uses:

```cpp
std::thread
```

and:

```cpp
std::chrono
```

The repeat loop waits for the initial delay.

Current initial delay:

```text
500 milliseconds
```

The repeat interval is:

```text
50 milliseconds
```

This means the approximate behavior is:

```text
PRESS
 |
 +---- 500 ms ----+
                   |
                   v
                REPEAT
                   |
             +-----+-----+
             |     |     |
            50ms  50ms  50ms
             |     |     |
             v     v     v
           Repeat Repeat Repeat
```

---

# Key Repeat Example

A successful test produced output similar to:

```text
Key pressed: 42 -> Client 2
Key repeat: 42 -> Client 2
Key repeat: 42 -> Client 2
Key repeat: 42 -> Client 2
Key released: 42 -> Client 2
```

This confirms that:

1. The key was detected.
2. The key remained held.
3. Repeat events were generated.
4. The repeat events used the focused client.
5. Releasing the key stopped the repeat.

---

# Initialization Flow

The LUMEN application starts with:

```cpp
InputSubsystem input;
```

Then:

```cpp
input.initialize();
```

The initialization flow is:

```text
main()
  |
  v
InputSubsystem
  |
  +----> Seat initialization
  |
  +----> Keyboard initialization
  |
  v
InputManager
  |
  v
libinput initialization
  |
  v
seat0 assignment
  |
  v
Input system ready
```

---

# Runtime Event Loop

After initialization, LUMEN starts the input loop:

```cpp
inputManager.run();
```

The current loop continuously performs:

```text
while running
      |
      v
libinput_dispatch()
      |
      v
libinput_get_event()
      |
      v
Is event keyboard?
      |
      +---- No ----> Ignore
      |
      +---- Yes
             |
             v
       Keyboard::processEvent()
             |
             v
       Check key state
             |
       +-----+------+
       |            |
       v            v
    Press        Release
       |            |
       +-----+------+
             |
             v
       Current Focus
```

Each processed libinput event is destroyed after handling.

---

# Build System

The keyboard input implementation is included in the LUMEN CMake
build.

The executable currently contains:

```text
compositor/main.cpp
compositor/input/InputSubsystem.cpp
compositor/input/InputManager.cpp
compositor/input/Keyboard.cpp
compositor/input/Seat.cpp
```

The project links against:

```text
input
udev
Threads
```

The C++ standard is:

```text
C++20
```

---

# Building LUMEN

Configure the project:

```bash
cmake -S . -B build
```

Build the project:

```bash
cmake --build build
```

Successful output:

```text
[100%] Built target lumen
```

---

# Running LUMEN

Run the executable:

```bash
./build/lumen
```

Expected startup output:

```text
Keyboard initialized
Keyboard focus set to client: 1
Keyboard focus set to client: 2
Libinput initialized
LUMEN input subsystem ready
LUMEN listening for keyboard events...
```

Keyboard events can then be generated by pressing keys.

---

# Permissions

Linux input device nodes normally have restricted permissions.

For example:

```text
crw-rw----. 1 root input ... /dev/input/event0
```

The device belongs to the:

```text
input
```

group.

During development, the user running LUMEN may need appropriate
permissions to access the input devices.

The development environment used:

```bash
sudo usermod -aG input <username>
```

After changing group membership, a new session or group refresh is
required.

For example:

```bash
newgrp input
```

The group membership can be checked using:

```bash
groups
```

---

# Testing

The keyboard subsystem was tested at multiple levels.

---

## Test 1 — Linux Input Devices

Input devices were inspected using:

```bash
ls /dev/input/
```

This confirms that Linux exposes input device nodes.

---

## Test 2 — Linux Input Device Information

The registered input devices were inspected using:

```bash
cat /proc/bus/input/devices
```

This confirms that the keyboard is registered with the Linux input
system.

---

## Test 3 — libinput Device Detection

libinput devices were inspected using:

```bash
sudo libinput list-devices
```

The keyboard device was successfully detected.

---

## Test 4 — libinput Debug Events

The keyboard was tested directly with:

```bash
sudo libinput debug-events
```

Keyboard press and release events were successfully observed.

This verified that libinput was receiving keyboard input independently
of the LUMEN application.

---

## Test 5 — LUMEN Build

The project was built using:

```bash
cmake --build build
```

Successful result:

```text
[100%] Built target lumen
```

---

## Test 6 — Keyboard Initialization

Running:

```bash
./build/lumen
```

produced:

```text
Keyboard initialized
```

This confirms that the LUMEN keyboard module initialized correctly.

---

## Test 7 — libinput Initialization

LUMEN produced:

```text
Libinput initialized
```

This confirms that the libinput context was successfully created and
assigned to the compositor seat.

---

## Test 8 — Key Press

A keyboard key was pressed.

Example:

```text
Key pressed: 30 -> Client 1
```

This confirms key press detection.

---

## Test 9 — Key Release

A keyboard key was released.

Example:

```text
Key released: 30 -> Client 1
```

This confirms key release detection.

---

## Test 10 — Key Repeat

A key was held.

Example:

```text
Key pressed: 42 -> Client 2
Key repeat: 42 -> Client 2
Key repeat: 42 -> Client 2
Key repeat: 42 -> Client 2
Key released: 42 -> Client 2
```

This confirms the current basic repeat mechanism.

---

## Test 11 — Focus Switching

The focus was first assigned to Client 1:

```text
Keyboard focus set to client: 1
```

Then changed to Client 2:

```text
Keyboard focus set to client: 2
```

After the change, keyboard events were routed to Client 2:

```text
Key pressed: 42 -> Client 2
Key released: 42 -> Client 2
```

This confirms the current focus-routing foundation.

---

# Test Summary

| Test | Result |
|---|---|
| Linux input device detection | PASS |
| Keyboard detected by libinput | PASS |
| LUMEN build | PASS |
| Keyboard initialization | PASS |
| libinput initialization | PASS |
| Key press detection | PASS |
| Key release detection | PASS |
| Key hold detection | PASS |
| Basic key repeat | PASS |
| Keyboard focus | PASS |
| Focus switching | PASS |
| Focus-based routing | PASS |

---

# Debugging

The following commands are useful when debugging keyboard input.

## List input devices

```bash
ls /dev/input/
```

## Inspect Linux input devices

```bash
cat /proc/bus/input/devices
```

## List libinput devices

```bash
sudo libinput list-devices
```

## Monitor libinput events

```bash
sudo libinput debug-events
```

## Check permissions

```bash
ls -l /dev/input/event*
```

## Check user groups

```bash
groups
```

## Build LUMEN

```bash
cmake --build build
```

## Run LUMEN

```bash
./build/lumen
```

---

# Current Implementation

The current implementation provides the following architecture:

```text
                     +----------------+
                     |     Linux      |
                     | Input System   |
                     +-------+--------+
                             |
                             v
                         +-------+
                         | evdev |
                         +---+---+
                             |
                             v
                       +-----------+
                       | libinput  |
                       +-----+-----+
                             |
                             v
                    +----------------+
                    | InputManager   |
                    +-------+--------+
                            |
                            v
                     +-------------+
                     |   Keyboard  |
                     +------+------+ 
                            |
                            v
                       +---------+
                       |  Seat   |
                       +----+----+
                            |
                            v
                    Keyboard Focus
                            |
                            v
                     Focused Client
```

---

# Current Limitations

The current implementation is intentionally a foundation.

The following features are not yet implemented.

## Real Wayland Keyboard Protocol

The current system does not yet send keyboard events through:

```text
wl_keyboard
```

The current client ID is only a test representation.

---

## Real Wayland Clients

The current implementation does not yet have complete Wayland client
objects.

Therefore:

```text
Client 1
Client 2
```

are only logical test IDs.

They are not real Wayland clients.

---

## Client Lifecycle

The current input subsystem does not yet manage:

- Client creation
- Client destruction
- Client disconnect
- Client close
- Focus cleanup after client destruction

Therefore, the real test:

```text
Client closes while focused
```

cannot yet be performed honestly.

This requires the Wayland client lifecycle system first.

---

## xkbcommon

The current implementation uses raw Linux/libinput key codes.

It does not yet implement keyboard layout interpretation through
xkbcommon.

For example:

```text
Key code
   ↓
xkbcommon
   ↓
Key symbol
```

is future work.

---

## Modifier Handling

The current implementation does not yet fully process:

- Shift
- Ctrl
- Alt
- Super
- Caps Lock
- Num Lock
- Other keyboard modifiers

These will be handled through the keyboard state and xkbcommon
integration.

---

## Production Key Repeat

The current repeat implementation is a basic learning implementation.

It uses a thread and timers.

A production implementation should integrate properly with the
Wayland keyboard protocol and keyboard state.

---

## Production Seat Management

The current development implementation opens input devices through
basic file-descriptor callbacks.

Production compositor device access should use proper seat/device
management.

---

# Future Wayland Integration

The current keyboard subsystem is designed to later connect to the
actual Wayland compositor.

The future architecture is:

```text
Physical Keyboard
       |
       v
Linux Kernel
       |
       v
evdev
       |
       v
libinput
       |
       v
InputManager
       |
       v
Keyboard
       |
       v
Seat
       |
       v
Keyboard Focus
       |
       v
xkbcommon
       |
       v
wl_keyboard
       |
       v
Wayland Client
```

---

# Future xkbcommon Integration

xkbcommon will provide keyboard layout and key symbol processing.

The future flow will be:

```text
libinput
    |
    v
Raw Key Code
    |
    v
xkbcommon
    |
    v
Keyboard Symbol
    |
    v
Modifier State
    |
    v
Wayland Keyboard Event
    |
    v
Client
```

For example:

```text
Physical key
     |
     v
Linux key code
     |
     v
xkbcommon
     |
     v
"a"
```

This allows LUMEN to support keyboard layouts and modifiers correctly.

---

# Future Client Routing

The current routing system is:

```text
Keyboard Event
      |
      v
focusedClient = 2
      |
      v
print event
```

The future system will be:

```text
Keyboard Event
      |
      v
Seat
      |
      v
Focused Surface
      |
      v
Focused Wayland Client
      |
      v
wl_keyboard
      |
      v
Client Application
```

This will replace the current integer client ID foundation.

---

# Future Client Close Handling

Once real Wayland client management exists, the compositor must handle
the situation where the focused client disappears.

The desired behavior will be:

```text
Client A has keyboard focus
        |
        v
Client A closes
        |
        v
Remove Client A
        |
        v
Clear keyboard focus
        |
        v
Select new focus
        |
        v
Send keyboard focus to new client
```

This is not implemented yet because it depends on the real Wayland
client lifecycle.

---

# Production Architecture

The eventual LUMEN keyboard subsystem should look approximately like:

```text
                         LUMEN
                           |
                           v
                  +----------------+
                  | InputSubsystem |
                  +-------+--------+
                          |
             +------------+------------+
             |                         |
             v                         v
      +-------------+            +----------+
      | InputManager|            |   Seat   |
      +------+------+            +----+-----+
             |                        |
             v                        |
         libinput                    |
             |                        |
             v                        |
        Keyboard State <--------------+
             |
             v
         xkbcommon
             |
             v
      Keyboard Symbols
             |
             v
       Focus Manager
             |
             v
      Wayland Client
             |
             v
       wl_keyboard
             |
             v
        Application
```

---

# Development Notes

## Keep Input Responsibilities Separate

The input subsystem should not contain window-management logic.

Keyboard input should determine:

```text
What key happened?
```

The seat/focus system should determine:

```text
Who should receive it?
```

The Wayland layer should determine:

```text
How should it be delivered?
```

This separation keeps the architecture clean.

---

## Raw Key Code vs Key Symbol

The current system works with raw key codes.

Example:

```text
42
```

A future xkbcommon layer will convert the raw key information into
keyboard symbols and modifier states.

Therefore:

```text
libinput
```

should not be treated as the component responsible for translating
the key into the final character.

---

## Input vs Window Management

Keyboard input and window management are different responsibilities.

The input subsystem detects:

```text
Key pressed
Key released
```

The compositor/window manager decides what those events mean for the
current focus.

For example:

```text
Super + Enter
```

could later be interpreted as a compositor shortcut.

Normal application keyboard input should be delivered to the focused
Wayland client.

---

# Current Day 3 Result

The keyboard input foundation successfully achieved the following:

```text
✓ Keyboard module created
✓ Keyboard initialization
✓ libinput integration
✓ Linux input device access
✓ Keyboard event detection
✓ Key press detection
✓ Key release detection
✓ Seat foundation
✓ Keyboard focus
✓ Focus switching
✓ Focus-based routing foundation
✓ Basic key repeat
✓ Build verification
✓ Runtime testing
✓ libinput testing
✓ Documentation
```

---

# Architecture Status

Current:

```text
Linux
  ↓
evdev
  ↓
libinput
  ↓
InputManager
  ↓
Keyboard
  ↓
Seat
  ↓
Client ID
```

Future:

```text
Linux
  ↓
evdev
  ↓
libinput
  ↓
InputManager
  ↓
Keyboard
  ↓
Seat
  ↓
xkbcommon
  ↓
Focus Manager
  ↓
wl_keyboard
  ↓
Wayland Client
```

---

# Conclusion

The LUMEN Keyboard Input Subsystem now provides the basic compositor
foundation required to receive and process keyboard input.

The subsystem successfully receives keyboard events through libinput,
detects key presses and releases, maintains keyboard focus, switches
focus between clients, performs basic key-repeat, and routes events
according to the current focus.

The current implementation intentionally stops before pretending to
implement the complete Wayland keyboard protocol.

The next major stages are:

```text
Current Foundation
       |
       v
Wayland Server
       |
       v
Real Wayland Clients
       |
       v
Real Seat / Focus Management
       |
       v
xkbcommon
       |
       v
wl_keyboard
       |
       v
Complete Keyboard Delivery
```

The current keyboard subsystem therefore serves as the foundation for
the complete LUMEN compositor input architecture.
