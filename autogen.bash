#!/bin/bash
mkdir -p m4
autoreconf -fi -Wall
intltoolize --force --automake

