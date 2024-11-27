# Pipeline implementation project - Arquitectura de Computadoras

## Integrantes
- Badi Masud Rodriguez Ramirez
- Luis Enrique Cortijo Gonzales
- Enrique Francisco Flores Teniente

## Project requirements and rubric: 
All information regarding the required elements and rubric for the project can be found at the following
link, which contains a comprehensive breakdown of each part.

Link: `https://utec.instructure.com/courses/15375/files/3444578/download?download_frd=1`

## General Description

This repository contains all the required components and elements to simulate the design and implementation of a Pipeline Processor.
We decided to utilize the basic implementation of a Single Cycle ARM proccesor we had been presented in class before, and began to build up from it
after evaluating the multiple components neccesary to recreate a fully functional Pipeline Processor.

We took plenty of liberties, from modying existing core modules and functionalities of the original Single Cycle ARM processor, to create our own components and encoding rules for the
instructions of our Pipelined Processor.

Finally, the entire project had been developed with the great help of our teacher Carlos (and the ARM Harris book), who we owe a lot to. Especially me, Badi Rodriguez, I am the student
writing this segment!

## Disclaimer

For all intents and purposes, this project would have been impossible without the usage of a plethora of online resources and even the ARM Harris book itself, we don't plan to take
full credit for all the elements for all the element used for this project (we only used conceptual assistance). However, in the spirit of any good student who desires to present a fine piece of work, we used these
online uses sparingly so, making sure that our own creativity shined among all the resources we decided to inspire from. This creative approach and effort from our part naturally comes in the form of our implementations.

We hope this doesn't cause any trouble, and we appreciate our instructor's understanding!

## Directory distribution

## Usage guide

### Format: 
We utilize a special encoding and format for our functions and instructions for the Pipelined Proccesor.

Encoding input syntax: 

---
    `XXXX XX XXXXXX XXXX XXXX XXXXXXXXXXXX` 
    `[ 1 ] [ 2 ] [ 3 ] [ 4 ] [ 5 ] [ 6 ]` 
--- 

- [1] : Condition ()
- [2] : OP ()
- [3] : Function
- [4] : Rn ()
- [5] : Rd ()
- [6] : imm|Rm ()

## Not the book, 100% legal sources:
- https://dl.acm.org/doi/pdf/10.5555/2815529
