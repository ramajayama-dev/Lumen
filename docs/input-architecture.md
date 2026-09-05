# LUMEN Input Architecture

## Overview

The LUMEN InputSubsystem is responsible for organizing input handling
inside the compositor.

The basic input flow is:

Hardware
   ↓
Linux Kernel
   ↓
evdev
   ↓
libinput
   ↓
LUMEN InputSubsystem
   ↓
Event Routing
   ↓
Focused / Target Window
   ↓
Wayland Client


## What I Learned

### 1. Linux Input Architecture

Linux receives input from hardware through the kernel input subsystem.

Input devices are exposed to userspace through interfaces such as:

`/dev/input/eventX`

Basic flow:

Keyboard / Mouse
       ↓
Linux Kernel
       ↓
Input Subsystem
       ↓
evdev
       ↓
/dev/input/eventX
       ↓
libinput
       ↓
LUMEN


### 2. evdev

evdev provides a standard userspace interface for Linux input events.

Important event types:

- EV_KEY — keyboard and button events
- EV_REL — relative movement such as a mouse
- EV_ABS — absolute position such as a touchscreen
- EV_SYN — synchronization of related events

Example:

EV_KEY + KEY_A + 1

means the A key was pressed.


### 3. libinput

libinput is a userspace input library commonly used by Wayland
compositors.

It handles input devices and processes their events before the
compositor uses them.

Relationship:

evdev
  ↓
libinput
  ↓
LUMEN compositor


### 4. Wayland Seat

A Wayland seat represents a user's collection of input capabilities.

Seat
├── Keyboard
├── Pointer
└── Future: Touch

A seat is not one physical device. It represents the input
capabilities available to a user/session.


### 5. Input → Window Relationship

The compositor decides which client should receive input.

Keyboard:

Keyboard Event
      ↓
LUMEN InputSubsystem
      ↓
Keyboard Focus
      ↓
Focused Window
      ↓
Wayland Client


Pointer:

Pointer Event
      ↓
LUMEN InputSubsystem
      ↓
Pointer Target
      ↓
Target Window / Surface
      ↓
Wayland Client


## LUMEN InputSubsystem Architecture

The initial architecture is:

                    InputSubsystem
                          │
          ┌───────────────┼───────────────┐
          ↓               ↓               ↓
      Keyboard         Pointer          Seat
          │               │               │
          └───────────────┼───────────────┘
                          ↓
                   Event Routing
                          ↓
                  Focus / Window
                          ↓
                    Wayland Client


### InputSubsystem

The main input department of LUMEN.

It will coordinate keyboard, pointer, seat, and event-routing
functionality.


### Keyboard

Responsible for keyboard-related input.

Later it will handle:

- Key press
- Key release
- Key repeat
- Keyboard focus


### Pointer

Responsible for pointer-related input.

Later it will handle:

- Mouse movement
- Mouse buttons
- Scrolling
- Pointer position
- Pointer targeting


### Seat

Represents the user's input capabilities.

It connects keyboard, pointer, and future touch capabilities to the
Wayland input model.


### Event Routing

Event Routing determines where an input event should go.

It uses information such as:

- Keyboard focus
- Pointer target
- Window
- Workspace

The final destination is a Wayland client.


## C++ Scaffold

The initial C++ structure is:

compositor/
└── input/
    ├── InputSubsystem.hpp
    └── InputSubsystem.cpp

The InputSubsystem currently contains only the basic class structure,
constructor, initialization method, and internal initialization state.

Real keyboard and pointer handling has not been implemented yet.


## Build System

The input subsystem is connected to the CMake build system.

CMakeLists.txt
      ↓
main.cpp
      +
InputSubsystem.cpp
      ↓
C++ Compiler
      ↓
build/lumen

The LUMEN scaffold builds successfully with CMake.


## Current Status

Completed:

- Linux input architecture study
- evdev study
- libinput study
- Wayland seat model study
- Input-to-window relationship study
- InputSubsystem architecture design
- C++ InputSubsystem scaffold
- CMake integration
- Successful LUMEN build

Not implemented yet:

- Real keyboard handling
- Real pointer handling
- Real evdev processing
- Real libinput event processing
- Wayland input event forwarding
